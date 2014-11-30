//
//  SSNDBFetchController.m
//  ssn
//
//  Created by lingminjun on 14/11/29.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBFetchController.h"
#import "SSNDB.h"
#import "SSNDBTable.h"
#import "SSNDBFetch.h"
#import "SSNCuteSerialQueue.h"
#import "SSNSafeArray.h"
#import <sqlite3.h>
#import "ssnbase.h"

const NSUInteger SSNDBFetchedChangeNan = 0;

@interface SSNDBFetchIndexBox : NSObject
@property (nonatomic,strong) id<SSNDBFetchObject> obj;
@property (nonatomic,strong) id<SSNDBFetchObject> nObj;//新的对象
@property (nonatomic) SSNDBFetchedChangeType changeType;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger nIndex;//新的位置
@end

@implementation SSNDBFetchIndexBox
@end

@interface SSNDBFetchController ()

@property (nonatomic,strong) NSMutableArray *metaResults;//原始数据集
@property (nonatomic, strong) SSNCuteSerialQueue *queue;//执行线程，放到db线程中执行并不是最好的选择

@property (nonatomic,strong) SSNSafeArray *results;//数据集，已经备份，不做安全考虑

@property (nonatomic) BOOL isPerformed;

- (void)dbupdatedNotification:(NSNotification *)notice;

- (void)processAddAllObjects:(NSArray *)objs;
- (void)processRemoveAllObjects;

@end


@implementation SSNDBFetchController

- (dispatch_queue_t)delegateQueue {
    if (!_delegateQueue) {
        _delegateQueue = dispatch_get_main_queue();
    }
    return _delegateQueue;
}

- (void)setFetch:(SSNDBFetch *)fetch {
    [_queue async:^{
        if (_isPerformed) {
            [_metaResults removeAllObjects];
            [self processRemoveAllObjects];
            _isPerformed = NO;
        }
    }];
    _fetch = fetch;
}

#pragma mark init

- (instancetype)initWithDB:(SSNDB *)db table:(SSNDBTable *)table fetch:(SSNDBFetch *)fetch {
    NSAssert(db && table, @"必须传入数据库以及操作的表");
    NSAssert(table.db == db, @"传入的数据表必须同样是当前数据下面的表");
    self = [super init];
    if (self) {
        _db = db;
        _table = table;
        _fetch = [fetch copy];
        _metaResults = [[NSMutableArray alloc] init];
        _results = [[SSNSafeArray alloc] init];
        _delegateQueue = dispatch_get_main_queue();
        _queue = [SSNCuteSerialQueue queueWithName:[NSString stringWithFormat:@"fetch.%@.queue", _table.name] syncPriStrategy:NO];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)fetchControllerWithDB:(SSNDB *)db table:(SSNDBTable *)table fetch:(SSNDBFetch *)fetch {
    return [[[self class] alloc] initWithDB:db table:table fetch:fetch];
}

#pragma mark status
- (NSString *)fetchSql {
    return [NSString stringWithFormat:@"SELECT rowid,* FROM %@ %@", _table.name, [_fetch sqlStatement]];
}

- (NSString *)fetchForRowidSql {
    return [NSString stringWithFormat:@"SELECT rowid,* FROM %@ WHERE rowid = ? LIMIT 0,1", _table.name];
}


- (BOOL)performFetch {
    
    if (_isPerformed) {
        return NO;
    }
    
    dispatch_block_t block = ^{
        if (_isPerformed) {
            return ;
        }
        
        _isPerformed = YES;
        
        //监听数据变化
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbupdatedNotification:) name:SSNDBUpdatedNotification object:_db];
        
        NSString *sql = [self fetchSql];
        
        ssn_log("\n perform fetch sql = %s！ \n", [sql UTF8String]);
        
        NSArray *objs = [_db objects:_fetch.entity sql:sql arguments:nil];
        if (objs) {
            [_metaResults setArray:objs];
            
            //复制所有数据给result，meta数据理论上是只读得，如果被返回到外界，将不可控
            NSMutableArray *list = [NSMutableArray array];
            if (_fetchReadonly) {
                [list setArray:objs];
            }
            else {
                for (id<SSNDBFetchObject> obj in _metaResults) {
                    [list addObject:[obj copyWithZone:NULL]];
                }
            }
            
            //开始第一轮插入所有数据
            [self processAddAllObjects:list];
        }
    };
    
    [_queue async:block];
    
    return YES;
}

#pragma mark object manager
- (NSUInteger)count {
    return [_results count];
}

- (NSArray *)objects {
    return [_results array];
}

- (id)objectAtIndex:(NSUInteger)index {
    NSUInteger i = index + _fetch.offset;
    return [_results objectAtIndex:i];
}

- (NSUInteger)indexOfObject:(id)object {
    return [_results indexOfObject:object];
}

#pragma mark 核心处理
- (void)dbupdatedNotification:(NSNotification *)notice {
    //只关心数据的增删改
    NSDictionary *userInfo = notice.userInfo;
    NSString *tableName = [userInfo objectForKey:SSNDBTableNameUserInfoKey];
    if (![_table.name isEqualToString:tableName]) {
        return ;
    }
    
    int operation = [[userInfo objectForKey:SSNDBOperationUserInfoKey] intValue];
    if (SQLITE_INSERT != operation && SQLITE_UPDATE != operation && SQLITE_DELETE != operation) {
        return ;
    }
    
    int64_t row_id = [[userInfo objectForKey:SSNDBRowIdUserInfoKey] longLongValue];
    if (row_id <= 0) {
        return ;
    }
    
    //可以处理数据了
    [_queue async:^{ [self addOperation:operation rowId:row_id]; }];
    
}

- (NSComparisonResult)comparisonResultWithSorts:(NSArray *)sorts object:(id<SSNDBFetchObject>)obj otherObject:(id<SSNDBFetchObject>)other {

    //一级一级比较
    NSComparisonResult comp_rt = NSOrderedDescending;
    for (NSSortDescriptor *sort in sorts) {
        comp_rt = [sort compareObject:obj toObject:other];
        
        if (comp_rt != NSOrderedSame) {
            break ;
        }
    }
    
    return comp_rt;
}

- (SSNDBFetchIndexBox *)findIndexForRowId:(int64_t)rowid operation:(int)operation {
    
    SSNDBFetchIndexBox *box = [[SSNDBFetchIndexBox alloc] init];
    box.changeType = SSNDBFetchedChangeNan;//默认值
    box.index = NSNotFound;//默认值
    box.nIndex = NSNotFound;//默认值
    
    //step 1用rowid寻找位置，基于效率考虑，没必要去查询一次数据库
    NSUInteger count = [_metaResults count];
    for (NSUInteger idx = 0; idx < count; idx ++) {
        id<SSNDBFetchObject> obj = [_metaResults objectAtIndex:idx];
        if ([obj rowid] == rowid) {
            box.obj = obj;
            box.index = idx;
            break ;
        }
    }
    
    //如果是插入或者更新，需要进一步确认其位置
    if (operation != SQLITE_INSERT && operation != SQLITE_UPDATE) {
        if (box.obj) {
            box.changeType = SSNDBFetchedChangeDelete;
        }
        return box;
    }
    
    //step 2 因为前面找不到，只能去数据库查询新对象(还无法断定此数据是有效区间内，sql replace方法将使得 rowid 新增)
    NSArray *objs = [_db objects:_fetch.entity sql:[self fetchForRowidSql] arguments:@[ @(rowid) ]];
    box.nObj = [objs firstObject];//取第一个对象
    if (nil == box.nObj) {//根本找不到对象，可以认定是下一被删除的数据
        return box;
    }
    
    //step 3 用对象来找原来的位置
    for (NSUInteger idx = 0; idx < count; idx ++) {
        id<SSNDBFetchObject> obj = [_metaResults objectAtIndex:idx];
        if ([box.nObj isEqual:obj]) {
            box.obj = obj;
            box.index = idx;
            break ;
        }
    }
    
    //step 4 检查是否满足fetch条件，检查第一个和最后一个，如果比第一个“小”，比最后一个“大”，则丢弃
    NSArray *sorts = _fetch.sortDescriptors;
    id<SSNDBFetchObject> firstObj = [_metaResults firstObject];
    id<SSNDBFetchObject> lastObj = [_metaResults lastObject];
    
    NSComparisonResult com_rt1 = [self comparisonResultWithSorts:sorts object:box.nObj otherObject:firstObj];
    NSComparisonResult com_rt2 = [self comparisonResultWithSorts:sorts object:box.nObj otherObject:lastObj];
    
    if (com_rt1 < NSOrderedAscending || com_rt2 > NSOrderedDescending) {//比第一个“小”，比最后一个“大”，返回直接丢弃或删除
        if (box.obj) {
            box.changeType = SSNDBFetchedChangeDelete;
        }
        return box;
    }
    
    //step 5 既然在fetch条件内，则继续检查新的位置，先计算比较起始位置，减少for循环（看比原来大还是小）
    NSUInteger begin_index = 0;
    NSUInteger end_index = count;
    if (box.obj) {
        NSComparisonResult rt = [self comparisonResultWithSorts:sorts object:box.nObj otherObject:box.obj];
        if (rt == NSOrderedSame) {//位置一样，不用遍历
            box.changeType = SSNDBFetchedChangeUpdate;
            begin_index = box.index;
            end_index = box.index;
        }
        else if (rt == NSOrderedAscending) {//比原来位置小，end_index设置
            box.changeType = SSNDBFetchedChangeMove;
            end_index = box.index;
        }
        else {//比原来位置大，begin_index设置
            box.changeType = SSNDBFetchedChangeMove;
            begin_index = box.index;
        }
    }
    else {
        box.changeType = SSNDBFetchedChangeInsert;
    }
    
    //step 6 根据起始位置寻找，找到第一次小于当前位置返回
    for (NSUInteger idx = begin_index; idx < end_index; idx++) {
        id<SSNDBFetchObject> obj = [_metaResults objectAtIndex:idx];
        
        NSComparisonResult rt = [self comparisonResultWithSorts:sorts object:box.nObj otherObject:obj];
        if (rt == NSOrderedAscending) {
            box.nIndex = idx;//最初找到位置
            break ;
        }
    }
    
    //step 7 仍然没有找到新的，直接插入到end位置上，但是需要检查此对象是否插入limit以外
    if (box.nIndex == NSNotFound) {
        
        if (_fetch.limit == 0 || (_fetch.limit > 0 && end_index < _fetch.limit)) {
            box.nIndex = end_index;
        }
        else {
            if (box.obj) {//将原来的对象删除掉
                box.changeType = SSNDBFetchedChangeDelete;
            }
            else {//忽略即可
                box.changeType = SSNDBFetchedChangeNan;
            }
            box.nObj = nil;//既然不是目标对象，就直接释放吧
        }
    }
    
    return box;
}

- (void)addOperation:(int)operation rowId:(int64_t)rowId {
    //step 1、寻找出需要操作的对象和位置
    SSNDBFetchIndexBox *box = [self findIndexForRowId:rowId operation:operation];
    if (box.index == NSNotFound && box.nIndex == NSNotFound) {
        ssn_log("\n rowid = %lld 不在结果的数据变更！！！忽略！！！ \n", rowId);
        return ;
    }
    
    if (box.changeType == SSNDBFetchedChangeDelete) {
        ssn_log("\n rowid = %lld deleted object at index = %ld！\n", rowId, box.index);
        //删除原始数据
        [_metaResults removeObjectAtIndex:box.index];
        [self processDeletedObject:box.obj atIndex:box.index];
    }
    else if (box.changeType == SSNDBFetchedChangeInsert) {
        ssn_log("\n rowid = %lld insert object at index = %ld！\n", rowId, box.nIndex);
        
        //检查是否超出
        id<SSNDBFetchObject> rmObj = nil;
        NSUInteger rmIndex = NSNotFound;
        if (_fetch.limit > 0 && [_metaResults count] >= _fetch.limit) {
            rmObj = [_metaResults lastObject];
            rmIndex = _fetch.limit - 1;//最后一个位置上（必须按照老位置计算）
            ssn_log("\n rowid = %lld insert evict object at index = %ld！\n", rowId, _fetch.limit);
        }
        
        [_metaResults insertObject:box.nObj atIndex:box.nIndex];
        
        id<SSNDBFetchObject> nObj = nil;
        if (_fetchReadonly) {
            nObj = box.nObj;
        }
        else {
            [box.nObj copyWithZone:NULL];//复制对象
        }
        
        [self processInsertedObject:nObj atIndex:box.nIndex evictObject:rmObj evictIndex:rmIndex];
    }
    else if (box.changeType == SSNDBFetchedChangeUpdate) {
        ssn_log("\n rowid = %lld update object at index = %ld！\n", rowId, box.index);
        
        [_metaResults replaceObjectAtIndex:box.index withObject:box.nObj];
        
        id<SSNDBFetchObject> nObj = nil;
        if (_fetchReadonly) {
            nObj = box.nObj;
        }
        else {
            [box.nObj copyWithZone:NULL];//复制对象
        }
        
        [self processUpdatedObject:nObj atIndex:box.index];
    }
    else if (box.changeType == SSNDBFetchedChangeMove) {
        ssn_log("\n rowid = %lld move object from index = %ld to index = %ld！\n", rowId, box.index, box.nIndex);
        
        [_metaResults removeObjectAtIndex:box.index];
        [_metaResults insertObject:box.nObj atIndex:box.nIndex];
        
        id<SSNDBFetchObject> nObj = nil;
        if (_fetchReadonly) {
            nObj = box.nObj;
        }
        else {
            [box.nObj copyWithZone:NULL];//复制对象
        }
        
        [self processMovedObject:nObj fromIndex:box.index toIndex:box.nIndex];
    }
    else {
        ssn_log("\n rowid = %lld 不清楚的操作！！！忽略！！！ \n", rowId);
    }
}

#pragma mark delegate process 回调到委托
- (void)processDeletedObject:(id<SSNDBFetchObject>)obj atIndex:(NSUInteger)index {
    dispatch_block_t block = ^{
        
        [_delegate ssndb_controllerWillChange:self];
        
        //删除老数据
        [_delegate ssndb_controller:self didChangeObject:obj atIndex:index forChangeType:SSNDBFetchedChangeDelete newIndex:0];
        [_results removeObjectAtIndex:index];
        
        [_delegate ssndb_controllerDidChange:self];
        
    };
    dispatch_async(self.delegateQueue, block);
}

- (void)processInsertedObject:(id<SSNDBFetchObject>)obj atIndex:(NSUInteger)index evictObject:()evictObj evictIndex:(NSUInteger)evictIndex {
    dispatch_block_t block = ^{
        
        [_delegate ssndb_controllerWillChange:self];
        
        //删除被挤出的对象
        if (evictObj) {
            [_delegate ssndb_controller:self didChangeObject:evictObj atIndex:evictIndex forChangeType:SSNDBFetchedChangeDelete newIndex:0];
            [_results removeObjectAtIndex:evictIndex];//
        }
        
        //插入新的元素
        [_results insertObject:obj atIndex:index];
        [_delegate ssndb_controller:self didChangeObject:obj atIndex:index forChangeType:SSNDBFetchedChangeInsert newIndex:index];
        
    
        [_delegate ssndb_controllerDidChange:self];
        
    };
    dispatch_async(self.delegateQueue, block);
}

- (void)processUpdatedObject:(id<SSNDBFetchObject>)obj atIndex:(NSUInteger)index {
    dispatch_block_t block = ^{
        
        [_delegate ssndb_controllerWillChange:self];
        
        //更新数据
        [_results replaceObjectAtIndex:index withObject:obj];
        [_delegate ssndb_controller:self didChangeObject:obj atIndex:index forChangeType:SSNDBFetchedChangeUpdate newIndex:index];
        
        [_delegate ssndb_controllerDidChange:self];
        
    };
    dispatch_async(self.delegateQueue, block);
}

- (void)processMovedObject:(id<SSNDBFetchObject>)obj fromIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex {
    dispatch_block_t block = ^{
        
        [_delegate ssndb_controllerWillChange:self];
        
        //更新数据
        [_results removeObjectAtIndex:index];
        [_results insertObject:obj atIndex:toIndex];
        
        [_delegate ssndb_controller:self didChangeObject:obj atIndex:index forChangeType:SSNDBFetchedChangeMove newIndex:toIndex];
        
        [_delegate ssndb_controllerDidChange:self];
        
    };
    dispatch_async(self.delegateQueue, block);
}

- (void)processAddAllObjects:(NSArray *)objs {
    dispatch_block_t block = ^{
        
        [_delegate ssndb_controllerWillChange:self];
        
        //删除老数据
        [_results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_delegate ssndb_controller:self didChangeObject:obj atIndex:idx forChangeType:SSNDBFetchedChangeDelete newIndex:0];
        }];
        
        //设置新的值
        [_results setArray:objs];
        
        //插入新数据
        [_results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_delegate ssndb_controller:self didChangeObject:obj atIndex:idx forChangeType:SSNDBFetchedChangeInsert newIndex:idx];
        }];
        
        [_delegate ssndb_controllerDidChange:self];
        
    };
    dispatch_async(self.delegateQueue, block);
}
- (void)processRemoveAllObjects {
    dispatch_block_t block = ^{
        
        [_delegate ssndb_controllerWillChange:self];
        
        //删除所有数据
        [_results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_delegate ssndb_controller:self didChangeObject:obj atIndex:idx forChangeType:SSNDBFetchedChangeDelete newIndex:0];
        }];
        
        //设置新的值
        [_results removeAllObjects];
        
        [_delegate ssndb_controllerDidChange:self];
        
    };
    dispatch_async(self.delegateQueue, block);
}

@end

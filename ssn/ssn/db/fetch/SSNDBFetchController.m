//
//  SSNDBFetchController.m
//  ssn
//
//  Created by lingminjun on 14/11/29.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBFetchController.h"
#import "SSNDB.h"
#import "SSNDBFetch.h"
#import "SSNCuteSerialQueue.h"
#import "SSNSafeArray.h"
#import <sqlite3.h>
#import "ssndiff.h"

#if DEBUG
#define ssn_fetch_log(s, ...) printf(s, ##__VA_ARGS__)
#else
#define ssn_fetch_log(s, ...) ((void)0)
#endif

const NSUInteger SSNDBFetchedChangeNan = 0;

@interface SSNDBFetchIndexBox : NSObject
@property (nonatomic,strong) id<SSNDBFetchObject> obj;
@property (nonatomic,strong) id<SSNDBFetchObject> nObj;//新的对象
@property (nonatomic) SSNDBFetchedChangeType changeType;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger nIndex;//新的位置
@property (nonatomic) BOOL refetch;//重新fetch结果集，针对非可变型数据集重新无法计算数据移动路线时需要
@end

@implementation SSNDBFetchIndexBox
@end

@interface SSNDBFetchChangesResult : NSObject
@property (nonatomic,strong) NSMutableArray *results;
@property (nonatomic,strong) NSArray *changedRowids;//触发改变的rowid
@end

@implementation SSNDBFetchChangesResult
- (instancetype)init {
    self = [super init];
    if (self) {
        _results = [[NSMutableArray alloc] init];
    }
    return self;
}
@end

@interface SSNDBFetchController ()

@property (nonatomic,strong) NSMutableArray *metaResults;//原始数据集
@property (nonatomic, strong) SSNCuteSerialQueue *queue;//执行线程，放到db线程中执行并不是最好的选择

@property (nonatomic,strong) SSNSafeArray *results;//数据集，已经备份，不做安全考虑

@property (nonatomic) BOOL isPerformed;

@property (nonatomic) BOOL isNoticeDBUpdated;

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
    SSNDBFetch *tfetch = [fetch copy];
    
    //同步赋值，
    [_queue sync:^{
        _fetch = tfetch;
        if (_isPerformed) {
            [_metaResults removeAllObjects];
            [self processRemoveAllObjects];
            _isPerformed = NO;
        }
    }];
}

#pragma mark init

- (instancetype)initWithDB:(SSNDB *)db fetch:(id<SSNDBFetchRequest>)fetch {
    NSAssert(db, @"必须传入数据库");
    self = [super init];
    if (self) {
        _db = db;
        //_table = table;
        _fetch = [fetch copyWithZone:NULL];
        _metaResults = [[NSMutableArray alloc] init];
        _results = [[SSNSafeArray alloc] init];
        _delegateQueue = dispatch_get_main_queue();
        _queue = [SSNCuteSerialQueue queueWithName:[NSString stringWithFormat:@"fetch.%@.queue", [_fetch dbTable]] syncPriStrategy:NO];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)fetchControllerWithDB:(SSNDB *)db fetch:(id<SSNDBFetchRequest>)fetch {
    return [[[self class] alloc] initWithDB:db fetch:fetch];
}

#pragma mark status
- (NSString *)fetchSql {
    return [_fetch fetchSql];
}

- (NSString *)fetchForRowidSql {
    return [_fetch fetchForRowidSql];
}

- (void)observerDBYpdatedNotification {
    
    if (_isNoticeDBUpdated) {
        return ;
    }
    _isNoticeDBUpdated = YES;
    
    //监听数据变化
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbupdatedNotification:) name:SSNDBUpdatedNotification object:_db];
}

int db_fetch_elem_equal(void *from, void *to, const size_t f_idx, const size_t t_idx, void *context) {
    id<SSNDBFetchObject> old_obj = [(__bridge NSArray *)from objectAtIndex:f_idx];
    id<SSNDBFetchObject> new_obj = [(__bridge NSArray *)to objectAtIndex:t_idx];
    return [old_obj isEqual:new_obj];
}


void db_fetch_chgs_iter(void *from, void *to, const size_t f_idx, const size_t t_idx, const ssn_diff_change_type type, void *context) {
    SSNDBFetchChangesResult *changesResult = (__bridge SSNDBFetchChangesResult *)context;
    switch (type) {
        case ssn_diff_no_change: {
            id<SSNDBFetchObject> old_obj = [(__bridge NSArray *)from objectAtIndex:f_idx];
            id<SSNDBFetchObject> new_obj = [(__bridge NSArray *)to objectAtIndex:t_idx];
            
            NSNumber *new_rowid = @([new_obj ssn_dbfetch_rowid]);
            if ([changesResult.changedRowids containsObject:new_rowid]) {//当前变化的数据正是引发重新perform的数据，则要记录update
                SSNDBFetchIndexBox *box = [[SSNDBFetchIndexBox alloc] init];
                box.index = f_idx;
                box.nIndex = t_idx;
                box.obj = old_obj;
                box.nObj = new_obj;
                box.changeType = SSNDBFetchedChangeUpdate;
                ssn_fetch_log("\n rowid = %lld update object at index = %ld！\n", [new_obj ssn_dbfetch_rowid], box.index);
                [changesResult.results addObject:box];
            }
        }
            break;
        case ssn_diff_insert: {
            id<SSNDBFetchObject> new_obj = [(__bridge NSArray *)to objectAtIndex:t_idx];
            SSNDBFetchIndexBox *box = [[SSNDBFetchIndexBox alloc] init];
            box.index = t_idx;
            box.nIndex = t_idx;
            box.nObj = new_obj;
            box.changeType = SSNDBFetchedChangeInsert;
            ssn_fetch_log("\n rowid = %lld insert object at index = %ld！\n", [new_obj ssn_dbfetch_rowid], box.nIndex);
            [changesResult.results addObject:box];
        }
            break;
        case ssn_diff_delete: {
            id<SSNDBFetchObject> old_obj = [(__bridge NSArray *)from objectAtIndex:f_idx];
            SSNDBFetchIndexBox *box = [[SSNDBFetchIndexBox alloc] init];
            box.index = f_idx;
            box.nIndex = NSNotFound;
            box.obj = old_obj;
            box.changeType = SSNDBFetchedChangeDelete;
            ssn_fetch_log("\n rowid = %lld delete object at index = %ld！\n", [old_obj ssn_dbfetch_rowid], box.index);
            [changesResult.results addObject:box];
        }
            break;
        default:
            break;
    }
}

//计算出删除，更新，和插入的数据，并且记录第一次插入数据的index
- (NSArray *)changesFrom:(NSArray *)from to:(NSArray *)to changedRowids:(NSArray *)rowids {
    
    @autoreleasepool {
        SSNDBFetchChangesResult *changesResult = [[SSNDBFetchChangesResult alloc] init];
        changesResult.changedRowids = rowids;
        
        ssn_diff((__bridge void *)from, (__bridge void *)to, [from count], [to count], db_fetch_elem_equal, db_fetch_chgs_iter, (__bridge void *)changesResult);
        
        return changesResult.results;
    }
}

- (void)resetResults:(NSArray *)objs {
    [self resetResults:objs changedRowids:nil];
}

- (void)resetResults:(NSArray *)objs changedRowids:(NSArray *)rowids {//此函数将来可以优化下，两个结果集比较一下，将需要删除的数据先删除，然后将要插入的数据重新插入
    /*
    if (objs) {
        [_metaResults setArray:objs];//直接替换感觉不是很好，简单粗暴
    }
    else {
        [_metaResults removeAllObjects];
    }
    
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
     
    */
    //优化后结果存在错误
    NSMutableArray *olds = [NSMutableArray arrayWithArray:_metaResults];
    
    //修改原始数据集
    [_metaResults setArray:objs];
    
    //复制所有数据给result，meta数据理论上是只读得，如果被返回到外界，将不可控
    NSMutableArray *news = [NSMutableArray array];
    if (_fetchReadonly) {
        [news setArray:objs];
    }
    else {
        for (id<SSNDBFetchObject> obj in _metaResults) {
            [news addObject:[obj copyWithZone:NULL]];
        }
    }
    
    NSArray *changes = [self changesFrom:olds to:news changedRowids:rowids];

    //开始第一轮插入所有数据
    [self processResetObjects:news obeyChanges:changes];
    
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
        [self observerDBYpdatedNotification];
        
        NSString *sql = [self fetchSql];
        
        ssn_fetch_log("\n perform fetch sql = %s！ \n", [sql UTF8String]);
        
        NSArray *objs = [_db objects:_fetch.entity sql:sql arguments:nil];
        
        //重置结果集
        [self resetResults:objs];
    };
    
    [_queue async:block];
    
    return YES;
}

- (BOOL)reperformFetchWithChangedRowids:(NSArray *)rowids {//重新发起查询

    dispatch_block_t block = ^{

        _isPerformed = YES;
        
        //监听数据变化
        [self observerDBYpdatedNotification];
        
        NSString *sql = [self fetchSql];
        ssn_fetch_log("\n reperform fetch sql = %s！ \n", [sql UTF8String]);
        
        NSArray *objs = [_db objects:_fetch.entity sql:sql arguments:nil];
        
        //重置结果集
        [self resetResults:objs changedRowids:rowids];
    };
    
    [_queue async:block];
    
    return YES;
}

- (void)performNextFetchCount:(NSUInteger)count {
    
    if (count == 0) {
        return ;
    }
    
    dispatch_block_t block = ^{
        
        if (_fetch.limit == 0) {//limit没有限制，说明根本不支持翻页
            return ;
        }
        
        //计算翻页
        if (!_isExtensible) {//不可变容量时，offset需要偏移
            _fetch.offset += count;
        }
        _fetch.limit += count;
        
        _isPerformed = YES;
        
        //监听数据变化
        [self observerDBYpdatedNotification];
        
        NSString *sql = [self fetchSql];
        
        ssn_fetch_log("\n perform next fetch sql = %s！ \n", [sql UTF8String]);
        
        NSArray *objs = [_db objects:_fetch.entity sql:sql arguments:nil];
        
        //重置结果集
        [self resetResults:objs];
    };
    
    [_queue async:block];
    
}

- (void)performPrevFetchCount:(NSUInteger)count {
    if (count == 0) {
        return ;
    }
    
    dispatch_block_t block = ^{
        if (_fetch.limit == 0) {//limit没有限制，说明根本不支持翻页
            return ;
        }
        
        if (_fetch.offset == 0) {//已经是最前一页了
            return ;
        }
        
        //计算翻页
        NSUInteger old_limit = _fetch.limit;
        NSUInteger old_offset = _fetch.offset;
        if (_fetch.offset > count) {//offset需要偏移，如果往前不够翻一页，则需要翻到最前面
            _fetch.offset -= count;
        }
        else {
            _fetch.offset = 0;
        }
        
        //limit需要缩减
        if (!_isExtensible) {//不可变容量时，翻页count为准
            _fetch.limit = count;
        }
        else {//可变就麻烦一点，从新的offset开始计算，到老的count为准
            _fetch.limit = old_limit + old_offset - _fetch.offset;
        }
        
        _isPerformed = YES;
        
        //监听数据变化
        [self observerDBYpdatedNotification];
        
        NSString *sql = [self fetchSql];
        
        ssn_fetch_log("\n perform prev fetch sql = %s！ \n", [sql UTF8String]);
        
        NSArray *objs = [_db objects:_fetch.entity sql:sql arguments:nil];
        
        //重置结果集
        [self resetResults:objs];
    };
    
    [_queue async:block];
}

#pragma mark object manager
- (NSUInteger)count {
    return [_results count];
}

- (NSArray *)objects {
    return [_results array];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_results objectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)object {
    return [_results indexOfObject:object];
}

#pragma mark 核心处理
- (void)dbupdatedNotification:(NSNotification *)notice {
    //只关心数据的增删改
    NSDictionary *userInfo = notice.userInfo;
    NSString *tableName = [userInfo objectForKey:SSNDBTableNameUserInfoKey];
    if (![_fetch.dbTable isEqualToString:tableName]) {
        
        if ([_fetch respondsToSelector:@selector(cascadedTables)]) {
            NSSet *tables = [_fetch cascadedTables];
            if ([tables containsObject:tableName]) {
                [self cascadedTableChangedNotify:notice];
            }
        }
        
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

- (void)cascadedTableChangedNotify:(NSNotification *)notice {
    NSDictionary *userInfo = notice.userInfo;
    
    NSString *tableName = [userInfo objectForKey:SSNDBTableNameUserInfoKey];
    
    int operation = [[userInfo objectForKey:SSNDBOperationUserInfoKey] intValue];
    if (SQLITE_INSERT != operation && SQLITE_UPDATE != operation && SQLITE_DELETE != operation) {
        return ;
    }
    
    int64_t row_id = [[userInfo objectForKey:SSNDBRowIdUserInfoKey] longLongValue];
    if (row_id <= 0) {
        return ;
    }
    
    //可以处理数据了
    [_queue async:^{ [self addOperation:operation rowId:row_id changeTable:tableName]; }];

}

- (NSComparisonResult)comparisonResultWithSorts:(NSArray *)sorts object:(id<SSNDBFetchObject>)obj otherObject:(id<SSNDBFetchObject>)other {

    if (nil == other) {
        return NSOrderedDescending;
    }
    
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

- (id<SSNDBFetchObject>)objectForRowid:(int64_t)rowid index:(NSUInteger *)pindex {
    __block id<SSNDBFetchObject> result = nil;
    [_metaResults enumerateObjectsUsingBlock:^(id<SSNDBFetchObject> obj, NSUInteger idx, BOOL *stop) {
        if ([obj ssn_dbfetch_rowid] == rowid) {
            result = obj;
            if (pindex) {
                *pindex = idx;
            }
            *stop = YES;
        }
    }];
    return result;
}

- (id<SSNDBFetchObject>)objectForIdenticalTo:(id)anObject index:(NSUInteger *)pindex {
    __block id<SSNDBFetchObject> result = nil;
    [_metaResults enumerateObjectsUsingBlock:^(id<SSNDBFetchObject> obj, NSUInteger idx, BOOL *stop) {
        if ([anObject isEqual:obj]) {
            result = obj;
            if (pindex) {
                *pindex = idx;
            }
            *stop = YES;
        }
    }];
    return result;
}

- (SSNDBFetchIndexBox *)findIndexForRowId:(int64_t)rowid operation:(int)operation {
    
    SSNDBFetchIndexBox *box = [[SSNDBFetchIndexBox alloc] init];
    box.changeType = SSNDBFetchedChangeNan;//默认值
    box.index = NSNotFound;//默认值
    box.nIndex = NSNotFound;//默认值
    
    //step 1 先用rowid在内存中寻找原来的数据和位置，（基于效率考虑，尽量不去查询数据库）
    NSUInteger count = [_metaResults count];
    NSUInteger index = 0;
    box.obj = [self objectForRowid:rowid index:&index];
    box.index = index;
    
    //step 2 如果不是插入和更新操作（暂时只有删除），则直接认定删除，立即返回结果
    if (operation != SQLITE_INSERT && operation != SQLITE_UPDATE) {
        if (NO == _isExtensible && _fetch.limit > 0 &&  _fetch.offset > 0){//数据不在指定的结果集范围，非可扩充型数据将需要重新查询数据
            if (box.obj && count < _fetch.limit) {
                box.changeType = SSNDBFetchedChangeDelete;
            }
            else {//结果集如果开始是满的，也必须重新refetch
                box.refetch = YES;
            }
        }
        else if (box.obj) {//可变性很好办，删除数据就ok
            box.changeType = SSNDBFetchedChangeDelete;
        }
        return box;
    }
    
    //step 3 用rowid到数据库获取最新的值
    NSArray *objs = [_db objects:_fetch.entity sql:[self fetchForRowidSql] arguments:@[ @(rowid) ]];
    box.nObj = [objs firstObject];//取第一个对象
    if (nil == box.nObj) {//根本找不到对象，可以认定是下一被删除的数据(数据在表中已经删除，但是还没有hook回调过来)
        return box;
    }
    
    //step 4 用新数据来找原来的数据和位置（防止replace sql语句，replace语句使得rowid变更；或者一个sql事务中，删除所有行，重新插入新数据，rowid将从0开始）
    if (nil == box.obj || NO == [box.obj isEqual:box.nObj]) {
        box.obj = [self objectForIdenticalTo:box.nObj index:&index];
        box.index = index;
    }
    
    //step 5 计算新数据大致在结果集中所处的位置，其实就是跟结果集首尾位置比较
    NSArray *sorts = _fetch.sortDescriptors;
    NSComparisonResult fore_compare = [self comparisonResultWithSorts:sorts object:box.nObj otherObject:[_metaResults firstObject]];
    NSComparisonResult aft_compare = [self comparisonResultWithSorts:sorts object:box.nObj otherObject:[_metaResults lastObject]];
    
    //step 6 分析数据在数据集中的移动轨迹（不一定能分析出来）
    /*
     step 6 说明：
     1）在不可扩充型数据集中，我们无法精确计算offset的移动，除非重新调用sql查询数据集。先看下面分析：
     
     我们将所有符合where子句的数据按照offset，limit做如下区分
     第一段：[0 , offset]
     第二段：[offset , (offset+limit)] //(控制器持有的数据)
     第三段：[(offset+limit) , +无穷]
     
     所以每一次数据修改，都必须清楚记录，是从哪一个区段到哪一个区段，然控制器结果集仅仅记录第二断，所以第一段和第三段的数据我们无法判断。
     
     但是当offset为零时，数据仅仅被分成两个区段，而且这种情况是我们常见的情况，此时数据移动是可以被计算出来的，所以这种情况不需要重新查询数据库
     第一段：[0==offset , limit]
     第二段：[limit , +无穷]
     
     2）可扩充型数据集因为只需要将数据新增即可，所以不要精确计算offset的位置（足以满足业务需要，如动态，消息都应该是可扩充型数据集）
     */
    if (NO == _isExtensible && _fetch.limit > 0 &&  _fetch.offset > 0) {//过滤哪些无法找到数据移动轨迹的情况
        if (nil == box.obj //第一种情况，不知道原来数据属于哪一区段
            || (box.obj && fore_compare == NSOrderedAscending) //移到了最前面，无法判断是否还在offset以内
            || (box.obj && aft_compare == NSOrderedDescending) //移到了最后面，无法判断是否还在limit以内
            ) {
            box.refetch = YES;
            return box;
        }
    }
    
    //step 7 针对可扩充型数据集做一次数据集范围调整
    /*
     step 7 说明：
     可变型数据集，只要有新数据过来都可以认定是插入，但是有几个原则：
        1）无论数据插入到什么位置，最前面也不例外，offset始终不变
        2）插入数据超过数据集大小限制，将自动将limit调整到可以放入此数据
        3）删除任何数据都不引起offset和limit的变化
     */
    if (_isExtensible && nil == box.obj && count == _fetch.limit) {
        _fetch.limit += 1;
    }
    
    //step 8 精确新数据插入位置与操作类型
    //既然在fetch条件内，则继续检查新的位置，先计算比较起始位置，减少for循环（看比原来大还是小）
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
    
    //step 9 根据起始位置寻找，找到第一次小于当前位置返回
    for (NSUInteger idx = begin_index; idx < end_index; idx++) {
        id<SSNDBFetchObject> obj = [_metaResults objectAtIndex:idx];
        
        NSComparisonResult rt = [self comparisonResultWithSorts:sorts object:box.nObj otherObject:obj];
        if (rt == NSOrderedAscending) {
            box.nIndex = idx;//最初找到位置
            break ;
        }
    }
    
    //step 10 仍然没有找到新的，直接插入到end位置上，但是需要检查此对象是否插入limit以外
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

- (void)addOperation:(int)operation rowId:(int64_t)rowId changeTable:(NSString *)changeTable
{
    if (![_fetch respondsToSelector:@selector(fetchForCascadedTableChangedSql:)]) {
        ssn_fetch_log("\n 级联表%s发生更改，造成结果集%s数据发生变化，因为没有实现查询语句，忽略！！！\n", [changeTable UTF8String],[[_fetch dbTable] UTF8String]);
        return ;
    }
    
    NSString *change_sql = [_fetch fetchForCascadedTableChangedSql:changeTable];
    NSArray *rowids = [_db objects:nil sql:change_sql arguments:@[@(rowId)]];
    if ([rowids count] == 0) {
        ssn_fetch_log("\n 级联表%s发生更改，造成结果集%s数据发生变化，没有找到影响变化的行，忽略！！！\n", [changeTable UTF8String],[[_fetch dbTable] UTF8String]);
        return ;
    }
    
    //得到被影响的rowids，这些数据需要更新
    rowids = [rowids valueForKey:@"ssn_dbfetch_rowid"];
    
    ssn_fetch_log("\n 级联表%s发生更改，造成结果集%s数据发生变化，影响数据rowid in%s，重新fetch！！！\n", [changeTable UTF8String],[[_fetch dbTable] UTF8String],[[[rowids description] stringByReplacingOccurrencesOfString:@"\n" withString:@""] UTF8String]);
    
    [self reperformFetchWithChangedRowids:rowids];
}

- (void)addOperation:(int)operation rowId:(int64_t)rowId {
    //step 1、寻找出需要操作的对象和位置
    SSNDBFetchIndexBox *box = [self findIndexForRowId:rowId operation:operation];
    
    //先要检查是否需要重新fetch，如果是需要重新fetch的，单的处理比较好
    if (box.refetch) {
        ssn_fetch_log("\n rowid = %lld 使得结果集必须重新fetch！！！\n", rowId);
        [self reperformFetchWithChangedRowids:@[@(rowId)]];
        return ;
    }
    
    if (box.index == NSNotFound && box.nIndex == NSNotFound) {
        ssn_fetch_log("\n rowid = %lld 不在结果的数据变更！！！忽略！！！ \n", rowId);
        return ;
    }
    
    id<SSNDBFetchObject> nObj = nil;//复制出新的对象给对外结果集
    if (_fetchReadonly) {
        nObj = box.nObj;
    }
    else {
        nObj = [box.nObj copyWithZone:NULL];//复制对象
    }
    
    if (box.changeType == SSNDBFetchedChangeDelete) {
        ssn_fetch_log("\n rowid = %lld delete object at index = %ld！\n", rowId, box.index);
        //删除原始数据
        [_metaResults removeObjectAtIndex:box.index];
        [self processDeletedObject:box.obj atIndex:box.index];
    }
    else if (box.changeType == SSNDBFetchedChangeInsert) {
        ssn_fetch_log("\n rowid = %lld insert object at index = %ld！\n", rowId, box.nIndex);
        
        //检查是否超出
        id<SSNDBFetchObject> rmObj = nil;
        NSUInteger rmIndex = NSNotFound;
        if (_fetch.limit > 0 && [_metaResults count] >= _fetch.limit) {
            rmObj = [_metaResults lastObject];
            rmIndex = _fetch.limit - 1;//最后一个位置上（必须按照老位置计算）
            ssn_fetch_log("\n rowid = %lld insert evict object at index = %ld！\n", rowId, _fetch.limit);
        }
        
        [_metaResults insertObject:box.nObj atIndex:box.nIndex];
        
        [self processInsertedObject:nObj atIndex:box.nIndex evictObject:rmObj evictIndex:rmIndex];
    }
    else if (box.changeType == SSNDBFetchedChangeUpdate) {
        ssn_fetch_log("\n rowid = %lld update object at index = %ld！\n", rowId, box.index);
        
        [_metaResults replaceObjectAtIndex:box.index withObject:box.nObj];
        
        [self processUpdatedObject:nObj atIndex:box.index];
    }
    else if (box.changeType == SSNDBFetchedChangeMove) {
        ssn_fetch_log("\n rowid = %lld move object from index = %ld to index = %ld！\n", rowId, box.index, box.nIndex);
        
        [_metaResults removeObjectAtIndex:box.index];
        [_metaResults insertObject:box.nObj atIndex:box.nIndex];
        
        [self processMovedObject:nObj fromIndex:box.index toIndex:box.nIndex];
    }
    else {
        ssn_fetch_log("\n rowid = %lld 不清楚的操作！！！忽略！！！ \n", rowId);
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

- (void)processResetObjects:(NSArray *)objs obeyChanges:(NSArray *)changes {
    dispatch_block_t block = ^{
        
        [_delegate ssndb_controllerWillChange:self];
        
        //删除老数据
        [changes enumerateObjectsUsingBlock:^(SSNDBFetchIndexBox *box, NSUInteger idx, BOOL *stop) {
            
            switch (box.changeType) {
                case SSNDBFetchedChangeInsert:
                    [_delegate ssndb_controller:self didChangeObject:box.nObj atIndex:box.index forChangeType:SSNDBFetchedChangeInsert newIndex:box.nIndex];
                    break;
                case SSNDBFetchedChangeDelete:
                    [_delegate ssndb_controller:self didChangeObject:box.obj atIndex:box.index forChangeType:SSNDBFetchedChangeDelete newIndex:0];
                    break;
                case SSNDBFetchedChangeMove:
                    [_delegate ssndb_controller:self didChangeObject:box.nObj atIndex:box.index forChangeType:SSNDBFetchedChangeMove newIndex:box.nIndex];
                    break;
                case SSNDBFetchedChangeUpdate:
                    [_delegate ssndb_controller:self didChangeObject:box.nObj atIndex:box.index forChangeType:SSNDBFetchedChangeUpdate newIndex:box.nIndex];
                    break;
                default:
                    break;
            }
            
        }];
        
        [_results setArray:objs];
        
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

//
//  SSNListFetchController.m
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNListFetchController.h"
#import "SSNVMCellItem.h"
#import "ssndiff.h"
#import "NSObject+SSNBlock.h"

#if DEBUG
#define ssn_fetch_log(s, ...) printf(s, ##__VA_ARGS__)
#else
#define ssn_fetch_log(s, ...) ((void)0)
#endif

const NSUInteger SSNListFetchedChangeNan = 0;

@interface SSNListFetchIndexBox : NSObject
@property (nonatomic,strong) id<SSNCellModel> obj;
@property (nonatomic,strong) id<SSNCellModel> nObj;//新的对象
@property (nonatomic) SSNListFetchedChangeType changeType;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger nIndex;//新的位置
@end

@implementation SSNListFetchIndexBox
@end

@interface SSNListFetchController()

@property (nonatomic,strong) NSMutableArray *results;

@property (nonatomic,copy) NSDictionary *userInfo;

@property (nonatomic) BOOL isLoading;

@property (nonatomic) BOOL hasMore;

@end

@implementation SSNListFetchController

- (instancetype)initWithGrouping:(BOOL)grouping {
    self = [super init];
    if (self) {
        _isGrouping = grouping;
        _results = [[NSMutableArray alloc] initWithCapacity:1];
        _limit = SSN_LIST_FETCH_CONTROLLER_DEFAULT_LIMIT;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithGrouping:NO];
}

/**
 *  更新所有数据，默认offset被重置为0，正在加载时忽略调用
 */
- (void)loadData {
    if (_isLoading) {
        return ;
    }
    
    if (![self.dataSource respondsToSelector:@selector(ssnlist_controller:loadDataWithOffset:limit:userInfo:completion:)]) {
        return ;
    }
    
    _isLoading = YES;
    
    __weak typeof(self) w_self = self;
    void (^block)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) = ^(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) {
        __strong typeof(w_self) self = w_self; if (!w_self) { return ; }
        
        self.isLoading = NO;
        
        if (!finished) {
            return ;
        }
        
        self.hasMore = hasMore;
        self.userInfo = userInfo;
        
        //重置数据
        [self resetResults:results];
    };
    
    [self.dataSource ssnlist_controller:self loadDataWithOffset:0 limit:_limit userInfo:_userInfo completion:block];
}

/**
 *  加载更多数据，hasMore为NO时忽略调用，正在加载时忽略调用
 *  等价与
 */
- (void)loadMoreData {
    if (_isLoading) {
        return ;
    }
    
    if (!_hasMore) {
        return ;
    }
    
    if (![self.dataSource respondsToSelector:@selector(ssnlist_controller:loadDataWithOffset:limit:userInfo:completion:)]) {
        return ;
    }
    
    _isLoading = YES;
    NSUInteger count = [self.results count];
    
    __weak typeof(self) w_self = self;
    void (^block)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) = ^(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) {
        __strong typeof(w_self) self = w_self; if (!w_self) { return ; }
        
        self.isLoading = NO;
        
        if (!finished) {
            return ;
        }
        
        self.hasMore = hasMore;
        self.userInfo = userInfo;
        
        [self addResults:results];
    };
    
    [self.dataSource ssnlist_controller:self loadDataWithOffset:count limit:_limit userInfo:_userInfo completion:block];
}

#pragma mark object manager
- (NSUInteger)count {
    return [self.results count];
}

- (NSArray *)objects {
    return [self.results copy];
}

- (id<SSNCellModel>)objectAtIndex:(NSUInteger)index {
    if (index >= [self.results count]) {
        return nil;
    }
    return [self.results objectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id<SSNCellModel>)object {
    return [self.results indexOfObject:object];
}

#pragma mark 数据集局部改变通知接口

- (void)insertData:(id)data atIndex:(NSUInteger)index {
    if (nil == data) {
        return ;
    }
}

- (void)deleteObjectsAtIndexs:(NSIndexSet *)indexs {
    
}

- (void)updateData:(id)data atIndex:(NSUInteger)index {
    
}

- (void)insertDatas:(NSArray *)datas atIndex:(NSUInteger)index {
    
}

#pragma mark 工厂方法
+ (instancetype)fetchControllerWithDelegate:(id<SSNListFetchControllerDelegate>)delegate dataSource:(id<SSNListFetchControllerDataSource>)dataSource {
    SSNListFetchController *controller = [[SSNListFetchController alloc] init];
    controller.delegate = delegate;
    controller.dataSource = dataSource;
    return controller;
}

#pragma mark 数据集改变回调
int list_fetch_elem_equal(void *from, void *to, const size_t f_idx, const size_t t_idx, void *context) {
    id<SSNCellModel> old_obj = [(__bridge NSArray *)from objectAtIndex:f_idx];
    id<SSNCellModel> new_obj = [(__bridge NSArray *)to objectAtIndex:t_idx];
    return [old_obj isEqual:new_obj];
}


void list_fetch_chgs_iter(void *from, void *to, const size_t f_idx, const size_t t_idx, const ssn_diff_change_type type, void *context) {
    NSMutableDictionary *info = (__bridge NSMutableDictionary *)context;
    NSMutableArray *changesResult = [info objectForKey:@"changesResult"];
    NSIndexSet *indexs = [info objectForKey:@"changedIndexs"];
    switch (type) {
        case ssn_diff_no_change: {
            id<SSNCellModel> old_obj = [(__bridge NSArray *)from objectAtIndex:f_idx];
            id<SSNCellModel> new_obj = [(__bridge NSArray *)to objectAtIndex:t_idx];
            if ([indexs containsIndex:f_idx]) {//去重时，可能数据有变化，所以记录update
                SSNListFetchIndexBox *box = [[SSNListFetchIndexBox alloc] init];
                box.index = f_idx;
                box.nIndex = t_idx;
                box.obj = old_obj;
                box.nObj = new_obj;
                box.changeType = SSNListFetchedChangeUpdate;
                ssn_fetch_log("\n update object at index = %ld！\n", box.index);
                [changesResult addObject:box];
            }
        }
            break;
        case ssn_diff_insert: {
            id<SSNCellModel> new_obj = [(__bridge NSArray *)to objectAtIndex:t_idx];
            SSNListFetchIndexBox *box = [[SSNListFetchIndexBox alloc] init];
            box.index = t_idx;
            box.nIndex = t_idx;
            box.nObj = new_obj;
            box.changeType = SSNListFetchedChangeInsert;
            ssn_fetch_log("\n insert object at index = %ld！\n", box.nIndex);
            [changesResult addObject:box];
        }
            break;
        case ssn_diff_delete: {
            id<SSNCellModel> old_obj = [(__bridge NSArray *)from objectAtIndex:f_idx];
            SSNListFetchIndexBox *box = [[SSNListFetchIndexBox alloc] init];
            box.index = f_idx;
            box.nIndex = NSNotFound;
            box.obj = old_obj;
            box.changeType = SSNListFetchedChangeDelete;
            ssn_fetch_log("\n delete object at index = %ld！\n",  box.index);
            [changesResult addObject:box];
        }
            break;
        default:
            break;
    }
}

//计算出删除，更新，和插入的数据，并且记录第一次插入数据的index
- (NSArray *)changesFrom:(NSArray *)from to:(NSArray *)to changedIndexs:(NSIndexSet *)indexs{
    @autoreleasepool {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        NSMutableArray *changesResult = [[NSMutableArray alloc] initWithCapacity:0];
        [info setValue:changesResult forKey:@"changesResult"];
        [info setValue:indexs forKey:@"changedIndexs"];
        
        ssn_diff((__bridge void *)from, (__bridge void *)to, [from count], [to count], list_fetch_elem_equal, list_fetch_chgs_iter, (__bridge void *)info);
        
        return changesResult;
    }
}

- (void)resetResults:(NSArray *)datas {
    @autoreleasepool {
        //记录老数据
        NSArray *olds = [NSArray arrayWithArray:_results];
        
        //获得新数据
        NSMutableArray *news = [NSMutableArray array];
        if ([datas count]) {
            //数据是否需要转化
            if ([self.dataSource respondsToSelector:@selector(ssnlist_controller:constructObjectsFromResults:)]) {
                NSArray *list = [self.dataSource ssnlist_controller:self constructObjectsFromResults:datas];
                if (list) {
                    [news setArray:list];
                }
            }
            else {
                [news setArray:datas];
            }
        }
        
        //排序检查
        if (_isMandatorySorting && [news count]) {
            [news sortUsingSelector:@selector(ssn_compare:)];
        }
        
        NSArray *changes = [self changesFrom:olds to:news changedIndexs:nil];
        
        //开始第一轮插入所有数据
        [self processResetObjects:news obeyChanges:changes];
    }
}

- (void)addResults:(NSArray *)datas {
    @autoreleasepool {
        //记录老数据
        NSArray *olds = [NSArray arrayWithArray:_results];
        
        //获得新数据
        NSMutableArray *temp_news = [NSMutableArray array];
        if ([datas count]) {
            //数据是否需要转化
            if ([self.dataSource respondsToSelector:@selector(ssnlist_controller:constructObjectsFromResults:)]) {
                NSArray *list = [self.dataSource ssnlist_controller:self constructObjectsFromResults:datas];
                if (list) {
                    [temp_news setArray:list];
                }
            }
            else {
                [temp_news setArray:datas];
            }
        }
        
        //追加数据，但是需要去重
        NSMutableIndexSet *sets = [NSMutableIndexSet indexSet];
        NSMutableArray *news = [NSMutableArray arrayWithArray:_results];
        [temp_news enumerateObjectsUsingBlock:^(id<SSNCellModel> obj, NSUInteger idx, BOOL *stop) {
            if (![news containsObject:obj]) {
                [news addObject:obj];
            }
            else {//替换新值
                NSUInteger index = [news indexOfObject:obj];
                [sets addIndex:index];
                [news replaceObjectAtIndex:index withObject:obj];
            }
        }];
        
        //排序检查
        if (_isMandatorySorting && [news count]) {
            [news sortUsingSelector:@selector(ssn_compare:)];
        }
        
        NSArray *changes = [self changesFrom:olds to:news changedIndexs:sets];
        
        //开始第一轮插入所有数据
        [self processResetObjects:news obeyChanges:changes];
    }
}

- (void)processResetObjects:(NSArray *)objs obeyChanges:(NSArray *)changes {
    dispatch_block_t block = ^{
        
        [_delegate ssnlist_controllerWillChange:self];
        
        //删除老数据
        [changes enumerateObjectsUsingBlock:^(SSNListFetchIndexBox *box, NSUInteger idx, BOOL *stop) {
            
            switch (box.changeType) {
                case SSNListFetchedChangeInsert:
                    [_delegate ssnlist_controller:self didChangeObject:box.nObj atIndex:box.index forChangeType:SSNListFetchedChangeInsert newIndex:box.nIndex];
                    break;
                case SSNListFetchedChangeDelete:
                    [_delegate ssnlist_controller:self didChangeObject:box.obj atIndex:box.index forChangeType:SSNListFetchedChangeDelete newIndex:0];
                    break;
                case SSNListFetchedChangeMove:
                    [_delegate ssnlist_controller:self didChangeObject:box.nObj atIndex:box.index forChangeType:SSNListFetchedChangeMove newIndex:box.nIndex];
                    break;
                case SSNListFetchedChangeUpdate:
                    [_delegate ssnlist_controller:self didChangeObject:box.nObj atIndex:box.index forChangeType:SSNListFetchedChangeUpdate newIndex:box.nIndex];
                    break;
                default:
                    break;
            }
            
        }];
        
        [_results setArray:objs];
        
        [_delegate ssnlist_controllerDidChange:self];
        
    };
    
    [self ssn_mainThreadAsyncBlock:block];
    //dispatch_async(dispatch_get_main_queue(), block);
}


@end

//
//  SSNListFetchController.m
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNListFetchController.h"
#import "SSNVMSectionInfo.h"
#import "SSNVMCellItem.h"
#import "ssndiff.h"
#import "NSObject+SSNBlock.h"
#import "NSRunLoop+SSN.h"

//#if DEBUG
//#define ssn_fetch_log(s, ...) printf(s, ##__VA_ARGS__)
//#else
#define ssn_fetch_log(s, ...) ((void)0)
//#endif

//#if DEBUG
//#define ssn_t_log(s, ...) NSLog(s, ##__VA_ARGS__)
//#else
#define ssn_t_log(s, ...) ((void)0)
//#endif

NSString *const SSNFetchDefaultSectionIdentify = @"_$_#_";

const NSUInteger SSNListFetchedChangeNan = 0;

@interface SSNListFetchChangeLog : NSObject
@property (nonatomic,strong) id<SSNCellModel> obj;
@property (nonatomic,strong) id<SSNCellModel> nObj;//新的对象
@property (nonatomic) SSNListFetchedChangeType changeType;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger nIndex;//新的位置
@end

@implementation SSNListFetchChangeLog
@end

@interface SSNListFetchSectionChangeLog : NSObject
@property (nonatomic,strong) SSNVMSectionInfo *section;
@property (nonatomic,strong) SSNVMSectionInfo *nSection;//新的对象
@property (nonatomic) SSNListFetchedChangeType changeType;
@property (nonatomic,strong) NSArray *changes;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger nIndex;//新的位置
@end

@implementation SSNListFetchSectionChangeLog
@end

@interface SSNListFetchController()

@property (nonatomic,strong) NSMutableArray *list;
@property (nonatomic,strong) NSMutableDictionary *sectionMap;

@property (nonatomic,copy) NSDictionary *userInfo;

@property (nonatomic) BOOL isLoading;

@property (nonatomic) BOOL hasMore;

@property (nonatomic) BOOL dataSourceRespondSectionDidLoad;

@property (nonatomic,strong) NSRunLoop *mainRunLoop;

//记录有更新的indexs （现阶段不需要，因为数据并没有update状态）
@property (nonatomic,strong) NSMutableSet *changeIndexPaths;
//@property (nonatomic,strong) NSMutableSet *sectionChangeIndexs;
//@property (nonatomic,strong) NSMutableDictionary *objectChangeIndexs;


@end

@implementation SSNListFetchController

- (instancetype)initWithGrouping:(BOOL)grouping {
    self = [super init];
    if (self) {
        _isGrouping = grouping;
        _list = [[NSMutableArray alloc] initWithCapacity:1];
        _sectionMap = [[NSMutableDictionary alloc] initWithCapacity:1];
        _changeIndexPaths = [[NSMutableSet alloc] initWithCapacity:1];
        _limit = SSN_LIST_FETCH_CONTROLLER_DEFAULT_LIMIT;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithGrouping:NO];
}

- (NSRunLoop *)mainRunLoop {
    if (_mainRunLoop) {
        return _mainRunLoop;
    }
    
    _mainRunLoop = [NSRunLoop mainRunLoop];
    
    return _mainRunLoop;
}

- (void)setDataSource:(id<SSNListFetchControllerDataSource>)dataSource {
    _dataSource = dataSource;

    //效率考虑，只判断一次
    _dataSourceRespondSectionDidLoad = [dataSource respondsToSelector:@selector(ssnlist_controller:sectionDidLoad:sectionIdntify:)];
}

/**
 *  更新所有数据，默认offset被重置为0，正在加载时忽略调用
 */
- (void)loadData {
    
    [self loadDataWithOffset:0 limit:_limit];
    
}

/**
 *  加载更多数据，hasMore为NO时忽略调用，正在加载时忽略调用
 *  等价与
 */
- (void)loadMoreData {
    
    if (!_hasMore) {
        return ;
    }
    
    [self loadDataWithOffset:[_list count] limit:_limit];
    
}

- (void)loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit {
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
        
        [self resetResults:results isMerge:(offset != 0)];
    };
    
    [self.dataSource ssnlist_controller:self loadDataWithOffset:offset limit:limit userInfo:_userInfo completion:block];
}

#pragma mark object manager
- (NSUInteger)sectionCount {
    return [_list count];
}

/**
 *  所有数据集大小
 *
 *  @return 所有数据集大小
 */
- (NSUInteger)objectsCount {
    __block NSUInteger count = 0;
    [_list enumerateObjectsUsingBlock:^(SSNVMSectionInfo *section, NSUInteger idx, BOOL *stop) {
        count += [section count];
    }];
    return count;
}

/**
 *  所有sections，返回的数据是不可以修改的，即使修改也不会有任何作用
 *
 *  @return 返回所有sections
 */
- (NSArray *)sections {
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:1];
    [_list enumerateObjectsUsingBlock:^(SSNVMSectionInfo *section, NSUInteger idx, BOOL *stop) {
        [sections addObject:[section copy]];
    }];
    return sections;
}

/**
 *  返回所有当前数据 返回 SSNCellModel @see SSNCellModel
 *
 *  @return 返回所有当前数据
 */
- (NSArray *)objects {
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
    [_list enumerateObjectsUsingBlock:^(SSNVMSectionInfo *section, NSUInteger idx, BOOL *stop) {
        [objects addObjectsFromArray:[section objects]];
    }];
    return objects;
}

/**
 *  返回section info
 *
 *  @param index 所在位置
 *
 *  @return 返回数据
 */
- (SSNVMSectionInfo *)sectionAtIndex:(NSUInteger)section {
    if (section >= [_list count]) {
        return nil;
    }
    return [[_list objectAtIndex:section] copy];
}


- (SSNVMSectionInfo *)sectionWithSectionIdentify:(NSString *)identify {
    __block SSNVMSectionInfo *tsection = nil;
    [_list enumerateObjectsUsingBlock:^(SSNVMSectionInfo *section, NSUInteger idx, BOOL *stop) {
        if ([section.identify isEqualToString:identify]) {
            tsection = [section copy];
            *stop = YES;
        }
    }];
    return tsection;
}

/**
 *  返回section所在位置
 *
 *  @param section
 *
 *  @return 位置，如果结果集中没找到返回NSNotFound
 */
- (NSUInteger)indexWithSection:(SSNVMSectionInfo *)section {
    return [_list indexOfObject:section];
}

/**
 *  返回section
 *
 *  @param identify section唯一标示
 *
 *  @return 获取section
 */
- (NSUInteger)indexWithSectionIdentify:(NSString *)identify {
    __block NSUInteger index = NSNotFound;
    [_list enumerateObjectsUsingBlock:^(SSNVMSectionInfo *section, NSUInteger idx, BOOL *stop) {
        if ([section.identify isEqualToString:identify]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

/**
 *  返回数据
 *
 *  @param indexPath 位置
 *
 *  @return 数据
 */
- (id<SSNCellModel>)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [_list objectAtIndexPath:indexPath];
}

/**
 *  获取数据位置，如果结果集中没找到返回NSNotFound
 *
 *  @param object 数据
 *
 *  @return 位置
 */
- (NSIndexPath *)indexPathOfObject:(id<SSNCellModel>)object {
    __block NSUInteger sec = 0;
    __block NSUInteger row = NSNotFound;
    [_list enumerateObjectsUsingBlock:^(SSNVMSectionInfo *section, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [section indexOfObject:object];
        if (index != NSNotFound) {
            sec = idx;
            row = index;
            *stop = YES;
        }
    }];
    return [NSIndexPath indexPathForRow:row inSection:sec];
}

#pragma mark 数据集局部改变通知接口

/**
 *  新增数据
 *
 *  @param indexPaths  对应的位置新增，实际位置并不取决于它
 */
- (void)insertDatasAtIndexPaths:(NSArray *)indexPaths withContext:(void *)context {
    
    if ([indexPaths count] == 0) {
        return ;
    }
    
    NSRunLoop *runloop = self.mainRunLoop;
    if ([runloop ssn_flag_count_for_tag:(NSUInteger)self]) {
        ssn_t_log(@"fetctController:%p 忽略插入！说明此时数据源并没有稳定",self);
        return ;
    }
    
    if (![_dataSource respondsToSelector:@selector(ssnlist_controller:insertDataWithIndexPath:context:)]) {
        ssn_t_log(@"fetctController:%p 忽略插入！委托没人实现",self);
        return ;
    }
    
    int64_t flag = [runloop ssn_push_flag_for_tag:(NSUInteger)self];
    ssn_t_log(@"在fetctController:%p 插入数据 标记flag = %lld",self,flag);
    
    [_delegate ssnlist_controllerWillChange:self];
    
    NSMutableArray *newSections = [NSMutableArray array];
    NSMutableArray *changeSections = [NSMutableArray array];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        id<SSNCellModel> model = [_dataSource ssnlist_controller:self insertDataWithIndexPath:indexPath context:context];
        if (!model) {
            return ;
        }
        
        SSNVMSectionInfo *sectionInfo = [_list objectAtIndex:indexPath.section];//
        if (indexPath.section >= [_list count]) {
            
            NSString *sectionIdentify = [model cellSectionIdentify];
            sectionInfo = [self loadSectionWithSectionIdentify:sectionIdentify];
            
            if (!sectionInfo) {
                return ;
            }
            
            [_list addObject:sectionInfo];
            [newSections addObject:sectionInfo];
            [changeSections addObject:sectionInfo];
            
            [_delegate ssnlist_controller:self didChangeSection:sectionInfo atIndex:indexPath.section forChangeType:SSNListFetchedChangeInsert];
        }
        else {
            if (![changeSections containsObject:sectionInfo]) {
                [changeSections addObject:sectionInfo];
                
                //让section更新一下（修改header）
                [_delegate ssnlist_controller:self didChangeSection:sectionInfo atIndex:indexPath.section forChangeType:SSNListFetchedChangeUpdate];
            }
        }
        
        [sectionInfo.objects insertObject:model atIndex:indexPath.row];
        
        if (![newSections containsObject:sectionInfo]) {
            [_delegate ssnlist_controller:self didChangeObject:model atIndexPath:indexPath forChangeType:SSNListFetchedChangeInsert newIndexPath:indexPath];
        }
        
    }];
    
    [_delegate ssnlist_controllerDidChange:self];
    
    [runloop ssn_pop_flag_for_tag:(NSUInteger)self];
    ssn_t_log(@"在fetctController:%p 插入数据 取消标记flag = %lld",self,flag);
}

/**
 *  删除对应位置的数据
 *
 *  @param indexPaths NSIndexPaths数据所在位置
 */
- (void)deleteDatasAtIndexPaths:(NSArray *)indexPaths withContext:(void *)context {
    if ([indexPaths count] == 0) {
        return ;
    }
    
    NSRunLoop *runloop = self.mainRunLoop;
    if ([runloop ssn_flag_count_for_tag:(NSUInteger)self]) {
        ssn_t_log(@"fetctController:%p 忽略删除！说明此时数据源并没有稳定",self);
        return ;
    }
    
    int64_t flag = [runloop ssn_push_flag_for_tag:(NSUInteger)self];
    ssn_t_log(@"在fetctController:%p 删除数据 标记flag = %lld",self,flag);
    
    [_delegate ssnlist_controllerWillChange:self];
    
    //先计算哪些section需要改变
    NSMutableDictionary *changeSections = [NSMutableDictionary dictionary];
    NSMutableDictionary *delIndexsMap = [NSMutableDictionary dictionary];
    NSMutableDictionary *delPathsMap = [NSMutableDictionary dictionary];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *path, NSUInteger idx, BOOL *stop) {
        NSNumber *section = @(path.section);
        
        SSNVMSectionInfo *sectionInfo = [changeSections objectForKey:section];//哪些section发生了改变
        if (!sectionInfo) {
            sectionInfo = [_list objectAtIndex:path.section];
            [changeSections setObject:sectionInfo forKey:section];
        }
        
        NSMutableArray *delPaths = [delPathsMap objectForKey:section];//需要删除的path
        if (!delPaths) {
            delPaths = [NSMutableArray array];
            [delPathsMap setObject:delPaths forKey:section];
        }
        
        if (![delPaths containsObject:indexPaths]) {
            [delPaths addObject:path];
        }
        
        NSMutableIndexSet *delIndexs = [delIndexsMap objectForKey:section];//需要删除的range
        if (!delIndexs) {
            delIndexs = [NSMutableIndexSet indexSet];
            [delIndexsMap setObject:delIndexs forKey:section];
        }
        
        [delIndexs addIndex:path.row];
    }];
    
    [changeSections enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, SSNVMSectionInfo *obj, BOOL *stop) {
        NSUInteger section = [key integerValue];
        
        NSIndexSet *delSet = [delIndexsMap objectForKey:key];
        NSArray *oldObjs = [obj.objects copy];
        [obj.objects removeObjectsAtIndexes:delSet];
        
        //表示直接可以删除
        if ([obj.objects count] == 0) {
            ssn_t_log(@"delete section at index %lu",section);
            [_sectionMap removeObjectForKey:obj.identify];
            [_list removeObject:obj];//删除section
            
            //仅仅删除section
            [_delegate ssnlist_controller:self didChangeSection:obj atIndex:section forChangeType:SSNListFetchedChangeDelete];
        }
        else {
            [_delegate ssnlist_controller:self didChangeSection:obj atIndex:section forChangeType:SSNListFetchedChangeUpdate];
            NSArray *delPaths = [delPathsMap objectForKey:key];
            [delPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                id<SSNCellModel> obj = [oldObjs objectAtIndex:indexPath.row];
                 ssn_t_log(@"delete object at index %lu in section %lu",indexPath.row,section);
                [_delegate ssnlist_controller:self didChangeObject:obj atIndexPath:indexPath forChangeType:SSNListFetchedChangeDelete newIndexPath:nil];
            }];
        }
    }];
    
    [_delegate ssnlist_controllerDidChange:self];
    
    [runloop ssn_pop_flag_for_tag:(NSUInteger)self];
    ssn_t_log(@"在fetctController:%p 删除数据 取消标记flag = %lld",self,flag);
}

/**
 *  更新位置的数据，如果对应位置数据没有确实有变化，可能重新排序
 *
 *  @param indexPaths 位置
 */
- (void)updateDatasAtIndexPaths:(NSArray *)indexPaths withContext:(void *)context {
    
    if ([indexPaths count] == 0) {
        return ;
    }
    
    NSRunLoop *runloop = self.mainRunLoop;
    if ([runloop ssn_flag_count_for_tag:(NSUInteger)self]) {
        ssn_t_log(@"fetctController:%p 更新！说明此时数据源并没有稳定",self);
        [self.changeIndexPaths addObjectsFromArray:indexPaths];
        return ;
    }
    
    if (![_dataSource respondsToSelector:@selector(ssnlist_controller:updateDataWithOriginalData:indexPath:context:)]) {
        ssn_t_log(@"fetctController:%p 忽略更新！委托没人实现",self);
        return ;
    }
    
    int64_t flag = [runloop ssn_push_flag_for_tag:(NSUInteger)self];
    ssn_t_log(@"在fetctController:%p 更新数据 标记flag = %lld",self,flag);
    
    [_delegate ssnlist_controllerWillChange:self];
    
    NSMutableArray *changeSections = [NSMutableArray array];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        id<SSNCellModel> oldModel = [self objectAtIndexPath:indexPath];
        if (!oldModel) {
            return ;
        }
        
        id<SSNCellModel> model = [_dataSource ssnlist_controller:self updateDataWithOriginalData:oldModel indexPath:indexPath context:context];
        if (!model) {
            return ;
        }
        
        SSNVMSectionInfo *sectionInfo = [_list objectAtIndex:indexPath.section];//
        if (!sectionInfo) {
            return ;
        }
        
        if (![changeSections containsObject:sectionInfo]) {
            [changeSections addObject:sectionInfo];
            
            //让section更新一下（修改header）
            [_delegate ssnlist_controller:self didChangeSection:sectionInfo atIndex:indexPath.section forChangeType:SSNListFetchedChangeUpdate];
        }
        
        [sectionInfo.objects replaceObjectAtIndex:indexPath.row withObject:model];
        [_delegate ssnlist_controller:self didChangeObject:model atIndexPath:indexPath forChangeType:SSNListFetchedChangeUpdate newIndexPath:indexPath];
        
    }];
    
    [_delegate ssnlist_controllerDidChange:self];
    
    [runloop ssn_pop_flag_for_tag:(NSUInteger)self];
    ssn_t_log(@"在fetctController:%p 更新数据 取消标记flag = %lld",self,flag);
}

#pragma mark 工厂方法
+ (instancetype)fetchControllerWithDelegate:(id<SSNListFetchControllerDelegate>)delegate dataSource:(id<SSNListFetchControllerDataSource>)dataSource isGrouping:(BOOL)isGrouping {
    SSNListFetchController *controller = [[SSNListFetchController alloc] initWithGrouping:isGrouping];
    controller.delegate = delegate;
    controller.dataSource = dataSource;
    return controller;
}

#pragma mark 数据集改变回调
int list_fetch_elem_equal(void *from, void *to, const size_t f_idx, const size_t t_idx, void *context) {
    NSObject *old_obj = [(__bridge NSArray *)from objectAtIndex:f_idx];
    NSObject *new_obj = [(__bridge NSArray *)to objectAtIndex:t_idx];
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
                SSNListFetchChangeLog *box = [[SSNListFetchChangeLog alloc] init];
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
            SSNListFetchChangeLog *box = [[SSNListFetchChangeLog alloc] init];
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
            SSNListFetchChangeLog *box = [[SSNListFetchChangeLog alloc] init];
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

void list_fetch_sctn_chgs_iter(void *from, void *to, const size_t f_idx, const size_t t_idx, const ssn_diff_change_type type, void *context) {
    NSMutableDictionary *info = (__bridge NSMutableDictionary *)context;
    NSMutableArray *changesResult = [info objectForKey:@"changesResult"];
    NSIndexSet *indexs = [info objectForKey:@"changedIndexs"];
    NSDictionary *modelChanges = [info objectForKey:@"modelChangedIndexs"];
    switch (type) {
        case ssn_diff_no_change: {
            SSNVMSectionInfo *old_obj = [(__bridge NSArray *)from objectAtIndex:f_idx];
            SSNVMSectionInfo *new_obj = [(__bridge NSArray *)to objectAtIndex:t_idx];
            if ([indexs containsIndex:f_idx]) {//去重时，可能数据有变化，所以记录update
                SSNListFetchSectionChangeLog *box = [[SSNListFetchSectionChangeLog alloc] init];
                box.index = f_idx;
                box.nIndex = t_idx;
                box.section = old_obj;
                box.nSection = new_obj;
                box.changeType = SSNListFetchedChangeUpdate;
                
                NSMutableDictionary *tinfo = [NSMutableDictionary dictionaryWithCapacity:1];
                NSMutableArray *changes = [NSMutableArray arrayWithCapacity:1];
                box.changes = changes;
                [tinfo setValue:changes forKey:@"changesResult"];
                NSIndexSet *indexs = [modelChanges objectForKey:old_obj.identify];
                [tinfo setValue:indexs forKey:@"changedIndexs"];
                
                ssn_diff((__bridge void *)(old_obj.objects), (__bridge void *)(new_obj.objects), [old_obj.objects count], [new_obj.objects count], list_fetch_elem_equal, list_fetch_chgs_iter, (__bridge void *)tinfo);
                
                ssn_fetch_log("\n update section at index = %ld！\n", box.index);
                [changesResult addObject:box];
            }
        }
            break;
        case ssn_diff_insert: {
            SSNVMSectionInfo *new_obj = [(__bridge NSArray *)to objectAtIndex:t_idx];
            SSNListFetchSectionChangeLog *box = [[SSNListFetchSectionChangeLog alloc] init];
            box.index = t_idx;
            box.nIndex = t_idx;
            box.nSection = new_obj;
            box.changeType = SSNListFetchedChangeInsert;
            ssn_fetch_log("\n insert section at index = %ld！\n", box.nIndex);
            [changesResult addObject:box];
        }
            break;
        case ssn_diff_delete: {
            SSNVMSectionInfo *old_obj = [(__bridge NSArray *)from objectAtIndex:f_idx];
            SSNListFetchSectionChangeLog *box = [[SSNListFetchSectionChangeLog alloc] init];
            box.index = f_idx;
            box.nIndex = NSNotFound;
            box.section = old_obj;
            box.changeType = SSNListFetchedChangeDelete;
            ssn_fetch_log("\n delete section at index = %ld！\n",  box.index);
            [changesResult addObject:box];
        }
            break;
        default:
            break;
    }
}

//计算出删除，更新，和插入的数据，并且记录第一次插入数据的index
- (NSArray *)changesFrom:(NSArray *)from to:(NSArray *)to changedIndexs:(NSIndexSet *)indexs sectionModelChangeIndexs:(NSDictionary *)changes {
    @autoreleasepool {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        NSMutableArray *changesResult = [[NSMutableArray alloc] initWithCapacity:0];
        [info setValue:changesResult forKey:@"changesResult"];
        [info setValue:indexs forKey:@"changedIndexs"];
        [info setValue:changes forKey:@"modelChangedIndexs"];
        
        ssn_diff((__bridge void *)from, (__bridge void *)to, [from count], [to count], list_fetch_elem_equal, list_fetch_sctn_chgs_iter, (__bridge void *)info);
        
        return changesResult;
    }
}


- (NSArray *)checkMandatorySortingModels:(NSArray *)models {
    if (_isMandatorySorting) {
        return [models sortedArrayUsingSelector:@selector(ssn_compare:)];
    }
    return models;
}

- (SSNVMSectionInfo *)loadSectionWithSectionIdentify:(NSString *)identify {
    SSNVMSectionInfo *section = [SSNVMSectionInfo sectionInfoWithIdentify:identify title:identify];
    if (_isGrouping && _dataSourceRespondSectionDidLoad) {
        [self.dataSource ssnlist_controller:self sectionDidLoad:section sectionIdntify:identify];
    }
    
    if (!_isGrouping) {//非分组类型，section的header和footer都不需要显示
        section.hiddenHeader = YES;
        section.hiddenFooter = YES;
    }
    
    return section;
}

- (void)resetResults:(NSArray *)models isMerge:(BOOL)isMerge {
    @autoreleasepool {
        
        NSRunLoop *runloop = self.mainRunLoop;
        [runloop ssn_push_flag_for_tag:(NSUInteger)self];
        ssn_t_log(@"fetctController:%p reload！标记一下，此时结果集仍然是老结果集",self);
        
        NSArray *news = nil;

        NSArray *olds = [NSArray arrayWithArray:_list];
        NSIndexSet *changeSet = nil;
        NSDictionary *modelChange = nil;
        
        NSMutableDictionary *nSections = [NSMutableDictionary dictionaryWithCapacity:1];
        
        NSMutableIndexSet *changes = [NSMutableIndexSet indexSet];
        NSMutableDictionary *uSectionsChanges = [NSMutableDictionary dictionaryWithCapacity:1];
        
        [models enumerateObjectsUsingBlock:^(id<SSNCellModel> obj, NSUInteger idx, BOOL *stop) {
            NSString *sectionIdentify = [obj cellSectionIdentify];
            if ([sectionIdentify length] == 0) {
                sectionIdentify = SSNFetchDefaultSectionIdentify;
            }
            
            //生产新的section副本来存放新数据
            SSNVMSectionInfo *nSection = [nSections objectForKey:sectionIdentify];
            if (!nSection) {
                SSNVMSectionInfo *oSection = [_sectionMap objectForKey:sectionIdentify];
                if (oSection) {
                    nSection = [oSection copy];
                    
                    if (!isMerge) {//老数据需要保留，否则仅仅拷贝section属性
                        [nSection.objects removeAllObjects];
                    }
                    [uSectionsChanges setObject:[NSMutableIndexSet indexSet] forKey:sectionIdentify];
                    
                    NSUInteger index = [olds indexOfObject:oSection];
                    if (index != NSNotFound) {
                        [changes addIndex:index];
                    }
                }
                else {
                    nSection = [self loadSectionWithSectionIdentify:sectionIdentify];
                    [_sectionMap setObject:nSection forKey:sectionIdentify];//直接加到数据集中
                }
                
                [nSections setObject:nSection forKey:sectionIdentify];
            }
            
            //采用后来替换方式加入所有对象
            if ([nSection.objects containsObject:obj]) {
                NSUInteger index = [nSection.objects indexOfObject:obj];
                [nSection.objects replaceObjectAtIndex:index withObject:obj];
                
                //注意有变化的位置需要记下来(记老数据位置，主要是要将这部分数据update下，以防止修改不更新)
                NSMutableIndexSet *set = [uSectionsChanges objectForKey:sectionIdentify];
                if (index != NSNotFound) {
                    [set addIndex:index];
                }
            }
            else {
                [nSection.objects addObject:obj];
            }
        }];
        
        //将新增的section中数据集排序下
        if (_isMandatorySorting) {
            NSArray *values = [nSections allValues];
            [values enumerateObjectsUsingBlock:^(SSNVMSectionInfo *obj, NSUInteger idx, BOOL *stop) {
                [obj.objects sortUsingSelector:@selector(ssn_compare:)];
            }];
        }
        
        //若是merge将老的section组合起来
        if (isMerge) {
            [olds enumerateObjectsUsingBlock:^(SSNVMSectionInfo *obj, NSUInteger idx, BOOL *stop) {
                if (![nSections objectForKey:obj.identify]) {//将老的数据加入
                    [nSections setObject:obj forKey:obj.identify];
                }
            }];
        }
        
        //如果更新过程有update数据，需要放到此次更新中
        [_changeIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
            if (indexPath.section >= [_list count]) {
                return ;
            }
            
            SSNVMSectionInfo *section = [_list objectAtIndex:indexPath.section];
            NSMutableIndexSet *indexSets = [uSectionsChanges objectForKey:section.identify];
            if (!indexSets) {
                [uSectionsChanges setObject:[NSMutableIndexSet indexSet] forKey:section.identify];
                
                [changes addIndex:indexPath.section];
            }
            
            [indexSets addIndex:indexPath.row];
        }];
        
        news = [[nSections allValues] sortedArrayUsingSelector:@selector(compare:)];
        changeSet = changes;
        modelChange = uSectionsChanges;
        
        
        //将结果进行比较
        NSArray *sectionChanges = [self changesFrom:olds to:news changedIndexs:changeSet sectionModelChangeIndexs:modelChange];
        
        //计算完changes后，去掉临时用的section
        NSMutableDictionary *nsectionMap = [NSMutableDictionary dictionaryWithCapacity:1];
        NSMutableArray *lastNewList = [NSMutableArray arrayWithCapacity:1];
        
        NSMutableDictionary *sectionToValues = [NSMutableDictionary dictionaryWithCapacity:1];
        
        [news enumerateObjectsUsingBlock:^(SSNVMSectionInfo *section, NSUInteger idx, BOOL *stop) {
            SSNVMSectionInfo *origin_section = [_sectionMap objectForKey:section.identify];
            if (origin_section && origin_section != section) {
                
                [sectionToValues setObject:section.objects forKey:section.identify];
                
                [nsectionMap setObject:origin_section forKey:section.identify];
                [lastNewList addObject:origin_section];
            }
            else {
                [nsectionMap setObject:section forKey:section.identify];
                [lastNewList addObject:section];
            }
        }];
        [_sectionMap setDictionary:nsectionMap];
        
        [self processReset:lastNewList sectionToValues:sectionToValues obeyChanges:sectionChanges];
    }
}

- (void)processReset:(NSArray *)sections sectionToValues:(NSDictionary *)sectionToValues obeyChanges:(NSArray *)changes {
    dispatch_block_t block = ^{
        
        NSRunLoop *runloop = self.mainRunLoop;
        
        int64_t flag = [runloop ssn_pop_flag_for_tag:(NSUInteger)self];
        if (flag) {
            ssn_t_log(@"fetctController:%p 准备更新到界面",self);
        }
        
        /** 说明结果集被反复修改，此时仅仅更新最后一次，
            遗留问题：前几次的update数据可能被遗漏更新
         */
        if ([runloop ssn_flag_count_for_tag:(NSUInteger)self]) {
            ssn_t_log(@"fetctController:%p 说明后面还有更新的数据",self);
            return ;
        }
        
        //可以清楚积累的需要更新数据了
        [_changeIndexPaths removeAllObjects];
        
        //并没有任何修改
        if ([changes count] == 0) {
             ssn_t_log(@"fetctController:%p 数据最后发现不需要通知界面",self);
            return;
        }
        
        [_delegate ssnlist_controllerWillChange:self];
        
        //删除老数据
        [changes enumerateObjectsUsingBlock:^(SSNListFetchSectionChangeLog *box, NSUInteger idx, BOOL *stop) {
            
            switch (box.changeType) {
                case SSNListFetchedChangeInsert:{
                    [_delegate ssnlist_controller:self didChangeSection:box.nSection atIndex:box.index forChangeType:SSNListFetchedChangeInsert];
                }
                    break;
                case SSNListFetchedChangeDelete:{
                    [_delegate ssnlist_controller:self didChangeSection:box.section atIndex:box.index forChangeType:SSNListFetchedChangeDelete];
                }
                    break;
                case SSNListFetchedChangeUpdate:{
                    [_delegate ssnlist_controller:self didChangeSection:box.nSection atIndex:box.nIndex forChangeType:SSNListFetchedChangeUpdate];
                    [box.changes enumerateObjectsUsingBlock:^(SSNListFetchChangeLog *log, NSUInteger idx, BOOL *stop) {
                        switch (log.changeType) {
                            case SSNListFetchedChangeInsert:{
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:log.index inSection:box.nIndex];
                                [_delegate ssnlist_controller:self didChangeObject:log.nObj atIndexPath:indexPath forChangeType:SSNListFetchedChangeInsert newIndexPath:indexPath];
                            }
                                break;
                            case SSNListFetchedChangeDelete:{
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:log.index inSection:box.nIndex];
                                [_delegate ssnlist_controller:self didChangeObject:log.obj atIndexPath:indexPath forChangeType:SSNListFetchedChangeDelete newIndexPath:nil];
                            }
                                break;
                            case SSNListFetchedChangeMove:{
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:log.index inSection:box.nIndex];
                                NSIndexPath *nIndexPath = [NSIndexPath indexPathForRow:log.nIndex inSection:box.nIndex];
                                [_delegate ssnlist_controller:self didChangeObject:log.nObj atIndexPath:indexPath forChangeType:SSNListFetchedChangeMove newIndexPath:nIndexPath];
                            }
                                break;
                            case SSNListFetchedChangeUpdate:{
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:log.index inSection:box.nIndex];
                                [_delegate ssnlist_controller:self didChangeObject:log.nObj atIndexPath:indexPath forChangeType:SSNListFetchedChangeUpdate newIndexPath:indexPath];
                            }
                                break;
                            default:
                                break;
                        }
                    }];
                }
                    break;
                default:
                    break;
            }
        }];
        
        [sections enumerateObjectsUsingBlock:^(SSNVMSectionInfo *section, NSUInteger idx, BOOL *stop) {
            NSArray *toValues = [sectionToValues objectForKey:section.identify];
            if (toValues) {
                [section.objects setArray:toValues];
            }
        }];

        
        [_list setArray:sections];
        ssn_t_log(@"fetctController:%p 数据最后被更新",self);
        
        [_delegate ssnlist_controllerDidChange:self];
        
    };
    
    [self ssn_mainThreadAsyncBlock:block];
}



@end

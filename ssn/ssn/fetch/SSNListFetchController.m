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

#if DEBUG
#define ssn_fetch_log(s, ...) printf(s, ##__VA_ARGS__)
#else
#define ssn_fetch_log(s, ...) ((void)0)
#endif

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

@property (nonatomic) BOOL synchronFlag;//用于回调同步

@end

@implementation SSNListFetchController

- (instancetype)initWithGrouping:(BOOL)grouping {
    self = [super init];
    if (self) {
        _isGrouping = grouping;
        _list = [[NSMutableArray alloc] initWithCapacity:1];
        _sectionMap = [[NSMutableDictionary alloc] initWithCapacity:1];
        _limit = SSN_LIST_FETCH_CONTROLLER_DEFAULT_LIMIT;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithGrouping:NO];
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
        [objects addObject:[section objects]];
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
    SSNVMSectionInfo *section = [_list objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
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
- (void)insertDatasAtIndexPaths:(NSArray *)indexPaths {
    if ([_dataSource respondsToSelector:@selector(ssnlist_controller:loadDataWithIndexPaths:userInfo:completion:)]) {
        
        __weak typeof(self) w_self = self;
        void (^block)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) = ^(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) {
            __strong typeof(w_self) self = w_self; if (!w_self) { return ; }
            
            if (!finished) {
                return ;
            }
            
            self.userInfo = userInfo;
            
            //重置数据
            [self resetResults:results isMerge:YES];
        };
        
        [self.dataSource ssnlist_controller:self loadDataWithIndexPaths:indexPaths userInfo:self.userInfo completion:block];
    }
}

/**
 *  删除对应位置的数据
 *
 *  @param indexPaths NSIndexPaths数据所在位置
 */
- (void)deleteDatasAtIndexPaths:(NSArray *)indexPaths {
    NSMutableIndexSet *changeSectionsSet = [NSMutableIndexSet indexSet];
    NSMutableDictionary *delIndexs = [NSMutableDictionary dictionaryWithCapacity:1];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *path, NSUInteger idx, BOOL *stop) {
        NSUInteger section = path.section;
        NSMutableIndexSet *set = [delIndexs objectForKey:@(section)];
        if (!set) {
            set = [NSMutableIndexSet indexSet];
            [delIndexs setObject:set forKey:@(section)];
            [changeSectionsSet addIndex:section];
        }
        
        [set addIndex:path.row];
    }];
    
    //求出新的list
    NSMutableArray *news = [NSMutableArray array];
    [_list enumerateObjectsUsingBlock:^(SSNVMCellItem *section, NSUInteger idx, BOOL *stop) {
        
        NSIndexSet *set = [delIndexs objectForKey:@(idx)];
        if (set) {
            SSNVMSectionInfo *nSection = [section copy];
            [nSection.objects removeObjectsAtIndexes:set];
            if ([nSection.objects count]) {
                [news addObject:nSection];
            }
        }
        else {
            [news addObject:section];
        }
    }];
    
    //将结果进行比较
    NSArray *olds = [NSArray arrayWithArray:_list];
    NSArray *sectionChanges = [self changesFrom:olds to:news changedIndexs:changeSectionsSet sectionModelChangeIndexs:nil];
    
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

/**
 *  更新位置的数据，如果对应位置数据没有确实有变化，可能重新排序
 *
 *  @param indexPaths 位置
 */
- (void)updateDatasAtIndexPaths:(NSArray *)indexPaths {
    if ([_dataSource respondsToSelector:@selector(ssnlist_controller:loadDataWithIndexPaths:userInfo:completion:)]) {
        
        __weak typeof(self) w_self = self;
        void (^block)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) = ^(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) {
            __strong typeof(w_self) self = w_self; if (!w_self) { return ; }
            
            if (!finished) {
                return ;
            }
            
            self.userInfo = userInfo;
            
            //重置数据
            [self resetResults:results isMerge:YES];
        };
        
        [self.dataSource ssnlist_controller:self loadDataWithIndexPaths:indexPaths userInfo:self.userInfo completion:block];
    }
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

- (NSArray *)convertModelsFromDatas:(NSArray *)datas {
    NSMutableArray *array = [NSMutableArray array];
    
    @autoreleasepool {
        
        if ([datas count]) {
            //数据是否需要转化
            if ([self.dataSource respondsToSelector:@selector(ssnlist_controller:constructObjectsFromResults:)]) {
                NSArray *list = [self.dataSource ssnlist_controller:self constructObjectsFromResults:datas];
                if (list) {
                    [array setArray:list];
                }
            }
            else {
                [array setArray:datas];
            }
        }
        
    }
    
    return array;
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

- (void)resetResults:(NSArray *)datas isMerge:(BOOL)isMerge {
    @autoreleasepool {
        
        _synchronFlag++;
        
        //数据转换
        NSArray *models = [self convertModelsFromDatas:datas];
        
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
                    
                    NSUInteger index = [_list indexOfObject:oSection];
                    [changes addIndex:index];
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
                [set addIndex:index];
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
        _synchronFlag--;
        
        /** 说明结果集被反复修改，此时仅仅更新最后一次，
            遗留问题：前几次的update数据可能被遗漏更新
         */
        if (_synchronFlag > 0) {
            return ;
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
        
        [_delegate ssnlist_controllerDidChange:self];
        
    };
    
    [self ssn_mainThreadAsyncBlock:block];
}



@end

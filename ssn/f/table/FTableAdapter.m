//
//  FTableAdapter.m
//  ssn
//
//  Created by lingminjun on 16/7/17.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import "FTableAdapter.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

/**
 *  数据修改委托
 */
typedef NS_ENUM(NSUInteger, FTableChangeType){
    /**
     *  数据插入
     */
    FTableChangeInsert = 1,
    /**
     *  数据更新
     */
    FTableChangeDelete = 2,
    /**
     *  数据移动
     */
    FTableChangeMove = 3,
    /**
     *  数据更新
     */
    FTableChangeUpdate = 4
};

@implementation UITableViewCell (FTableCell)
- (void)ftable_display:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView {}

static char *ftable_cell_model_key = NULL;
- (void)ftable_setCellModel:(id<FTableCellModel>)cellModel {
    objc_setAssociatedObject(self, &(ftable_cell_model_key),cellModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<FTableCellModel>)ftable_cellModel {
    return objc_getAssociatedObject(self, &(ftable_cell_model_key));
}

- (void)ftable_onDisplay:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView {
    //防止嵌套调用ftable_display方法
    
    //提前替换掉cell model
    [self ftable_setCellModel:cellModel];
    
    //调用展示函数
    @try {
        [self ftable_display:cellModel atIndexPath:indexPath inTable:tableView];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
        //
    }
    
    //最后防止数据被串改回来
    [self ftable_setCellModel:cellModel];
}
@end


@interface FTableAdapter () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray<id<FTableCellModel>> *objs;//数据源

@end

@implementation FTableAdapter

- (instancetype)init {
    self = [super init];
    if (self) {
        _objs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView {
    if (_tableView == tableView) {
        return;
    }
    
    if (_tableView != nil) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    [_tableView reloadData];
}

- (void)refreash {[_tableView reloadData];}

- (NSUInteger)count {return [_objs count];}

- (NSArray<id<FTableCellModel> > *)models {
    return [NSArray arrayWithArray:_objs];
}

- (id<FTableCellModel>)modelAtIndex:(NSUInteger)index {
    if (index >= [_objs count]) {
        return nil;
    }
    return [_objs objectAtIndex:index];
}

- (NSUInteger)indexOfModel:(id<FTableCellModel>)model {
    return [_objs indexOfObject:model];
}

- (void)setModels:(NSArray<id<FTableCellModel> > *)models {
    if (models != nil) {
        [_objs setArray:models];
        
        //需要改进
        [_tableView reloadData];
    }
}

- (void)appendModels:(NSArray<id<FTableCellModel> > *)models {
    if (models == nil || [models count] == 0) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_objs count] inSection:0];
    [self insertDatas:models atIndexPath:indexPath];
}

- (void)appendModel:(id<FTableCellModel>)model {
    if (model == nil) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_objs count] inSection:0];
    [self insertDatas:@[model] atIndexPath:indexPath];
}

- (void)insertModel:(id<FTableCellModel>)model atIndex:(NSUInteger)index {
    if (model == nil) {
        return;
    }
    
    NSUInteger idx = index;
    if (index >= [_objs count]) {
        idx = [_objs count];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    [self insertDatas:@[model] atIndexPath:indexPath];
}

- (void)insertModels:(NSArray<id<FTableCellModel> > *)models atIndex:(NSUInteger)index {
    if (models == nil || [models count] == 0) {
        return;
    }
    
    NSUInteger idx = index;
    if (index >= [_objs count]) {
        idx = [_objs count];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    [self insertDatas:models atIndexPath:indexPath];
}

/**
 *  更新对应位置的数据
 *
 *  @param model 可以传入空
 *  @param index 对应位置数据更新
 */
- (void)updateModel:(id<FTableCellModel>)model atIndex:(NSUInteger)index {
    if (index >= [_objs count]) {
        return;
    }
    
    id<FTableCellModel> md = model;
    if (md == nil) {
        md = [_objs objectAtIndex:index];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self updateDatas:@[md] atIndexPaths:@[indexPath]];
}

- (void)deleteModel:(id<FTableCellModel>)model {
    NSUInteger idx = [_objs indexOfObject:model];
    
    if (idx > [_objs count]) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    [self deleteDatasAtIndexPaths:@[indexPath]];
}

- (void)deleteModelAtIndex:(NSUInteger)index {
    if (index > [_objs count]) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self deleteDatasAtIndexPaths:@[indexPath]];
}

- (void)deleteModelsInRange:(NSRange)range {
    if (range.location > [_objs count] || range.length == 0) {
        return;
    }
    
    NSMutableArray *ary = [NSMutableArray array];
    for (NSUInteger idx = 0; idx < range.length; idx++) {
        NSUInteger t_idx = (idx + range.location);
        if (t_idx > [_objs count]) {
            continue;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(idx + range.location) inSection:0];
        [ary addObject:indexPath];
    }
    
    [self deleteDatasAtIndexPaths:ary];
}

//////////////////////////////////////////////////////////////////////////////////
// 具体实现
//////////////////////////////////////////////////////////////////////////////////
/**
 *  新增数据
 *
 *  @param indexPaths  对应的位置新增，实际位置并不取决于它
 */
- (void)insertDatas:(NSArray<id<FTableCellModel> > *)datas atIndexPath:(NSIndexPath *)indexPath {
    
    if ([datas count] == 0) {
        return ;
    }
//    
//    NSRunLoop *runloop = self.mainRunLoop;
//    if ([runloop ssn_flag_count_for_tag:(NSUInteger)self]) {
//        ssn_t_log(@"fetctController:%p 忽略插入！说明此时数据源并没有稳定",self);
//        return ;
//    }
//    
//    int64_t flag = [runloop ssn_push_flag_for_tag:(NSUInteger)self];
//    ssn_t_log(@"在fetctController:%p 插入数据 标记flag = %lld",self,flag);
//    
    [self ftable_dataWillChange];
    
//    NSMutableArray *newSections = [NSMutableArray array];
//    NSMutableArray *changeSections = [NSMutableArray array];
    
    [datas enumerateObjectsUsingBlock:^(id<FTableCellModel> model, NSUInteger idx, BOOL * stop) {
        
//        SSNSectionModel *sectionInfo = [_list objectAtIndex:indexPath.section];//
//        if (indexPath.section >= [_list count]) {
//            
//            NSString *sectionIdentify = [model cellSectionIdentify];
//            sectionInfo = [self loadSectionWithSectionIdentify:sectionIdentify];
//            
//            if (!sectionInfo) {
//                return ;
//            }
//            
//            [_list addObject:sectionInfo];
//            [newSections addObject:sectionInfo];
//            [changeSections addObject:sectionInfo];
//            
//            [_delegate ssnlist_controller:self didChangeSection:sectionInfo atIndex:indexPath.section forChangeType:FTableChangeInsert];
//        }
//        else {
//            if (![changeSections containsObject:sectionInfo]) {
//                [changeSections addObject:sectionInfo];
//                
//                //让section更新一下（修改header）
//                [_delegate ssnlist_controller:self didChangeSection:sectionInfo atIndex:indexPath.section forChangeType:FTableChangeUpdate];
//            }
//        }
        
        [_objs insertObject:model atIndex:(indexPath.row + idx)];
        
//        if (![newSections containsObject:sectionInfo]) {
            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:(indexPath.row + idx) inSection:indexPath.section];
            [self ftable_dataDidChangeObject:model atIndexPath:newIndex forChangeType:FTableChangeInsert newIndexPath:newIndex];
//        }
        
    }];
    
    [self ftable_dataDidChange];
    
//    [runloop ssn_pop_flag_for_tag:(NSUInteger)self];
//    ssn_t_log(@"在fetctController:%p 插入数据 取消标记flag = %lld",self,flag);
}

/**
 *  删除对应位置的数据
 *
 *  @param indexPaths NSIndexPaths数据所在位置
 */
- (void)deleteDatasAtIndexPaths:(NSArray *)indexPaths {
    if ([indexPaths count] == 0) {
        return ;
    }
    
//    NSRunLoop *runloop = self.mainRunLoop;
//    if ([runloop ssn_flag_count_for_tag:(NSUInteger)self]) {
//        ssn_t_log(@"fetctController:%p 忽略删除！说明此时数据源并没有稳定",self);
//        return ;
//    }
//    
//    int64_t flag = [runloop ssn_push_flag_for_tag:(NSUInteger)self];
//    ssn_t_log(@"在fetctController:%p 删除数据 标记flag = %lld",self,flag);
    
    [self ftable_dataWillChange];
    
    //先计算哪些section需要改变
//    NSMutableDictionary *changeSections = [NSMutableDictionary dictionary];
//    NSMutableDictionary *delIndexsMap = [NSMutableDictionary dictionary];
//    NSMutableDictionary *delPathsMap = [NSMutableDictionary dictionary];
//    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *path, NSUInteger idx, BOOL *stop) {
//        NSNumber *section = @(path.section);
//        
//        SSNSectionModel *sectionInfo = [changeSections objectForKey:section];//哪些section发生了改变
//        if (!sectionInfo) {
//            sectionInfo = [_list objectAtIndex:path.section];
//            [changeSections setObject:sectionInfo forKey:section];
//        }
//        
//        NSMutableArray *delPaths = [delPathsMap objectForKey:section];//需要删除的path
//        if (!delPaths) {
//            delPaths = [NSMutableArray array];
//            [delPathsMap setObject:delPaths forKey:section];
//        }
//        
//        if (![delPaths containsObject:indexPaths]) {
//            [delPaths addObject:path];
//        }
//        
//        NSMutableIndexSet *delIndexs = [delIndexsMap objectForKey:section];//需要删除的range
//        if (!delIndexs) {
//            delIndexs = [NSMutableIndexSet indexSet];
//            [delIndexsMap setObject:delIndexs forKey:section];
//        }
//        
//        [delIndexs addIndex:path.row];
//    }];
//    
//    [changeSections enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, SSNSectionModel *obj, BOOL *stop) {
//        NSUInteger section = [key integerValue];
//        
//        NSIndexSet *delSet = [delIndexsMap objectForKey:key];
//        NSArray *oldObjs = [obj.objects copy];
//        [obj.objects removeObjectsAtIndexes:delSet];
//        
//        //表示直接可以删除
//        if ([obj.objects count] == 0) {
//            ssn_t_log(@"delete section at index %lu",section);
//            [_sectionMap removeObjectForKey:obj.identify];
//            [_list removeObject:obj];//删除section
//            
//            //仅仅删除section
//            [_delegate ssnlist_controller:self didChangeSection:obj atIndex:section forChangeType:FTableChangeDelete];
//        }
//        else {
//            [_delegate ssnlist_controller:self didChangeSection:obj atIndex:section forChangeType:FTableChangeUpdate];
//            NSArray *delPaths = [delPathsMap objectForKey:key];
    NSArray<id<FTableCellModel> > *olddata = [self models];
    NSMutableIndexSet *delIndexs = [NSMutableIndexSet indexSet];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *path, NSUInteger idx, BOOL *stop) {
        [delIndexs addIndex:path.row];
    }];
    [_objs removeObjectsAtIndexes:delIndexs];
    
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        id<FTableCellModel> obj = [olddata objectAtIndex:indexPath.row];
        [self ftable_dataDidChangeObject:obj atIndexPath:indexPath forChangeType:FTableChangeDelete newIndexPath:nil];
    }];
//        }
//    }];
    
    [self ftable_dataDidChange];
    
//    [runloop ssn_pop_flag_for_tag:(NSUInteger)self];
//    ssn_t_log(@"在fetctController:%p 删除数据 取消标记flag = %lld",self,flag);
}


/**
 *  更新位置的数据，如果对应位置数据没有确实有变化，可能重新排序
 *
 *  @param indexPaths 位置
 */
- (void)updateDatas:(NSArray<id<FTableCellModel> > *)datas atIndexPaths:(NSArray *)indexPaths {
    
    if ([indexPaths count] != [datas count] || [indexPaths count] == 0) {
        return ;
    }
    
//    NSRunLoop *runloop = self.mainRunLoop;
//    if ([runloop ssn_flag_count_for_tag:(NSUInteger)self]) {
//        ssn_t_log(@"fetctController:%p 更新！说明此时数据源并没有稳定",self);
//        [self.changeIndexPaths addObjectsFromArray:indexPaths];
//        return ;
//    }
//    
//    int64_t flag = [runloop ssn_push_flag_for_tag:(NSUInteger)self];
//    ssn_t_log(@"在fetctController:%p 更新数据 标记flag = %lld",self,flag);
    
    [self ftable_dataWillChange];
    
//    NSMutableArray *changeSections = [NSMutableArray array];
    [datas enumerateObjectsUsingBlock:^(id<FTableCellModel> model, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [indexPaths objectAtIndex:idx];
        
        id<FTableCellModel> oldModel = [self modelAtIndex:indexPath.row];
        if (!oldModel) {
            return ;
        }
        
        if (!model) {
            return ;
        }
        
//        SSNSectionModel *sectionInfo = [_list objectAtIndex:indexPath.section];//
//        if (!sectionInfo) {
//            return ;
//        }
        
//        if (![changeSections containsObject:sectionInfo]) {
//            [changeSections addObject:sectionInfo];
//            
//            //让section更新一下（修改header）
//            [_delegate ssnlist_controller:self didChangeSection:sectionInfo atIndex:indexPath.section forChangeType:FTableChangeUpdate];
//        }
        
        [_objs replaceObjectAtIndex:indexPath.row withObject:model];
        [self ftable_dataDidChangeObject:model atIndexPath:indexPath forChangeType:FTableChangeUpdate newIndexPath:indexPath];
        
    }];
    
    [self ftable_dataDidChange];
    
//    [runloop ssn_pop_flag_for_tag:(NSUInteger)self];
//    ssn_t_log(@"在fetctController:%p 更新数据 取消标记flag = %lld",self,flag);
}

//////////////////////////////////////////////////////////////////////////
- (void)ftable_dataDidChangeSection:(id<FTableCellModel>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(FTableChangeType)type {
    if (_tableView == nil) {
        return ;
    }
    
    switch(type) {
        case FTableChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case FTableChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:break;
    }
}

- (void)ftable_dataDidChangeObject:(id<FTableCellModel>)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(FTableChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (_tableView == nil) {
        return ;
    }
    
    switch (type) {
        case FTableChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case FTableChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case FTableChangeMove:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case FTableChangeUpdate:
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell ftable_onDisplay:object atIndexPath:indexPath inTable:self.tableView];
//            [cell ssn_configureCellWithModel:object atIndexPath:indexPath inTableView:self.tableView];
        }
            break;
        default:
            break;
    }
}

- (void)ftable_dataWillChange {
    [self.tableView beginUpdates];
}

- (void)ftable_dataDidChange {
    [self.tableView endUpdates];
}

//////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.tableView) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return 0;
    }
    
    return [_objs count];
}

- (UITableViewCell *)loadCellWithTableView:(UITableView *)tableView cellModel:(id<FTableCellModel>)cellModel {
    //优先从nib加载
    NSString *nibName = nil;
    Class clazz = nil;
    if ([cellModel respondsToSelector:@selector(ftable_displayCellNibName)] > 0) {
        nibName = [cellModel ftable_displayCellNibName];
    }
    if ([cellModel respondsToSelector:@selector(ftable_displayCellClass)]) {
        clazz = [cellModel ftable_displayCellClass];
    }
    
    
    NSString *cellId = @"ftablecell";
    if ([nibName length] > 0) {
        cellId = [NSString stringWithFormat:@"ftable-%@",nibName];
    } else if (clazz) {
        cellId = [NSString stringWithFormat:@"ftable-%@",NSStringFromClass(clazz)];
    }
    
    //先取复用队列
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell) {
        return cell;
    }
    
    
    if ([nibName length] > 0) {
        NSArray *views =  [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
        cell = (UITableViewCell *)[views objectAtIndex:0];
    }
    if (cell) {
        return cell;
    }
    
    //自己创建
    if (clazz) {
        cell = [[clazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (cell) {
        return cell;
    }
    
    //默认返回
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    id<FTableCellModel> model = [self modelAtIndex:indexPath.row];
    
    UITableViewCell *cell = [self loadCellWithTableView:tableView cellModel:model];
    
    [cell ftable_onDisplay:model atIndexPath:indexPath inTable:tableView];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return 44;
    }
    
    id<FTableCellModel> model = [self modelAtIndex:indexPath.row];
    CGFloat height = 44.0f;
    if ([model respondsToSelector:@selector(ftable_cellHeight)]) {
        height = [model ftable_cellHeight];
    }
    
    if (height <= 0) {
        height = tableView.rowHeight == 0 ? 44 : tableView.rowHeight;
    }
    return height;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return UITableViewCellEditingStyleNone;
    }
    
    //仅仅支持删除
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ftable_adapter:tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        @try {
            [self.delegate ftable_adapter:self tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
            //
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return nil;
    }
    
    id<FTableCellModel> model = [self modelAtIndex:indexPath.row];
    if ([model respondsToSelector:@selector(ftable_cellDeleteConfirmationButtonTitle)]) {
        return [model ftable_cellDeleteConfirmationButtonTitle];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return NO;
    }
    
    id<FTableCellModel> model = [self modelAtIndex:indexPath.row];
    if ([model respondsToSelector:@selector(ftable_cellDeleteConfirmationButtonTitle)]) {
        return [model ftable_cellDeleteConfirmationButtonTitle] > 0;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<FTableCellModel> model = [self modelAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(ftable_adapter:tableView:didSelectModel:atIndexPath:)]) {
        @try {
            [self.delegate ftable_adapter:self tableView:tableView didSelectModel:model atIndexPath:indexPath];
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
            //
        }
    }
}

@end

//
//  UIViewController+SSNTableViewEasyConfigure.m
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIViewController+SSNTableViewEasyConfigure.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif


@interface SSNTableViewConfigurator ()
@end


@implementation SSNTableViewConfigurator

@synthesize listFetchController = _listFetchController;
- (SSNListFetchController *)listFetchController {
    if (_listFetchController) {
        return _listFetchController;
    }
    
    _listFetchController = [SSNListFetchController fetchControllerWithDelegate:self dataSource:self isGrouping:NO];
    return _listFetchController;
}

- (void)setTableView:(UITableView *)tableView {
    
    if (tableView.delegate != self) {//不相等时再赋值，setDelegate会触发内部检查一些委托方法是否实现问题
        tableView.delegate = self;
    }
    
    if (tableView.dataSource != self) {//不相等时再赋值，setDataSource会触发内部检查一些委托方法是否实现问题
        tableView.dataSource = self;
    }
    
    tableView.ssn_headerPullRefreshView.delegate = self;
    tableView.ssn_footerLoadMoreView.delegate = self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView = tableView;
}

- (void)configureWithTableView:(UITableView *)tableView groupingFetchController:(BOOL)grouping {
    if (tableView) {
        self.tableView = tableView;
    }
    
    if (_listFetchController.isGrouping != grouping) {
        _listFetchController = [SSNListFetchController fetchControllerWithDelegate:self dataSource:self isGrouping:grouping];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.tableView) {
        return 0;
    }
    
    return [self.listFetchController sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return 0;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    return [sec count];
}

- (UITableViewCell *)loadCellWithTableView:(UITableView *)tableView cellModel:(id<SSNCellModel>)cellModel {
    NSString *cellId = [cellModel cellIdentify];
    if (!cellId) {
        cellId = @"cell";
    }
    
    //先取复用队列
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell) {
        return cell;
    }
    
    //优先从nib加载
    if ([cellModel.cellNibName length] > 0) {
        NSArray *views =  [[NSBundle mainBundle] loadNibNamed:cellModel.cellNibName owner:nil options:nil];
        cell = (UITableViewCell *)[views objectAtIndex:0];
    }
    if (cell) {
        return cell;
    }
    
    //自己创建
    Class clazz = nil;
    if ([cellModel respondsToSelector:@selector(cellClass)]) {
        clazz = cellModel.cellClass;
    }
    
    if (clazz) {
        cell = [[clazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
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
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    
    //加载cell
    UITableViewCell *cell = [self loadCellWithTableView:tableView cellModel:model];
    
    cell.ssn_cellModel = model;
    
    if (model.isDisabledSelect) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    [cell ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    cell.ssn_cellModel = model;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return SSN_VM_CELL_ITEM_DEFAULT_HEIGHT;
    }
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    return [model cellHeight];
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
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.delegate ssn_configurator:self tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return nil;
    }
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    return [model cellDeleteConfirmationButtonTitle];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return NO;
    }
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    return [model cellDeleteConfirmationButtonTitle] > 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return ;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    if (model.isDisabledSelect) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:tableView:didSelectModel:atIndexPath:)]) {
        [self.delegate ssn_configurator:self tableView:tableView didSelectModel:model atIndexPath:indexPath];
    }
}

//header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return nil;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenHeader) {
        return nil;
    }
    return sec.headerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return 0.0f;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenHeader) {
        return 0.0f;
    }
    return sec.headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return nil;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenHeader) {
        return nil;
    }
    return sec.customHeaderView;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return nil;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenFooter) {
        return nil;
    }
    return sec.footerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return 0.0f;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenFooter) {
        return 0.0f;
    }
    return sec.footerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return nil;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenFooter) {
        return nil;
    }
    return sec.customFooterView;
}

#pragma mark - uiscroll view delegate 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.tableView) {
        return ;
    }
    
    UITableView *tableView = self.tableView;
    
    [tableView.ssn_headerPullRefreshView scrollViewDidScroll:scrollView];
    [tableView.ssn_footerLoadMoreView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.tableView) {
        return ;
    }
    
    UITableView *tableView = self.tableView;
    
    [tableView.ssn_headerPullRefreshView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    [tableView.ssn_footerLoadMoreView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.tableView) {
        return ;
    }
    
    UITableView *tableView = self.tableView;
    [tableView.ssn_footerLoadMoreView scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != self.tableView) {
        return ;
    }
    
    UITableView *tableView = self.tableView;
    
    [tableView.ssn_headerPullRefreshView scrollViewWillBeginDragging:scrollView];
    [tableView.ssn_footerLoadMoreView scrollViewWillBeginDragging:scrollView];
}

#pragma mark - pull refresh delegate
/**
 *  将要触发动作
 *
 *  @param view
 */
- (void)ssn_pullRefreshViewDidTriggerRefresh:(SSNPullRefreshView *)view {
    if (view == self.tableView.ssn_headerPullRefreshView) {
        [self.listFetchController loadData];
    }
    else if (view == self.tableView.ssn_footerLoadMoreView) {
        [self.listFetchController loadMoreData];
    }
}

- (NSString *)ssn_pullRefreshView:(SSNPullRefreshView *)view copywritingAtLatestUpdatedTime:(NSDate *)time {
    if (view == self.tableView.ssn_headerPullRefreshView) {
        if (time) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            return [NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:time]];
        }
    }
    else if (view == self.tableView.ssn_footerLoadMoreView) {
        //
    }
    return nil;
}


#pragma mark - list fetch controller delegate
- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeSection:(SSNVMSectionInfo *)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(SSNListFetchedChangeType)type {
    if (controller != self.listFetchController) {
        return ;
    }

    switch(type) {
        case SSNListFetchedChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case SSNListFetchedChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:break;
    }
}

- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeObject:(id<SSNCellModel>)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(SSNListFetchedChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (controller != self.listFetchController) {
        return ;
    }
    
    switch (type) {
        case SSNListFetchedChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeMove:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeUpdate:
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell ssn_configureCellWithModel:object atIndexPath:indexPath inTableView:self.tableView];
        }
            break;
        default:
            break;
    }
    
}

- (void)ssnlist_controllerWillChange:(SSNListFetchController *)controller {
    if (controller != self.listFetchController) {
        return ;
    }
    
    [self.tableView beginUpdates];
}

- (void)ssnlist_controllerDidChange:(SSNListFetchController *)controller {
    if (controller != self.listFetchController) {
        return ;
    }
    
    [self.tableView endUpdates];
}

#pragma mark - list fetch controller datasource

- (void)ssnlist_controller:(SSNListFetchController *)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion
{
    if (controller != self.listFetchController) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:controller:loadDataWithOffset:limit:userInfo:completion:)]) {
        
        void (^block)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) = ^(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) {
            
            if (offset == 0) {
                [self.tableView.ssn_headerPullRefreshView finishedLoading];
            }
            else {
                [self.tableView.ssn_footerLoadMoreView finishedLoading];
            }
            
            if (self.isAutoEnabledLoadMore) {
                self.tableView.ssn_loadMoreEnabled = hasMore;
                _tableView.ssn_footerLoadMoreView.delegate = self;
            }
            
            if (completion) {
                completion(results,hasMore,userInfo,finished);
            }
        };
        
        [self.delegate ssn_configurator:self controller:controller loadDataWithOffset:offset limit:limit userInfo:userInfo completion:block];
    }
}


- (NSArray *)ssnlist_controller:(SSNListFetchController *)controller constructObjectsFromResults:(NSArray *)results
{
    if (controller != self.listFetchController) {
        return results;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:controller:constructObjectsFromResults:)]) {
        return [self.delegate ssn_configurator:self controller:controller constructObjectsFromResults:results];
    }
    
    return results;
}

@end


@implementation UIViewController (SSNTableViewEasyConfigure)
#pragma mark list fetch controller
static char * ssn_table_configurator_key = NULL;
- (SSNTableViewConfigurator *)ssn_tableViewConfigurator {
    SSNTableViewConfigurator *configurator = objc_getAssociatedObject(self, &(ssn_table_configurator_key));
    if (configurator) {
        return configurator;
    }
    
    configurator = [[SSNTableViewConfigurator alloc] init];
    configurator.delegate = self;
    
    objc_setAssociatedObject(self, &(ssn_table_configurator_key),configurator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return configurator;
}

#pragma mark - 委托默认实现
- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator tableView:(UITableView *)tableView didSelectModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath {
}

- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator controller:(SSNListFetchController *)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    if (completion) {
        completion(nil,NO,userInfo,YES);
    }
    
}

@end

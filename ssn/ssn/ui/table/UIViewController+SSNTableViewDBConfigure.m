//
//  UIViewController+SSNTableViewDBConfigure.m
//  ssn
//
//  Created by lingminjun on 15/3/3.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIViewController+SSNTableViewDBConfigure.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif


@interface SSNTableViewDBConfigurator ()
@end


@implementation SSNTableViewDBConfigurator

@synthesize dbFetchController = _dbFetchController;
- (void)setDbFetchController:(SSNDBFetchController *)dbFetchController {
    dbFetchController.delegate = self;
    _dbFetchController = dbFetchController;
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


#pragma mark - UITableViewDataSource
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
    
    return [self.dbFetchController count];
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
    
    id<SSNCellModel> model = [self.dbFetchController objectAtIndex:indexPath.row];
    
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
    
    id<SSNCellModel> model = [self.dbFetchController objectAtIndex:indexPath.row];
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
    
    id<SSNCellModel> model = [self.dbFetchController objectAtIndex:indexPath.row];
    return [model cellDeleteConfirmationButtonTitle];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return NO;
    }
    
    id<SSNCellModel> model = [self.dbFetchController objectAtIndex:indexPath.row];
    return [model cellDeleteConfirmationButtonTitle] > 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return ;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<SSNCellModel> model = [self.dbFetchController objectAtIndex:indexPath.row];
    if (model.isDisabledSelect) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:tableView:didSelectModel:atIndexPath:)]) {
        [self.delegate ssn_configurator:self tableView:tableView didSelectModel:model atIndexPath:indexPath];
    }
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
        [self.dbFetchController performFetch];
    }
    else if (view == self.tableView.ssn_footerLoadMoreView) {
        [self.dbFetchController performNextFetchCount:SSNDBFetchPageSize];
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


#pragma mark - db fetch controller delegate
- (void)ssndb_controller:(SSNDBFetchController *)controller didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(SSNDBFetchedChangeType)type newIndex:(NSUInteger)newIndex {
    if (controller != self.dbFetchController) {
        return ;
    }
    
    switch (type) {
        case SSNDBFetchedChangeInsert:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNDBFetchedChangeDelete:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNDBFetchedChangeMove:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNDBFetchedChangeUpdate:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell ssn_configureCellWithModel:object atIndexPath:indexPath inTableView:self.tableView];
        }
            break;
        default:
            break;
    }
    
}

- (void)ssndb_controllerWillChange:(SSNDBFetchController *)controller {
    if (controller != self.dbFetchController) {
        return ;
    }
    [self.tableView beginUpdates];
}

- (void)ssndb_controllerDidChange:(SSNDBFetchController *)controller {
    if (controller != self.dbFetchController) {
        return ;
    }
    [self.tableView endUpdates];
}

@end


@implementation UIViewController (SSNTableViewDBConfigure)
#pragma mark list fetch controller
static char * ssn_db_configurator_key = NULL;
- (SSNTableViewDBConfigurator *)ssn_tableViewDBConfigurator {
    SSNTableViewDBConfigurator *configurator = objc_getAssociatedObject(self, &(ssn_db_configurator_key));
    if (configurator) {
        return configurator;
    }
    
    configurator = [[SSNTableViewDBConfigurator alloc] init];
    configurator.delegate = self;
    
    objc_setAssociatedObject(self, &(ssn_db_configurator_key),configurator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return configurator;
}

#pragma mark - 委托默认实现
- (void)ssn_configurator:(SSNTableViewDBConfigurator *)configurator tableView:(UITableView *)tableView didSelectModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath {
}

- (void)ssn_configurator:(SSNTableViewDBConfigurator *)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    if (completion) {
        completion(nil,NO,userInfo,YES);
    }
    
}

@end

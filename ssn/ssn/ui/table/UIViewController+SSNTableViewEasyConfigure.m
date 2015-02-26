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

@implementation UIViewController (SSNTableViewEasyConfigure)
#pragma mark list fetch controller
static char * ssn_list_fetch_controller_key = NULL;
- (SSNListFetchController *)ssn_listFetchController {
    SSNListFetchController *controller = objc_getAssociatedObject(self, &(ssn_list_fetch_controller_key));
    if (controller) {
        return controller;
    }
    
    controller = [SSNListFetchController fetchControllerWithDelegate:self dataSource:nil];
    
    objc_setAssociatedObject(self, &(ssn_list_fetch_controller_key),controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return controller;
}

static char * ssn_list_fetch_table_key = NULL;
@dynamic ssn_resultsTableView;
- (UITableView *)ssn_resultsTableView {
    return objc_getAssociatedObject(self, &(ssn_list_fetch_table_key));
}
- (void)setSsn_resultsTableView:(UITableView *)ssn_resultsTableView {
    objc_setAssociatedObject(self, &(ssn_list_fetch_table_key),ssn_resultsTableView, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView != self.ssn_resultsTableView) {
        return 0;
    }
    return [self.ssn_listFetchController count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.ssn_resultsTableView) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    id<SSNCellModel> model = [self.ssn_listFetchController objectAtIndex:indexPath.row];
    
    NSString *cellId = [model cellIdentify];
    if (!cellId) {
        cellId = @"cell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    // Configure the cell...
    if (!cell) {
        if (model.cellClass) {
            cell = [[(Class)(model.cellClass) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
    }
    
    [cell ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    return cell;

}

#pragma mark - list fetch controller delegate
- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeObject:(id<SSNCellModel>)object atIndex:(NSUInteger)index forChangeType:(SSNListFetchedChangeType)type newIndex:(NSUInteger)newIndex {
    if (controller != self.ssn_listFetchController) {
        return ;
    }
    
    switch (type) {
        case SSNListFetchedChangeInsert:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.ssn_resultsTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeDelete:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.ssn_resultsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeMove:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.ssn_resultsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            [self.ssn_resultsTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeUpdate:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            UITableViewCell *cell = [self.ssn_resultsTableView cellForRowAtIndexPath:indexPath];
            [cell ssn_configureCellWithModel:object atIndexPath:indexPath inTableView:self.ssn_resultsTableView];
        }
            break;
        default:
            break;
    }
    
}

- (void)ssnlist_controllerWillChange:(SSNListFetchController *)controller {
    if (controller != self.ssn_listFetchController) {
        return ;
    }
    
    [self.ssn_resultsTableView beginUpdates];
}

- (void)ssnlist_controllerDidChange:(SSNListFetchController *)controller {
    if (controller != self.ssn_listFetchController) {
        return ;
    }
    
    [self.ssn_resultsTableView endUpdates];
}

@end

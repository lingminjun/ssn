//
//  UIViewController+SSNTableViewEasyConfigure.h
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNVMCellItem.h"
#import "SSNListFetchController.h"

/**
 *  对简易行的tableView结果集委托有一套默认实现，方便使用者使用
 *  UITableViewDataSource仅仅实现必要委托
 */
@interface UIViewController (SSNTableViewEasyConfigure) <UITableViewDataSource,SSNListFetchControllerDelegate>

/**
 *  默认ssn_listFetchController的委托是控制器本身
 *  数据源的委托还未指定
 */
@property (nonatomic,strong,readonly) SSNListFetchController *ssn_listFetchController;

/**
 *  结果呈现的table
 */
@property (nonatomic,assign) UITableView *ssn_resultsTableView;

@end

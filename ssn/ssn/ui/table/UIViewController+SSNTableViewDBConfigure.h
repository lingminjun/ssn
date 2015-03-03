//
//  UIViewController+SSNTableViewDBConfigure.h
//  ssn
//
//  Created by lingminjun on 15/3/3.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNTableViewConfigureProtocol.h"
#import "SSNDBFetchController.h"

#define SSNDBFetchPageSize (10)

/**
 *  给出一种默认的实现，让控制器变得更佳简介易用
 */
@interface SSNTableViewDBConfigurator : NSObject<SSNTableViewConfigurator,UITableViewDelegate,UITableViewDataSource,SSNPullRefreshDelegate,SSNDBFetchControllerDelegate>

/**
 *  委托
 */
@property (nonatomic,weak) id<SSNTableViewConfiguratorDelegate> delegate;

/**
 *  默认ssn_listFetchController的委托是控制器本身
 *  数据源的委托还未指定
 */
@property (nonatomic,strong) SSNDBFetchController *dbFetchController;

/**
 *  结果呈现的table，此ui应该由ui来把持
 */
@property (nonatomic,weak) UITableView *tableView;

/**
 *  自动检查loadMore功能，不需要你处理tableView.ssn_loadMoreEnabled属性，自动检查是否有更多
 */
@property (nonatomic) BOOL isAutoEnabledLoadMore;


@end


/**
 *  对简易行的tableView结果集委托有一套默认实现，方便使用者使用
 *  UITableViewDataSource仅仅实现必要委托
 */
@interface UIViewController (SSNTableViewDBConfigure) <SSNTableViewConfiguratorDelegate>

/**
 *  table配置器
 */
@property (nonatomic,strong,readonly) SSNTableViewDBConfigurator *ssn_tableViewDBConfigurator;


@end


//
//  UIViewController+SSNTableViewEasyConfigure.h
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNListFetchController.h"
#import "SSNTableViewConfigureProtocol.h"

@protocol SSNTableViewConfiguratorDelegate;

/**
 *  给出一种默认的实现，让控制器变得更佳简介易用
 */
@interface SSNTableViewConfigurator : NSObject<SSNTableViewConfigurator,UITableViewDelegate,UITableViewDataSource,SSNScrollEdgeViewDelegate,SSNListFetchControllerDelegate,SSNListFetchControllerDataSource>

/**
 *  委托
 */
@property (nonatomic,weak) id<SSNTableViewConfiguratorDelegate> delegate;

/**
 *  默认ssn_listFetchController的委托是控制器本身
 *  数据源的委托还未指定
 */
@property (nonatomic,strong,readonly) SSNListFetchController *listFetchController;

/**
 *  结果呈现的table，此ui应该由ui来把持
 */
@property (nonatomic,weak) UITableView *tableView;

/**
 *  cell更新动画
 */
@property (nonatomic) UITableViewRowAnimation rowAnimation;


/**
 *  table更新无动画
 */
@property (nonatomic) BOOL isWithoutAnimation;

/**
 *  自动检查loadMore功能，不需要你处理tableView.ssn_loadMoreEnabled属性，自动检查是否有更多
 */
@property (nonatomic) BOOL isAutoEnabledLoadMore;

/**
 *  请务必调用此方法配置你的Configurator
 *
 *  @param tableView 需要设置的table
 *  @param grouping  listFetchController的类型定义
 */
- (void)configureWithTableView:(UITableView *)tableView groupingFetchController:(BOOL)grouping;

@end


/**
 *  对简易行的tableView结果集委托有一套默认实现，方便使用者使用
 *  UITableViewDataSource仅仅实现必要委托
 */
@interface UIViewController (SSNTableViewEasyConfigure) <SSNTableViewConfiguratorDelegate>

/**
 *  table配置器
 */
@property (nonatomic,strong,readonly) SSNTableViewConfigurator *ssn_tableViewConfigurator;


@end

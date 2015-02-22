//
//  UITableView+SSNPullRefresh.h
//  ssn
//
//  Created by lingminjun on 15/2/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNPullRefreshView.h"

/**
 *  扩充tableview具备下拉刷新和加载更多功能
 */
@interface UITableView (SSNPullRefresh)

/**
 *  是否开启下拉刷新功能
 */
@property (nonatomic) BOOL ssn_pullRefreshEnabled;

/**
 *  是否开启加载更多功能
 */
@property (nonatomic) BOOL ssn_loadMoreEnabled;

/**
 *  下拉刷新view，你可以修改其显示内容
 */
@property (nonatomic,strong,readonly) SSNPullRefreshView *ssn_headerPullRefreshView;

/**
 *  上提加载更多view，你可以修改其显示内容
 */
@property (nonatomic,strong,readonly) SSNPullRefreshView *ssn_footerLoadMoreView;

@end


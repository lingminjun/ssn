//
//  SSNLoadMoreView.h
//  ssn
//
//  Created by lingminjun on 15/5/8.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSNLoadMoreView;

/**
 *  触发委托
 */
@protocol SSNLoadMoreViewDelegate <NSObject>

@required
/**
 *  阀值被触发回调，此时需要加载更多数据，加载完后调用-finishedLoading方法结束加载
 *
 *  @param loadMoreView 当前触发的ScrollHeader
 */
- (void)ssn_loadMoreViewDidTrigger:(SSNLoadMoreView *)loadMoreView;

@end


/**
 *  加载更多tableFooterView
 */
@interface SSNLoadMoreView : UIView

/**
 *  是否在加载
 */
@property (nonatomic,readonly) BOOL isLoading;

/**
 *  触发动作委托
 */
@property (nonatomic,weak) id<SSNLoadMoreViewDelegate> delegate;


/**
 *  加载菊花，你可以根据需要改变其风格与大小
 */
@property (nonatomic,strong,readonly) UIActivityIndicatorView *indicatorView;

/**
 *  显示描述信息，你可以根据需要改变其风格
 */
@property (nonatomic,strong,readonly) UILabel *descriptionLabel;

/**
 *  是否有更多加载
 */
@property (nonatomic) BOOL hasMore;

/**
 *  文案设置
 */
@property (nonatomic,strong) NSString *redrapeMessage;//上提时文案，如：上提加载更多
@property (nonatomic,strong) NSString *loosenMessage;//松手时文案，如：松开开始加载
@property (nonatomic,strong) NSString *loadingMessage;//加载过程文案，如：加载中...

/**
 *  依赖的tableView
 *
 *  @return 返回正在作用的tableView
 */
- (UITableView *)contextTableView;

/**
 *  将其安装到tableView上，其实就赋值给tableView.tableFooterView
 *
 *  @param tableView 依赖的tableView，非空
 */
- (void)installToTableView:(UITableView *)tableView;

/**
 *  结束加载过程
 */
- (void)finishedLoading;

@end

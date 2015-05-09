//
//  SSNDefaultLoadMoreView.h
//  ssn
//
//  Created by lingminjun on 15/5/8.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNScrollEdgeView.h"


/**
 *  加载更多tableFooterView
 */
@interface SSNDefaultLoadMoreView : UIView<SSNScrollEdgeContentView>

/**
 *  加载菊花，你可以根据需要改变其风格与大小
 */
@property (nonatomic,strong,readonly) UIActivityIndicatorView *indicatorView;

/**
 *  显示描述信息，你可以根据需要改变其风格
 */
@property (nonatomic,strong,readonly) UILabel *descriptionLabel;

/**
 *  文案设置
 */
@property (nonatomic,strong) NSString *redrapeMessage;//上提时文案，如：上提加载更多
@property (nonatomic,strong) NSString *loosenMessage; //松手时文案，如：松开开始加载
@property (nonatomic,strong) NSString *loadingMessage;//加载过程文案，如：加载中...

/**
 *  下拉刷新View
 *
 *  @return 下拉刷新view
 */
+ (SSNScrollEdgeView *)loadMoreView;

@end

/**
 *  拓展ScrollEdgeView
 */
@interface SSNScrollEdgeView (SSNLoadMoreView)

/**
 *  是否有更多加载
 */
@property (nonatomic) BOOL hasMore;

/**
 *  将其安装到tableView上，即tableView.tableFooterView
 *
 *  @param tableView 依赖的tableView，非空
 */
- (void)installToTableView:(UITableView *)tableView;

/**
 *  返回依赖的tableView
 *
 *  @return 依赖的tableView
 */
- (UITableView *)contextTableView;

@end

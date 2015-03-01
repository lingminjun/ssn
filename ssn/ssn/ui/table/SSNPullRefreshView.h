//
//  SSNPullRefreshView.h
//  ssn
//
//  Created by lingminjun on 15/2/11.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 *  下拉刷新样式
 */
typedef NS_ENUM(NSUInteger, SSNPullRefreshStyle){
    /**
     *  下拉刷新
     */
    SSNPullRefreshHeaderRefresh,
    /**
     *  上提加载更多
     */
    SSNPullRefreshFooterLoadMore,
};

/**
 *  PullRefresh 状态
 */
typedef NS_ENUM(NSUInteger, SSNPullRefreshState){
    /**
     *  没有拉取
     */
    SSNPullRefreshNarmal,
    /**
     *  正在拉取
     */
    SSNPullRefreshPulling,
    /**
     *  正在加载
     */
    SSNPullRefreshLoading,
};

/**
 *  一些默认配置
 */
#define SSNPullRefreshBackgroudColor       [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]
#define SSNPullRefreshTextColor            [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define SSNPullRefreshActivityIndicatorStyle UIActivityIndicatorViewStyleWhite

#define SSNPullRefreshAnimationDuration    (0.18f)

#define SSNPullRefreshArrowImage           [UIImage imageNamed:@"ssn_pull_refresh_blue_arrow"]

#define SSNPullRefreshHeaderPullingCopywriting   @"松开即可刷新..."
#define SSNPullRefreshHeaderNarmalCopywriting    @"下拉可以刷新..."
#define SSNPullRefreshHeaderLoadingCopywriting   @"加载中..."

#define SSNPullRefreshFooterPullingCopywriting   @"松开即可加载更多..."
#define SSNPullRefreshFooterNarmalCopywriting    @"上拉可以加载更多..."
#define SSNPullRefreshFooterLoadingCopywriting   @"加载中..."

#define SSNPullRefreshHeaderTriggerHeight        (60)
#define SSNPullRefreshFooterTriggerHeight        (44)

#define SSNPullRefreshLabelSpaceHeight           (0)

@protocol SSNPullRefreshDelegate;

/**
 *  下拉刷新 view
 */
@interface SSNPullRefreshView : UIView <UIScrollViewDelegate>

/**
 *  pull refresh类型
 */
@property (nonatomic,readonly) SSNPullRefreshStyle style;

/**
 *  委托
 */
@property(nonatomic,weak) id<SSNPullRefreshDelegate> delegate;

/**
 *  是否在加载
 */
@property (nonatomic,readonly) BOOL isLoading;

/**
 *  字体颜色
 */
@property (nonatomic,strong) UIColor *textColor;

/**
 *  箭头图片
 */
@property (nonatomic,strong) UIImage *arrowImage;

/**
 *  触发动作阀值，下拉刷新默认值是60，而加载更多默认值是44
 */
@property (nonatomic) CGFloat triggerHeight;

/**
 *  起始的偏移值，此值自动获取
 *  表示所依赖tableView.contentInset.top的值
 *  而loadMore则表示tableView.contentInset.bottom
 */
@property (nonatomic,readonly) CGFloat startOffset;

/**
 *  结束加载过程
 */
- (void)finishedLoading;

/**
 *  唯一初始化方法
 *
 *  @param style 风格
 *
 *  @return 返回 SSNPullRefreshView 实例
 */
- (instancetype)initWithStyle:(SSNPullRefreshStyle)style delegate:(id<SSNPullRefreshDelegate>)delegate;

/**
 *  UIScrollViewDelegate仅仅实现的方法声明
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

/**
 *  refresh更新回调委托
 */
@protocol SSNPullRefreshDelegate <NSObject>

/**
 *  将要触发动作
 *
 *  @param view
 */
- (void)ssn_pullRefreshViewDidTriggerRefresh:(SSNPullRefreshView *)view;

@optional
/**
 *  loading过程中文案提示（最后更新时间）
 *
 *  @param view
 *  @param time 最后更新时间
 *
 *  @return 返回文案
 */
- (NSString *)ssn_pullRefreshView:(SSNPullRefreshView *)view copywritingAtLatestUpdatedTime:(NSDate *)time;

@end

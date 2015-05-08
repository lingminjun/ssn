//
//  SSNScrollHeader.h
//  ssn
//
//  Created by lingminjun on 15/5/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  ScrollHeader 状态
 */
typedef NS_ENUM(NSUInteger, SSNScrollHeaderState){
    /**
     *  没有拉取
     */
    SSNScrollHeaderStill,
    /**
     *  正在拉取
     */
    SSNScrollHeaderPulling,
    /**
     *  正在加载
     */
    SSNScrollHeaderLoading,
};

@class SSNScrollHeader;

/**
 *  触发委托
 */
@protocol SSNScrollHeaderDelegate <NSObject>

@required
/**
 *  阀值被触发回调，此时需要加载数据，加载完后调用-finishedLoading方法结束加载
 *
 *  @param scrollHeader 当前触发的ScrollHeader
 */
- (void)ssn_scrollHeaderDidTrigger:(SSNScrollHeader *)scrollHeader;

@end

@protocol SSNScrollHeaderContentView;

/**
 *  此view适合做下拉刷新等功能，下拉动画没有配置
 */
@interface SSNScrollHeader : UIView

/**
 *  触发动作委托
 */
@property (nonatomic,weak) id<SSNScrollHeaderDelegate> delegate;

/**
 *  触发高度，默认值60
 */
@property (nonatomic) CGFloat triggerHeight;

/**
 *  状态
 */
@property (nonatomic,readonly) SSNScrollHeaderState state;

/**
 *  是否在加载
 */
@property (nonatomic,readonly) BOOL isLoading;

/**
 *  背景图片，大小一个屏幕大小
 */
@property (nonatomic,strong,readonly) UIImageView *backgroudImageView;

/**
 *  是否停用
 */
@property (nonatomic) BOOL disabled;

/**
 *  依赖的scrollview
 *
 *  @return 返回正在作用的scrollView
 */
- (UIScrollView *)contextScrollView;

/**
 *  将其安装到scrollview上
 *
 *  @param scrollView 依赖的scrollview，非空
 */
- (void)installToScrollView:(UIScrollView *)scrollView;

/**
 *  设置内容view
 *
 *  @param subview 设置可以展示view
 */
- (void)setContentViewClass:(UIView<SSNScrollHeaderContentView> *)subview;

/**
 *  结束加载过程
 */
- (void)finishedLoading;

@end


@protocol SSNScrollHeaderContentView <NSObject>

@required
/**
 *  当headerView被拉伸时回调，此回调在整个拉伸过程中都会回调
 *
 *  @param scrollHeader 当前的scrollHeader
 *  @param stretchForce 拉伸力度，[0~1](零到一)
 */
- (void)scrollHeader:(SSNScrollHeader *)scrollHeader didPullingWithStretchForce:(CGFloat)stretchForce;

@required
/**
 *  当headerView将要触发阀值时回调，此时可以开始加载动画
 *
 *  @param scrollHeader 当前的scrollHeader
 */
- (void)scrollHeaderWillTrigger:(SSNScrollHeader *)scrollHeader;

/**
 *  当headerView将被拖拽时回调，此时可以改变提示语句
 *
 *  @param scrollHeader 当前的scrollHeader
 */
- (void)scrollHeaderWillDragging:(SSNScrollHeader *)scrollHeader;

/**
 *  当headerView结束加载过程后回调，此时可以停止加载动画
 *
 *  @param scrollHeader 当前的scrollHeader
 */
- (void)scrollHeaderDidFinish:(SSNScrollHeader *)scrollHeader;

@end


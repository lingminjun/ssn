//
//  SSNScrollEdgeView.h
//  ssn
//
//  Created by lingminjun on 15/5/9.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSNScrollEdgeViewDelegate,SSNScrollEdgeContentView;

/**
 *  ScrollEdgeView状态
 */
typedef NS_ENUM(NSUInteger, SSNScrollEdgeState){
    /**
     *  常规状态
     */
    SSNScrollEdgeStill,
    /**
     *  正在拉取
     */
    SSNScrollEdgePulling,
    /**
     *  正在加载
     */
    SSNScrollEdgeLoading,
};

/**
 *  UIScrollView top or bottom edge view protocol
 *  实现下拉刷新或者加载更多等场景
 */
@interface SSNScrollEdgeView : UIView

/**
 *  触发动作委托
 */
@property (nonatomic,weak) id<SSNScrollEdgeViewDelegate> delegate;

/**
 *  阀值
 */
@property (nonatomic) CGFloat triggerHeight;

/**
 *  状态
 */
@property (nonatomic,readonly) SSNScrollEdgeState state;

/**
 *  是否在加载
 */
@property (nonatomic,readonly) BOOL isLoading;

/**
 *  背景图片
 */
@property (nonatomic,strong,readonly) UIImageView *backgroudImageView;

/**
 *  是否停用
 */
@property (nonatomic) BOOL disabled;

/**
 *  是否作用于scrollView的底部，默认为NO（即scrollView的顶部）
 */
@property (nonatomic) BOOL isBottomEdge;

/**
 *  scrollView 开始位置
 */
@property (nonatomic) CGFloat startOffset;

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
@property (nonatomic,assign) UIView<SSNScrollEdgeContentView> *contentView;

/**
 *  结束加载过程
 */
- (void)finishedLoading;

@end

/**
 *  触发委托
 */
@protocol SSNScrollEdgeViewDelegate <NSObject>

@required
/**
 *  阀值被触发回调，此时需要加载数据，加载完后调用-finishedLoading方法结束加载
 *
 *  @param scrollEdgeView 当前触发的scrollEdgeView
 */
- (void)ssn_scrollEdgeViewDidTrigger:(SSNScrollEdgeView *)scrollEdgeView;

@end

@protocol SSNScrollEdgeContentView <NSObject>

@optional
/**
 *  当scrollEdgeView被拉伸时回调，此回调在整个拉伸过程中都会回调
 *
 *  @param scrollEdgeView 当前的scrollEdgeView
 *  @param stretchForce 拉伸力度，[0~1](零到一)，实际上当手指划过整个屏幕，force也不会超过0.5
 */
- (void)scrollEdgeView:(SSNScrollEdgeView *)scrollEdgeView didPullingWithStretchForce:(CGFloat)stretchForce;

@required
/**
 *  当scrollEdgeView将要触发阀值时回调，此时可以开始加载动画
 *
 *  @param scrollEdgeView 当前的scrollEdgeView
 */
- (void)scrollEdgeViewWillTrigger:(SSNScrollEdgeView *)scrollEdgeView;

/**
 *  当scrollEdgeView将被拖拽时回调，此时可以改变提示语句
 *
 *  @param scrollEdgeView 当前的scrollEdgeView
 */
- (void)scrollEdgeViewWillDragging:(SSNScrollEdgeView *)scrollEdgeView;

/**
 *  当scrollEdgeView结束加载过程后回调，此时可以停止加载动画
 *
 *  @param scrollEdgeView 当前的scrollEdgeView
 */
- (void)scrollEdgeViewDidFinish:(SSNScrollEdgeView *)scrollEdgeView;

@end


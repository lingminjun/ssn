//
//  SSNNavigationBarAnimator.h
//  ssn
//
//  Created by lingminjun on 15/5/17.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSNNavigationBarAnimator;
@protocol SSNNavigationBarAnimatorDelegate <NSObject>

@optional
/**
 *  当scroll要隐藏或者显示导航栏时动画
 *
 *  @param animator 动画发起者
 *  @param hidden   是否隐藏导航栏
 *  @param animated 是否有动画影藏
 */
- (void)animator:(SSNNavigationBarAnimator *)animator didSetNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

/**
 *  scroll滚动时隐藏或者显示导航栏
 */
@interface SSNNavigationBarAnimator : NSObject

/**
 *  委托
 */
@property(nonatomic,weak)id<SSNNavigationBarAnimatorDelegate> delegate;

/**
 *  动画控制导航bar所拥有者——导航栏，根据targetView自动寻找，若返回nil，动画无效
 *
 *  @return 导航栏控制器
 */
- (UINavigationController *)navigationController;//用于处理导航是否要隐藏

/**
 *  当前触发动画所在的view
 */
@property(nonatomic,weak) UIView *targetView;//作用的View

/**
 *  当前触发动画所在的控制器，也是拥有targetView的控制器
 *
 *  @return 控制器
 */
- (UIViewController *)targetViewController;

/**
 *  动画是否生效
 */
@property (nonatomic) BOOL enabled;

#pragma mark 对导航栏的一些操作
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (BOOL)isNavigationBarHidden;

#pragma mark 对statusBar背景设置支持
@property (nonatomic,strong) UIColor *statusBarColor;

@property (nonatomic,strong) UIImage *statusBarImage;

@end

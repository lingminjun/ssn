//
//  SSNPageControl.h
//  ssn
//
//  Created by lingminjun on 15/5/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSNPageControl;

/**
 *  页控制器协议
 */
@protocol SSNPageControlDelegate<NSObject>

@optional
- (void)ssn_control:(SSNPageControl *)control willEnterPage:(UIView *)page atIndex:(NSUInteger)index;

- (void)ssn_control:(SSNPageControl *)control didEnterPage:(UIView *)page atIndex:(NSUInteger)index;

@end

/**
 *  页控制其，水平多页面之间切换
 */
@interface SSNPageControl : UIView

/**
 *  页面切换委托
 */
@property (nonatomic,weak) id<SSNPageControlDelegate> delegate;

/**
 *  每页的边距，默认为0
 */
@property (nonatomic) UIEdgeInsets pageInsets;

/**
 *  页数
 */
@property (nonatomic,readonly) NSUInteger pageCount;

/**
 *  是否需要弹簧效果，默认为yes
 */
@property (nonatomic) BOOL alwaysBounce;

/**
 *  唯一初始化方法
 *
 *  @param pageCount 也数
 *
 *  @return 返回实例
 */
- (instancetype)initWithPageCount:(NSUInteger)pageCount;

/**
 *  添加子view到page中
 *
 *  @param view  子view
 *  @param index 位置，越界忽略
 */
- (void)addView:(UIView *)view atIndex:(NSUInteger)index;

/**
 *  越界忽略
 *
 *  @param index 位置
 */
- (void)removeViewsAtIndex:(NSUInteger)index;

/**
 *  当前选中页所有子view
 *
 *  @param index 位置
 *
 *  @return 所有子view
 */
- (NSArray *)subviewsAtIndex:(NSUInteger)index;

/**
 *  当前选中的index
 */
@property (nonatomic) NSUInteger selectedIndex;

/**
 *  选中某个页面
 *
 *  @param index    位置
 *  @param animated 是否要动画
 */
- (void)selectIndex:(NSInteger)index animated:(BOOL)animated;

@end

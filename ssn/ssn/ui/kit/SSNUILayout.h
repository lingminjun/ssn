//
//  SSNUILayout.h
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  元素布局模型
 */
typedef NS_ENUM(NSUInteger, SSNUIContentMode){
    /**
     *  默认依赖，如果默认实际使用SSNUIContentModeTopLeft
     */
    SSNUIContentModeNan,
    /**
     *  依靠左上角
     */
    SSNUIContentModeTopLeft,
    /**
     *  依靠右上角
     */
    SSNUIContentModeTopRight,
    /**
     *  依靠左下角
     */
    SSNUIContentModeBottomLeft,
    /**
     *  依靠右下角
     */
    SSNUIContentModeBottomRight,
    /**
     *  填充
     */
    SSNUIContentModeScaleToFill,
    /**
     *  居中
     */
    SSNUIContentModeCenter,
    /**
     *  上边依靠
     */
    SSNUIContentModeTop,
    /**
     *  下边依靠
     */
    SSNUIContentModeBottom,
    /**
     *  左边依靠
     */
    SSNUIContentModeLeft,
    /**
     *  右边依靠
     */
    SSNUIContentModeRight,
};

/**
 *  布局计算方向，画布坐标系方向（x,y），注意，此处x,y与View frame的x,y有区别
 *  如果直接转动手机，看括号中的解释，始终保持坐标系x,y是从左到右，从上到下
 */
typedef NS_ENUM(NSUInteger, SSNUILayoutOrientation){
    /**
     *  正向的，x:从左到右（isReverse时从右往左），y:从上到下，（将手机正放，home键在下面，x:从左到右，y:从上到下）
     */
    SSNUILayoutOrientationPortrait           = 0,
    /**
     *  颠倒的，x:从右往左（isReverse时从左往右），y:从下到上，（将手机倒放，home键在上面，x:从左到右，y:从上到下）
     */
    SSNUILayoutOrientationPortraitUpsideDown = 1,
    /**
     *  向左的，x:从上往下（isReverse时从下往上），y:从右至左，（将手机左转放平，home键在右边，x:从左到右，y:从上到下）
     */
    SSNUILayoutOrientationLandscapeLeft      = 2,
    /**
     *  向右的，x:从下往上（isReverse时从上往下），y:从左至右，（将手机右转放平，home键在左边，x:从左到右，y:从上到下）
     */
    SSNUILayoutOrientationLandscapeRight     = 3,
};

/**
 *  布局描述，只能依附属于view存在
 */
@interface SSNUILayout : NSObject

/**
 *  返回当前layout的id
 *
 *  @return 返回layoutid
 */
- (NSString *)layoutID;

/**
 *  设置当前layout的id
 *
 *  @param layoutID 设置的id
 *
 *  @return 设置成功返回yes，设置失败返回no
 */
- (BOOL)setLayoutID:(NSString *)layoutID;

/**
 *  一个布局只能应用于一个view上面
 *
 *  @return 返回作用的view上面
 */
- (UIView *)panel;

/**
 *  所有参与此类布局的子view
 *
 *  @return 所有参与此类布局的子view @see UIView
 */
- (NSArray *)subviews;

/**
 *  获取view所在的布局对象，返回nil可能是在位置布局上也可能是不在任何布局
 *
 *  @param view 一个子view
 *
 *  @return 返回view所在的布局对象
 */
+ (SSNUILayout *)dependentLayoutWithView:(UIView *)view;

/**
 *  添加子view到此布局中，并且加入到UIView上面，已经在UIView上的子view，仅仅添加到布局，不改变它在原来UIView中的层级
 *
 *  @param view 添加子view [不允许为空]
 *  @param key  子view对应key [不允许为空]
 */
- (void)addSubview:(UIView *)view forKey:(NSString *)key;

/**
 *  增加一个子view到对应的位置上，只是布局位置上的插入，与view层级没关系
 *  已经在UIView上的子view，仅仅添加到布局，不改变它在原来UIView中的层级
 *
 *  @param view 添加子view [不允许为空]
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key  子view对应key [不允许为空]
 */
- (void)insertSubview:(UIView *)view atIndex:(NSUInteger)index forKey:(NSString *)key;

/**
 *  移动一个字view到某个位置上，只是布局位置上的移动，与view层级没关系
 *
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key   子view对应key，找不到view忽略
 */
- (void)moveSubviewToIndex:(NSUInteger)index forKey:(NSString *)key;

/**
 *  返回此布局中的subview
 *
 *  @param key subview的key
 *
 *  @return 在此布局中的subview，找不到返回nil
 */
- (UIView *)subviewForKey:(NSString *)key;

/**
 *  返回key对应subview在此布局中的位置
 *
 *  @param key subview的key
 *
 *  @return 布局中的位置，找不到时返回NSNotFound
 */
- (NSUInteger)indexForKey:(NSString *)key;

/**
 *  返回subview在此布局中的位置
 *
 *  @param subview 需要寻找的subview
 *
 *  @return 布局中的位置，找不到时返回NSNotFound
 */
- (NSUInteger)indexOfSubview:(UIView *)subview;

/**
 *  将一个子view移除此布局且从panel中移除
 *
 *  @param key 需要移除的key
 */
- (void)removeSubviewForKey:(NSString *)key;

/**
 *  将一个子view移除此布局，不从panel中移除
 *
 *  @param key 需要移除的key
 */
- (void)moveOutSubviewForKey:(NSString *)key;

/**
 *  画布边界预留值，根据不同布局模型发生起作用，默认值UIEdgeInsetsZero. 所有值需大于等于零
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) UIEdgeInsets contentInset;

/**
 *  布局计算方向，布局坐标系方向，不会旋转子view，仅仅是布局坐标方向
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) SSNUILayoutOrientation orientation;

/**
 *  布局"x"轴（行中元素反向）逆向执行
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) BOOL isRowReverse;

/**
 *  布局所有子view
 */
- (void)layoutSubviews;

/**
 *  返回此布局中的subview
 *
 *  @param key subview的key
 *
 *  @return 在此布局中的subview，找不到返回nil
 */
- (UIView *)objectForKeyedSubscript:(NSString *)key;
@end


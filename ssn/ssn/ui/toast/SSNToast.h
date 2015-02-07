//
//  SSNToast.h
//  ssn
//
//  Created by lingminjun on 15/2/5.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  toast显示位置
 */
typedef NS_ENUM(NSUInteger, SSNToastDisplayPosition){
    /** 居中显示 */
    SSNToastCenterPosition,
    /** 顶端显示 */
    SSNToastTopPosition,
    /** 底部显示 */
    SSNToastBottomPosition,
    /** 自定义位置显示，你可以通过设置displayCenter来改变位置 */
    SSNToastCustomPosition,
};

/**
 *  toast显示
 */
typedef NS_ENUM(NSUInteger, SSNToastModalStyle) {
    /** 集中显示 */
    SSNToastFocusModalStyle,
    /** 满屏显示 */
    SSNToastFullModalStyle,
};

/**
 *  显示动画
 */
typedef NS_ENUM(NSUInteger, SSNToastAnimation) {
    /** Opacity animation */
    SSNToastAnimationFade,
    /** Opacity + scale out animation */
    SSNToastAnimationZoomOut,
    /** Opacity + scale in animation */
    SSNToastAnimationZoomIn,
    /** No animation */
    SSNToastAnimationNan,
};


/**
 *  toast显示器，你永远也不要去修改其frame，因为他总是填充整个屏幕
 */
@interface SSNToast : UIView

/**
 *  显示位置
 */
@property (nonatomic,readonly) SSNToastDisplayPosition position;

/**
 *  显示内容中心点位置，当position == SSNToastCustomPosition时，位置可以被调整
 */
@property (nonatomic) CGPoint displayCenter;

/**
 *  显示内容
 */
@property (nonatomic,copy,readonly) NSString *message;

/**
 *  字体大小
 */
@property (nonatomic,copy) UIFont *font;


/**
 *  toast透明度80%，[0,1]
 */
@property (nonatomic) CGFloat opacity;

/**
 * toast颜色，默认黑色
 */
@property (nonatomic,copy) UIColor *color;

/**
 *  显示的自定义view，只要设置，就会被显示
 */
@property (nonatomic,strong) UIView *customView;

/**
 *  模态显示风格（显示前设置）
 */
@property (nonatomic) SSNToastModalStyle modalStyle;

/**
 *  是否有活动指示器
 */
@property (nonatomic,readonly) BOOL activityIndicator;

/**
 *  唯一初始化方法
 *
 *  @param target  target 赖以生存的对象，当target被释放时，toast将被销毁，可以传入nil，若传入nil表示此toast不依赖任何对象
 *  @param message 消息内容
 *  @param activityIndicator 是否有活动指示器
 *
 *  @return 返回一个toast
 */
- (instancetype)initWithTarget:(NSObject *)target message:(NSString *)message activityIndicator:(BOOL)activityIndicator;

/**
 *  工程方法
 *
 *  @param target  target 赖以生存的对象，当target被释放时，toast将被销毁，可以传入nil，若传入nil表示此toast不依赖任何对象
 *  @param message 消息内容
 *  @param activityIndicator 是否有活动指示器
 *
 *  @return 返回一个toast
 */
+ (instancetype)toastWithTarget:(NSObject *)target message:(NSString *)message activityIndicator:(BOOL)activityIndicator;

/**
 *  展示一个toast
 */
- (void)show;

/**
 *  显示
 *
 *  @param view      展示视图所在view画布，传入nil表示整个屏幕
 *  @param position  在view画布中的位置
 *  @param animation 展示动画
 */
- (void)showForView:(UIView *)view atPosition:(SSNToastDisplayPosition)position animation:(SSNToastAnimation)animation;

/**
 *  显示
 *
 *  @param rect      展示视图所在画布（rect是以[UIScreen mainScreen].bounds为坐标）
 *  @param position  在view画布中的位置
 *  @param animation 展示动画
 */
- (void)showForRect:(CGRect)rect atPosition:(SSNToastDisplayPosition)position animation:(SSNToastAnimation)animation;

/**
 *  隐藏
 *
 *  @param animated 是否与动画，
 */
- (void)hideAnimated:(BOOL)animated;

/**
 *  隐藏
 *
 *  @param animated 是否有动画
 *  @param delay    延后消失
 */
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

#pragma mark 高级方法
/**
 *  隐藏所有toast
 */
+ (void)hideAllToast;

@end


/**
 *  常使用的方法
 */
@interface SSNToast (Convenient)

#pragma mark 居中
/**
 *  显示一个居中加载等待菊花
 *
 *  @param loading 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)showProgressLoading:(NSString *)loading;

/**
 *  显示一个居中加载等待菊花
 *
 *  @param target  关联到某个对象上
 *  @param loading 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)showTarget:(NSObject *)target progressLoading:(NSString *)loading;

/**
 *  显示一秒钟的一个居中提示
 *
 *  @param message 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)awhileToastMessage:(NSString *)message;

/**
 *  显示一个居中提示
 *
 *  @param message 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)showToastMessage:(NSString *)message;


#pragma mark 黄金分割点
/**
 *  显示一个黄金分割点加载等待菊花
 *
 *  @param loading 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)showProgressLoadingAtGoldenSection:(NSString *)loading;

/**
 *  显示一个黄金分割点加载等待菊花
 *
 *  @param target  关联到某个对象上
 *  @param loading 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)showTarget:(NSObject *)target progressLoadingAtGoldenSection:(NSString *)loading;

/**
 *  显示一秒钟的一个黄金分割点提示
 *
 *  @param message 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)awhileToastMessageAtGoldenSection:(NSString *)message;

/**
 *  显示一个黄金分割点提示
 *
 *  @param message 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)showToastMessageAtGoldenSection:(NSString *)message;
@end

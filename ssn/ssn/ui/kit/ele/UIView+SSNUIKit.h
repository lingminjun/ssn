//
//  UIView+SSNUIKit.h
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const SSNUIThemeChangedNotification;//主题变化通知
UIKIT_EXTERN NSString *const SSNUIThemeUserInfoKey;//NSDictionary主题包

/**
 *  主题更换协议，所有视觉元素可以参照此协议来更换其视觉
 */
@protocol SSNUIThemeChangeProtocol

/**
 *  是否应用主题控制，默认不开启
 */
@property (nonatomic) BOOL ssn_enableTheme;

/**
 *  被更改主题包
 *
 *  @param themeInfo 主题包种包含各种主题的key，可以根据需要取值，主题包由各自产品定义，大体分类为文体大小，文字颜色，背景色，尺寸，以及图标等等
 */
- (void)ssn_themeDidChange:(NSDictionary *)themeInfo;

@end

/**
 *  主题控制
 */
@interface UIView (SSNUIKit)<SSNUIThemeChangeProtocol>

/**
 *  设置主题
 *
 *  @param themeInfo 主题包
 */
+ (void)ssn_setTheme:(NSDictionary *)themeInfo;


/**
 *  重新改变尺寸
 */
- (void)ssn_sizeToFit;

@end


#define ssn_uikit_value_synthesize(type,get,set) _ssn_uikit_value_synthesize_(type,get,set)
#define ssn_uikit_obj_synthesize(type,get,set) _ssn_uikit_obj_synthesize_(type,get,set)

#define _ssn_uikit_value_synthesize_(t,g,s) \
static char * g ## _key = NULL;\
- (t) g { \
    NSNumber *v = objc_getAssociatedObject(self, &(g ## _key)); \
    return [v t ## Value ]; \
} \
- (void) set ## s :(t) g { \
    objc_setAssociatedObject(self, &(g ## _key), @( g ), OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
}

#define _ssn_uikit_obj_synthesize_(type,get,set) \
static char * g ## _key = NULL;\
- (t) g { \
    return objc_getAssociatedObject(self, &(g ## _key)); \
} \
- (void) set ## s :(t) g { \
    objc_setAssociatedObject(self, &(g ## _key), ( g ), OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
}

#if defined(__LP64__) && __LP64__
# define ssn_ceil(value) ceil(value)
# define ssn_floor(value) floor(value)
#else
# define ssn_ceil(value) ceilf(value)
# define ssn_floor(value) floorf(value)
#endif

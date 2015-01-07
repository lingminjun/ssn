//
//  UIView+SSNUIKit.m
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIView+SSNUIKit.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

NSString *const SSNUIThemeChangedNotification = @"SSNUIThemeChangedNotification";//主题变化通知
NSString *const SSNUIThemeUserInfoKey         = @"SSNUIThemeUserInfoKey";//NSDictionary主题包

/**
 *  主题切换执行
 */
@interface SSNUIThemeHandler : NSObject
@property (nonatomic,weak) UIView *view;
@end

@implementation SSNUIThemeHandler

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themeChangedNotification:)
                                                     name:SSNUIThemeChangedNotification
                                                   object:nil];
        _view = view;
    }
    return self;
}

- (void)themeChangedNotification:(NSNotification *)notification {
    NSDictionary *theme = [[notification userInfo] objectForKey:SSNUIThemeUserInfoKey];
    [_view ssn_themeDidChange:theme];
}

@end

@implementation UIView (SSNUIKit)

static char *ssn_uikit_enable_theme_key = NULL;
- (BOOL)ssn_enableTheme {
    SSNUIThemeHandler *handler = objc_getAssociatedObject(self, &ssn_uikit_enable_theme_key);
    return handler != nil;
}

- (void)setSsn_enableTheme:(BOOL)enable {
    SSNUIThemeHandler *handler = objc_getAssociatedObject(self, &ssn_uikit_enable_theme_key);
    if ((enable && handler != nil)
        || (!enable && handler == nil)) {
        return ;
    }
    
    if (enable) {
        handler = [[SSNUIThemeHandler alloc] initWithView:self];
    }
    else {
        handler = nil;
    }
    
    objc_setAssociatedObject(self, &ssn_uikit_enable_theme_key, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 *  被更改主题包
 *
 *  @param themeInfo 主题包种包含各种主题的key，可以根据需要取值，主题包由各自产品定义，大体分类为文体大小，文字颜色，背景色，尺寸，以及图标等等
 */
- (void)ssn_themeDidChange:(NSDictionary *)themeInfo {
}

/**
 *  设置主题
 *
 *  @param themeInfo 主题包
 */
+ (void)ssn_setTheme:(NSDictionary *)themeInfo {
    if (themeInfo) {
        NSDictionary *info = @{ SSNUIThemeUserInfoKey:themeInfo };
        [[NSNotificationCenter defaultCenter] postNotificationName:SSNUIThemeChangedNotification object:nil userInfo:info];
    }
}

/**
 *  重新改变尺寸
 */
- (void)ssn_sizeToFit {
    
}

@end

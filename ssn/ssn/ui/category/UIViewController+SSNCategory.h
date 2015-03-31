//
//  UIViewController+SSNCategory.h
//  ssn
//
//  Created by lingminjun on 15/3/29.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+SSNUIHex.h"

#define SSN_NAV_BAR_BACK_BUTTON_IMAGE   [UIImage imageNamed:@"com_nav_back"]
#define SSN_NAV_BAR_BUTTON_FONT         [UIFont systemFontOfSize:15]

#define SSN_NAV_BAR_BUTTON_TITLE_COLOR_NORMAL         [UIColor blackColor]
#define SSN_NAV_BAR_BUTTON_TITLE_COLOR_DISABLED       [UIColor ssn_colorWithHex:0xCCCCCC]
#define SSN_NAV_BAR_BUTTON_TITLE_COLOR_SELECTED       [UIColor ssn_colorWithHex:0x989898]

@interface UIViewController (SSNCategory)

//重置返回按钮
- (void)ssn_resetBackButtonItemWithTitle:(NSString *)title action:(SEL)action;

//添加导航左边按钮
- (void)ssn_addLeftButtonItemWithTitle:(NSString *)title action:(SEL)action;

//添加导航右边按钮
- (void)ssn_addRightButtonItemWithTitle:(NSString *)title action:(SEL)action;

//添加导航左边按钮
- (void)ssn_addLeftButtonItemWithImageName:(NSString *)imageName action:(SEL)action;

//添加导航右边按钮
- (void)ssn_addRightButtonItemWithImageName:(NSString *)imageName action:(SEL)action;

@end

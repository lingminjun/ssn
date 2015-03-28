//
//  UIViewController+SSNToast.h
//  ssn
//
//  Created by lingminjun on 15/3/28.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNToast.h"

@interface UIViewController (SSNToast)

@property (nonatomic,strong) SSNToast *ssn_toast;

- (void)ssn_showToast:(NSString *)message;//显示一条toast消息，默认在黄金分割点显示

- (void)ssn_loadingToast:(NSString *)message;//加载一条toast loading，默认在黄金分割点显示

- (void)ssn_hideToast;//隐藏toast

@end

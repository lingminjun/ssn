//
//  UIViewController+SSNToast.m
//  ssn
//
//  Created by lingminjun on 15/3/28.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIViewController+SSNToast.h"

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif


@implementation UIViewController (SSNToast)

static char *ssn_toast_key = NULL;
- (SSNToast *)ssn_toast {
    return  objc_getAssociatedObject(self, &ssn_toast_key);
}

- (void)setSsn_toast:(SSNToast *)ssn_toast {
    
    SSNToast *old = [self ssn_toast];
    if (old) {
        [old hideAnimated:NO];
    }
    
    objc_setAssociatedObject(self, &ssn_toast_key, ssn_toast, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ssn_showToast:(NSString *)message {
    [SSNToast awhileToastMessageAtGoldenSection:message];
}

- (void)ssn_loadingToast:(NSString *)message {
    self.ssn_toast = [SSNToast awhileToastMessageAtGoldenSection:message];
}

- (void)ssn_hideToast {
    [self.ssn_toast hideAnimated:YES];
    self.ssn_toast = nil;
}

@end

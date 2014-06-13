//
//  NavigationQueueController.h
//  Routable
//
//  Created by lingminjun on 14-6-10.
//  Copyright (c) 2014年 TurboProp Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationQueueController : UINavigationController

- (void)setNavigationDelegate:(id<UINavigationControllerDelegate>)navigationDelegate;

- (id<UINavigationControllerDelegate>)navigationDelegate;

@end

//
//  SSNVC+Router.h
//  ssn
//
//  Created by lingminjun on 14-7-27.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNPage.h"


@interface UIWindow (SSNRouter) <SSNParentPage>
@end


@interface UIViewController (SSNRouter) <SSNParentPage>
@end


@interface UINavigationController (SSNRouter) <SSNParentPage>
@end


@interface UITabBarController (SSNRouter) <SSNParentPage>
@end




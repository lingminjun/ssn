//
//  SSNVC+Router.m
//  ssn
//
//  Created by lingminjun on 14-7-27.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNVC+Router.h"

@implementation UIWindow (SSNRouter)

- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query
{
    return YES;
}

- (id<SSNParentPage>)ssn_parentPage
{
    return nil;
}

//如果要自己定义父控制器，一定要实现此方法
- (NSArray *)ssn_containedPages
{
    NSMutableArray *pages = [NSMutableArray arrayWithCapacity:1];
    if (self.rootViewController)
    {
        [pages addObject:self.rootViewController];
    }
    return pages;
}

//最外层
- (id<SSNPage>)ssn_topPage
{
    id<SSNPage> page = self.rootViewController;
    if ([page respondsToSelector:@selector(ssn_topPage)])
    {
        return [(id<SSNParentPage>)page ssn_topPage];
    }
    return page;
}

//具体打开子页面方法
- (BOOL)ssn_openPage:(id<SSNPage>)page query:(NSDictionary *)query animated:(BOOL)animated
{

    if ([page isKindOfClass:[UIViewController class]])
    {

        UIViewController *vc = (UIViewController *)page;
        //[self addSubview:vc.view];

        //第一个被赋值到rootvc上
        if (self.rootViewController != vc)
        {
            self.rootViewController = vc;
        }

        [self makeKeyAndVisible];

        return YES;
    }

    if ([page isKindOfClass:[UIView class]])
    {
        UIView *v = (UIView *)page;
        [self addSubview:v];
        return YES;
    }

    return NO;
}

//子页面返回
- (void)ssn_pageBack
{
    id<SSNPage> page = [self ssn_topPage];
    [[page ssn_parentPage] ssn_pageBack];
}

@end

@implementation UIViewController (SSNRouter)

- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query
{
    return NO;
}

- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query
{
    self.title = [query objectForKey:@"title"];
}

- (id<SSNParentPage>)ssn_parentPage
{
    if (self.presentingViewController)
    {
        return (id<SSNParentPage>)self.presentingViewController;
    }
    return (id<SSNParentPage>)self.parentViewController;
}

- (id<SSNPage>)ssn_topPage
{
    id<SSNPage> page = self.presentedViewController;
    if ([page respondsToSelector:@selector(ssn_topPage)])
    {
        return [(id<SSNParentPage>)page ssn_topPage];
    }
    return page;
}

- (NSArray *)ssn_containedPages
{
    NSMutableArray *pages = [NSMutableArray arrayWithCapacity:1];
    if (self.presentedViewController)
    {
        [pages addObject:self.presentedViewController];
    }
    return pages;
}

- (BOOL)ssn_openPage:(id<SSNPage>)page query:(NSDictionary *)query animated:(BOOL)animated
{
    if ([page isKindOfClass:[UIViewController class]])
    {

        BOOL isModal = [[query objectForKey:@"isModal"] boolValue];

        if (isModal && nil == self.presentedViewController)
        { //已经存在，只能返回NO
            [self presentViewController:(UIViewController *)page animated:animated completion:nil];
            return YES;
        }

        return NO;
    }

    if ([page isKindOfClass:[UIView class]])
    {
        [self.view addSubview:(UIView *)page];
        return YES;
    }

    return NO;
}

- (void)ssn_pageBack
{
    if (self.presentedViewController)
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end

@implementation UINavigationController (SSNRouter)

- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query
{
    return YES;
}

- (NSArray *)ssn_containedPages
{
    NSMutableArray *pages = [NSMutableArray arrayWithCapacity:1];
    NSArray *vcs = self.viewControllers;
    if (vcs)
    {
        [pages setArray:vcs];
    }

    if (self.presentedViewController)
    {
        [pages addObject:self.presentedViewController];
    }
    return pages;
}

- (id<SSNPage>)ssn_topPage
{

    id<SSNPage> page = nil;
    if (self.presentedViewController)
    {
        page = self.presentedViewController;
    }
    else
    {
        page = [self.viewControllers lastObject];
    }
    if ([page respondsToSelector:@selector(ssn_topPage)])
    {
        return [(id<SSNParentPage>)page ssn_topPage];
    }
    return page;
}

- (BOOL)ssn_openPage:(id<SSNPage>)page query:(NSDictionary *)query animated:(BOOL)animated
{

    if (![page isKindOfClass:[UIViewController class]])
    {
        return NO;
    }

    BOOL isModal = [[query objectForKey:@"isModal"] boolValue];
    if (isModal)
    {
        return [super ssn_openPage:page query:query animated:animated];
    }

    UIViewController *vc = (UIViewController *)page;

    NSArray *vcs = self.viewControllers;

    BOOL root = [[query objectForKey:@"root"] boolValue];
    if (root)
    {
        if ([vcs count])
        {
            if ([vcs objectAtIndex:0] == vc)
            {
                return YES;
            }
        }

        [self setViewControllers:[NSArray arrayWithObject:vc] animated:animated];

        return YES;
    }

    if ([vcs containsObject:vc])
    {
        [self popToViewController:vc animated:animated];
    }
    else
    {
        [self pushViewController:vc animated:animated];
    }

    return YES;
}

- (void)ssn_pageBack
{

    if (self.presentedViewController)
    {
        [super ssn_pageBack];
        return;
    }

    [self popViewControllerAnimated:YES];
}

@end

@implementation UITabBarController (SSNRouter)

- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query
{
    return YES;
}

- (NSArray *)ssn_containedPages
{
    NSMutableArray *pages = [NSMutableArray arrayWithCapacity:1];
    NSArray *vcs = self.viewControllers;
    if (vcs)
    {
        [pages setArray:vcs];
    }

    if (self.presentedViewController)
    {
        [pages addObject:self.presentedViewController];
    }
    return pages;
}

- (id<SSNPage>)ssn_topPage
{

    id<SSNPage> page = nil;
    if (self.presentedViewController)
    {
        page = self.presentedViewController;
    }
    else
    {
        page = self.selectedViewController;
    }
    if ([page respondsToSelector:@selector(ssn_topPage)])
    {
        return [(id<SSNParentPage>)page ssn_topPage];
    }
    return page;
}

- (BOOL)ssn_openPage:(id<SSNPage>)page query:(NSDictionary *)query animated:(BOOL)animated
{
    if (![page isKindOfClass:[UIViewController class]])
    {
        return NO;
    }

    UIViewController *vc = (UIViewController *)page;

    BOOL isModal = [[query objectForKey:@"isModal"] boolValue];
    if (isModal)
    {
        return [super ssn_openPage:page query:query animated:animated];
    }

    //回退其他栈
    UIViewController *old_vc = self.selectedViewController;
    if (old_vc != vc && [old_vc isKindOfClass:[UINavigationController class]])
    {
        [(UINavigationController *)old_vc popToRootViewControllerAnimated:NO];
    }

    NSArray *vcs = self.viewControllers;

    if (![vcs containsObject:vc])
    {
        NSMutableArray *tvcs = [NSMutableArray arrayWithCapacity:1];
        if (vcs)
        {
            [tvcs setArray:vcs];
        }
        [tvcs addObject:vc];
        [self setViewControllers:tvcs];
    }

    self.selectedViewController = vc;

    return YES;
}

- (void)ssn_pageBack
{
    if (self.presentedViewController)
    {
        [super ssn_pageBack];
        return;
    }
}

@end

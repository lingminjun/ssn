//
//  AppDelegate.m
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "AppDelegate.h"
#import "SSNRouter.h"

#import "DMSignNavController.h"
#import "DMSignViewController.h"
#import "DMTabViewController.h"
#import "DMContactNavController.h"
#import "DMContactViewController.h"
#import "DMSessionNavController.h"
#import "DMSessionViewController.h"
#import "DMSettingNavController.h"
#import "DMSettingViewController.h"

@interface AppDelegate ()<SSNRouterDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self.router setScheme:@"app"];

    [self.router addComponent:@"sign" pageClass:[DMSignNavController class]];
    [self.router addComponent:@"signin" pageClass:[DMSignViewController class]];
    [self.router addComponent:@"main" pageClass:[DMTabViewController class]];
    [self.router addComponent:@"session" pageClass:[DMContactNavController class]];
    [self.router addComponent:@"chat" pageClass:[DMContactViewController class]];
    [self.router addComponent:@"contact" pageClass:[DMSessionNavController class]];
    [self.router addComponent:@"friend" pageClass:[DMSessionViewController class]];
    [self.router addComponent:@"confige" pageClass:[DMSettingNavController class]];
    [self.router addComponent:@"setting" pageClass:[DMSettingViewController class]];

    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    [self router].delegate = self;
    [self router].window = self.window;

    BOOL isSingin = NO;
    if (isSingin)
    {
        [self.router openURL:[NSURL URLWithString:@"app://default"]]; //转到重定向中加载ui
    }
    else
    {
        [self.router openURL:[NSURL URLWithString:@"app://login"]]; //转到重定向中加载ui
    }

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of
    // temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use
    // this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application
    // state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate:
    // when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes
    // made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application
    // was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also
    // applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotatio {
    
    return [self.router openURL:url];
}

#pragma mark open url delegate
- (NSURL *)router:(SSNRouter *)router redirectURL:(NSURL *)url query:(NSDictionary *)query
{
    if ([url.absoluteString isEqualToString:@"app://login"])
    {
        [self.router openURL:[NSURL URLWithString:@"app://sign"]];

        return [NSURL URLWithString:@"app://sign/signin"];
    }
    else if ([url.absoluteString isEqualToString:@"app://default"])
    {
        //不能按照路径创建目录，必须一级一级创建
        [self.router openURL:[NSURL URLWithString:@"app://main"]];

        [self.router openURL:[NSURL URLWithString:@"app://main/session"]];
        [self.router openURL:[NSURL URLWithString:@"app://main/session/chat"]];

        [self.router openURL:[NSURL URLWithString:@"app://main/contact"]];
        [self.router openURL:[NSURL URLWithString:@"app://main/contact/friend"]];

        [self.router openURL:[NSURL URLWithString:@"app://main/confige"]];
        [self.router openURL:[NSURL URLWithString:@"app://main/confige/setting"]];

        return [NSURL URLWithString:@"app://main/session/chat"];
    }
    return nil;
}

@end

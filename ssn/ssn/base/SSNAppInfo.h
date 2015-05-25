//
//  SSNAppInfo.h
//  ssn
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNAppInfo : NSObject

/**
 *  获取当前app名字
 *
 *  @return app名字
 */
+ (NSString *)appName;

/**
 *  获取当前app名字
 *
 *  @return app名字
 */
+ (NSString *)appLocalizedName;

/**
 *  返回app版本，如：1.0.0
 *
 *  @return app版本
 */
+ (NSString *)appVersion;

/**
 *  返回app辅助版本号，流水号
 *
 *  @return app的流水版本号
 */
+ (NSString *)appBuildNumber;


/**
 *  完整版本号 appVersion.appBuildNumber
 *
 *  @return 完整版本号
 */
+ (NSString *)appWholeVersion;

/**
 *  最后一次启动的版本号，返回的是whole version
 *
 *  @return 范湖最后一次启动版本号
 */
+ (NSString *)latestLaunchAppVersion;

/**
 *  更新下启动版本，既将最新的WholeVersion更新到永久化中
 */
+ (void)updateLaunchAppVersion;

/**
 *  app的BundleId
 *
 *  @return app的BundleId
 */
+ (NSString *)appBundleId;

/**
 *  客户端型号
 *
 *  @return 客户端型号
 */
+ (NSString *)userAgent;

/**
 *  设备版本号
 *
 *  @return 设备版本号
 */
+ (NSString *)device;

@end

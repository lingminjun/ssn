//
//  SSNAppInfo.m
//  ssn
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNAppInfo.h"
#import "sys/utsname.h"

NSString *const kAppBuildVersion = @"CFBundleShortVersionString";
NSString *const kAppBuildNumber = @"CFBundleVersion";
NSString *const kAppBuildName = @"CFBundleDisplayName";

NSString *const kAppLaunchVersion = @"AppLaunchVersion";

@implementation SSNAppInfo

+ (NSString *)appName
{
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:kAppBuildName];;
    return bundleName;
}

/**
 *  获取当前app名字
 *
 *  @return app名字
 */
+ (NSString *)appLocalizedName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:kAppBuildName];
}

+ (NSString *)appVersion
{
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:kAppBuildVersion];
    return bundleVersion;
}


+ (NSString *)appBuildNumber
{
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:kAppBuildNumber];
    return buildNumber;
}

+ (NSString *)appWholeVersion
{
    NSString *appVersion = [self appVersion];
    NSString *buildNumber = [self appBuildNumber];
    NSString *fullVersion = [NSString stringWithFormat:@"%@.%@", appVersion, buildNumber];
    return fullVersion;
}

+ (NSString *)latestLaunchAppVersion {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    return [defs stringForKey:kAppLaunchVersion];
}

+ (void)updateLaunchAppVersion {
    NSString *wholeVersion = [self appWholeVersion];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:wholeVersion forKey:kAppLaunchVersion];
    [defs synchronize];
}

+ (NSString *)appBundleId
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return bundleIdentifier;
}

+ (NSString *)userAgent
{
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceName = [device model];
    NSString *OSName = [device systemName];
    NSString *OSVersion = [device systemVersion];
    NSString *appVersion = [self appVersion];
    NSString *buildNumber = [self appBuildNumber];
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSString *UA = [NSString stringWithFormat:@"iOS %@ rv:%@ (%@; %@ %@; %@)", appVersion, buildNumber, deviceName,
                    OSName, OSVersion, locale];
    return UA;
}


+ (NSString *)device
{
    
    // 需要#import "sys/utsname.h"
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone1G";
    
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone3G";
    
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone3GS";
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone4";
    
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone4";
    
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone4S";
    
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone5";
    
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone5S";
    
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone5S";
    
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone6Plus";
    
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone6";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch1";
    
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch2";
    
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch3";
    
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch4";
    
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch5";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad1";
    
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad2(WiFi)";
    
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad2(GSM)";
    
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad2(CDMA)";
    
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad2(32nm)";
    
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini(WiFi)";
    
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini(GSM)";
    
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini(CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad3(WiFi)";
    
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad3(CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad3(GSM)";
    
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad4(WiFi)";
    
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad4(GSM)";
    
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad4(CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,7"])      return @"iPad4(CDMA)";
    
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air(WiFi)";
    
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini2(WiFi)";
    
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini3(WiFi)";
    
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini3(LTE)";
    
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air2(WiFi)";
    
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air2(LTE)";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    
    return deviceString;
    
}

@end

//
//  SSNCrashReport.h
//  ssn
//
//  Created by lingminjun on 15/1/21.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNCrashReport : NSObject

+ (void)launchExceptionHandler;//启动

+ (BOOL)hasCrashLog;//是否存在crash日志

+ (void)reportCrash;//报告异常

+ (NSUncaughtExceptionHandler*)getHandler;

@end

//
//  SSNLogger.h
//  ssn
//
//  Created by lingminjun on 14/12/2.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>


#define SSN_LOG_MACRO(level, fmt, ...)          [[SSNLogger sharedInstance] log:level format:(fmt), ##__VA_ARGS__]

#define SSNLog(fmt, ...)                        SSN_LOG_MACRO(SSNInfoLogger, fmt, ##__VA_ARGS__)

#define SSNLogWarn(fmt, ...)                    SSN_LOG_MACRO(SSNWarningLogger,fmt, ##__VA_ARGS__)

#define SSNLogError(fmt, ...)             SSN_LOG_MACRO(SSNErrorLogger, fmt, ##__VA_ARGS__)

#define SSNLogVerbose(fmt, ...)           SSN_LOG_MACRO(SSNVerboseLogger, fmt, ##__VA_ARGS__)


typedef enum : NSUInteger {
    SSNInfoLogger           = 0,//提示日志（不写文件）
    SSNWarningLogger        = 1,//警告日志（不写入文件）
    SSNErrorLogger          = 2,//错误日志（写文件）
    SSNVerboseLogger        = 3,//详细日志（写文件）
} SSNLoggerLevel;

/**
 *  日志记录，仅仅提供简单地以行为单位的日志记录（）
 *  日志文件存放在:Documents/log或者Library/Caches/log中
 */
@interface SSNLogger : NSObject

/**
 *  在Library/Caches/ssnlog/_ssn_default_下写日志，
 *  @retaurn 对应Library/Caches/ssnlog/_ssn_default_下的日志目录
 */
+ (instancetype)sharedInstance;

/**
 *  在Library/Caches/ssnlog/[scope]下写日志，不建议使用此方法
 *  @param scope 日志级别
 *  @retaurn 对应Library/Caches/ssnlog/[scope]下的日志目录
 */
+ (instancetype)loggerWithScope:(NSString *)scope;

/**
 *  在Library/Caches/ssnlog下写日志
 *  @param level 日志级别
 *  @param format 日志format
 */
- (void)log:(SSNLoggerLevel)level format:(NSString *)format, ...;

/**
 *  在Documents/ssnlog下写日志，不建议使用此方法
 *  @param level 日志级别
 *  @param format 日志format
 */
//- (void)focuslog:(SSNLoggerLevel)level format:(NSString *)format, ...;


@end

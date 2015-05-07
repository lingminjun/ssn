//
//  ssnbase.h
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef ssn_ssnbase_h
#define ssn_ssnbase_h

#import <Foundation/Foundation.h>


#import <sys/time.h>
//#import <time.h>

#if DEBUG
#define ssn_log(s, ...) printf(s, ##__VA_ARGS__)
#else
#define ssn_log(s, ...) ((void)0)
#endif


FOUNDATION_EXTERN long long ssn_sec_timestamp();//当前时间戳（utc时间 秒）
FOUNDATION_EXTERN long long ssn_usec_timestamp();//当前时间戳（utc时间 毫秒）

#if DEBUG
#define ssn_time_track_begin(t)                                                                                        \
    struct timeval _##t##_b_tv;                                                                                           \
    gettimeofday(&_##t##_b_tv, NULL);

#define ssn_time_track_end(t)                                                                                          \
    struct timeval _##t##_e_tv;                                                                                           \
    gettimeofday(&_##t##_e_tv, NULL);                                                                                     \
    long long _##t##_time = (_##t##_e_tv.tv_sec - _##t##_b_tv.tv_sec) * USEC_PER_SEC + (_##t##_e_tv.tv_usec - _##t##_b_tv.tv_usec);      \
    ssn_log("\n%s lost time is:\t%lld(us)\n", #t, _##t##_time);

#define ssn_time_track_balance(t, in)                                                                                  \
    struct timeval _##t##_e_tv;                                                                                           \
    gettimeofday(&_##t##_e_tv, NULL);                                                                                     \
    long long _##t##_time = (_##t##_e_tv.tv_sec - _##t##_b_tv.tv_sec) * USEC_PER_SEC + (_##t##_e_tv.tv_usec - _##t##_b_tv.tv_usec);      \
    in += _##t##_time;                                                                                                    \
    ssn_log("\n%s lost time is:\t%lld(us)\n", #t, _##t##_time);

#include <mach/mach_time.h>

FOUNDATION_EXPORT double ssn_orwl_timebase;
FOUNDATION_EXPORT uint64_t ssn_orwl_timestart;

FOUNDATION_EXTERN struct timespec ssn_orwl_gettime(void);

#define ssn_ntime_track_begin(t) struct timespec _##t##_b_tv = ssn_orwl_gettime();

#define ssn_ntime_track_end(t)                                                                                         \
    struct timespec _##t##_e_tv = ssn_orwl_gettime();                                                                     \
    long long _##t##_time = (_##t##_e_tv.tv_sec - _##t##_b_tv.tv_sec) * NSEC_PER_SEC + (_##t##_e_tv.tv_nsec - _##t##_b_tv.tv_nsec);   \
    ssn_log("\n%s lost time is:\t%lld(ns)\n", #t, _##t##_time);

#define ssn_ntime_track_balance(t, in)                                                                                 \
    struct timespec _##t##_e_tv = ssn_orwl_gettime();                                                                     \
    long long _##t##_time = (_##t##_e_tv.tv_sec - _##t##_b_tv.tv_sec) * NSEC_PER_SEC + (_##t##_e_tv.tv_nsec - _##t##_b_tv.tv_nsec);   \
    in += _##t##_time;                                                                                                    \
    ssn_log("\n%s lost time is:\t%lld(ns)\n", #t, _##t##_time);

#else
#define ssn_time_track_begin(t)
#define ssn_time_track_end(t)
#define ssn_time_track_balance(t, in)
#define ssn_ntime_track_begin(t)
#define ssn_ntime_track_end(t)
#define ssn_ntime_track_balance(t, in)
#endif

//文件引入
#import "NSObject+SSN.h"
#import "NSData+SSN.h"
#import "NSString+SSN.h"
#import "NSData+SSNBase64.h"
#import "NSFileManager+SSN.h"
#import "NSNotificationCenter+SSN.h"
#import "NSObject+SSNBlock.h"
#import "NSThread+SSN.h"
#import "NSRunLoop+SSN.h"
#import "NSURL+SSN.h"

#import "SSNCuteSerialQueue.h"
#import "SSNRigidCache.h"

#import "SSNSafeSet.h"
#import "SSNSafeArray.h"
#import "SSNSafeDictionary.h"

#import "SSNSeqGen.h"
#import "SSNMessageInterceptor.h"

#endif

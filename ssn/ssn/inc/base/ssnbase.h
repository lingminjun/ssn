//
//  ssnbase.h
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef ssn_ssnbase_h
#define ssn_ssnbase_h

#import "NSString+SSN.h"

#import <sys/time.h>
//#import <time.h>

#if DEBUG
#define ssn_log(s, ...) printf(s, ##__VA_ARGS__)
#else
#define ssn_log(s, ...) ((void)0)
#endif

#if DEBUG
#define ssn_time_track_begin(t)                                                                                        \
    struct timeval t##_b_tv;                                                                                           \
    gettimeofday(&t##_b_tv, NULL);

#define ssn_time_track_end(t)                                                                                          \
    struct timeval t##_e_tv;                                                                                           \
    gettimeofday(&t##_e_tv, NULL);                                                                                     \
    long long t##_time = (t##_e_tv.tv_sec - t##_b_tv.tv_sec) * USEC_PER_SEC + (t##_e_tv.tv_usec - t##_b_tv.tv_usec);      \
    ssn_log("\n%s lost time is:\t%lld(us)\n", #t, t##_time);

#define ssn_time_track_balance(t, in)                                                                                  \
    struct timeval t##_e_tv;                                                                                           \
    gettimeofday(&t##_e_tv, NULL);                                                                                     \
    long long t##_time = (t##_e_tv.tv_sec - t##_b_tv.tv_sec) * USEC_PER_SEC + (t##_e_tv.tv_usec - t##_b_tv.tv_usec);      \
    in += t##_time;                                                                                                    \
    ssn_log("\n%s lost time is:\t%lld(us)\n", #t, t##_time);

#include <mach/mach_time.h>
#define ORWL_NANO (+1.0E-9)
#define ORWL_GIGA UINT64_C(1000000000)

static double ssn_orwl_timebase = 0.0;
static uint64_t ssn_orwl_timestart = 0;

static struct timespec ssn_orwl_gettime(void)
{
    // be more careful in a multithreaded environement
    if (!ssn_orwl_timestart)
    {
        mach_timebase_info_data_t tb = {0};
        mach_timebase_info(&tb);
        ssn_orwl_timebase = tb.numer;
        ssn_orwl_timebase /= tb.denom;
        ssn_orwl_timestart = mach_absolute_time();
    }
    struct timespec t;
    double diff = (mach_absolute_time() - ssn_orwl_timestart) * ssn_orwl_timebase;
    t.tv_sec = diff * ORWL_NANO;
    t.tv_nsec = diff - (t.tv_sec * ORWL_GIGA);
    return t;
}

#define ssn_ntime_track_begin(t) struct timespec t##_b_tv = ssn_orwl_gettime();

#define ssn_ntime_track_end(t)                                                                                         \
    struct timespec t##_e_tv = ssn_orwl_gettime();                                                                     \
    long long t##_time = (t##_e_tv.tv_sec - t##_b_tv.tv_sec) * NSEC_PER_SEC + (t##_e_tv.tv_nsec - t##_b_tv.tv_nsec);   \
    ssn_log("\n%s lost time is:\t%lld(ns)\n", #t, t##_time);

#define ssn_ntime_track_balance(t, in)                                                                                 \
    struct timespec t##_e_tv = ssn_orwl_gettime();                                                                     \
    long long t##_time = (t##_e_tv.tv_sec - t##_b_tv.tv_sec) * NSEC_PER_SEC + (t##_e_tv.tv_nsec - t##_b_tv.tv_nsec);   \
    in += t##_time;                                                                                                    \
    ssn_log("\n%s lost time is:\t%lld(ns)\n", #t, t##_time);

#else
#define ssn_time_track_begin(t)
#define ssn_time_track_end(t)
#define ssn_time_track_balance(t, in)
#define ssn_ntime_track_begin(t)
#define ssn_ntime_track_end(t)
#define ssn_ntime_track_balance(t, in)
#endif

#import "SSNRigidCache.h"

#endif

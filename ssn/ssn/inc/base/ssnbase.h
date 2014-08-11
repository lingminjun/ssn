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
    long long t##_time = (t##_e_tv.tv_sec - t##_b_tv.tv_sec) * 1000000 + (t##_e_tv.tv_usec - t##_b_tv.tv_usec);        \
    ssn_log("\n%s lost time is:\t%lld(us)\n", #t, t##_time);
#else
#define ssn_time_track_begin(t)
#define ssn_time_track_end(t)
#endif

#import "SSNRigidDictionary.h"

#endif

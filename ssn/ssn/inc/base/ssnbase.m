//
//  ssnbase.c
//  ssn
//
//  Created by lingminjun on 14-11-19.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "ssnbase.h"
#include <mach/mach_time.h>

#define ORWL_NANO (+1.0E-9)
#define ORWL_GIGA UINT64_C(1000000000)

double ssn_orwl_timebase = 0.0f;
uint64_t ssn_orwl_timestart = 0;

struct timespec ssn_orwl_gettime(void)
{
    // be more careful in a multithreaded environement
    if (!ssn_orwl_timestart)
    {
        mach_timebase_info_data_t tb = {0,0};
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

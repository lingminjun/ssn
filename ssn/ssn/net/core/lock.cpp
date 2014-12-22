//
//  lock.cpp
//  ssn
//
//  Created by lingminjun on 14-8-19.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "lock.h"

namespace ssn
{
void unlock_glock(void *pArg)
{
    pthread_mutex_t *mutex = (pthread_mutex_t *)pArg;
    pthread_mutex_unlock(mutex);
    printf("unlock_glock.");
}

void delay_time_spec(const uint64_t &delay_misc, struct timespec &ts)
{
    struct timeval now;
    gettimeofday(&now, NULL);

    ts.tv_sec = now.tv_sec;
    ts.tv_nsec = now.tv_usec;

    ts.tv_sec += delay_misc / 1000;
    long cur_misc = ts.tv_nsec / 1000000;
    long tmp_misc = cur_misc + delay_misc % 1000;
    ts.tv_sec += tmp_misc / 1000;
    ts.tv_nsec = (tmp_misc % 1000) * 1000000;
}
}

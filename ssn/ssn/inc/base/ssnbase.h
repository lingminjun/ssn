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


#define SSNBeginTrackTime(t)   \
struct timeval t ## _b_tv;\
gettimeofday(& t ## _b_tv,NULL);

#define SSNEndTrackTime(t)     \
struct timeval t ## _e_tv;\
gettimeofday(& t ## _e_tv,NULL);\
long long t ##_time = (t ## _e_tv.tv_sec - t ## _b_tv.tv_sec) * 1000000 + (t ## _e_tv.tv_usec - t ## _b_tv.tv_usec);\
printf("\n%s lost time is:\t%lld(us)\n", #t ,t ##_time);


#endif

//
//  SSNPerformance.h
//  ssn
//
//  Created by lingminjun on 14-11-17.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef ssn_Performancedd_h
#define ssn_Performancedd_h

#if defined(__cplusplus)
#define SSN_C_EXTERN extern "C"
#else
#define SSN_C_EXTERN extern
#endif

SSN_C_EXTERN double ssn_current_cpu_usage(void);//当前进程cpu占有率

SSN_C_EXTERN double ssn_current_thread_cpu_usage(void);//当前线程cpu占有率

SSN_C_EXTERN double ssn_current_thread_memory_usage(void);//当前进程内存占有率


#endif


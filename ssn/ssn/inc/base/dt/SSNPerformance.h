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

typedef struct _ssn_performance_info_t {
    long long    user_time;      /* user run cost time (usec) */
    long long    system_time;    /* system run cost time (usec) */
    double       cpu_usage;           /* scaled cpu usage percentage */
} ssn_performance_info_t;

SSN_C_EXTERN double ssn_current_cpu_usage(void);//当前进程cpu占有率

SSN_C_EXTERN double ssn_current_thread_cpu_usage(void);//当前线程cpu占有率

SSN_C_EXTERN ssn_performance_info_t ssn_current_performance_info(void); //当前线程性能信息

SSN_C_EXTERN ssn_performance_info_t ssn_performance_info_imp_called(void *obj,void *cmd,void (*imp)(void *,void *));//函数调用性能参数返回

SSN_C_EXTERN double ssn_current_thread_memory_usage(void);//当前进程内存占有率


#endif


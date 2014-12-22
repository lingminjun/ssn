//
//  ssncop.h
//  ssn
//
//  Created by lingminjun on 14/12/3.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

//Coefficient Of Performance

#ifndef __ssn__ssncop__
#define __ssn__ssncop__

#if defined(__cplusplus)
#define SSN_COP_EXTERN extern "C"
#else
#define SSN_COP_EXTERN extern
#endif

typedef struct _ssn_performance_info_t {
    long long    user_time;      /* user run cost time (usec) */
    long long    system_time;    /* system run cost time (usec) */
    double       cpu_usage;           /* scaled cpu usage percentage */
} ssn_performance_info_t;

typedef void (*ssn_performance_info_imp_t)(void *);

SSN_COP_EXTERN double ssn_current_cpu_usage(void);//当前进程cpu占有率

SSN_COP_EXTERN double ssn_current_thread_cpu_usage(void);//当前线程cpu占有率

SSN_COP_EXTERN ssn_performance_info_t ssn_current_performance_info(void); //当前线程性能信息

SSN_COP_EXTERN ssn_performance_info_t ssn_performance_info_imp_called(ssn_performance_info_imp_t imp, void *context);//函数调用性能参数返回

SSN_COP_EXTERN double ssn_current_thread_memory_usage(void);//当前进程内存占有率

SSN_COP_EXTERN long long ssn_disk_free_space(void);//获取剩余磁盘大小（字节）

SSN_COP_EXTERN long long ssn_get_dir_space(const char *dir_path);//获取目录大小（字节）

SSN_COP_EXTERN unsigned int ssn_os_is_jail_broken(void);//是否越狱

#endif /* defined(__ssn__ssncop__) */

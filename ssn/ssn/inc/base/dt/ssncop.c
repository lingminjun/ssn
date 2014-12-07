//
//  ssncop.c
//  ssn
//
//  Created by lingminjun on 14/12/3.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "ssncop.h"
#include <mach/mach.h>
#include <mach/kern_return.h>
#include <assert.h>
#include <pthread/pthread.h>

#include <sys/param.h>
#include <sys/mount.h>

#include <unistd.h>

// Defines
#define MB (1024*1024)
#define GB (MB*1024)

double ssn_current_cpu_usage(void)
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    //    long tot_sec = 0;
    //    long tot_usec = 0;
    double tot_cpu = 0;
    int j;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0) {
        stat_thread += thread_count;
    }
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            continue ;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            //            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            //            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (double)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

double ssn_current_thread_cpu_usage(void)
{
    kern_return_t kr;
    
    pthread_t current_thread = pthread_self();
    mach_port_t current_port = pthread_mach_thread_np(current_thread);
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
    
    thread_basic_info_t basic_info_th;
    
    double tot_cpu = 0;
    
    kr = thread_info(current_port, THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    basic_info_th = (thread_basic_info_t)thinfo;
    
    if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
        tot_cpu = basic_info_th->cpu_usage / (double)TH_USAGE_SCALE * 100.0;
    }
    
    return tot_cpu;
}

ssn_performance_info_t ssn_current_performance_info(void) {
    kern_return_t kr;
    
    pthread_t current_thread = pthread_self();
    mach_port_t current_port = pthread_mach_thread_np(current_thread);
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
    
    thread_basic_info_t basic_info_th;
    
    ssn_performance_info_t performance_info = {0,0,0.0};
    
    kr = thread_info(current_port, THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
    if (kr == KERN_SUCCESS) {
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            performance_info.user_time = (basic_info_th->user_time.seconds * 1000000ull) + basic_info_th->user_time.microseconds;
            performance_info.system_time = (basic_info_th->system_time.seconds * 1000000ull) + basic_info_th->system_time.microseconds;
            performance_info.cpu_usage = basic_info_th->cpu_usage / (double)TH_USAGE_SCALE * 100.0;
        }
    }
    
    return performance_info;
}

ssn_performance_info_t ssn_performance_info_imp_called(ssn_performance_info_imp_t imp, void *context) {
    kern_return_t kr;
    
    pthread_t current_thread = pthread_self();
    mach_port_t current_port = pthread_mach_thread_np(current_thread);
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
    
    thread_basic_info_t basic_info_th;
    
    ssn_performance_info_t performance_info = {0,0,0.0};
    
    kr = thread_info(current_port, THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
    if (kr == KERN_SUCCESS) {
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            performance_info.user_time -= (basic_info_th->user_time.seconds * 1000000ull) + basic_info_th->user_time.microseconds;
            performance_info.system_time -= (basic_info_th->system_time.seconds * 1000000ull) + basic_info_th->system_time.microseconds;
        }
    }
    
    //函数imp调用
    if(imp) {
        imp(context);
    }
    
    
    kr = thread_info(current_port, THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
    if (kr == KERN_SUCCESS) {
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            performance_info.user_time += (basic_info_th->user_time.seconds * 1000000ull) + basic_info_th->user_time.microseconds;
            performance_info.system_time += (basic_info_th->system_time.seconds * 1000000ull) + basic_info_th->system_time.microseconds;
            performance_info.cpu_usage = basic_info_th->cpu_usage / (double)TH_USAGE_SCALE * 100.0;
        }
    }
    
    return performance_info;
}

double ssn_current_thread_memory_usage(void)
{
    // pages belonging to a (shared) memory mapped file (e.g. a library) will count as resident pages for the task
    // they will be ignored by the Xcode
    double tot_memory = 0;
    struct task_basic_info info;
    mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if( kerr == KERN_SUCCESS ) {
        tot_memory = (double)info.resident_size / MB;
    } else {
        //printf("Error with task_info(): %s", mach_error_string(kerr));
    }
    
    return tot_memory;
}

#pragma mark 磁盘大小计算
long long ssn_disk_free_space(void) {
    struct statfs tStats;
    long long freespace = -1;
    if(statfs("/", &tStats) >= 0){
        freespace = (long long)tStats.f_bsize * tStats.f_bfree;
    }
    
    return freespace;
}

long long ssn_get_dir_space(const char *dir_path) {
    struct statfs tStats;
    statfs(dir_path, &tStats);
    long long  space = (long long )(tStats.f_blocks * tStats.f_bsize);
    
    return space;
}

unsigned int ssn_os_is_jail_broken(void)
{
    const char* jailbreak_apps[] =
    {
        "/Applications/Cydia.app",
        "/Applications/limera1n.app",
        "/Applications/greenpois0n.app",
        "/Applications/blackra1n.app",
        "/Applications/blacksn0w.app",
        "/Applications/redsn0w.app",
        "/Applications/Absinthe.app",
        NULL,
    };
    
    // Now check for known jailbreak apps. If we encounter one, the device is jailbroken.
    for(int i = 0; jailbreak_apps[i] != NULL; ++i)
    {
        if(0 == access(jailbreak_apps[i], F_OK))
        {
            return 1;
        }
    }
    return 0;
}
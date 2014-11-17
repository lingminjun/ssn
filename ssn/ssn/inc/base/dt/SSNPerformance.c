//
//  SSNPerformance.c
//  ssn
//
//  Created by lingminjun on 14-11-17.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "SSNPerformance.h"
#include <mach/mach.h>
#include <mach/kern_return.h>
#include <assert.h>
#include <pthread/pthread.h>

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

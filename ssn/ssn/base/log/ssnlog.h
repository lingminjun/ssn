//
//  log.h
//  ssn
//
//  Created by lingminjun on 14/12/1.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__log__
#define __ssn__log__

#if defined(__cplusplus)
#define SSN_LOG_EXTERN extern "C"
#else
#define SSN_LOG_EXTERN extern
#endif

#include <stdio.h>

typedef enum _ssn_log_level {
    ssn_disk_log    = 0,       //仅仅写入文件日志
    ssn_console_log = 1,    //仅仅写入控制台日志
    ssn_verbose_log = 2     //文件和控制台
} ssn_log_level;

/**
 *  获取日志目录名
 *  @param [out]: 目录名
 *  @param [in]:  与现在间隔的时间(s)
 */
SSN_LOG_EXTERN void ssn_log_get_dir_name(char *,const long);

/**
 *  获取日志文件名
 *  @param [out]: 文件名
 */
SSN_LOG_EXTERN void ssn_log_get_file_name(char *);

/**
 *  获得文件大小
 *  @param filename [in]: 文件名
 *  @return 文件大小
 */
SSN_LOG_EXTERN long ssn_log_get_file_size(const char *);

/**
 *  写入日志
 *  @param  [in]:    日志文件名（带路径）
 *  @param  [in]:    日志级别
 *  @param  [in]:    format
 *  @return 空
 */
SSN_LOG_EXTERN void ssn_file_log(const char *, const ssn_log_level, const char * __restrict, ...);

/**
 *  写入日志
 *  @param  [in]:    已经open的日志文件handler
 *  @param  [in]:    日志级别
 *  @param  [in]:    format
 *  @return 空
 */
SSN_LOG_EXTERN void ssn_file_puts_log(FILE *, const ssn_log_level, const char * __restrict, ...);

/**
 *  写入日志
 *  @param  [in]:    已经open的日志文件handler
 *  @param  [in]:    日志级别
 *  @param  [in]:    format
 *  @return 空
 */
SSN_LOG_EXTERN void ssn_file_puts_line(FILE *, const ssn_log_level, const char *);

#endif /* defined(__ssn__log__) */

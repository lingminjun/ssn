//
//  log.h
//  ssn
//
//  Created by lingminjun on 14/12/1.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__log__
#define __ssn__log__

typedef enum _ssn_log_level {
    ssn_release_log = 0,    //仅仅写入文件日志
    ssn_debug_log   = 1,    //不写入文件
    ssn_verbose_log = 2     //文件和控制台
} ssn_log_level;

/**
 *  获取日志文件名
 *  @param [out]: 文件名
 */
void ssn_log_get_file_name(char *);

/**
 *  写入日志
 *  @param  [in]:    日志文件名（带路径）
 *  @param  [in]:    日志级别
 *  @param  [in]:    format
 *  @return 空
 */
void ssn_file_log(const char *, const ssn_log_level, const char * __restrict, ...);

#endif /* defined(__ssn__log__) */

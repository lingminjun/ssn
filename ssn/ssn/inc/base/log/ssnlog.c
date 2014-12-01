//
//  log.c
//  ssn
//
//  Created by lingminjun on 14/12/1.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "ssnlog.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#ifdef WIN32
#include <windows.h>
#else
#include <unistd.h>		// linux下头文件
#endif
#include <stdarg.h>

#define SSN_FILE_MAX_LINES 1024         //每行ASII 128 个，大致1024行
#define SSN_FILE_MAX_SIZE (1024*1024)   //1M的限定

/*
 获得当前时间字符串，采用“2014-12-01 22:13:36”格式，占用较多字符
 @param buffer [out]: 时间字符串
 @return 空
 */
void ssn_log_get_local_clear_time(char* buffer)
{
    time_t rawtime;
    struct tm* timeinfo;
    
    time(&rawtime);
    timeinfo = localtime(&rawtime);
    
    sprintf(buffer, "%04d-%02d-%02d %02d:%02d:%02d",
            (timeinfo->tm_year+1900), (timeinfo->tm_mon+1), timeinfo->tm_mday,
            timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
}

/*
 获得当前时间字符串，utc-1900时间，并且采用十六进制显示
 @param buffer [out]: 时间字符串
 @return 空
 */
void ssn_log_get_local_utc_hex_time(char* buffer)
{
    time_t rawtime = 0;
    time(&rawtime);
    
//    if (rawtime > SSN_1970_UTC_TIME) {
//        rawtime -= SSN_1970_UTC_TIME;
//    }
    
    //采用这种方式显示占用太大字符
    sprintf(buffer, "%08x",(unsigned int)rawtime);
}

/*
 获得文件大小
 @param filename [in]: 文件名
 @return 文件大小
 */
long ssn_log_get_file_size(const char* filename)
{
    long length = 0;
    FILE *fp = NULL;
    
    fp = fopen(filename, "rb");
    if (fp != NULL)
    {
        fseek(fp, 0, SEEK_END);
        length = ftell(fp);
    }
    
    if (fp != NULL)
    {
        fclose(fp);
        fp = NULL;
    }
    
    return length;
}

/**
 *  获取日志文件名
 *  @param filename [out]: 文件名
 */
void ssn_log_get_file_name(char* filename)
{
    char now[32] = {'\0'};
    ssn_log_get_local_clear_time(now);
    sprintf(filename, "%s.txt", now);
}

/*
 写入日志文件
 @param filename [in]: 日志文件名
 @param max_size [in]: 日志文件大小限制
 @param buffer [in]: 日志内容
 @param buf_size [in]: 日志内容大小
 @return 空
 */
void ssn_log_write_log_file(const char* filename, const long max_size, const char* buffer, const size_t buf_size)
{
    if (filename != NULL && buffer != NULL)
    {
        // 文件超过最大限制, 删除
        long length = ssn_log_get_file_size(filename);
        
        if (length > max_size)
        {
            unlink(filename); // 删除文件
        }
        
        // 写日志
        {
            FILE *fp;
            fp = fopen(filename, "at+");
            if (fp != NULL)
            {
                fwrite(buffer, buf_size, 1, fp);
                
                fclose(fp);
                fp = NULL;
            }
        }
    }
}

#define ssn_log_buffer_size (1024*2)
/**
 *  写入日志
 *  @param level  [in]:    日志级别
 *  @param format [in]:    format
 *  @return 空
 */
void ssn_file_log(const char *file, const ssn_log_level level, const char * __restrict format, ...) {
    char *pbuffer = NULL;
    char buffer[ssn_log_buffer_size] = {'\0'};
    va_list arg_ptr;
    
#ifdef DEBUG
    ssn_log_get_local_clear_time(buffer);
#else
    ssn_log_get_local_utc_hex_time(buffer);
#endif
    
    size_t len = strlen(buffer);
    buffer[len] = ' ';//插入一个空格
    pbuffer = (buffer + len + 1);
    
    va_start(arg_ptr, format);
    vsprintf(pbuffer, format, arg_ptr);
    va_end(arg_ptr);
    
    //写文件todo
    if (file) {
        ssn_log_write_log_file(file, SSN_FILE_MAX_SIZE, buffer, strlen(buffer));
    }
    
#ifndef DEBUG
    if (level == ssn_verbose_log && level == ssn_debug_log) {
#endif
        printf("%s\n",buffer);
#ifndef DEBUG
    }
#endif
}
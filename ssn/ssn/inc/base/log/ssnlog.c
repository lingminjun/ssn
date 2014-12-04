//
//  log.c
//  ssn
//
//  Created by lingminjun on 14/12/1.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "ssnlog.h"

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
 *  获取日志目录名
 *  @param [out]: 目录名
 */
void ssn_log_get_dir_name(char *dirname,const long interval)
{
    time_t rawtime;
    struct tm* timeinfo;
    
    time(&rawtime);
    
    rawtime += interval;//加上间隔时间
    
    timeinfo = localtime(&rawtime);
    
    //文件格式限定字符
    sprintf(dirname, "%04d-%02d-%02d", (timeinfo->tm_year+1900), (timeinfo->tm_mon+1), timeinfo->tm_mday);
}

/**
 *  获取日志文件名
 *  @param filename [out]: 文件名
 */
void ssn_log_get_file_name(char* filename)
{
    char now[32] = {'\0'};
    
    time_t rawtime;
    struct tm* timeinfo;
    
    time(&rawtime);
    timeinfo = localtime(&rawtime);
    
    //文件格式限定字符
    sprintf(now, "%04d-%02d-%02d %02d-%02d-%02d",
            (timeinfo->tm_year+1900), (timeinfo->tm_mon+1), timeinfo->tm_mday,
            timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
    
    sprintf(filename, "%s.txt", now);
}

/*
 写入日志文件
 @param filename [in]: 日志文件名
 @param buffer [in]: 日志内容
 @return 空
 */
void ssn_log_write_log_file(const char* filename, const char* buffer)
{
    
    FILE *fp;
    
    if (filename != NULL && buffer != NULL)
    {
        // 写日志
        fp = fopen(filename, "at+");
        if (fp != NULL)
        {
            //按照行输入
            fputs(buffer, fp);
            fflush(fp);//效率稍微稍微收到影响
            
            fclose(fp);
            fp = NULL;
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
    size_t len = 0;
    
    va_list arg_ptr;
    
#ifdef DEBUG
    ssn_log_get_local_clear_time(buffer);
#else
    ssn_log_get_local_utc_hex_time(buffer);//utc节省日志控件
#endif
    
    len = strlen(buffer);
    buffer[len] = ' ';//插入一个空格
    pbuffer = (buffer + len + 1);
    
    va_start(arg_ptr, format);
    vsprintf(pbuffer, format, arg_ptr);
    va_end(arg_ptr);
    
    len = strlen(buffer);
    buffer[len] = '\n';//插入一个空格
    
    //写文件todo
    if (file) {
        ssn_log_write_log_file(file, buffer);
    }
    
#ifndef DEBUG
    if (level == ssn_console_log && level == ssn_verbose_log) {
#endif
        printf("%s",buffer);
#ifndef DEBUG
    }
#endif
}


/**
 *  写入日志
 *  @param  [in]:    已经open的日志文件handler
 *  @param  [in]:    日志级别
 *  @param  [in]:    format
 *  @return 空
 */
void ssn_file_puts_log(FILE *fp, const ssn_log_level level, const char * __restrict format, ...) {
    char *pbuffer = NULL;
    char buffer[ssn_log_buffer_size] = {'\0'};
    size_t len = 0;
    
    va_list arg_ptr;
    
#ifdef DEBUG
    ssn_log_get_local_clear_time(buffer);
#else
    ssn_log_get_local_utc_hex_time(buffer);
#endif
    
    len = strlen(buffer);
    buffer[len] = ' ';//插入一个空格
    pbuffer = (buffer + len + 1);
    
    va_start(arg_ptr, format);
    vsprintf(pbuffer, format, arg_ptr);
    va_end(arg_ptr);
    
    len = strlen(buffer);
    buffer[len] = '\n';//插入一个空格
    
    //写文件todo
    if (fp) {
        fputs(buffer, fp);
        fflush(fp);//效率稍微稍微收到影响
    }
    
#ifndef DEBUG
    if (level == ssn_verbose_log && level == ssn_debug_log) {
#endif
        printf("%s",buffer);
#ifndef DEBUG
    }
#endif

}

void ssn_file_puts_line(FILE *fp, const ssn_log_level level, const char *log) {
    
    char buffer[ssn_log_buffer_size] = {'\0'};
    size_t len = 0;
    char *pbuffer = NULL;
    
    if ((strlen(log) + 21) > ssn_log_buffer_size) {
        pbuffer = (char *)malloc(strlen(log) + 21);
    }
    else {
        pbuffer = buffer;
    }
    
#ifdef DEBUG
    ssn_log_get_local_clear_time(pbuffer);
#else
    ssn_log_get_local_utc_hex_time(pbuffer);
#endif
    
    len = strlen(pbuffer);
    pbuffer[len] = ' ';//插入一个空格
    
    strcat(pbuffer, log);
    
    len = strlen(pbuffer);
    pbuffer[len] = '\n';//插入一个空格
    
    //写文件todo
    if (fp) {
        fputs(pbuffer, fp);
        fflush(fp);//效率稍微稍微收到影响
    }
    
#ifndef DEBUG
    if (level == ssn_verbose_log && level == ssn_debug_log) {
#endif
        printf("%s",pbuffer);
#ifndef DEBUG
    }
#endif
    
    if (pbuffer && pbuffer != buffer) {
        free(pbuffer);
    }
}

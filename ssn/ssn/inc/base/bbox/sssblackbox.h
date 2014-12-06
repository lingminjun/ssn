//
//  sssblackbox.h
//  ssn
//
//  Created by lingminjun on 14/12/5.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

/**
 * @brief 采用c语言实现，反编译后可读性降低
 */
#ifndef __ssn__sssblackbox__
#define __ssn__sssblackbox__

#include <stdio.h>

#if defined(__cplusplus)
#define SSN_BBOX_EXTERN extern "C"
#else
#define SSN_BBOX_EXTERN extern
#endif

#define SSN_BBOX_NOERROR    0
#define SSN_BBOX_ERROR      1
#define SSN_BBOX_EINVAL     2


/**
 *  防止gdb调试，debug下不起作用
 */
SSN_BBOX_EXTERN void ssn_bbox_disable_gdb(void);

/**
 *  获取key对应的值
 *  @param  value [out] 获取值存放
 *  @param  key [in] 需要取值的key
 *  @param  file [in] 值键存放位置
 *  @return 操作是否成功，成功返回 SSN_BBOX_NOERROR
 */
SSN_BBOX_EXTERN int ssn_bbox_get_value(char *value, const char *key, FILE *file);

/**
 *  存入值键对
 *  @param  value [in]  存放的值
 *  @param  key [in]    存放的key
 *  @param  file [in] 值键存放位置
 *  @return 操作是否成功，成功返回 SSN_BBOX_NOERROR
 */
SSN_BBOX_EXTERN int ssn_bbox_set_value(const char *value, const char *key, FILE *file);

/**
 *  移除值键对
 *  @param  key [in]    存放的key
 *  @param  file [in] 值键存放位置
 *  @return 操作是否成功，成功返回 SSN_BBOX_NOERROR
 */
SSN_BBOX_EXTERN int ssn_bbox_remove_value(const char *key, FILE *file);

#endif /* defined(__ssn__sssblackbox__) */

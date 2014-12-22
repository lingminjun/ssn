//
//  ssn_diff.h
//  ssn
//
//  Created by lingminjun on 14/12/16.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__ssn_diff__
#define __ssn__ssn_diff__

#include <stddef.h>

#if defined(__cplusplus)
#define SSN_DIFF_EXTERN extern "C"
#else
#define SSN_DIFF_EXTERN extern
#endif

/**
 @brief diff比较时对别元素的变化
 */
typedef enum _ssn_diff_change_type {
    ssn_diff_no_change    = 0,    //<! 无变化
    ssn_diff_insert       = 1,    //<! 新增元素
    ssn_diff_delete       = 2     //<! 删除元素
} ssn_diff_change_type;

#define ssn_diff_equal   1  //<! 元素相等
#define ssn_diff_unequal 0  //<! 元素不相等

/**
 @brief 元素是否相回调
 @param from 原始结果集
 @param to 目标结果集
 @param f_idx 原始结果集位置
 @param t_idx 目标结果集位置
 @param context 上下文
 @return 是否相等，返回ssn_diff_equal表示相等，返回ssn_diff_unequal表示不相等
 */
typedef int (*ssn_diff_element_is_equal)(void *from, void *to, const size_t f_idx, const size_t t_idx, void *context);

/**
 @brief 比较结果回调
 @param from 原始结果集，当type == ssn_diff_insert时，from为NULL
 @param to 目标结果集，当type == ssn_diff_delete时，to为NULL
 @param f_idx 原始结果集位置
 @param t_idx 目标结果集位置
 @param type 元素对应的变化
 @param context 上下文
 */
typedef void (*ssn_diff_results_iterator)(void *from, void *to, const size_t f_idx, const size_t t_idx, const ssn_diff_change_type type, void *context);

/**
 @brief diff 比较
 @param from 原始结果集
 @param to 目标结果集
 @param f_size 原始结果大小
 @param t_size 目标结果大小
 @param equal  元素相等回调
 @param iterator 遍历结果回调
 @param context 上下文
 */
void ssn_diff(void *from, void *to, const size_t f_size, const size_t t_size, ssn_diff_element_is_equal equal, ssn_diff_results_iterator iterator, void *context);

#endif /* defined(__ssn__ssn_diff__) */

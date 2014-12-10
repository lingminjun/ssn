//
//  ssnblackbox.h
//  ssn
//
//  Created by lingminjun on 14/12/5.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

/**
 * @brief 采用c语言实现，反编译后可读性降低
 */
#ifndef __ssn__ssnblackbox__
#define __ssn__ssnblackbox__

#include "ssnsmap.h"
#include <pthread.h>

#if defined(__cplusplus)
#define SSN_BBOX_EXTERN extern "C"
#else
#define SSN_BBOX_EXTERN extern
#endif

#define SSN_BBOX_NOERROR    0
#define SSN_BBOX_ERROR      1
#define SSN_BBOX_EINVAL     2

/**
 @brief 一个黑匣子操作对象
 */
typedef struct _ssn_bbox_t {
    const char *path;         //文件存储地址
    ssn_smap_t *map;          //元素内存缓存
    pthread_rwlock_t rwlock; //读写锁
} ssn_bbox_t;

/**
 *  防止gdb调试，debug下不起作用
 */
SSN_BBOX_EXTERN void ssn_bbox_disable_gdb(void);

/**
 *  获取bbox实例
 *  @param  path [in] 存储路径
 *  @param  hash_size [in] 值键容量
 *  @return ssn_bbox_t
 */
SSN_BBOX_EXTERN ssn_bbox_t *ssn_bbox_create(const char *path, const unsigned long hash_size);

/**
 *  获取key对应的值
 *  @param  key [in] 需要取值的key
 *  @param  bbox [in] 值键存放位置
 *  @return value no copy
 */
SSN_BBOX_EXTERN const char *ssn_bbox_get_value(const char *key, ssn_bbox_t *bbox);


/**
 *  获取key对应的值
 *  @param  key [in] 需要取值的key
 *  @param  bbox [in] 值键存放位置
 *  @return value
 */
SSN_BBOX_EXTERN const char *ssn_bbox_copy_value(const char *key, ssn_bbox_t *bbox);

/**
 *  存入值键对
 *  @param  value [in]  存放的值
 *  @param  key [in]    存放的key
 *  @param  bbox [in] 值键存放位置
 *  @return 操作是否成功，成功返回 SSN_BBOX_NOERROR
 */
SSN_BBOX_EXTERN int ssn_bbox_set_value(const char *value, const char *key, ssn_bbox_t *bbox);

/**
 *  移除值键对
 *  @param  key [in]    存放的key
 *  @param  bbox [in] 值键存放位置
 *  @return 操作是否成功，成功返回 SSN_BBOX_NOERROR
 */
SSN_BBOX_EXTERN int ssn_bbox_remove_value(const char *key, ssn_bbox_t *bbox);

/**
 *  释放bbox实例
 *  @param  bbox [in]  释放对象
 */
SSN_BBOX_EXTERN void ssn_bbox_destroy(ssn_bbox_t *bbox);

#endif /* defined(__ssn__sssblackbox__) */
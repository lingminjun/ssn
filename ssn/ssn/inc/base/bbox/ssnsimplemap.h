//
//  ssnsimplemap.h
//  ssn
//
//  Created by lingminjun on 14/12/6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__ssnsimplemap__
#define __ssn__ssnsimplemap__

#if defined(__cplusplus)
#define SSN_SMAP_EXTERN extern "C"
#else
#define SSN_SMAP_EXTERN extern
#endif

#define SSN_SMAP_NOERROR    0
#define SSN_SMAP_ERROR      1

/**
 @brief 结点定义
 */
typedef struct _ssn_simple_map_node {
    const char *key;
    const char *value;
    struct _ssn_simple_map_node *next;
} ssn_simple_map_node;

/**
 @brief 一个简易的hash map对象
 */
typedef struct _ssn_simple_map_t {
    unsigned long hash_size;        //hash容量（冗余度决定）
    unsigned long size;             //元素个数
    unsigned int nocopy;            //元素是否拷贝，key一定会被拷贝
    struct _ssn_simple_map_node *header;
} ssn_simple_map_t[0];

/**
 @brief 获取一个map
 @param hash_size 传入零默认使用1024
 */
SSN_SMAP_EXTERN ssn_simple_map_t *ssn_smap_create(const unsigned long hash_size, unsigned int nocopy);

/**
 @brief 添加元素
 @param map   操作的数据对象
 @param value 需要添加的内容，如果是nocopy将不会申请新资源
 @param key 添加的key
 */
SSN_SMAP_EXTERN int ssn_smap_add_node(ssn_simple_map_t *map, const char *value, const char *key);


/**
 @brief 获取元素，
 @param map   操作的数据对象
 @param key 对应的key
 @return 获取key下面的内容，不管是否为nocopy，都会copy出数据
 */
SSN_SMAP_EXTERN const char *ssn_smap_copy_value(ssn_simple_map_t *map, const char *key);


/**
 @brief 获取元素，
 @param map   操作的数据对象
 @param key 对应的key
 @param 获取key下面的内容指针，不会copy数据
 */
SSN_SMAP_EXTERN const char *ssn_smap_get_value(ssn_simple_map_t *map, const char *key);


/**
 @brief 删除对象，是否释放资源
 @param map   操作的数据对象
 @param key 对应的key
 @param freevalue 资源是否释放
 */
SSN_SMAP_EXTERN int ssn_smap_remove_value(ssn_simple_map_t *map, const char *key, const unsigned int freevalue);


/**
 @brief 删除对象，是否释放资源
 @param map   操作的数据对象
 @param key 对应的key
 @param freevalue 资源是否释放
 */
SSN_SMAP_EXTERN void ssn_smap_destroy(ssn_simple_map_t *map, const unsigned int freevalue);

#endif /* defined(__ssn__ssnsimplemap__) */

//
//  ssnsimplemap.c
//  ssn
//
//  Created by lingminjun on 14/12/6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "ssnsmap.h"

#include <string.h>
#include <stdlib.h>

#define SSN_S_MAP_DEFAULT_HASHSIZE (1024)

typedef struct _ssn_smap_t ssn_smap_inner_t;


unsigned long ssn_smap_hash(const char *k, const unsigned long hash_size) {
    unsigned long h = 0;
    while (*k) {
        h = *k+h*31;
        k++;
    }
    h = h%hash_size;
    return h;
}

ssn_smap_node *ssn_smap_lookup(ssn_smap_inner_t *pmap, const char *k, const unsigned long hash_size, ssn_smap_node **pre_np){
    unsigned long h = ssn_smap_hash(k, hash_size);
    ssn_smap_node *np = (pmap->header + h);
    
    //前一个节点保存
    if (pre_np) {
        *pre_np = np;
    }
    
    while (np && np->key) {
        
        if (pre_np && np->next) {
            *pre_np = np;
        }
        
        if (strcmp(np->key,k) == 0){
            return np;
        }
        
        np = np->next;
    }
    
    return NULL;
}

void ssn_smap_set_node_key(ssn_smap_node *np, const char *key) {
    size_t size = strlen(key);
    char *k = (char *)malloc(size + 1);
    memcpy(k, key, size);
    memset(k+size, 0, 1);
    np->key = k;
}


void ssn_smap_set_node_value(ssn_smap_node *np, const char *value, unsigned int nocopy) {
    
    size_t size = strlen(value);
    
    if (nocopy) {
        np->value = value;
    }
    else {
        char *v = (char *)malloc(size + 1);
        memcpy(v, value, size);
        memset(v+size, 0, 1);
        np->value = v;
    }
}

void ssn_smap_free_node(ssn_smap_node *np, unsigned int freevalue, unsigned int freeme) {
    if (np->key) {
        free((void *)(np->key));
        np->key = NULL;
    }
    
    if (np->value && freevalue) {
        free((void *)(np->value));
        np->value = NULL;
    }
    
    if (freeme) {
        free(np);
    }
}

/**
 @brief 获取一个map
 @param hash_size 传入零默认使用1024
 */
ssn_smap_t *ssn_smap_create(const unsigned long hash_size, unsigned int nocopy) {
    ssn_smap_inner_t *pmap = (ssn_smap_inner_t *)malloc(sizeof(ssn_smap_inner_t));
    pmap->hash_size = hash_size == 0 ? SSN_S_MAP_DEFAULT_HASHSIZE : hash_size;
    pmap->nocopy = nocopy;
    pmap->size = 0;
    pmap->header = (ssn_smap_node *)malloc(sizeof(ssn_smap_node) * pmap->hash_size);
    memset(pmap->header, 0, sizeof(ssn_smap_node) * pmap->hash_size);
    return (ssn_smap_t *)pmap;
}

/**
 @brief 添加元素
 @param map   操作的数据对象
 @param value 需要添加的内容，如果是nocopy将不会申请新资源
 @param key 添加的key
 */
int ssn_smap_add_node(ssn_smap_t *map, const char *value, const char *key) {
    
    ssn_smap_node *pre_np = NULL;
    ssn_smap_inner_t *pmap = (ssn_smap_inner_t *)map;
    ssn_smap_node *np = ssn_smap_lookup(pmap, key, pmap->hash_size, &pre_np);
    
    //已经存在key，替换
    if (np) {
        ssn_smap_set_node_value(np, value, pmap->nocopy);
        return SSN_SMAP_NOERROR;
    }
    
    //不存在key，先看header是否有值
    if (!(pre_np->key)) {//头部还不存在数据
        ssn_smap_set_node_key(pre_np, key);
        ssn_smap_set_node_value(pre_np, value, pmap->nocopy);
        return SSN_SMAP_NOERROR;
    }

    //创建一个新的node，插入到末尾
    np = (ssn_smap_node *)malloc(sizeof(ssn_smap_node));
    
    ssn_smap_set_node_key(np, key);
    ssn_smap_set_node_value(np, value, pmap->nocopy);

    np->next = pre_np->next;
    pre_np->next = np;
    
    return SSN_SMAP_NOERROR;
}


/**
 @brief 获取元素，
 @param map   操作的数据对象
 @param key 对应的key
 */
const char *ssn_smap_copy_value(ssn_smap_t *map, const char *key) {
    char *value = NULL;
    size_t size = 0;
    ssn_smap_inner_t *pmap = (ssn_smap_inner_t *)map;
    ssn_smap_node *np = ssn_smap_lookup(pmap, key, pmap->hash_size, NULL);
    
    if (np) {
        size = strlen(np->value);
        value = malloc(size + 1);
        memcpy(value, np->value, size);
        memset(value+size, 0, 1);
    }
    
    return value;
}


/**
 @brief 获取元素，
 @param map   操作的数据对象
 @param pvalue 获取key下面的内容指针，不会copy数据
 @param key 对应的key
 */
const char *ssn_smap_get_value(ssn_smap_t *map, const char *key) {
    ssn_smap_inner_t *pmap = (ssn_smap_inner_t *)map;
    ssn_smap_node *np = ssn_smap_lookup(pmap, key, pmap->hash_size, NULL);
    
    if (np) {
        return  np->value;
    }
    
    return NULL;
}


/**
 @brief 枚举所有值建对
 @param map   操作的数据对象
 @param iterator 迭代器
 */
void ssn_smap_enumerate_key_value(ssn_smap_t *map,void *context, void (*iterator)(const char *value, const char *key, void *context)) {
    ssn_smap_node *np = NULL;
    ssn_smap_inner_t *pmap = (ssn_smap_inner_t *)map;
    long index = 0;
    
    for (index = 0; index < pmap->hash_size; index++) {
        np = (pmap->header + index);
        while (np && np->key) {
            if (iterator) {
                iterator(np->value,np->key,context);
            }
            np = np->next;
        }
    }
}


/**
 @brief 删除对象，是否释放资源
 @param map   操作的数据对象
 @param key 对应的key
 @param freevalue 资源是否释放
 */
int ssn_smap_remove_value(ssn_smap_t *map, const char *key, const unsigned int freevalue) {
    unsigned int freeme = 1;
    ssn_smap_node *pre_np = NULL;
    ssn_smap_inner_t *pmap = (ssn_smap_inner_t *)map;
    ssn_smap_node *np = ssn_smap_lookup(pmap, key, pmap->hash_size, &pre_np);
    
    if (np) {//找到后先解开链路
        
        if (pre_np == np) {//就是头节点，不需要释放
            freeme = 0;
        }
        
        pre_np->next = np->next;
        np->next = NULL;
        
        ssn_smap_free_node(np, freevalue, freeme);
    }
    
    return SSN_SMAP_NOERROR;
}


/**
 @brief 删除对象，是否释放资源
 @param map   操作的数据对象
 @param key 对应的key
 @param freevalue 资源是否释放
 */
void ssn_smap_destroy(ssn_smap_t *map, unsigned int freevalue) {
    ssn_smap_inner_t *pmap = (ssn_smap_inner_t *)map;
    unsigned long index = 0;
    ssn_smap_node *header_np = NULL;
    ssn_smap_node *np = NULL;
    
    for (index = 0; index < pmap->hash_size; index++) {
        header_np = (pmap->header + index);
        
        ssn_smap_free_node(header_np, freevalue, 0);//不需要释放自己
        
        //从头开始向后释放
        while (header_np->next) {
            np = header_np->next;
            header_np->next = np->next;
            ssn_smap_free_node(np, freevalue, 1);//释放节点
        }
    }
    
    free(pmap->header);
    
    free(pmap);
}


//
//  ssnblackbox.c
//  ssn
//
//  Created by lingminjun on 14/12/5.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "ssnbbox.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonCryptor.h>

#include <dlfcn.h>
#include <sys/types.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "ssnbase64.h"

typedef int (*ssn_bbox_ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

void ssn_bbox_disable_gdb(void) {
#ifndef DEBUG
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ssn_bbox_ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
#endif
}

#define ssn_bbox_aes256_length          (32)
#define ssn_bbox_key_split_length       (2)

//将函数名混乱掉，防止从函数名得知语句块分析
#define ssn_bbox_aes256_encrypt         ssn_bbox_dsbhoq_dhjjgfd
#define ssn_bbox_aes256_decrypt         ssn_bbox_xmchds_sqgzyys
#define ssn_bbox_surplus_key_format     ssn_bbox_fhuagdj_rjd_fxhkdx
#define ssn_bbox_key_hash_to_cryp       ssn_bbox_ifg_hsnx_td_sgdh
#define ssn_bbox_gather_key_from_cryp   ssn_bbox_jdhsdl_osz_qskx_eqmc

const char *ssn_bbox_surplus_key_format = "!j:k<+d~z|a]p[r^y&d&w$i%(d)w%t%d$b,l@";

int ssn_bbox_aes256_encrypt(char *cryp, size_t *cryp_size,const size_t buff_size, const char *text,const size_t text_size, const char *key) {
    /*private function no if
    if (!cryp || !text || !aeskey) {
        return SSN_BBOX_EINVAL;
    }
     */
    
    CCCryptorStatus status = CCCrypt(kCCEncrypt, kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding | kCCOptionECBMode,
                                     key, kCCKeySizeAES256,
                                     NULL,
                                     text, text_size,
                                     cryp, buff_size,
                                     cryp_size);
    
    if (status == kCCSuccess)
    {
        return SSN_BBOX_NOERROR;
    }
    
    return SSN_BBOX_ERROR;
}

int ssn_bbox_aes256_decrypt(char *text, size_t *text_size,const size_t buff_size, const char *cryp, const size_t cryp_size, const char *key) {
    
    /*private function no if
    if (!cryp || !text || !aeskey) {
        return SSN_BBOX_EINVAL;
    }
     */
    
    CCCryptorStatus status = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding | kCCOptionECBMode,
                                     key, kCCKeySizeAES128,
                                     NULL,
                                     cryp, cryp_size,
                                     text, buff_size,
                                     text_size);
    
    if (status == kCCSuccess)
    {
        return SSN_BBOX_NOERROR;
    }
    
    return SSN_BBOX_ERROR;
}

int ssn_bbox_key_hash_to_cryp(char *buff, size_t buff_size, const char *cryp,const size_t cryp_size, const char *key) {
    
    long vector = 0;
    long split_count = 0;
    const char *soucre_point = NULL;
    char *target_point = NULL;
    const char *key_point = NULL;
    long index = 0;
    
    /*private function no if
     if (!buff || !cryp || !key) {
     return SSN_BBOX_EINVAL;
     }
     if (cryp_size <= ssn_bbox_aes256_length) {
     return SSN_BBOX_EINVAL;
     }
     */
    
    split_count = (long)(ssn_bbox_aes256_length/ssn_bbox_key_split_length);
    vector = (long)(cryp_size/split_count);
    vector = vector > 0 ? vector : 0;
    
    soucre_point = cryp;
    target_point = buff;
    key_point = key;
    
    for (index = 0; index < split_count; index++)
    {
        memcpy(target_point, soucre_point, vector);
        soucre_point = soucre_point + vector;
        target_point = target_point + vector;
        
        memcpy(target_point, key_point, ssn_bbox_key_split_length);
        target_point = target_point + ssn_bbox_key_split_length;
        key_point = key_point + ssn_bbox_key_split_length;
    }
    
    if (soucre_point != cryp + cryp_size)
    {
        //末尾的数据合入
        memcpy(target_point, soucre_point, cryp_size - (vector * split_count));
    }

    return SSN_BBOX_ERROR;
}

int ssn_bbox_gather_key_from_cryp(char *buff, size_t *buff_size, const char *cryp,const size_t cryp_size, char *key) {
    long vector = 0;
    long split_count = 0;
    const char *soucre_point = NULL;
    char *target_point = NULL;
    char *key_point = NULL;
    long index = 0;
    
    /*private function no if
     if (!buff || !cryp || !key) {
     return SSN_BBOX_EINVAL;
     }
     if (cryp_size <= ssn_bbox_aes256_length) {
     return SSN_BBOX_EINVAL;
     }
     */
    
    split_count = (long)(ssn_bbox_aes256_length/ssn_bbox_key_split_length);
    vector = (long)((cryp_size - ssn_bbox_aes256_length)/split_count);
    vector = vector > 0 ? vector : 0;
    
    soucre_point = cryp;
    target_point = buff;
    key_point = key;
    
    for (index = 0; index < split_count; index++)
    {
        memcpy(target_point, soucre_point, vector);
        target_point = target_point + vector;
        soucre_point = soucre_point + vector;
        
        memcpy(key_point, soucre_point, ssn_bbox_key_split_length);
        soucre_point = soucre_point + ssn_bbox_key_split_length;
        key_point = key_point + ssn_bbox_key_split_length;
    }
    
    if (soucre_point != cryp + cryp_size)
    {
        //末尾的数据合入
        memcpy(target_point, soucre_point, cryp_size - ((vector * split_count) + ssn_bbox_aes256_length));
    }
    
    *buff_size = cryp_size - ssn_bbox_aes256_length;
    
    return SSN_BBOX_NOERROR;
}

long ssn_bbox_read_line_size(FILE *file) {
    long size = 0;
    fscanf(file,"%ld\n",&size);
    return size;
}

void ssn_bbox_read_line(FILE *file,char *buff,long line_size) {
    fgets(buff, (int)line_size, file);
}

const char *ssn_bbox_split_char = "&";//非base64字符

void ssn_bbox_joined_value_key(char *buff,const char *value, const char *key) {
    unsigned long value_len = 0,key_len = 0;
    unsigned char *base64_value = NULL,*base64_key = NULL;
    
    base64_value = ssn_base64_encode((const unsigned char *)value, strlen(value), &value_len);
    base64_key = ssn_base64_encode((const unsigned char *)key, strlen(key), &key_len);
    memcpy(buff, base64_key, key_len);
    buff = buff + key_len;
    memcpy(buff, ssn_bbox_split_char, 1);//分割符
    buff = buff + 1;
    memcpy(buff, base64_value, value_len);
    
    free(base64_value);
    free(base64_key);
}

void ssn_bbox_split_value_key(char *value, char *key, char *text) {
    unsigned long value_len = 0,key_len = 0;
    char *base64_value = NULL,*base64_key = NULL;
    char *original_value = NULL,*original_key = NULL;
    
    base64_key = strtok(text, ssn_bbox_split_char);
    if (base64_key) {
        base64_value = strtok(NULL, ssn_bbox_split_char);
    }
    
    original_key = (char *)ssn_base64_decode((unsigned char *)base64_key, strlen(base64_key), &key_len);
    original_value = (char *)ssn_base64_decode((unsigned char *)base64_value, strlen(base64_value), &value_len);
    
    memcpy(key, original_key, key_len);
    memcpy(value, original_value, value_len);
    
    free(original_key);
    free(original_value);
}

void ssn_bbox_get_key_from_key(char *okey, const char *ikey) {
    size_t len = 0;
    strncpy(okey, ikey, ssn_bbox_aes256_length);
    len = strlen(okey);
    if (len < ssn_bbox_aes256_length) {//长度不够
        memcpy((okey + len), ssn_bbox_surplus_key_format, (ssn_bbox_aes256_length - len));
    }
}


void ssn_bbox_read_file_to_map(const char *path, ssn_smap_t *map) {
    
    long line_size = 0;
    char *buff = NULL;
    char *out_base64 = NULL;
    char *text = NULL;
    char *original_text = NULL;
    char aeskey[ssn_bbox_aes256_length + 1] = {'\0'};
    unsigned long out_len = 0, text_out_size = 0,out_size = 0;
    char *key = NULL, *value = NULL;
    
    FILE *fp = fopen(path, "rt");
    
    if (!fp) {
        return ;
    }
    
    while(!feof(fp))
    {
        line_size = ssn_bbox_read_line_size(fp);
        
        if (line_size == 0) {
            continue;
        }
        
        buff = malloc(line_size + 1);
        memset(buff,0,line_size + 1);
        memset(aeskey, 0, ssn_bbox_aes256_length + 1);
        
        ssn_bbox_read_line(fp, buff, 1024);
        
        out_base64 = (char *)ssn_base64_decode((unsigned char *)buff, line_size, &out_len);
        if (out_len<line_size) {
            out_len = line_size;
        }
        
        text = malloc(out_len+1);
        memset(text, 0, out_len+1);
        
        original_text = malloc(out_len+1);
        memset(original_text, 0, out_len+1);
        
        //收集key
        ssn_bbox_gather_key_from_cryp(text, &text_out_size, out_base64, out_len, aeskey);
        
        //解密
        ssn_bbox_aes256_decrypt(original_text, &out_size, out_len, text, text_out_size, aeskey);
        
        //分割
        key = malloc(out_size);
        memset(key, 0, out_size);
        value = malloc(out_size);
        memset(value, 0, out_size);
        
        ssn_bbox_split_value_key(value, key, original_text);
        
        printf("key:%s = value:%s",key,value);
        
        //添加到内存
        ssn_smap_add_node(map, value, key);
        
        //释放资源
        free(value);
        free(key);
        free(original_text);
        free(text);
        free(out_base64);
    }
    
    fclose(fp);
}

void ssn_bbox_smap_iterator(const char *value, const char *key, FILE *fp) {
    char *in_base64 = NULL;
    char *text = NULL;
    char *original_text = NULL;
    char *file_text = NULL;
    char aeskey[ssn_bbox_aes256_length + 1] = {'\0'};
    unsigned long original_len = 0;
    unsigned long out_len = 0, out_size = 0;
    //char *key = NULL, *value = NULL;
    
    //生产加密key
    ssn_bbox_get_key_from_key(aeskey, key);
    
    //拼接内容
    original_len = strlen(key) + strlen(value) + strlen(ssn_bbox_split_char) + 1;
    original_text = malloc(original_len);
    memset(original_text, 0, original_len);
    ssn_bbox_joined_value_key(original_text, value, key);
    
    //加密内容
    if (original_len < 33) {
        original_len = 33;
    }
    text = malloc(original_len);
    memset(text, 0, original_len);
    ssn_bbox_aes256_encrypt(text, &out_len, original_len, original_text, strlen(original_text), aeskey);
    
    //秘钥散列到
    file_text = malloc(out_len + ssn_bbox_aes256_length + 1);
    memset(file_text, 0, out_len + ssn_bbox_aes256_length + 1);
    ssn_bbox_key_hash_to_cryp(file_text, (out_len + ssn_bbox_aes256_length + 1), text, out_len, aeskey);
    
    
    //base64下
    in_base64 = (char *)ssn_base64_encode((unsigned char *)file_text, (out_len + ssn_bbox_aes256_length), &out_size);
    
    //输入到文件
    fprintf(fp, "%ld\n%s",out_size,in_base64);
    
    free(in_base64);
    free(text);
    free(original_text);
}

void ssn_bbox_write_map_to_file(const char *path, ssn_smap_t *map) {
    
    FILE *fp = fopen(path, "wt");
    
    if (!fp) {
        return ;
    }
    
    ssn_smap_enumerate_key_value(map, fp, (void(*)(const char *, const char *, void *))ssn_bbox_smap_iterator);
    
    fflush(fp);
    fclose(fp);
    
}


/**
 *  获取bbox实例
 *  @param  path [in] 存储路径
 *  @param  hash_size [in] 值键容量
 *  @return ssn_bbox_t
 */
SSN_BBOX_EXTERN ssn_bbox_t *ssn_bbox_create(const char *path, const unsigned long hash_size) {
    size_t path_size = strlen(path);
    ssn_bbox_t *bbox = (ssn_bbox_t *)malloc(sizeof(ssn_bbox_t));
    pthread_rwlock_init(&(bbox->rwlock), NULL);
    bbox->map = ssn_smap_create(hash_size, 0);
    bbox->path = malloc(path_size + 1);
    strncpy((char *)bbox->path, path, path_size + 1);
    
    pthread_rwlock_wrlock(&(bbox->rwlock));
    ssn_bbox_read_file_to_map(bbox->path, bbox->map);
    pthread_rwlock_unlock(&(bbox->rwlock));
    
    return bbox;
}

/**
 *  获取key对应的值
 *  @param  key [in] 需要取值的key
 *  @param  bbox [in] 值键存放位置
 *  @return value no copy
 */
SSN_BBOX_EXTERN const char *ssn_bbox_get_value(const char *key, ssn_bbox_t *bbox) {
    const char *value = NULL;
    
    if (!bbox->path || !key || 0 == strlen(key) || 0 == strlen(bbox->path)) {
        return NULL;
    }
    
    pthread_rwlock_rdlock(&(bbox->rwlock));
    if (bbox->map) {
        value = ssn_smap_get_value(bbox->map, key);
        pthread_rwlock_unlock(&(bbox->rwlock));
        return value;
    }
    pthread_rwlock_unlock(&(bbox->rwlock));
    return NULL;
}


/**
 *  获取key对应的值
 *  @param  key [in] 需要取值的key
 *  @param  bbox [in] 值键存放位置
 *  @return value
 */
SSN_BBOX_EXTERN const char *ssn_bbox_copy_value(const char *key, ssn_bbox_t *bbox) {
    const char *value = NULL;
    
    if (!bbox->path || !key || 0 == strlen(key) || 0 == strlen(bbox->path)) {
        return NULL;
    }
    
    pthread_rwlock_rdlock(&(bbox->rwlock));
    if (bbox->map) {
        value = ssn_smap_copy_value(bbox->map, key);
        pthread_rwlock_unlock(&(bbox->rwlock));
        return value;
    }
    pthread_rwlock_unlock(&(bbox->rwlock));
    return NULL;
}

/**
 *  存入值键对
 *  @param  value [in]  存放的值
 *  @param  key [in]    存放的key
 *  @param  bbox [in] 值键存放位置
 *  @return 操作是否成功，成功返回 SSN_BBOX_NOERROR
 */
SSN_BBOX_EXTERN int ssn_bbox_set_value(const char *value, const char *key, ssn_bbox_t *bbox) {
    if (!bbox->path || !key || 0 == strlen(key) || 0 == strlen(bbox->path) || !value || 0 == strlen(value)) {
        return SSN_BBOX_EINVAL;
    }
    
    pthread_rwlock_wrlock(&(bbox->rwlock));
    if (bbox->map) {
        ssn_smap_add_node(bbox->map, value, key);
        ssn_bbox_write_map_to_file(bbox->path, bbox->map);
        pthread_rwlock_unlock(&(bbox->rwlock));
        return SSN_BBOX_NOERROR;
    }
    pthread_rwlock_unlock(&(bbox->rwlock));
    return SSN_BBOX_ERROR;

}

/**
 *  移除值键对
 *  @param  key [in]    存放的key
 *  @param  bbox [in] 值键存放位置
 *  @return 操作是否成功，成功返回 SSN_BBOX_NOERROR
 */
SSN_BBOX_EXTERN int ssn_bbox_remove_value(const char *key, ssn_bbox_t *bbox) {
    if (!bbox->path || !key || 0 == strlen(key) || 0 == strlen(bbox->path)) {
        return SSN_BBOX_EINVAL;
    }
    
    pthread_rwlock_wrlock(&(bbox->rwlock));
    if (bbox->map) {
        ssn_smap_remove_value(bbox->map, key, 1);
        ssn_bbox_write_map_to_file(bbox->path, bbox->map);
        pthread_rwlock_unlock(&(bbox->rwlock));
        return SSN_BBOX_NOERROR;
    }
    pthread_rwlock_unlock(&(bbox->rwlock));
    
    return SSN_BBOX_ERROR;
}


/**
 *  释放bbox实例
 *  @param  bbox [in]  释放对象
 */
SSN_BBOX_EXTERN void ssn_bbox_destroy(ssn_bbox_t *bbox) {
    if (!bbox) {
        return ;
    }
    
    ssn_smap_destroy(bbox->map, 1);
    free((void *)bbox->path);
    pthread_rwlock_destroy(&(bbox->rwlock));
    
    free(bbox);
    
}


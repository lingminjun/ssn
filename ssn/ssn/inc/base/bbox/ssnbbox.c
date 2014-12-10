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
    
    CCCryptorStatus status = CCCrypt(kCCDecrypt, kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding | kCCOptionECBMode,
                                     key, kCCKeySizeAES256,
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

void *ssn_malloc_buffer(unsigned long size) {
    void *buff = malloc(size);
    memset(buff, 0, size);
    return buff;
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
    char num[21] = {'\0'};//long length
    fgets(num, (int)21, file);
    return atol(num);
}

void ssn_bbox_read_line(FILE *file,char *buff,long line_size) {
    fgets(buff, (int)line_size, file);
}

const char ssn_bbox_split_char = '&';//非base64字符

void ssn_bbox_get_key_from_key(char *okey, const char *ikey) {
    size_t len = 0;
    strncpy(okey, ikey, ssn_bbox_aes256_length);
    len = strlen(okey);
    if (len < ssn_bbox_aes256_length) {//长度不够
        memcpy((okey + len), ssn_bbox_surplus_key_format, (ssn_bbox_aes256_length - len));
    }
}


void ssn_bbox_read_file_to_map(const char *path, ssn_smap_t *map) {
    
    char *buffer1 = NULL,*buffer2 = NULL;//两个实际操作的buffer
    char aeskey[ssn_bbox_aes256_length + 1] = {'\0'};
    char *point1 = NULL,*point2 = NULL;//两个游标，分别用于指向key，value起始位置
    unsigned long length1 = 0,length2 = 0;//记录key,value的长度
    unsigned long buffer_length = 0;
    
    FILE *fp = fopen(path, "rt");//文本只读打开
    
    if (!fp) {
        return ;
    }
    
    while(!feof(fp))
    {
        buffer_length = ssn_bbox_read_line_size(fp);//取行长度
        
        if (buffer_length == 0) {//出现错误，暂时先不管，打印下日志
            printf("ssn bbox read line size error\n");
            continue;
        }
        else {//方便后面加解密运算，将length长度适当调整成32的倍数
            buffer_length = (buffer_length < ssn_bbox_aes256_length ? ssn_bbox_aes256_length :((long)((buffer_length + ssn_bbox_aes256_length - 1)/ssn_bbox_aes256_length) * ssn_bbox_aes256_length)) + 1;
        }
        
        //buffer申请并清空
        buffer1 = ssn_malloc_buffer(buffer_length);
        buffer2 = ssn_malloc_buffer(buffer_length);
        
        //数据还原
        length1 = 0;
        length2 = 0;
        point1 = NULL;
        point2 = NULL;
        
        //清空key
        memset(aeskey, 0, ssn_bbox_aes256_length + 1);
        
        //读取数据
        ssn_bbox_read_line(fp, buffer1, buffer_length);
        printf("ssn bbox read line [%s]\n",buffer1);
        
        //解析数据。此时非常重要，出来的数据已经不是字符串了
        ssn_base64_decode((unsigned char *)buffer2, (unsigned char *)buffer1, strlen(buffer1), &length2);
        
        if (length2 == 0) {//base64出来的数据有错误
            printf("ssn bbox base64 decode error\n");
            continue;
        }
        
        //清空buffer1，数据已经没有意义
        memset(buffer1, 0, buffer_length);
        length1 = 0;
        
        //收集key并且获得密文数据
        ssn_bbox_gather_key_from_cryp(buffer1, &length1, buffer2, length2, aeskey);
        
        //清空buffer2，数据已经没有意义
        memset(buffer2, 0, buffer_length);
        length2 = 0;
        
        //解密数据到buffer2中
        ssn_bbox_aes256_decrypt(buffer2, &length2, buffer_length, buffer1, length1, aeskey);
        printf("ssn bbox read content[%s]\n", buffer2);//理论上是明文字符串了，可以打印看看
        
        
        //此时分割出key和value(base64版本)，
        point1 = buffer2;
        point2 = strchr(buffer2, ssn_bbox_split_char);
        if (point2 == NULL) {
            printf("ssn bbox split value key error\n");
            continue;
        }
        point2 += 1;//去掉分割伏
        
        //清空buffer1，数据已经没有意义
        memset(buffer1, 0, buffer_length);
        length1 = 0;
        
        //先解析出key，因为map是copy的，所以数据就保存到buffer1中就ok
        ssn_base64_decode((unsigned char *)buffer1, (unsigned char *)point1, (point2 - point1 - 1), &length1);
        point1 = buffer1;
        
        //解析出value，因为map是copy的，所以数据就保存到buffer1中就ok
        ssn_base64_decode((unsigned char *)(buffer1 + strlen(point1) + 1), (unsigned char *)point2, strlen(point2), &length1);
        point2 = (buffer1 + strlen(point1) + 1);
        
        //将数据加入到map
        printf("ssn bbox out[key:%s = value:%s]\n",point1,point2);
        ssn_smap_add_node(map, point2, point1);
        
        //释放资源
        free(buffer1);
        free(buffer2);
    }
    
    fclose(fp);
}

void ssn_bbox_smap_iterator(const char *value, const char *key, FILE *fp) {
    
    char *buffer1 = NULL,*buffer2 = NULL;//两个实际操作的buffer
    char aeskey[ssn_bbox_aes256_length + 1] = {'\0'};
    char *point1 = NULL,*point2 = NULL;//两个游标，分别用于指向key，value起始位置
    unsigned long length1 = 0,length2 = 0;//记录key,value的长度
    unsigned long buffer_length = 0;
    
    //打印需要写入的key和value
    printf("ssn bbox in[key:%s = value:%s]\n",key,value);
    
    //生产加密key
    ssn_bbox_get_key_from_key(aeskey, key);
    
    //计算buffer长度，key_len+value_len+1+ssn_bbox_aes256_length 32整数被
    buffer_length = strlen(key) + strlen(value) + ssn_bbox_aes256_length;
    
    //方便后面加解密运算，将length长度适当调整成32的倍数
    buffer_length = (buffer_length < ssn_bbox_aes256_length ? ssn_bbox_aes256_length :((long)((buffer_length + ssn_bbox_aes256_length - 1)/ssn_bbox_aes256_length) * ssn_bbox_aes256_length));
    
    //还需要考虑base64长度
    buffer_length = ssn_base64_encode_length(buffer_length);
    
    //申请内存
    buffer1 = ssn_malloc_buffer(buffer_length);
    buffer2 = ssn_malloc_buffer(buffer_length);
    
    //将key和value都base64到buffer1
    ssn_base64_encode((unsigned char*)buffer1, (unsigned char*)key, strlen(key), &length1);
    point1 = buffer1;
    
    //中间这位设置成分割符
    memset(point1 + strlen(point1), ssn_bbox_split_char, 1);
    
    //拼接value
    point2 = (buffer1 + strlen(point1));
    ssn_base64_encode((unsigned char*)point2, (unsigned char*)value, strlen(value), &length1);
    
    printf("ssn bbox write content[%s]\n", buffer1);//理论上是明文字符串了，
    
    //将拼接内容buffer1加密到buffer2上，此时必须要记录长度，因为不再是字符串，仅仅是数据流
    ssn_bbox_aes256_encrypt(buffer2, &length2, buffer_length, buffer1, strlen(buffer1), aeskey);
    
    //清空buffer1，数据已经没有意义
    memset(buffer1, 0, buffer_length);

    //将key散列到密文中，到buffer1
    length1 = length2 + ssn_bbox_aes256_length;//密文长度加秘钥长度
    ssn_bbox_key_hash_to_cryp(buffer1, buffer_length, buffer2, length2, aeskey);
    
    //清空buffer2，数据已经没有意义
    memset(buffer2, 0, buffer_length);
    length2 = 0;
    
    //将整个密文base64下到buffer2
    ssn_base64_encode((unsigned char *)buffer2, (unsigned char *)buffer1, length1, &length2);
    
    //输入到文件
    fprintf(fp, "%ld\n%s\n",length2,buffer2);
    printf("%ld\n%s\n",length2,buffer2);
    fflush(fp);
    
    free(buffer1);
    free(buffer2);
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


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

#include <pthread.h>

#include <string.h>

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

static const char *ssn_bbox_surplus_key_format = "!j:k<+d~z|a]p[r^y&d&w$i%(d)w%t%d$b,l@";

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

int ssn_bbox_key_hash_to_cryp(char *buff, size_t buff_size, const char *cryp,const size_t cryp_size, const char *key) {
    
    return SSN_BBOX_ERROR;
}
//
//- (NSData *)fileDataForKey:(NSString *)key encryData:(NSData *)encryData
//{
//    const int data_length = [encryData length];
//    const int key_length = [key length];
//    const int length = data_length + key_length;
//    const int split_count = 16;
//
//    assert(key.length >= 2 * split_count);
//
//    char *fileBytes = (char *)malloc(length*sizeof(char));
//
//    const void *bytes = [encryData bytes];
//
//    const char *soucrePoint = bytes;
//    char *filePoint = fileBytes;
//
//    int vector = data_length/split_count;
//    vector = vector > 0 ? vector : 0;
//
//    for (int index = 0; index < split_count; index++)
//    {
//        memcpy(filePoint, soucrePoint, vector);
//        soucrePoint = soucrePoint + vector;
//        filePoint = filePoint + vector;
//
//        memcpy(filePoint, [[key substringWithRange:NSMakeRange(2*index, 2)] UTF8String], 2);
//        filePoint = filePoint + 2;
//    }
//
//    if (soucrePoint != bytes + data_length)
//    {
//        //末尾的数据合入
//        memcpy(filePoint, soucrePoint, data_length - (vector * split_count));
//    }
//
//    NSData *result = [NSData dataWithBytes:fileBytes length:length];
//
//    free(fileBytes);
//
//    return result;
//}

int ssn_bbox_gather_key_from_cryp(char *buff, size_t *buff_size, const char *cryp,const size_t cryp_size, char *key) {
    int vector = 0;
    int split_count = 0;
    const char *soucre_point = NULL;
    char *target_point = NULL;
    char *key_point = NULL;
    
    /*private function no if
    if (!buff || !cryp || !key) {
        return SSN_BBOX_EINVAL;
    }
     if (cryp_size <= ssn_bbox_aes256_length) {
        return SSN_BBOX_EINVAL;
     }
     */
    
    split_count = (int)(ssn_bbox_aes256_length/ssn_bbox_key_split_length);
    vector = (int)((cryp_size - ssn_bbox_aes256_length)/split_count);
    vector = vector > 0 ? vector : 0;
    
    soucre_point = cryp;
    target_point = buff;
    
    for (int index = 0; index < split_count; index++)
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




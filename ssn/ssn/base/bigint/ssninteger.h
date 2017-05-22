//
//  ssninteger.h
//  ssn
//
//  Created by fengqu on 2017/5/20.
//  Copyright © 2017年 lingminjun. All rights reserved.
//

#ifndef __ssn__integer__
#define __ssn__integer__

#if defined(__cplusplus)
#define SSN_BIG_INT_EXTERN extern "C"
#else
#define SSN_BIG_INT_EXTERN extern
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*
 支持的大数运算：+, -, *, /, ^, %, ^%
 
 SSNBInteger 采用模拟二进制的形式进行运算
 SSNBInteger 采用补码进行存储和运算
 
 乘法：采用 Booth 一位乘
 除法：采用二分法去做减法
 */
#define BIG_INT_BIT_LEN 1024           // 定义SSNBInteger的位数
#define SIGN_BIT BIG_INT_BIT_LEN - 1   // 符号位的位置
#define BUFFER_SIZE BIG_INT_BIT_LEN    // 缓冲区大小
#define POSITIVE 0                     // 0表示正数
#define NEGATIVE 1                     // 1表示负数

typedef struct    // 大整数类型，均用补码表示
{
    char bit[BIG_INT_BIT_LEN]; //存入二进制数据, 按照字节存储, 后期优化成按位存储
} SSNBInteger;


// 打印SSNBInteger
SSN_BIG_INT_EXTERN void ssn_bigint_print(const SSNBInteger* const a);

// 2进制字符串转16进制字符串
SSN_BIG_INT_EXTERN const char* ssn_str_bin_to_hex(const char* binStr, char* hexStr);

// 字符串进制转换 srcBase原始进制； dstBase目标进制
SSN_BIG_INT_EXTERN const char* ssn_str_change_radix(const char* str, const int srcBase, const int dstBase, char* resultStr);

// 原码<=>补码
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_complement(const SSNBInteger* const src, SSNBInteger* const dst);

// 转为原码
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_complemet_copy(const SSNBInteger* const src, SSNBInteger* const dst);

// 转为相反数的补码 [x]补 => [-x]补,
// 注意：例如如果是8位整数，不能求-128相反数的补码
// 算法的思想是连同符号位一起求补，即符号位也要取反，可证明是正确的
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_not(const SSNBInteger* const src, SSNBInteger* const dst);


// 字符串转SSNBInteger，以补码存储
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_str_to_bigInt(const char* s, SSNBInteger* const a);

// int64_t转SSNBInteger，以补码存储
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_long_to_bigInt(const int64_t i, SSNBInteger* const a);

// SSNBInteger转字符串，以10进制表示
SSN_BIG_INT_EXTERN const char* ssn_bigint_to_str(SSNBInteger* const a, char* s);

// SSNBInteger转字符串
SSN_BIG_INT_EXTERN const int64_t ssn_bigint_to_long(const SSNBInteger* const a);

//从字节中获取
SSN_BIG_INT_EXTERN int ssn_bigint_transform_in_bytes(const SSNBInteger* const a, void *bytes, const int len);

//从byte中转换 暂时不支持大于int64的数 所以len不能超过8
SSN_BIG_INT_EXTERN void ssn_bigint_transform_from_bytes(const void *bytes, SSNBInteger* const a, const unsigned len);

// 复制SSNBInteger
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_copy(const SSNBInteger* const src, SSNBInteger* const dst);

// 算术左移
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_bit_left_move(const SSNBInteger* const src, const int indent, SSNBInteger* const dst);

// 加法实现
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_add(const SSNBInteger* const a, const  SSNBInteger* const b, SSNBInteger* const result);

// 减法实现
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_sub(const  SSNBInteger* const a, const  SSNBInteger* const b, SSNBInteger* const result);

// 乘法实现 Booth算法[补码1位乘] 转化为移位和加法
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_mul(const  SSNBInteger* const a, const  SSNBInteger* const b, SSNBInteger* const result);

// 在不溢出的情况下，获取最大算术左移的长度
SSN_BIG_INT_EXTERN int ssn_bigint_empty_left_byte_len(const  SSNBInteger* const a);

// 判断Bigint是否为0
SSN_BIG_INT_EXTERN int ssn_is_zero(const SSNBInteger* const a);

// 除法实现 用2分法去求商的各个为1的位 写得不够简洁><
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_div(const SSNBInteger* const a, const SSNBInteger* const b, SSNBInteger* const result, SSNBInteger* const remainder);


// 求模实现
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_mod(const SSNBInteger* const a, const SSNBInteger* const b, SSNBInteger* const remainder);


// 获取SSNBInteger真值的位长度,当为正数时，需要保留符号位
SSN_BIG_INT_EXTERN int ssn_bigint_value_len(const SSNBInteger* const a);

// 幂运算(二进制实现) 不能求负幂
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_pow(const SSNBInteger* const a, const SSNBInteger* const b, SSNBInteger* const result);


// 模幂运算(二进制实现)
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_bigint_pow_mod(const SSNBInteger* const a, const SSNBInteger* const b, const SSNBInteger* const c, SSNBInteger* const result);


// 扩展成 string 方式
SSN_BIG_INT_EXTERN const char* ssn_str_add(const char* s1, const char* s2, char* result);

SSN_BIG_INT_EXTERN const char* ssn_str_sub(const char* s1, const char* s2, char* result);

SSN_BIG_INT_EXTERN const char* ssn_str_mul(const char* s1, const char* s2, char* result);

SSN_BIG_INT_EXTERN const char* ssn_str_div(const char* s1, const char* s2, char* result, char* remainder);

SSN_BIG_INT_EXTERN const char* ssn_str_mod(const char* s1, const char* s2, char* remainder);

SSN_BIG_INT_EXTERN const char* ssn_str_pow(const char* s1, const char* s2, char* result);

SSN_BIG_INT_EXTERN const char* ssn_str_pow_mod(const char* s1, const char* s2, const char* s3, char* result);

#endif /* __ssn__integer__ */

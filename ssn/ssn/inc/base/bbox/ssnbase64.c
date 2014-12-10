//
//  ssnbase64.c
//  ssn
//
//  Created by lingminjun on 14/12/6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "ssnbase64.h"
#include <stdlib.h>
#include <string.h>


static const unsigned char ssn_base64_table[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/**
 * base64_encode - Base64 encode
 * @src: Data to be encoded
 * @len: Length of the data to be encoded
 * @out_len: Pointer to output length variable, or %NULL if not used
 * Returns: Allocated buffer of out_len bytes of encoded data,
 * or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer. Returned buffer is
 * nul terminated to make it easier to use as a C string. The nul terminator is
 * not included in out_len.
 */
unsigned char * ssn_base64_encode(unsigned char *out_buff, const unsigned char *src, unsigned long len, unsigned long *out_len)
{
    unsigned char *out, *pos;
    const unsigned char *end, *in;
    size_t olen;
    
    olen = ssn_base64_encode_length(len); /* 3-byte blocks to 4-byte */
    olen++; /* nul termination */
    if (out_buff) {
        out = out_buff;
    }
    else {
        out = malloc(olen);
    }
    
    if (out == NULL) {
        return NULL;
    }
    
    end = src + len;
    in = src;
    pos = out;
    
    while (end - in >= 3) {
        *pos++ = ssn_base64_table[in[0] >> 2];
        *pos++ = ssn_base64_table[((in[0] & 0x03) << 4) | (in[1] >> 4)];
        *pos++ = ssn_base64_table[((in[1] & 0x0f) << 2) | (in[2] >> 6)];
        *pos++ = ssn_base64_table[in[2] & 0x3f];
        in += 3;
    }
    
    if (end - in) {
        *pos++ = ssn_base64_table[in[0] >> 2];
        if (end - in == 1) {
            *pos++ = ssn_base64_table[(in[0] & 0x03) << 4];
            *pos++ = '=';
        } else {
            *pos++ = ssn_base64_table[((in[0] & 0x03) << 4) |
                                  (in[1] >> 4)];
            *pos++ = ssn_base64_table[(in[1] & 0x0f) << 2];
        }
        *pos++ = '=';
    }
    
    *pos = '\0';
    if (out_len) {
        *out_len = pos - out;
    }
    
    return out;
}

/**
 * base64_decode - Base64 decode
 * @src: Data to be decoded
 * @len: Length of the data to be decoded
 * @out_len: Pointer to output length variable
 * Returns: Allocated buffer of out_len bytes of decoded data,
 * or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer.
 */
unsigned char *ssn_base64_decode(unsigned char *out_buff, const unsigned char *src, unsigned long len, unsigned long *out_len)
{
    unsigned char *out, *pos, in[4], block[4], tmp, c;
    size_t i, count;
    
    if (out_buff) {
        out = out_buff;
    }
    else {
        out = malloc(len + 1);//最后多加一位，放'\0'
        memset(out, 0, len + 1);
    }
    
    if (out == NULL) {
        return NULL;
    }
    
    pos = out;//
    
    count = 0;
    for (i = 0; i < len; i++) {
        
        c = src[i];//取字符
        
        if (c >= 'A' && c <= 'Z') {
            tmp = c - 'A';
        }
        else if (c >= 'a' && c <= 'z') {
            tmp = 26 + c - 'a';
        }
        else if (c >= '0' && c <= '9') {
            tmp = 26 * 2 + c - '0';
        }
        else if (c == '+') {
            tmp = 26 * 2 + 10;
        }
        else if (c == '/') {
            tmp = 26 * 2 + 10 + 1;
        }
        else if (c == '=') {
            tmp = 0;
        }
        else {//其他字符不支持
            continue ;
        }
        
        in[count] = '=';
        block[count] = tmp;
        count++;
        if (count == 4) {
            *pos++ = (block[0] << 2) | (block[1] >> 4);
            *pos++ = (block[1] << 4) | (block[2] >> 2);
            *pos++ = (block[2] << 6) | block[3];
            count = 0;
        }
    }
    
    while (count) {//编码缺省结尾符
        in[count] = '=';
        block[count] = 0;
        count++;
        if (count == 4) {
            *pos++ = (block[0] << 2) | (block[1] >> 4);
            *pos++ = (block[1] << 4) | (block[2] >> 2);
            *pos++ = (block[2] << 6) | block[3];
            count = 0;
        }
    }
    
    if (pos > out) {//去掉结尾字符
        if (in[2] == '=') {
            pos -= 2;
        }
        else if (in[3] == '=') {
            pos--;
        }
    }
    
    *out_len = pos - out;
    if (out_len == 0) {//无法解析数据
        if (!out_buff) {
            free(out);
            out = NULL;
        }
    }
    
    return out;
}

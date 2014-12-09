//
//  ssnbase64.h
//  ssn
//
//  Created by lingminjun on 14/12/6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__ssnbase64__
#define __ssn__ssnbase64__

#if defined(__cplusplus)
#define SSN_BASE64_EXTERN extern "C"
#else
#define SSN_BASE64_EXTERN extern
#endif

#define ssn_base64_encode_length(len) ((len) * 4 / 3 + 4)

/**
 * base64_encode - Base64 encode
 * @buff: require variable length >= (len * 4 / 3 + 4)，you can see ssn_base64_encode_length
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
SSN_BASE64_EXTERN unsigned char *ssn_base64_encode(unsigned char *buff, const unsigned char *src, unsigned long len, unsigned long *out_len);


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
SSN_BASE64_EXTERN unsigned char *ssn_base64_decode(unsigned char *out_buff, const unsigned char *src, unsigned long len, unsigned long *out_len);


#endif /* defined(__ssn__ssnbase64__) */

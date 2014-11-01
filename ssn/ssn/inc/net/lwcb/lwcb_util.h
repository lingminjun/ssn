/**
 * Copyright 2013 Alibaba.com Corporation Limited.
 * All rights reserved.
 *
 * This software is the confidential and proprietary information of
 * Alibaba Company. ("Confidential Information").  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with Alibaba.com.
 */

#ifndef _LWCB_UTIL_H_
#define _LWCB_UTIL_H_

#include <lwcb.h>

int _lwcb_packet_alloc(struct _lwcb_packet *packet);
void _lwcb_check_keepalive(struct lwcb *lwcb);
int _lwcb_fix_sub_topic(char **subtopic);
uint16_t _lwcb_mid_generate(struct lwcb *lwcb);
int _lwcb_topic_wildcard_len_check(const char *str);

#if defined(WITH_TLS) && defined(WITH_TLS_PSK)
int _lwcb_hex2bin(const char *hex, unsigned char *bin, int bin_max_len);
#endif

#endif

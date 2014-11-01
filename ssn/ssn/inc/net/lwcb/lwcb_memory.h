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


#ifndef _LWCB_MEMORY_H_
#define _LWCB_MEMORY_H_

#include <sys/types.h>

#if defined(WITH_MEMORY_TRACKING) && defined(WITH_BROKER) && !defined(WIN32) && !defined(__SYMBIAN32__)
#define REAL_WITH_MEMORY_TRACKING
#endif

void *_lwcb_calloc(size_t nmemb, size_t size);
void _lwcb_free(void *mem);
void *_lwcb_malloc(size_t size);
#ifdef REAL_WITH_MEMORY_TRACKING
unsigned long _lwcb_memory_used(void);
unsigned long _lwcb_max_memory_used(void);
#endif
void *_lwcb_realloc(void *ptr, size_t size);
char *_lwcb_strdup(const char *s);

#endif

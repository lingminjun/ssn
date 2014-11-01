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

#include <lwcb_config.h>

#include <stdlib.h>
#include <string.h>

#include <lwcb_memory.h>

#ifdef REAL_WITH_MEMORY_TRACKING
#  if defined(__APPLE__)
#    define malloc_usable_size malloc_good_size
#  elif defined(__Android__)
#    define malloc_usable_size dlmalloc_usable_size
#  elif defined(__FreeBSD__)
#    include <malloc_np.h>
#  else
#    include <malloc.h>
#  endif
#endif

#include <lwcb_memory.h>

#ifdef REAL_WITH_MEMORY_TRACKING
static unsigned long memcount = 0;
static unsigned long max_memcount = 0;
#endif

void *_lwcb_calloc(size_t nmemb, size_t size)
{
	void *mem = calloc(nmemb, size);

#ifdef REAL_WITH_MEMORY_TRACKING
	memcount += malloc_usable_size(mem);
	if(memcount > max_memcount){
		max_memcount = memcount;
	}
#endif

	return mem;
}

void _lwcb_free(void *mem)
{
#ifdef REAL_WITH_MEMORY_TRACKING
	memcount -= malloc_usable_size(mem);
#endif
	free(mem);
}

void *_lwcb_malloc(size_t size)
{
	void *mem = malloc(size);

#ifdef REAL_WITH_MEMORY_TRACKING
	memcount += malloc_usable_size(mem);
	if(memcount > max_memcount){
		max_memcount = memcount;
	}
#endif

	return mem;
}

#ifdef REAL_WITH_MEMORY_TRACKING
unsigned long _lwcb_memory_used(void)
{
	return memcount;
}

unsigned long _lwcb_max_memory_used(void)
{
	return max_memcount;
}
#endif

void *_lwcb_realloc(void *ptr, size_t size)
{
	void *mem;
#ifdef REAL_WITH_MEMORY_TRACKING
	if(ptr){
		memcount -= malloc_usable_size(ptr);
	}
#endif
	mem = realloc(ptr, size);

#ifdef REAL_WITH_MEMORY_TRACKING
	memcount += malloc_usable_size(mem);
	if(memcount > max_memcount){
		max_memcount = memcount;
	}
#endif

	return mem;
}

char *_lwcb_strdup(const char *s)
{
	char *str = strdup(s);

#ifdef REAL_WITH_MEMORY_TRACKING
	memcount += malloc_usable_size(str);
	if(memcount > max_memcount){
		max_memcount = memcount;
	}
#endif

	return str;
}


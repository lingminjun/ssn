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
 
#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include <lwcb_internal.h>
#include <lwcb.h>
#include <lwcb_memory.h>

int _lwcb_log_printf(struct lwcb *lwcb, int priority, const char *fmt, ...)
{
	va_list va;
	char *s;
	int len;

	assert(lwcb);
	assert(fmt);

	pthread_mutex_lock(&lwcb->log_callback_mutex);

	if(lwcb->on_log){
		len = strlen(fmt) + 500;
		s = _lwcb_malloc(len*sizeof(char));
		if(!s){
			pthread_mutex_unlock(&lwcb->log_callback_mutex);
			return LWCB_ERR_NOMEM;
		}

		va_start(va, fmt);
		vsnprintf(s, len, fmt, va);
		va_end(va);
		s[len-1] = '\0'; /* Ensure string is null terminated. */
		lwcb->on_log(lwcb, lwcb->userdata, priority, s);
		_lwcb_free(s);
	}
	pthread_mutex_unlock(&lwcb->log_callback_mutex);

	return LWCB_ERR_SUCCESS;
}


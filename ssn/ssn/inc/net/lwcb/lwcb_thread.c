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

#ifndef WIN32
#include <unistd.h>
#endif

#include <lwcb_internal.h>
#include <lwcb_logging.h>

void *_lwcb_thread_main(void *obj);

int lwcb_loop_start(struct lwcb *lwcb) {
#ifdef WITH_THREADING
	if(!lwcb) return LWCB_ERR_INVAL;

	pthread_create(&lwcb->thread_id, NULL, _lwcb_thread_main, lwcb);

	return LWCB_ERR_SUCCESS;
#else
	return LWCB_ERR_NOT_SUPPORTED;
#endif
}

int lwcb_loop_stop(struct lwcb *lwcb, bool force) {
#ifdef WITH_THREADING
	if(!lwcb) return LWCB_ERR_INVAL;
	if(force) {
		pthread_cancel(lwcb->thread_id);
	}
	lwcb->thread_id = pthread_self();

	return LWCB_ERR_SUCCESS;
#else
	return LWCB_ERR_NOT_SUPPORTED;
#endif
}

#ifdef WITH_THREADING
void *_lwcb_thread_main(void *obj)
{
	struct lwcb *lwcb = obj;
	int run = 1;
	int rc;

	if(!lwcb) return NULL;

	pthread_mutex_lock(&lwcb->state_mutex);
	if(lwcb->state == lwcb_cs_connect_async) {
		pthread_mutex_unlock(&lwcb->state_mutex);
		lwcb_reconnect(lwcb);
	} else {
		pthread_mutex_unlock(&lwcb->state_mutex);
	}

	while(run) {
		do {
			rc = lwcb_loop(lwcb, -1, 1);
		}while(rc == LWCB_ERR_SUCCESS);
		pthread_mutex_lock(&lwcb->state_mutex);
		if(lwcb->state == lwcb_cs_disconnecting) {
			run = 0;
			pthread_mutex_unlock(&lwcb->state_mutex);
		} else {
			pthread_mutex_unlock(&lwcb->state_mutex);
#ifdef WIN32
			Sleep(1000);
#else
			sleep(1);
#endif
			lwcb_reconnect(lwcb);
		}
	}
	return obj;
}
#endif


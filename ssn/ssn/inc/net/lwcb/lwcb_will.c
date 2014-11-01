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
#include <errno.h>
#include <stdio.h>
#include <string.h>
#ifndef WIN32
#include <sys/select.h>
#include <unistd.h>
#else
#include <winsock2.h>
typedef int ssize_t;
#endif

#include <lwcb.h>
#include <lwcb_internal.h>
#include <lwcb_logging.h>
#include <lwcb_messages.h>
#include <lwcb_memory.h>
#include <lwcb_protocol.h>
#include <lwcb_net.h>
#include <lwcb_read_handle.h>
#include <lwcb_send.h>
#include <lwcb_util.h>

int _lwcb_will_set(struct lwcb *lwcb, const char *topic, int payloadlen, const void *payload, int qos, bool retain)
{
	int rc = LWCB_ERR_SUCCESS;

	if(!lwcb || !topic) return LWCB_ERR_INVAL;
	if(payloadlen < 0 || payloadlen > MQTT_MAX_PAYLOAD) return LWCB_ERR_PAYLOAD_SIZE;
	if(payloadlen > 0 && !payload) return LWCB_ERR_INVAL;

	if(lwcb->will){
		if(lwcb->will->topic){
			_lwcb_free(lwcb->will->topic);
			lwcb->will->topic = NULL;
		}
		if(lwcb->will->payload){
			_lwcb_free(lwcb->will->payload);
			lwcb->will->payload = NULL;
		}
		_lwcb_free(lwcb->will);
		lwcb->will = NULL;
	}

	lwcb->will = _lwcb_calloc(1, sizeof(struct lwcb_message));
	if(!lwcb->will) return LWCB_ERR_NOMEM;
	lwcb->will->topic = _lwcb_strdup(topic);
	if(!lwcb->will->topic){
		rc = LWCB_ERR_NOMEM;
		goto cleanup;
	}
	lwcb->will->payloadlen = payloadlen;
	if(lwcb->will->payloadlen > 0){
		if(!payload){
			rc = LWCB_ERR_INVAL;
			goto cleanup;
		}
		lwcb->will->payload = _lwcb_malloc(sizeof(char)*lwcb->will->payloadlen);
		if(!lwcb->will->payload){
			rc = LWCB_ERR_NOMEM;
			goto cleanup;
		}

		memcpy(lwcb->will->payload, payload, payloadlen);
	}
	lwcb->will->qos = qos;
	lwcb->will->retain = retain;

	return LWCB_ERR_SUCCESS;

cleanup:
	if(lwcb->will){
		if(lwcb->will->topic) _lwcb_free(lwcb->will->topic);
		if(lwcb->will->payload) _lwcb_free(lwcb->will->payload);
	}
	_lwcb_free(lwcb->will);
	lwcb->will = NULL;

	return rc;
}

int _lwcb_will_clear(struct lwcb *lwcb)
{
	if(!lwcb->will) return LWCB_ERR_SUCCESS;

	if(lwcb->will->topic){
		_lwcb_free(lwcb->will->topic);
		lwcb->will->topic = NULL;
	}
	if(lwcb->will->payload){
		_lwcb_free(lwcb->will->payload);
		lwcb->will->payload = NULL;
	}
	_lwcb_free(lwcb->will);
	lwcb->will = NULL;

	return LWCB_ERR_SUCCESS;
}


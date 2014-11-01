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

#include <lwcb.h>
#include <lwcb_logging.h>
#include <lwcb_memory.h>
#include <lwcb_net.h>
#include <lwcb_read_handle.h>

int _lwcb_handle_connack(struct lwcb *lwcb)
{
	uint8_t byte;
	uint8_t result;
	int rc;

	assert(lwcb);
#ifdef WITH_STRICT_PROTOCOL
	if(lwcb->in_packet.remaining_length != 2){
		return LWCB_ERR_PROTOCOL;
	}
#endif
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s received CONNACK", lwcb->id);
	rc = _lwcb_read_byte(&lwcb->in_packet, &byte); // Reserved byte, not used
	if(rc) return rc;
	rc = _lwcb_read_byte(&lwcb->in_packet, &result);
	if(rc) return rc;
	pthread_mutex_lock(&lwcb->callback_mutex);
	if(lwcb->on_connect){
		lwcb->in_callback = true;
		lwcb->on_connect(lwcb, lwcb->userdata, result);
		lwcb->in_callback = false;
	}
	pthread_mutex_unlock(&lwcb->callback_mutex);

	switch(result){
		case 0:
			lwcb->state = lwcb_cs_connected;
			return LWCB_ERR_SUCCESS;
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
			return LWCB_ERR_CONN_REFUSED;
		default:
			return LWCB_ERR_PROTOCOL;
	}
}


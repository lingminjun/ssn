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
#include <stdio.h>
#include <string.h>

#include <lwcb.h>
#include <lwcb_logging.h>
#include <lwcb_memory.h>
#include <lwcb_messages.h>
#include <lwcb_protocol.h>
#include <lwcb_net.h>
#include <lwcb_read_handle.h>
#include <lwcb_send.h>
#include <lwcb_util.h>
#ifdef WITH_BROKER
#include <lwcb_broker.h>
#endif

int _lwcb_handle_pingreq(struct lwcb *lwcb)
{
	assert(lwcb);
#ifdef WITH_STRICT_PROTOCOL
	if(lwcb->in_packet.remaining_length != 0){
		return LWCB_ERR_PROTOCOL;
	}
#endif
#ifdef WITH_BROKER
	_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Received PINGREQ from %s", lwcb->id);
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s received PINGREQ", lwcb->id);
#endif
	return _lwcb_send_pingresp(lwcb);
}

int _lwcb_handle_pingresp(struct lwcb *lwcb)
{
	assert(lwcb);
#ifdef WITH_STRICT_PROTOCOL
	if(lwcb->in_packet.remaining_length != 0){
		return LWCB_ERR_PROTOCOL;
	}
#endif
	lwcb->ping_t = 0; /* No longer waiting for a PINGRESP. */
#ifdef WITH_BROKER
	_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Received PINGRESP from %s", lwcb->id);
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s received PINGRESP", lwcb->id);
#endif
	return LWCB_ERR_SUCCESS;
}

int _lwcb_handle_pubackcomp(struct lwcb *lwcb, const char *type)
{
	uint16_t mid;
	int rc;

	assert(lwcb);
#ifdef WITH_STRICT_PROTOCOL
	if(lwcb->in_packet.remaining_length != 2){
		return LWCB_ERR_PROTOCOL;
	}
#endif
	rc = _lwcb_read_uint16(&lwcb->in_packet, &mid);
	if(rc) return rc;
#ifdef WITH_BROKER
	_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Received %s from %s (Mid: %d)", type, lwcb->id, mid);

	if(mid){
		rc = mqtt3_db_message_delete(lwcb, mid, lwcb_md_out);
		if(rc) return rc;
	}
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s received %s (Mid: %d)", lwcb->id, type, mid);

	if(!_lwcb_message_delete(lwcb, mid, lwcb_md_out)){
		/* Only inform the client the message has been sent once. */
		pthread_mutex_lock(&lwcb->callback_mutex);
		if(lwcb->on_publish){
			lwcb->in_callback = true;
			lwcb->on_publish(lwcb, lwcb->userdata, mid);
			lwcb->in_callback = false;
		}
		pthread_mutex_unlock(&lwcb->callback_mutex);
	}
#endif

	return LWCB_ERR_SUCCESS;
}

int _lwcb_handle_pubrec(struct lwcb *lwcb)
{
	uint16_t mid;
	int rc;

	assert(lwcb);
#ifdef WITH_STRICT_PROTOCOL
	if(lwcb->in_packet.remaining_length != 2){
		return LWCB_ERR_PROTOCOL;
	}
#endif
	rc = _lwcb_read_uint16(&lwcb->in_packet, &mid);
	if(rc) return rc;
#ifdef WITH_BROKER
	_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Received PUBREC from %s (Mid: %d)", lwcb->id, mid);

	rc = mqtt3_db_message_update(lwcb, mid, lwcb_md_out, ms_wait_for_pubcomp);
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s received PUBREC (Mid: %d)", lwcb->id, mid);

	rc = _lwcb_message_update(lwcb, mid, lwcb_md_out, lwcb_ms_wait_pubcomp);
#endif
	if(rc) return rc;
	rc = _lwcb_send_pubrel(lwcb, mid, false);
	if(rc) return rc;

	return LWCB_ERR_SUCCESS;
}

int _lwcb_handle_pubrel(struct lwcb_db *db, struct lwcb *lwcb)
{
	uint16_t mid;
#ifndef WITH_BROKER
	struct lwcb_message_all *message = NULL;
#endif
	int rc;

	assert(lwcb);
#ifdef WITH_STRICT_PROTOCOL
	if(lwcb->in_packet.remaining_length != 2){
		return LWCB_ERR_PROTOCOL;
	}
#endif
	rc = _lwcb_read_uint16(&lwcb->in_packet, &mid);
	if(rc) return rc;
#ifdef WITH_BROKER
	_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Received PUBREL from %s (Mid: %d)", lwcb->id, mid);

	if(mqtt3_db_message_release(db, lwcb, mid, lwcb_md_in)){
		/* Message not found. */
		return LWCB_ERR_SUCCESS;
	}
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s received PUBREL (Mid: %d)", lwcb->id, mid);

	if(!_lwcb_message_remove(lwcb, mid, lwcb_md_in, &message)){
		/* Only pass the message on if we have removed it from the queue - this
		 * prevents multiple callbacks for the same message. */
		pthread_mutex_lock(&lwcb->callback_mutex);
		if(lwcb->on_message){
			lwcb->in_callback = true;
			lwcb->on_message(lwcb, lwcb->userdata, &message->msg);
			lwcb->in_callback = false;
		}
		pthread_mutex_unlock(&lwcb->callback_mutex);
		_lwcb_message_cleanup(&message);
	}
#endif
	rc = _lwcb_send_pubcomp(lwcb, mid);
	if(rc) return rc;

	return LWCB_ERR_SUCCESS;
}

int _lwcb_handle_suback(struct lwcb *lwcb)
{
	uint16_t mid;
	uint8_t qos;
	int *granted_qos;
	int qos_count;
	int i = 0;
	int rc;

	assert(lwcb);
#ifdef WITH_BROKER
	_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Received SUBACK from %s", lwcb->id);
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s received SUBACK", lwcb->id);
#endif
	rc = _lwcb_read_uint16(&lwcb->in_packet, &mid);
	if(rc) return rc;

	qos_count = lwcb->in_packet.remaining_length - lwcb->in_packet.pos;
	granted_qos = _lwcb_malloc(qos_count*sizeof(int));
	if(!granted_qos) return LWCB_ERR_NOMEM;
	while(lwcb->in_packet.pos < lwcb->in_packet.remaining_length){
		rc = _lwcb_read_byte(&lwcb->in_packet, &qos);
		if(rc){
			_lwcb_free(granted_qos);
			return rc;
		}
		granted_qos[i] = (int)qos;
		i++;
	}
#ifndef WITH_BROKER
	pthread_mutex_lock(&lwcb->callback_mutex);
	if(lwcb->on_subscribe){
		lwcb->in_callback = true;
		lwcb->on_subscribe(lwcb, lwcb->userdata, mid, qos_count, granted_qos);
		lwcb->in_callback = false;
	}
	pthread_mutex_unlock(&lwcb->callback_mutex);
#endif
	_lwcb_free(granted_qos);

	return LWCB_ERR_SUCCESS;
}

int _lwcb_handle_unsuback(struct lwcb *lwcb)
{
	uint16_t mid;
	int rc;

	assert(lwcb);
#ifdef WITH_STRICT_PROTOCOL
	if(lwcb->in_packet.remaining_length != 2){
		return LWCB_ERR_PROTOCOL;
	}
#endif
#ifdef WITH_BROKER
	_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Received UNSUBACK from %s", lwcb->id);
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s received UNSUBACK", lwcb->id);
#endif
	rc = _lwcb_read_uint16(&lwcb->in_packet, &mid);
	if(rc) return rc;
#ifndef WITH_BROKER
	pthread_mutex_lock(&lwcb->callback_mutex);
	if(lwcb->on_unsubscribe){
		lwcb->in_callback = true;
	   	lwcb->on_unsubscribe(lwcb, lwcb->userdata, mid);
		lwcb->in_callback = false;
	}
	pthread_mutex_unlock(&lwcb->callback_mutex);
#endif

	return LWCB_ERR_SUCCESS;
}


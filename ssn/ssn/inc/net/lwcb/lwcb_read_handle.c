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

int _lwcb_packet_handle(struct lwcb *lwcb)
{
	assert(lwcb);

	switch((lwcb->in_packet.command)&0xF0){
		case PINGREQ:
			return _lwcb_handle_pingreq(lwcb);
		case PINGRESP:
			return _lwcb_handle_pingresp(lwcb);
		case PUBACK:
			return _lwcb_handle_pubackcomp(lwcb, "PUBACK");
		case PUBCOMP:
			return _lwcb_handle_pubackcomp(lwcb, "PUBCOMP");
		case PUBLISH:
			return _lwcb_handle_publish(lwcb);
		case PUBREC:
			return _lwcb_handle_pubrec(lwcb);
		case PUBREL:
			return _lwcb_handle_pubrel(NULL, lwcb);
		case CONNACK:
			return _lwcb_handle_connack(lwcb);
		case SUBACK:
			return _lwcb_handle_suback(lwcb);
		case UNSUBACK:
			return _lwcb_handle_unsuback(lwcb);
		default:
			/* If we don't recognise the command, return an error straight away. */
			_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unrecognised command %d\n", (lwcb->in_packet.command)&0xF0);
			return LWCB_ERR_PROTOCOL;
	}
}

int _lwcb_handle_publish(struct lwcb *lwcb)
{
	uint8_t header;
	struct lwcb_message_all *message;
	int rc = 0;
	uint16_t mid;

	assert(lwcb);

	message = _lwcb_calloc(1, sizeof(struct lwcb_message_all));
	if(!message) return LWCB_ERR_NOMEM;

	header = lwcb->in_packet.command;

	message->direction = lwcb_md_in;
	message->dup = (header & 0x08)>>3;
	message->msg.qos = (header & 0x06)>>1;
	message->msg.retain = (header & 0x01);

	rc = _lwcb_read_string(&lwcb->in_packet, &message->msg.topic);
	if(rc){
		_lwcb_message_cleanup(&message);
		return rc;
	}
	rc = _lwcb_fix_sub_topic(&message->msg.topic);
	if(rc){
		_lwcb_message_cleanup(&message);
		return rc;
	}
	if(!strlen(message->msg.topic)){
		_lwcb_message_cleanup(&message);
		return LWCB_ERR_PROTOCOL;
	}

	if(message->msg.qos > 0){
		rc = _lwcb_read_uint16(&lwcb->in_packet, &mid);
		if(rc){
			_lwcb_message_cleanup(&message);
			return rc;
		}
		message->msg.mid = (int)mid;
	}

	message->msg.payloadlen = lwcb->in_packet.remaining_length - lwcb->in_packet.pos;
	if(message->msg.payloadlen){
		message->msg.payload = _lwcb_calloc(message->msg.payloadlen+1, sizeof(uint8_t));
		rc = _lwcb_read_bytes(&lwcb->in_packet, message->msg.payload, message->msg.payloadlen);
		if(rc){
			_lwcb_message_cleanup(&message);
			return rc;
		}
	}
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG,
			"Client %s received PUBLISH (d%d, q%d, r%d, m%d, '%s', ... (%ld bytes))",
			lwcb->id, message->dup, message->msg.qos, message->msg.retain,
			message->msg.mid, message->msg.topic,
			(long)message->msg.payloadlen);

	message->timestamp = time(NULL);
	switch(message->msg.qos){
		case 0:
			pthread_mutex_lock(&lwcb->callback_mutex);
			if(lwcb->on_message){
				lwcb->in_callback = true;
				lwcb->on_message(lwcb, lwcb->userdata, &message->msg);
				lwcb->in_callback = false;
			}
			pthread_mutex_unlock(&lwcb->callback_mutex);
			_lwcb_message_cleanup(&message);
			return LWCB_ERR_SUCCESS;
		case 1:
			rc = _lwcb_send_puback(lwcb, message->msg.mid);
			pthread_mutex_lock(&lwcb->callback_mutex);
			if(lwcb->on_message){
				lwcb->in_callback = true;
				lwcb->on_message(lwcb, lwcb->userdata, &message->msg);
				lwcb->in_callback = false;
			}
			pthread_mutex_unlock(&lwcb->callback_mutex);
			_lwcb_message_cleanup(&message);
			return rc;
		case 2:
			rc = _lwcb_send_pubrec(lwcb, message->msg.mid);
			message->state = lwcb_ms_wait_pubrel;
			_lwcb_message_queue(lwcb, message);
			return rc;
		default:
			return LWCB_ERR_PROTOCOL;
	}
}


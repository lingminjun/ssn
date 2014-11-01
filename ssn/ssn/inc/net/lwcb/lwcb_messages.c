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
#include <stdlib.h>
#include <string.h>

#include <lwcb_internal.h>
#include <lwcb.h>
#include <lwcb_memory.h>
#include <lwcb_messages.h>
#include <lwcb_send.h>

void _lwcb_message_cleanup(struct lwcb_message_all **message)
{
	struct lwcb_message_all *msg;

	if(!message || !*message) return;

	msg = *message;

	if(msg->msg.topic) _lwcb_free(msg->msg.topic);
	if(msg->msg.payload) _lwcb_free(msg->msg.payload);
	_lwcb_free(msg);
}

void _lwcb_message_cleanup_all(struct lwcb *lwcb)
{
	struct lwcb_message_all *tmp;

	assert(lwcb);

	while(lwcb->messages){
		tmp = lwcb->messages->next;
		_lwcb_message_cleanup(&lwcb->messages);
		lwcb->messages = tmp;
	}
}

int lwcb_message_copy(struct lwcb_message *dst, const struct lwcb_message *src)
{
	if(!dst || !src) return LWCB_ERR_INVAL;

	dst->mid = src->mid;
	dst->topic = _lwcb_strdup(src->topic);
	if(!dst->topic) return LWCB_ERR_NOMEM;
	dst->qos = src->qos;
	dst->retain = src->retain;
	if(src->payloadlen){
		dst->payload = _lwcb_malloc(src->payloadlen);
		if(!dst->payload){
			_lwcb_free(dst->topic);
			return LWCB_ERR_NOMEM;
		}
		memcpy(dst->payload, src->payload, src->payloadlen);
		dst->payloadlen = src->payloadlen;
	}else{
		dst->payloadlen = 0;
		dst->payload = NULL;
	}
	return LWCB_ERR_SUCCESS;
}

int _lwcb_message_delete(struct lwcb *lwcb, uint16_t mid, enum lwcb_msg_direction dir)
{
	struct lwcb_message_all *message;
	int rc;
	assert(lwcb);

	rc = _lwcb_message_remove(lwcb, mid, dir, &message);
	if(rc == LWCB_ERR_SUCCESS){
		_lwcb_message_cleanup(&message);
	}
	return rc;
}

void lwcb_message_free(struct lwcb_message **message)
{
	struct lwcb_message *msg;

	if(!message || !*message) return;

	msg = *message;

	if(msg->topic) _lwcb_free(msg->topic);
	if(msg->payload) _lwcb_free(msg->payload);
	_lwcb_free(msg);
}

void _lwcb_message_queue(struct lwcb *lwcb, struct lwcb_message_all *message)
{
	struct lwcb_message_all *tail;

	assert(lwcb);
	assert(message);

	lwcb->queue_len++;
	message->next = NULL;
	if(lwcb->messages){
		tail = lwcb->messages;
		while(tail->next){
			tail = tail->next;
		}
		tail->next = message;
	}else{
		lwcb->messages = message;
	}
}

void _lwcb_messages_reconnect_reset(struct lwcb *lwcb)
{
	struct lwcb_message_all *message;
	struct lwcb_message_all *prev = NULL;
	assert(lwcb);

	lwcb->queue_len = 0;
	message = lwcb->messages;
	while(message){
		message->timestamp = 0;
		if(message->direction == lwcb_md_out){
			if(message->msg.qos == 1){
				message->state = lwcb_ms_wait_puback;
			}else if(message->msg.qos == 2){
				message->state = lwcb_ms_wait_pubrec;
			}
			lwcb->queue_len++;
		}else{
			if(prev){
				prev->next = message->next;
				_lwcb_message_cleanup(&message);
				message = prev;
			}else{
				lwcb->messages = message->next;
				_lwcb_message_cleanup(&message);
				message = lwcb->messages;
			}
		}
		prev = message;
		message = message->next;
	}
}

int _lwcb_message_remove(struct lwcb *lwcb, uint16_t mid, enum lwcb_msg_direction dir, struct lwcb_message_all **message)
{
	struct lwcb_message_all *cur, *prev = NULL;
	assert(lwcb);
	assert(message);

	cur = lwcb->messages;
	while(cur){
		if(cur->msg.mid == mid && cur->direction == dir){
			if(prev){
				prev->next = cur->next;
			}else{
				lwcb->messages = cur->next;
			}
			*message = cur;
			lwcb->queue_len--;
			return LWCB_ERR_SUCCESS;
		}
		prev = cur;
		cur = cur->next;
	}
	return LWCB_ERR_NOT_FOUND;
}

void _lwcb_message_retry_check(struct lwcb *lwcb)
{
	struct lwcb_message_all *message;
	time_t now = time(NULL);
	assert(lwcb);

	message = lwcb->messages;
	while(message){
		if(message->timestamp + lwcb->message_retry < now){
			switch(message->state){
				case lwcb_ms_wait_puback:
				case lwcb_ms_wait_pubrec:
					message->timestamp = now;
					message->dup = true;
					_lwcb_send_publish(lwcb, message->msg.mid, message->msg.topic, message->msg.payloadlen, message->msg.payload, message->msg.qos, message->msg.retain, message->dup);
					break;
				case lwcb_ms_wait_pubrel:
					message->timestamp = now;
					message->dup = true;
					_lwcb_send_pubrec(lwcb, message->msg.mid);
					break;
				case lwcb_ms_wait_pubcomp:
					message->timestamp = now;
					message->dup = true;
					_lwcb_send_pubrel(lwcb, message->msg.mid, true);
					break;
				default:
					break;
			}
		}
		message = message->next;
	}
}

void lwcb_message_retry_set(struct lwcb *lwcb, unsigned int message_retry)
{
	assert(lwcb);
	if(lwcb) lwcb->message_retry = message_retry;
}

int _lwcb_message_update(struct lwcb *lwcb, uint16_t mid, enum lwcb_msg_direction dir, enum lwcb_msg_state state)
{
	struct lwcb_message_all *message;
	assert(lwcb);

	message = lwcb->messages;
	while(message){
		if(message->msg.mid == mid && message->direction == dir){
			message->state = state;
			message->timestamp = time(NULL);
			return LWCB_ERR_SUCCESS;
		}
		message = message->next;
	}
	return LWCB_ERR_NOT_FOUND;
}


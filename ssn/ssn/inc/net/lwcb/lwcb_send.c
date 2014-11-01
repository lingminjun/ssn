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
#include <lwcb_internal.h>
#include <lwcb_logging.h>
#include <lwcb_protocol.h>
#include <lwcb_memory.h>
#include <lwcb_net.h>
#include <lwcb_send.h>
#include <lwcb_util.h>

#ifdef WITH_BROKER
#include <lwcb_broker.h>
extern uint64_t g_pub_bytes_sent;
#endif

int _lwcb_send_pingreq(struct lwcb *lwcb)
{
	int rc;
	assert(lwcb);
#ifdef WITH_BROKER
	_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Sending PINGREQ to %s", lwcb->id);
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending PINGREQ", lwcb->id);
#endif
	rc = _lwcb_send_simple_command(lwcb, PINGREQ);
	if(rc == LWCB_ERR_SUCCESS){
		lwcb->ping_t = time(NULL);
	}
	return rc;
}

int _lwcb_send_pingresp(struct lwcb *lwcb)
{
#ifdef WITH_BROKER
	if(lwcb) _lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Sending PINGRESP to %s", lwcb->id);
#else
	if(lwcb) _lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending PINGRESP", lwcb->id);
#endif
	return _lwcb_send_simple_command(lwcb, PINGRESP);
}

int _lwcb_send_puback(struct lwcb *lwcb, uint16_t mid)
{
#ifdef WITH_BROKER
	if(lwcb) _lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Sending PUBACK to %s (Mid: %d)", lwcb->id, mid);
#else
	if(lwcb) _lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending PUBACK (Mid: %d)", lwcb->id, mid);
#endif
	return _lwcb_send_command_with_mid(lwcb, PUBACK, mid, false);
}

int _lwcb_send_pubcomp(struct lwcb *lwcb, uint16_t mid)
{
#ifdef WITH_BROKER
	if(lwcb) _lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Sending PUBCOMP to %s (Mid: %d)", lwcb->id, mid);
#else
	if(lwcb) _lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending PUBCOMP (Mid: %d)", lwcb->id, mid);
#endif
	return _lwcb_send_command_with_mid(lwcb, PUBCOMP, mid, false);
}

int _lwcb_send_publish(struct lwcb *lwcb, uint16_t mid, const char *topic, uint32_t payloadlen, const void *payload, int qos, bool retain, bool dup)
{
#ifdef WITH_BROKER
	size_t len;
#ifdef WITH_BRIDGE
	int i;
	struct _mqtt3_bridge_topic *cur_topic;
	bool match;
	int rc;
	char *mapped_topic = NULL;
	char *topic_temp = NULL;
#endif
#endif
	assert(lwcb);
	assert(topic);

	if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;
#ifdef WITH_BROKER
	if(lwcb->listener && lwcb->listener->mount_point){
		len = strlen(lwcb->listener->mount_point);
		if(len > strlen(topic)){
			topic += strlen(lwcb->listener->mount_point);
		}else{
			/* Invalid topic string. Should never happen, but silently swallow the message anyway. */
			return LWCB_ERR_SUCCESS;
		}
	}
#ifdef WITH_BRIDGE
	if(lwcb->bridge && lwcb->bridge->topics && lwcb->bridge->topic_remapping){
		for(i=0; i<lwcb->bridge->topic_count; i++){
			cur_topic = &lwcb->bridge->topics[i];
			if(cur_topic->remote_prefix || cur_topic->local_prefix){
				/* Topic mapping required on this topic if the message matches */

				rc = lwcb_topic_matches_sub(cur_topic->local_topic, topic, &match);
				if(rc){
					return rc;
				}
				if(match){
					mapped_topic = _lwcb_strdup(topic);
					if(!mapped_topic) return LWCB_ERR_NOMEM;
					if(cur_topic->local_prefix){
						/* This prefix needs removing. */
						if(!strncmp(cur_topic->local_prefix, mapped_topic, strlen(cur_topic->local_prefix))){
							topic_temp = _lwcb_strdup(mapped_topic+strlen(cur_topic->local_prefix));
							_lwcb_free(mapped_topic);
							if(!topic_temp){
								return LWCB_ERR_NOMEM;
							}
							mapped_topic = topic_temp;
						}
					}

					if(cur_topic->remote_prefix){
						/* This prefix needs adding. */
						len = strlen(mapped_topic) + strlen(cur_topic->remote_prefix)+1;
						topic_temp = _lwcb_calloc(len+1, sizeof(char));
						if(!topic_temp){
							_lwcb_free(mapped_topic);
							return LWCB_ERR_NOMEM;
						}
						snprintf(topic_temp, len, "%s%s", cur_topic->remote_prefix, mapped_topic);
						_lwcb_free(mapped_topic);
						mapped_topic = topic_temp;
					}
					_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Sending PUBLISH to %s (d%d, q%d, r%d, m%d, '%s', ... (%ld bytes))", lwcb->id, dup, qos, retain, mid, mapped_topic, (long)payloadlen);
					g_pub_bytes_sent += payloadlen;
					rc =  _lwcb_send_real_publish(lwcb, mid, mapped_topic, payloadlen, payload, qos, retain, dup);
					_lwcb_free(mapped_topic);
					return rc;
				}
			}
		}
	}
#endif
	_lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Sending PUBLISH to %s (d%d, q%d, r%d, m%d, '%s', ... (%ld bytes))", lwcb->id, dup, qos, retain, mid, topic, (long)payloadlen);
	g_pub_bytes_sent += payloadlen;
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending PUBLISH (d%d, q%d, r%d, m%d, '%s', ... (%ld bytes))", lwcb->id, dup, qos, retain, mid, topic, (long)payloadlen);
#endif

	return _lwcb_send_real_publish(lwcb, mid, topic, payloadlen, payload, qos, retain, dup);
}

int _lwcb_send_pubrec(struct lwcb *lwcb, uint16_t mid)
{
#ifdef WITH_BROKER
	if(lwcb) _lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Sending PUBREC to %s (Mid: %d)", lwcb->id, mid);
#else
	if(lwcb) _lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending PUBREC (Mid: %d)", lwcb->id, mid);
#endif
	return _lwcb_send_command_with_mid(lwcb, PUBREC, mid, false);
}

int _lwcb_send_pubrel(struct lwcb *lwcb, uint16_t mid, bool dup)
{
#ifdef WITH_BROKER
	if(lwcb) _lwcb_log_printf(NULL, LWCB_LOG_DEBUG, "Sending PUBREL to %s (Mid: %d)", lwcb->id, mid);
#else
	if(lwcb) _lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending PUBREL (Mid: %d)", lwcb->id, mid);
#endif
	return _lwcb_send_command_with_mid(lwcb, PUBREL|2, mid, dup);
}

/* For PUBACK, PUBCOMP, PUBREC, and PUBREL */
int _lwcb_send_command_with_mid(struct lwcb *lwcb, uint8_t command, uint16_t mid, bool dup)
{
	struct _lwcb_packet *packet = NULL;
	int rc;

	assert(lwcb);
	packet = _lwcb_calloc(1, sizeof(struct _lwcb_packet));
	if(!packet) return LWCB_ERR_NOMEM;

	packet->command = command;
	if(dup){
		packet->command |= 8;
	}
	packet->remaining_length = 2;
	rc = _lwcb_packet_alloc(packet);
	if(rc){
		_lwcb_free(packet);
		return rc;
	}

	packet->payload[packet->pos+0] = LWCB_MSB(mid);
	packet->payload[packet->pos+1] = LWCB_LSB(mid);

	return _lwcb_packet_queue(lwcb, packet);
}

/* For DISCONNECT, PINGREQ and PINGRESP */
int _lwcb_send_simple_command(struct lwcb *lwcb, uint8_t command)
{
	struct _lwcb_packet *packet = NULL;
	int rc;

	assert(lwcb);
	packet = _lwcb_calloc(1, sizeof(struct _lwcb_packet));
	if(!packet) return LWCB_ERR_NOMEM;

	packet->command = command;
	packet->remaining_length = 0;

	rc = _lwcb_packet_alloc(packet);
	if(rc){
		_lwcb_free(packet);
		return rc;
	}

	return _lwcb_packet_queue(lwcb, packet);
}

int _lwcb_send_real_publish(struct lwcb *lwcb, uint16_t mid, const char *topic, uint32_t payloadlen, const void *payload, int qos, bool retain, bool dup)
{
	struct _lwcb_packet *packet = NULL;
	int packetlen;
	int rc;

	assert(lwcb);
	assert(topic);

	packetlen = 2+strlen(topic) + payloadlen;
	if(qos > 0) packetlen += 2; /* For message id */
	packet = _lwcb_calloc(1, sizeof(struct _lwcb_packet));
	if(!packet) return LWCB_ERR_NOMEM;

	packet->mid = mid;
	packet->command = PUBLISH | ((dup&0x1)<<3) | (qos<<1) | retain;
	packet->remaining_length = packetlen;
	rc = _lwcb_packet_alloc(packet);
	if(rc){
		_lwcb_free(packet);
		return rc;
	}
	/* Variable header (topic string) */
	_lwcb_write_string(packet, topic, strlen(topic));
	if(qos > 0){
		_lwcb_write_uint16(packet, mid);
	}

	/* Payload */
	if(payloadlen){
		_lwcb_write_bytes(packet, payload, payloadlen);
	}

	return _lwcb_packet_queue(lwcb, packet);
}

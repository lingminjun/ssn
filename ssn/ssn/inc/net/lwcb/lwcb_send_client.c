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
#include <string.h>

#include <lwcb.h>
#include <lwcb_logging.h>
#include <lwcb_memory.h>
#include <lwcb_protocol.h>
#include <lwcb_net.h>
#include <lwcb_send.h>
#include <lwcb_util.h>

#ifdef WITH_BROKER
#include <lwcb_broker.h>
#endif

int _lwcb_send_connect(struct lwcb *lwcb, uint16_t keepalive, bool clean_session)
{
	struct _lwcb_packet *packet = NULL;
	int payloadlen;
	uint8_t will = 0;
	uint8_t byte;
	int rc;
	uint8_t version = PROTOCOL_VERSION;

	assert(lwcb);
	assert(lwcb->id);

	packet = _lwcb_calloc(1, sizeof(struct _lwcb_packet));
	if(!packet) return LWCB_ERR_NOMEM;

	payloadlen = 2+strlen(lwcb->id);
	if(lwcb->will){
		will = 1;
		assert(lwcb->will->topic);

		payloadlen += 2+strlen(lwcb->will->topic) + 2+lwcb->will->payloadlen;
	}
	if(lwcb->username){
		payloadlen += 2+strlen(lwcb->username);
		if(lwcb->password){
			payloadlen += 2+strlen(lwcb->password);
		}
	}

	packet->command = CONNECT;
	packet->remaining_length = 12+payloadlen;
	rc = _lwcb_packet_alloc(packet);
	if(rc){
		_lwcb_free(packet);
		return rc;
	}

	/* Variable header */
	_lwcb_write_string(packet, PROTOCOL_NAME, strlen(PROTOCOL_NAME));
#if defined(WITH_BROKER) && defined(WITH_BRIDGE)
	if(lwcb->bridge && lwcb->bridge->try_private && lwcb->bridge->try_private_accepted){
		version |= 0x80;
	}else{
	}
#endif
	_lwcb_write_byte(packet, version);
	byte = (clean_session&0x1)<<1;
	if(will){
		byte = byte | ((lwcb->will->retain&0x1)<<5) | ((lwcb->will->qos&0x3)<<3) | ((will&0x1)<<2);
	}
	if(lwcb->username){
		byte = byte | 0x1<<7;
		if(lwcb->password){
			byte = byte | 0x1<<6;
		}
	}
	_lwcb_write_byte(packet, byte);
	_lwcb_write_uint16(packet, keepalive);

	/* Payload */
	_lwcb_write_string(packet, lwcb->id, strlen(lwcb->id));
	if(will){
		_lwcb_write_string(packet, lwcb->will->topic, strlen(lwcb->will->topic));
		_lwcb_write_string(packet, (const char *)lwcb->will->payload, lwcb->will->payloadlen);
	}
	if(lwcb->username){
		_lwcb_write_string(packet, lwcb->username, strlen(lwcb->username));
		if(lwcb->password){
			_lwcb_write_string(packet, lwcb->password, strlen(lwcb->password));
		}
	}

	lwcb->keepalive = keepalive;
#ifdef WITH_BROKER
# ifdef WITH_BRIDGE
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Bridge %s sending CONNECT", lwcb->id);
# endif
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending CONNECT", lwcb->id);
#endif
	return _lwcb_packet_queue(lwcb, packet);
}

int _lwcb_send_disconnect(struct lwcb *lwcb)
{
	assert(lwcb);
#ifdef WITH_BROKER
# ifdef WITH_BRIDGE
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Bridge %s sending DISCONNECT", lwcb->id);
# endif
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending DISCONNECT", lwcb->id);
#endif
	return _lwcb_send_simple_command(lwcb, DISCONNECT);
}


int _lwcb_send_subscribes(struct lwcb *lwcb, int *mid, bool dup, int count, const char *topics[], uint8_t topic_qos[]) {

	struct _lwcb_packet *packet = NULL;
	uint32_t packetlen;
	uint16_t local_mid;
	int rc;

	assert(lwcb);
	assert(topics);

	packet = _lwcb_calloc(1, sizeof(struct _lwcb_packet));
	if(!packet) return LWCB_ERR_NOMEM;

	packetlen = 2;
	for (int i = 0; i < count; i++) {
		packetlen += 2 + strlen(topics[i]) + 1;
	}

	packet->command = SUBSCRIBE | (dup<<3) | (1<<1);
	packet->remaining_length = packetlen;
	rc = _lwcb_packet_alloc(packet);
	if(rc){
		_lwcb_free(packet);
		return rc;
	}

	/* Variable header */
	local_mid = _lwcb_mid_generate(lwcb);
	if(mid) *mid = (int)local_mid;
	_lwcb_write_uint16(packet, local_mid);

	/* Payload */
	for (int i = 0; i < count; i++) {
		_lwcb_write_string(packet, topics[i], strlen(topics[i]));
		_lwcb_write_byte(packet, topic_qos[i]);
	}

#ifdef WITH_BROKER
# ifdef WITH_BRIDGE
	for (int i = 0; i < count; i++) {
		_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Bridge %s sending SUBSCRIBE (Mid: %d, Topic: %s, QoS: %d)", lwcb->id, local_mid, topics[i], topic_qos[i]);
	}
# endif
#else
	for (int i = 0; i < count; i++) {
		_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending SUBSCRIBE (Mid: %d, Topic: %s, QoS: %d)", lwcb->id, local_mid, topics[i], topic_qos[i]);
	}
#endif

	return _lwcb_packet_queue(lwcb, packet);
}

int _lwcb_send_subscribe(struct lwcb *lwcb, int *mid, bool dup, const char *topic, uint8_t topic_qos)
{
	/* FIXME - only deals with a single topic */
	struct _lwcb_packet *packet = NULL;
	uint32_t packetlen;
	uint16_t local_mid;
	int rc;

	assert(lwcb);
	assert(topic);

	packet = _lwcb_calloc(1, sizeof(struct _lwcb_packet));
	if(!packet) return LWCB_ERR_NOMEM;

	packetlen = 2 + 2+strlen(topic) + 1;

	packet->command = SUBSCRIBE | (dup<<3) | (1<<1);
	packet->remaining_length = packetlen;
	rc = _lwcb_packet_alloc(packet);
	if(rc){
		_lwcb_free(packet);
		return rc;
	}

	/* Variable header */
	local_mid = _lwcb_mid_generate(lwcb);
	if(mid) *mid = (int)local_mid;
	_lwcb_write_uint16(packet, local_mid);

	/* Payload */
	_lwcb_write_string(packet, topic, strlen(topic));
	_lwcb_write_byte(packet, topic_qos);

#ifdef WITH_BROKER
# ifdef WITH_BRIDGE
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Bridge %s sending SUBSCRIBE (Mid: %d, Topic: %s, QoS: %d)", lwcb->id, local_mid, topic, topic_qos);
# endif
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending SUBSCRIBE (Mid: %d, Topic: %s, QoS: %d)", lwcb->id, local_mid, topic, topic_qos);
#endif

	return _lwcb_packet_queue(lwcb, packet);
}


int _lwcb_send_unsubscribes(struct lwcb *lwcb, int *mid, bool dup, int count, const char *topics[]) {
	struct _lwcb_packet *packet = NULL;
	uint32_t packetlen;
	uint16_t local_mid;
	int rc;

	assert(lwcb);
	assert(topics);

	packet = _lwcb_calloc(1, sizeof(struct _lwcb_packet));
	if(!packet) return LWCB_ERR_NOMEM;

	packetlen = 2;

	for (int i = 0; i< count; i++) {
		packetlen+=2+strlen(topics[i]);
	}

	packet->command = UNSUBSCRIBE | (dup<<3) | (1<<1);
	packet->remaining_length = packetlen;
	rc = _lwcb_packet_alloc(packet);
	if(rc){
		_lwcb_free(packet);
		return rc;
	}

	/* Variable header */
	local_mid = _lwcb_mid_generate(lwcb);
	if(mid) *mid = (int)local_mid;
	_lwcb_write_uint16(packet, local_mid);

	/* Payload */
	for (int i = 0; i< count; i++) {
		_lwcb_write_string(packet, topics[i], strlen(topics[i]));
	}
#ifdef WITH_BROKER
# ifdef WITH_BRIDGE
	for (int i = 0; i < count; i++) {
		_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Bridge %s sending UNSUBSCRIBE (Mid: %d, Topic: %s)", lwcb->id, local_mid, topics[i]);
	}
# endif
#else
	for (int i = 0; i < count; i++) {
		_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending UNSUBSCRIBE (Mid: %d, Topic: %s)", lwcb->id, local_mid, topics[i]);
	}
#endif
	return _lwcb_packet_queue(lwcb, packet);
}

int _lwcb_send_unsubscribe(struct lwcb *lwcb, int *mid, bool dup, const char *topic)
{
	/* FIXME - only deals with a single topic */
	struct _lwcb_packet *packet = NULL;
	uint32_t packetlen;
	uint16_t local_mid;
	int rc;

	assert(lwcb);
	assert(topic);

	packet = _lwcb_calloc(1, sizeof(struct _lwcb_packet));
	if(!packet) return LWCB_ERR_NOMEM;

	packetlen = 2 + 2+strlen(topic);

	packet->command = UNSUBSCRIBE | (dup<<3) | (1<<1);
	packet->remaining_length = packetlen;
	rc = _lwcb_packet_alloc(packet);
	if(rc){
		_lwcb_free(packet);
		return rc;
	}

	/* Variable header */
	local_mid = _lwcb_mid_generate(lwcb);
	if(mid) *mid = (int)local_mid;
	_lwcb_write_uint16(packet, local_mid);

	/* Payload */
	_lwcb_write_string(packet, topic, strlen(topic));

#ifdef WITH_BROKER
# ifdef WITH_BRIDGE
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Bridge %s sending UNSUBSCRIBE (Mid: %d, Topic: %s)", lwcb->id, local_mid, topic);
# endif
#else
	_lwcb_log_printf(lwcb, LWCB_LOG_DEBUG, "Client %s sending UNSUBSCRIBE (Mid: %d, Topic: %s)", lwcb->id, local_mid, topic);
#endif
	return _lwcb_packet_queue(lwcb, packet);
}


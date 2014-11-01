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

#ifndef _LWCB_SEND_H_
#define _LWCB_SEND_H_

#include <lwcb.h>

int _lwcb_send_simple_command(struct lwcb *lwcb, uint8_t command);
int _lwcb_send_command_with_mid(struct lwcb *lwcb, uint8_t command, uint16_t mid, bool dup);
int _lwcb_send_real_publish(struct lwcb *lwcb, uint16_t mid, const char *topic, uint32_t payloadlen, const void *payload, int qos, bool retain, bool dup);

int _lwcb_send_connect(struct lwcb *lwcb, uint16_t keepalive, bool clean_session);
int _lwcb_send_disconnect(struct lwcb *lwcb);
int _lwcb_send_pingreq(struct lwcb *lwcb);
int _lwcb_send_pingresp(struct lwcb *lwcb);
int _lwcb_send_puback(struct lwcb *lwcb, uint16_t mid);
int _lwcb_send_pubcomp(struct lwcb *lwcb, uint16_t mid);
int _lwcb_send_publish(struct lwcb *lwcb, uint16_t mid, const char *topic, uint32_t payloadlen, const void *payload, int qos, bool retain, bool dup);
int _lwcb_send_pubrec(struct lwcb *lwcb, uint16_t mid);
int _lwcb_send_pubrel(struct lwcb *lwcb, uint16_t mid, bool dup);
int _lwcb_send_subscribe(struct lwcb *lwcb, int *mid, bool dup, const char *topic, uint8_t topic_qos);
int _lwcb_send_unsubscribe(struct lwcb *lwcb, int *mid, bool dup, const char *topic);

int _lwcb_send_subscribes(struct lwcb *lwcb, int *mid, bool dup, int count, const char *topics[], uint8_t topic_qos[]);
int _lwcb_send_unsubscribes(struct lwcb *lwcb, int *mid, bool dup, int count, const char *topics[]);

#endif

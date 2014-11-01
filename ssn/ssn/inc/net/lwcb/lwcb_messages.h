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

#ifndef _LWCB_MESSAGES_H_
#define _LWCB_MESSAGES_H_

#include <lwcb_internal.h>
#include <lwcb.h>

void _lwcb_message_cleanup_all(struct lwcb *lwcb);
void _lwcb_message_cleanup(struct lwcb_message_all **message);
int _lwcb_message_delete(struct lwcb *lwcb, uint16_t mid, enum lwcb_msg_direction dir);
void _lwcb_message_queue(struct lwcb *lwcb, struct lwcb_message_all *message);
void _lwcb_messages_reconnect_reset(struct lwcb *lwcb);
int _lwcb_message_remove(struct lwcb *lwcb, uint16_t mid, enum lwcb_msg_direction dir, struct lwcb_message_all **message);
void _lwcb_message_retry_check(struct lwcb *lwcb);
int _lwcb_message_update(struct lwcb *lwcb, uint16_t mid, enum lwcb_msg_direction dir, enum lwcb_msg_state state);

#endif

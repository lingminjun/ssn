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

#ifndef _LWCB_WILL_H_
#define _LWCB_WILL_H_

#include <lwcb.h>
#include <lwcb_internal.h>

int _lwcb_will_set(struct lwcb *lwcb, const char *topic, int payloadlen, const void *payload, int qos, bool retain);
int _lwcb_will_clear(struct lwcb *lwcb);

#endif

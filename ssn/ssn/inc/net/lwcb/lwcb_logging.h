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

#ifndef _LWCB_LOGGING_H_
#define _LWCB_LOGGING_H_

#include <lwcb.h>

int _lwcb_log_printf(struct lwcb *lwcb, int priority, const char *fmt, ...);

#endif

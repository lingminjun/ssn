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
 
#ifndef _READ_HANDLE_H_
#define _READ_HANDLE_H_

#include <lwcb.h>
struct lwcb_db;

int _lwcb_packet_handle(struct lwcb *lwcb);
int _lwcb_handle_connack(struct lwcb *lwcb);
int _lwcb_handle_pingreq(struct lwcb *lwcb);
int _lwcb_handle_pingresp(struct lwcb *lwcb);
int _lwcb_handle_pubackcomp(struct lwcb *lwcb, const char *type);
int _lwcb_handle_publish(struct lwcb *lwcb);
int _lwcb_handle_pubrec(struct lwcb *lwcb);
int _lwcb_handle_pubrel(struct lwcb_db *db, struct lwcb *lwcb);
int _lwcb_handle_suback(struct lwcb *lwcb);
int _lwcb_handle_unsuback(struct lwcb *lwcb);


#endif

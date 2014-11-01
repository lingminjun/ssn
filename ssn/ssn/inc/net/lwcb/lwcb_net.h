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

#ifndef _LWCB_NET_H_
#define _LWCB_NET_H_

#ifndef WIN32
#include <unistd.h>
#else
#include <winsock2.h>
typedef int ssize_t;
#endif

#include <lwcb_internal.h>
#include <lwcb.h>

#ifdef WITH_BROKER
struct lwcb_db;
#endif

#ifdef WIN32
#  define COMPAT_CLOSE(a) closesocket(a)
#  define COMPAT_ECONNRESET WSAECONNRESET
#  define COMPAT_EWOULDBLOCK WSAEWOULDBLOCK
#else
#  define COMPAT_CLOSE(a) close(a)
#  define COMPAT_ECONNRESET ECONNRESET
#  define COMPAT_EWOULDBLOCK EWOULDBLOCK
#endif

#ifndef WIN32
#else
#endif

/* For when not using winsock libraries. */
#ifndef INVALID_SOCKET
#define INVALID_SOCKET -1
#endif

/* Macros for accessing the MSB and LSB of a uint16_t */
#define LWCB_MSB(A) (uint8_t)((A & 0xFF00) >> 8)
#define LWCB_LSB(A) (uint8_t)(A & 0x00FF)

void _lwcb_net_init(void);
void _lwcb_net_cleanup(void);

void _lwcb_packet_cleanup(struct _lwcb_packet *packet);
int _lwcb_packet_queue(struct lwcb *lwcb, struct _lwcb_packet *packet);
int _lwcb_socket_connect(struct lwcb *lwcb, const char *host, uint16_t port);
int _lwcb_socket_close(struct lwcb *lwcb);

int _lwcb_read_byte(struct _lwcb_packet *packet, uint8_t *byte);
int _lwcb_read_bytes(struct _lwcb_packet *packet, void *bytes, uint32_t count);
int _lwcb_read_string(struct _lwcb_packet *packet, char **str);
int _lwcb_read_uint16(struct _lwcb_packet *packet, uint16_t *word);

void _lwcb_write_byte(struct _lwcb_packet *packet, uint8_t byte);
void _lwcb_write_bytes(struct _lwcb_packet *packet, const void *bytes, uint32_t count);
void _lwcb_write_string(struct _lwcb_packet *packet, const char *str, uint16_t length);
void _lwcb_write_uint16(struct _lwcb_packet *packet, uint16_t word);

ssize_t _lwcb_net_read(struct lwcb *lwcb, void *buf, size_t count);
ssize_t _lwcb_net_write(struct lwcb *lwcb, void *buf, size_t count);

int _lwcb_packet_write(struct lwcb *lwcb);
#ifdef WITH_BROKER
int _lwcb_packet_read(struct lwcb_db *db, struct lwcb *lwcb);
#else
int _lwcb_packet_read(struct lwcb *lwcb);
#endif

#endif

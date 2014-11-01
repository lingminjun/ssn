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

#ifndef _LWCB_INTERNAL_H_
#define _LWCB_INTERNAL_H_

#include <lwcb_config.h>

#ifdef WIN32
#  include <winsock2.h>
#endif

#ifdef WITH_TLS
#include <openssl/ssl.h>
#endif
#include <stdlib.h>
#include <time.h>

#if defined(WITH_THREADING) && !defined(WITH_BROKER)
#  include <pthread.h>
#  ifdef __Android__
#     define pthread_cancel(A)
#  endif
#else
#  include <dummypthread.h>
#endif

#ifdef WIN32
#	if _MSC_VER < 1600
		typedef unsigned char uint8_t;
		typedef unsigned short uint16_t;
		typedef unsigned int uint32_t;
		typedef unsigned long long uint64_t;
#	else
#		include <stdint.h>
#	endif
#else
#	include <stdint.h>
#endif

#include <lwcb.h>
#ifdef WITH_BROKER
struct lwcb_client_msg;
#endif

enum lwcb_msg_direction {
	lwcb_md_in = 0,
	lwcb_md_out = 1
};

enum lwcb_msg_state {
	lwcb_ms_invalid = 0,
	lwcb_ms_wait_puback = 1,
	lwcb_ms_wait_pubrec = 2,
	lwcb_ms_wait_pubrel = 3,
	lwcb_ms_wait_pubcomp = 4
};

enum lwcb_client_state {
	lwcb_cs_new = 0,
	lwcb_cs_connected = 1,
	lwcb_cs_disconnecting = 2,
	lwcb_cs_connect_async = 3
};

struct _lwcb_packet{
	uint8_t command;
	uint8_t have_remaining;
	uint8_t remaining_count;
	uint16_t mid;
	uint32_t remaining_mult;
	uint32_t remaining_length;
	uint32_t packet_length;
	uint32_t to_process;
	uint32_t pos;
	uint8_t *payload;
	struct _lwcb_packet *next;
};

struct lwcb_message_all{
	struct lwcb_message_all *next;
	time_t timestamp;
	enum lwcb_msg_direction direction;
	enum lwcb_msg_state state;
	bool dup;
	struct lwcb_message msg;
};

struct lwcb {
#ifndef WIN32
	int sock;
#else
	SOCKET sock;
#endif
	char *address;
	char *id;
	char *username;
	char *password;
	uint16_t keepalive;
	uint16_t reconn_interval;
	bool clean_session;
	enum lwcb_client_state state;
	time_t last_msg_in;
	time_t last_msg_out;
	time_t ping_t;
	uint16_t last_mid;
	struct _lwcb_packet in_packet;
	struct _lwcb_packet *current_out_packet;
	struct _lwcb_packet *out_packet;
	struct lwcb_message *will;
#ifdef WITH_TLS
	SSL *ssl;
	SSL_CTX *ssl_ctx;
	char *tls_cafile;
	char *tls_capath;
	char *tls_certfile;
	char *tls_keyfile;
	int (*tls_pw_callback)(char *buf, int size, int rwflag, void *userdata);
	int tls_cert_reqs;
	char *tls_version;
	char *tls_ciphers;
	char *tls_psk;
	char *tls_psk_identity;
#endif
	bool want_read;
	bool want_write;
#if defined(WITH_THREADING) && !defined(WITH_BROKER)
	pthread_mutex_t callback_mutex;
	pthread_mutex_t log_callback_mutex;
	pthread_mutex_t msgtime_mutex;
	pthread_mutex_t out_packet_mutex;
	pthread_mutex_t current_out_packet_mutex;
	pthread_mutex_t state_mutex;
	pthread_t thread_id;
#endif
#ifdef WITH_BROKER
	bool is_bridge;
	struct _mqtt3_bridge *bridge;
	struct lwcb_client_msg *msgs;
	struct _lwcb_acl_user *acl_list;
	struct _mqtt3_listener *listener;
	time_t disconnect_t;
	int pollfd_index;
#else
	void *userdata;
	bool in_callback;
	unsigned int message_retry;
	time_t last_retry_check;
	struct lwcb_message_all *messages;
	void (*on_connect)(struct lwcb *, void *userdata, int rc);
	void (*on_disconnect)(struct lwcb *, void *userdata, int rc);
	void (*on_publish)(struct lwcb *, void *userdata, int mid);
	void (*on_message)(struct lwcb *, void *userdata, const struct lwcb_message *message);
	void (*on_subscribe)(struct lwcb *, void *userdata, int mid, int qos_count, const int *granted_qos);
	void (*on_unsubscribe)(struct lwcb *, void *userdata, int mid);
	void (*on_log)(struct lwcb *, void *userdata, int level, const char *str);
	//void (*on_error)();
	char *host;
	int port;
	int queue_len;
#endif
};

#endif

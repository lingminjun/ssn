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
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#ifndef WIN32
#include <sys/select.h>
#include <sys/time.h>
#include <unistd.h>
#else
#include <winsock2.h>
#include <windows.h>
typedef int ssize_t;
#endif

#include <lwcb.h>
#include <lwcb_internal.h>
#include <lwcb_logging.h>
#include <lwcb_messages.h>
#include <lwcb_memory.h>
#include <lwcb_protocol.h>
#include <lwcb_net.h>
#include <lwcb_read_handle.h>
#include <lwcb_send.h>
#include <lwcb_util.h>
#include <lwcb_will.h>

#if !defined(WIN32) && defined(__SYMBIAN32__)
#define HAVE_PSELECT
#endif

void _lwcb_destroy(struct lwcb *lwcb);

int lwcb_lib_version(int *major, int *minor, int *revision)
{
	if(major) *major = LIBLWCB_MAJOR;
	if(minor) *minor = LIBLWCB_MINOR;
	if(revision) *revision = LIBLWCB_REVISION;
	return LIBLWCB_VERSION_NUMBER;
}

int lwcb_lib_init(void)
{
#ifdef WIN32
	srand(GetTickCount());
#else
	struct timeval tv;

	gettimeofday(&tv, NULL);
	srand(tv.tv_sec*1000 + tv.tv_usec/1000);
#endif

	_lwcb_net_init();

	return LWCB_ERR_SUCCESS;
}

int lwcb_lib_cleanup(void)
{
	_lwcb_net_cleanup();

	return LWCB_ERR_SUCCESS;
}

struct lwcb *lwcb_new(const char *id, bool clean_session, void *userdata)
{
	struct lwcb *lwcb = NULL;
	int rc;

	if(clean_session == false && id == NULL){
		errno = EINVAL;
		return NULL;
	}

#ifndef WIN32
	signal(SIGPIPE, SIG_IGN);
#endif

	lwcb = (struct lwcb *)_lwcb_calloc(1, sizeof(struct lwcb));
	if(lwcb){
		lwcb->sock = INVALID_SOCKET;
#ifdef WITH_THREADING
		lwcb->thread_id = pthread_self();
#endif
		rc = lwcb_reinitialise(lwcb, id, clean_session, userdata);
		if(rc){
			lwcb_destroy(lwcb);
			if(rc == LWCB_ERR_INVAL){
				errno = EINVAL;
			}else if(rc == LWCB_ERR_NOMEM){
				errno = ENOMEM;
			}
			return NULL;
		}
	}else{
		errno = ENOMEM;
	}
	return lwcb;
}

int lwcb_reinitialise(struct lwcb *lwcb, const char *id, bool clean_session, void *userdata)
{
	int i;

	if(!lwcb) return LWCB_ERR_INVAL;

	if(clean_session == false && id == NULL){
		return LWCB_ERR_INVAL;
	}

	_lwcb_destroy(lwcb);
	memset(lwcb, 0, sizeof(struct lwcb));

	if(userdata){
		lwcb->userdata = userdata;
	}else{
		lwcb->userdata = lwcb;
	}
	lwcb->sock = INVALID_SOCKET;
	lwcb->keepalive = 60;
	lwcb->reconn_interval = 2;
	lwcb->message_retry = 20;
	lwcb->last_retry_check = 0;
	lwcb->clean_session = clean_session;
	if(id){
		if(strlen(id) == 0){
			return LWCB_ERR_INVAL;
		}
		lwcb->id = _lwcb_strdup(id);
	}else{
		lwcb->id = (char *)_lwcb_calloc(24, sizeof(char));
		if(!lwcb->id){
			return LWCB_ERR_NOMEM;
		}
		lwcb->id[0] = 'm';
		lwcb->id[1] = 'o';
		lwcb->id[2] = 's';
		lwcb->id[3] = 'q';
		lwcb->id[4] = '/';

		for(i=5; i<23; i++){
			lwcb->id[i] = (rand()%73)+48;
		}
	}
	lwcb->in_packet.payload = NULL;
	_lwcb_packet_cleanup(&lwcb->in_packet);
	lwcb->out_packet = NULL;
	lwcb->current_out_packet = NULL;
	lwcb->last_msg_in = time(NULL);
	lwcb->last_msg_out = time(NULL);
	lwcb->ping_t = 0;
	lwcb->last_mid = 0;
	lwcb->state = lwcb_cs_new;
	lwcb->messages = NULL;
	lwcb->will = NULL;
	lwcb->on_connect = NULL;
	lwcb->on_publish = NULL;
	lwcb->on_message = NULL;
	lwcb->on_subscribe = NULL;
	lwcb->on_unsubscribe = NULL;
	lwcb->host = NULL;
	lwcb->port = 1883;
	lwcb->in_callback = false;
	lwcb->queue_len = 0;
#ifdef WITH_TLS
	lwcb->ssl = NULL;
	lwcb->tls_cert_reqs = SSL_VERIFY_PEER;
#endif
#ifdef WITH_THREADING
	pthread_mutex_init(&lwcb->callback_mutex, NULL);
	pthread_mutex_init(&lwcb->log_callback_mutex, NULL);
	pthread_mutex_init(&lwcb->state_mutex, NULL);
	pthread_mutex_init(&lwcb->out_packet_mutex, NULL);
	pthread_mutex_init(&lwcb->current_out_packet_mutex, NULL);
	pthread_mutex_init(&lwcb->msgtime_mutex, NULL);
	lwcb->thread_id = pthread_self();
#endif

	return LWCB_ERR_SUCCESS;
}

int lwcb_will_set(struct lwcb *lwcb, const char *topic, int payloadlen, const void *payload, int qos, bool retain)
{
	if(!lwcb) return LWCB_ERR_INVAL;
	return _lwcb_will_set(lwcb, topic, payloadlen, payload, qos, retain);
}

int lwcb_will_clear(struct lwcb *lwcb)
{
	if(!lwcb) return LWCB_ERR_INVAL;
	return _lwcb_will_clear(lwcb);
}


int lwcb_keepalive_set(struct lwcb *lwcb, int keepalive) {
	if(!lwcb) return LWCB_ERR_INVAL;
	lwcb->keepalive = keepalive;
	return LWCB_ERR_SUCCESS;
}

int lwcb_host_port_set(struct lwcb *lwcb, const char *host, int port) {
	if(!lwcb) return LWCB_ERR_INVAL;
	if(lwcb->host) _lwcb_free(lwcb->host);
	lwcb->host = _lwcb_strdup(host);
	if(!lwcb->host) return LWCB_ERR_NOMEM;
	lwcb->port = port;
	return LWCB_ERR_SUCCESS;
}

int lwcb_username_pw_set(struct lwcb *lwcb, const char *username, const char *password)
{
	if(!lwcb) return LWCB_ERR_INVAL;

	if(username){
		if(lwcb->username) _lwcb_free(lwcb->username);
		lwcb->username = _lwcb_strdup(username);
		if(!lwcb->username) return LWCB_ERR_NOMEM;
		if(lwcb->password){
			_lwcb_free(lwcb->password);
			lwcb->password = NULL;
		}
		if(password){
			lwcb->password = _lwcb_strdup(password);
			if(!lwcb->password){
				_lwcb_free(lwcb->username);
				lwcb->username = NULL;
				return LWCB_ERR_NOMEM;
			}
		}
	}else{
		if(lwcb->username){
			_lwcb_free(lwcb->username);
			lwcb->username = NULL;
		}
		if(lwcb->password){
			_lwcb_free(lwcb->password);
			lwcb->password = NULL;
		}
	}
	return LWCB_ERR_SUCCESS;
}


void _lwcb_destroy(struct lwcb *lwcb)
{
	struct _lwcb_packet *packet;
	if(!lwcb) return;

#ifdef WITH_THREADING
	if(!pthread_equal(lwcb->thread_id, pthread_self())){
		pthread_cancel(lwcb->thread_id);
		pthread_join(lwcb->thread_id, NULL);
	}

	if(lwcb->id){
		/* If lwcb->id is not NULL then the client has already been initialised
		 * and so the mutexes need destroying. If lwcb->id is NULL, the mutexes
		 * haven't been initialised. */
		pthread_mutex_destroy(&lwcb->callback_mutex);
		pthread_mutex_destroy(&lwcb->log_callback_mutex);
		pthread_mutex_destroy(&lwcb->state_mutex);
		pthread_mutex_destroy(&lwcb->out_packet_mutex);
		pthread_mutex_destroy(&lwcb->current_out_packet_mutex);
		pthread_mutex_destroy(&lwcb->msgtime_mutex);
	}
#endif
	if(lwcb->sock != INVALID_SOCKET){
		_lwcb_socket_close(lwcb);
	}
	_lwcb_message_cleanup_all(lwcb);
	_lwcb_will_clear(lwcb);
#ifdef WITH_TLS
	if(lwcb->ssl){
		SSL_free(lwcb->ssl);
	}
	if(lwcb->ssl_ctx){
		SSL_CTX_free(lwcb->ssl_ctx);
	}
	if(lwcb->tls_cafile) _lwcb_free(lwcb->tls_cafile);
	if(lwcb->tls_capath) _lwcb_free(lwcb->tls_capath);
	if(lwcb->tls_certfile) _lwcb_free(lwcb->tls_certfile);
	if(lwcb->tls_keyfile) _lwcb_free(lwcb->tls_keyfile);
	if(lwcb->tls_pw_callback) lwcb->tls_pw_callback = NULL;
	if(lwcb->tls_version) _lwcb_free(lwcb->tls_version);
	if(lwcb->tls_ciphers) _lwcb_free(lwcb->tls_ciphers);
	if(lwcb->tls_psk) _lwcb_free(lwcb->tls_psk);
	if(lwcb->tls_psk_identity) _lwcb_free(lwcb->tls_psk_identity);
#endif

	if(lwcb->address) _lwcb_free(lwcb->address);
	if(lwcb->id) _lwcb_free(lwcb->id);
	if(lwcb->username) _lwcb_free(lwcb->username);
	if(lwcb->password) _lwcb_free(lwcb->password);
	if(lwcb->host) _lwcb_free(lwcb->host);

	/* Out packet cleanup */
	if(lwcb->out_packet && !lwcb->current_out_packet){
		lwcb->current_out_packet = lwcb->out_packet;
		lwcb->out_packet = lwcb->out_packet->next;
	}
	while(lwcb->current_out_packet){
		packet = lwcb->current_out_packet;
		/* Free data and reset values */
		lwcb->current_out_packet = lwcb->out_packet;
		if(lwcb->out_packet){
			lwcb->out_packet = lwcb->out_packet->next;
		}

		_lwcb_packet_cleanup(packet);
		_lwcb_free(packet);
	}

	_lwcb_packet_cleanup(&lwcb->in_packet);
}

void lwcb_destroy(struct lwcb *lwcb)
{
	_lwcb_destroy(lwcb);
	_lwcb_free(lwcb);
}

int lwcb_socket(struct lwcb *lwcb)
{
	if(!lwcb) return LWCB_ERR_INVAL;
	return lwcb->sock;
}

int lwcb_connect(struct lwcb *lwcb, const char *host, int port, int keepalive)
{
	int rc;
	rc = lwcb_connect_async(lwcb, host, port, keepalive);
	if(rc) return rc;

	return lwcb_reconnect(lwcb);
}

int lwcb_connect_async(struct lwcb *lwcb, const char *host, int port, int keepalive)
{
	if(!lwcb) return LWCB_ERR_INVAL;
	if(!host || port <= 0) return LWCB_ERR_INVAL;

	if(lwcb->host) _lwcb_free(lwcb->host);
	lwcb->host = _lwcb_strdup(host);
	if(!lwcb->host) return LWCB_ERR_NOMEM;
	lwcb->port = port;

	lwcb->keepalive = keepalive;
	pthread_mutex_lock(&lwcb->state_mutex);
	lwcb->state = lwcb_cs_connect_async;
	pthread_mutex_unlock(&lwcb->state_mutex);

	return LWCB_ERR_SUCCESS;
}

int lwcb_reconnect(struct lwcb *lwcb)
{
	int rc;
	struct _lwcb_packet *packet;
	if(!lwcb) return LWCB_ERR_INVAL;
	if(!lwcb->host || lwcb->port <= 0) return LWCB_ERR_INVAL;

	pthread_mutex_lock(&lwcb->state_mutex);
	lwcb->state = lwcb_cs_new;
	pthread_mutex_unlock(&lwcb->state_mutex);

	pthread_mutex_lock(&lwcb->msgtime_mutex);
	lwcb->last_msg_in = time(NULL);
	lwcb->last_msg_out = time(NULL);
	pthread_mutex_unlock(&lwcb->msgtime_mutex);

	lwcb->ping_t = 0;

	_lwcb_packet_cleanup(&lwcb->in_packet);

	pthread_mutex_lock(&lwcb->current_out_packet_mutex);
	pthread_mutex_lock(&lwcb->out_packet_mutex);

	if(lwcb->out_packet && !lwcb->current_out_packet){
		lwcb->current_out_packet = lwcb->out_packet;
		lwcb->out_packet = lwcb->out_packet->next;
	}

	while(lwcb->current_out_packet){
		packet = lwcb->current_out_packet;
		/* Free data and reset values */
		lwcb->current_out_packet = lwcb->out_packet;
		if(lwcb->out_packet){
			lwcb->out_packet = lwcb->out_packet->next;
		}

		_lwcb_packet_cleanup(packet);
		_lwcb_free(packet);
	}
	pthread_mutex_unlock(&lwcb->out_packet_mutex);
	pthread_mutex_unlock(&lwcb->current_out_packet_mutex);

	_lwcb_messages_reconnect_reset(lwcb);

	rc = _lwcb_socket_connect(lwcb, lwcb->host, lwcb->port);
	//_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "lwcb_reconnect rc : %s", lwcb_strerror(rc));
	if(rc){
		return rc;
	}

//	char *sock_self_address = lwcb->address?_lwcb_strdup(lwcb->address):NULL;
//	rc = _lwcb_socket_connect(lwcb, lwcb->host, lwcb->port);
//	_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "lwcb_reconnect rc : %s", lwcb_strerror(rc));
//	if(rc){
//		if (LWCB_ERR_ERRNO == rc) {
//			if(sock_self_address &&
//				strcmp(sock_self_address,lwcb->address)==0 &&
//				lwcb->reconn_interval < 120) {
//				 lwcb->reconn_interval += 1;
//			}
//		}
//		return rc;
//	}
//	_lwcb_free(sock_self_address);
//	lwcb->reconn_interval = 1;

	return _lwcb_send_connect(lwcb, lwcb->keepalive, lwcb->clean_session);
}

int lwcb_disconnect(struct lwcb *lwcb)
{
	if(!lwcb) return LWCB_ERR_INVAL;

	pthread_mutex_lock(&lwcb->state_mutex);
	lwcb->state = lwcb_cs_disconnecting;
	pthread_mutex_unlock(&lwcb->state_mutex);

	if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;
	return _lwcb_send_disconnect(lwcb);
}

int lwcb_publish(struct lwcb *lwcb, int *mid, const char *topic, int payloadlen, const void *payload, int qos, bool retain)
{
	struct lwcb_message_all *message;
	uint16_t local_mid;

	if(!lwcb || !topic || qos<0 || qos>2) return LWCB_ERR_INVAL;
	if(strlen(topic) == 0) return LWCB_ERR_INVAL;
	if(payloadlen < 0 || payloadlen > MQTT_MAX_PAYLOAD) return LWCB_ERR_PAYLOAD_SIZE;

	if(_lwcb_topic_wildcard_len_check(topic) != LWCB_ERR_SUCCESS){
		return LWCB_ERR_INVAL;
	}

	local_mid = _lwcb_mid_generate(lwcb);
	if(mid){
		*mid = local_mid;
	}

	if(qos == 0){
		return _lwcb_send_publish(lwcb, local_mid, topic, payloadlen, payload, qos, retain, false);
	}else{
		message = _lwcb_calloc(1, sizeof(struct lwcb_message_all));
		if(!message) return LWCB_ERR_NOMEM;

		message->next = NULL;
		message->timestamp = time(NULL);
		message->direction = lwcb_md_out;
		if(qos == 1){
			message->state = lwcb_ms_wait_puback;
		}else if(qos == 2){
			message->state = lwcb_ms_wait_pubrec;
		}
		message->msg.mid = local_mid;
		message->msg.topic = _lwcb_strdup(topic);
		if(!message->msg.topic){
			_lwcb_message_cleanup(&message);
			return LWCB_ERR_NOMEM;
		}
		if(payloadlen){
			message->msg.payloadlen = payloadlen;
			message->msg.payload = _lwcb_malloc(payloadlen*sizeof(uint8_t));
			if(!message->msg.payload){
				_lwcb_message_cleanup(&message);
				return LWCB_ERR_NOMEM;
			}
			memcpy(message->msg.payload, payload, payloadlen*sizeof(uint8_t));
		}else{
			message->msg.payloadlen = 0;
			message->msg.payload = NULL;
		}
		message->msg.qos = qos;
		message->msg.retain = retain;
		message->dup = false;

		_lwcb_message_queue(lwcb, message);
		return _lwcb_send_publish(lwcb, message->msg.mid, message->msg.topic, message->msg.payloadlen, message->msg.payload, message->msg.qos, message->msg.retain, message->dup);
	}
}

int lwcb_subscribe(struct lwcb *lwcb, int *mid, const char *sub, int qos)
{
	if(!lwcb) return LWCB_ERR_INVAL;
	if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;

	return _lwcb_send_subscribe(lwcb, mid, false, sub, qos);
}

int lwcb_subscribes(struct lwcb *lwcb, int *mid, int count, const char *sub[], unsigned char qos[])
{
	if(!lwcb) return LWCB_ERR_INVAL;
	if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;

	return _lwcb_send_subscribes(lwcb, mid, false, count, sub, qos);
}

int lwcb_unsubscribe(struct lwcb *lwcb, int *mid, const char *sub)
{
	if(!lwcb) return LWCB_ERR_INVAL;
	if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;

	return _lwcb_send_unsubscribe(lwcb, mid, false, sub);
}


int lwcb_unsubscribes(struct lwcb *lwcb, int *mid, int count, const char *sub[])
{
	if(!lwcb) return LWCB_ERR_INVAL;
	if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;

	return _lwcb_send_unsubscribes(lwcb, mid, false, count, sub);
}


int lwcb_pingreq(struct lwcb *lwcb)
{
	if(!lwcb) return LWCB_ERR_INVAL;
	if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;

	return _lwcb_send_pingreq(lwcb);
}



int lwcb_tls_set(struct lwcb *lwcb, const char *cafile, const char *capath, const char *certfile, const char *keyfile, int (*pw_callback)(char *buf, int size, int rwflag, void *userdata))
{
#ifdef WITH_TLS
	FILE *fptr;

	if(!lwcb || (!cafile && !capath) || (certfile && !keyfile) || (!certfile && keyfile)) return LWCB_ERR_INVAL;

	if(cafile){
		fptr = fopen(cafile, "rt");
		if(fptr){
			fclose(fptr);
		}else{
			return LWCB_ERR_INVAL;
		}
		lwcb->tls_cafile = _lwcb_strdup(cafile);

		if(!lwcb->tls_cafile){
			return LWCB_ERR_NOMEM;
		}
	}else if(lwcb->tls_cafile){
		_lwcb_free(lwcb->tls_cafile);
		lwcb->tls_cafile = NULL;
	}

	if(capath){
		lwcb->tls_capath = _lwcb_strdup(capath);
		if(!lwcb->tls_capath){
			return LWCB_ERR_NOMEM;
		}
	}else if(lwcb->tls_capath){
		_lwcb_free(lwcb->tls_capath);
		lwcb->tls_capath = NULL;
	}

	if(certfile){
		fptr = fopen(certfile, "rt");
		if(fptr){
			fclose(fptr);
		}else{
			if(lwcb->tls_cafile){
				_lwcb_free(lwcb->tls_cafile);
				lwcb->tls_cafile = NULL;
			}
			if(lwcb->tls_capath){
				_lwcb_free(lwcb->tls_capath);
				lwcb->tls_capath = NULL;
			}
			return LWCB_ERR_INVAL;
		}
		lwcb->tls_certfile = _lwcb_strdup(certfile);
		if(!lwcb->tls_certfile){
			return LWCB_ERR_NOMEM;
		}
	}else{
		if(lwcb->tls_certfile) _lwcb_free(lwcb->tls_certfile);
		lwcb->tls_certfile = NULL;
	}

	if(keyfile){
		fptr = fopen(keyfile, "rt");
		if(fptr){
			fclose(fptr);
		}else{
			if(lwcb->tls_cafile){
				_lwcb_free(lwcb->tls_cafile);
				lwcb->tls_cafile = NULL;
			}
			if(lwcb->tls_capath){
				_lwcb_free(lwcb->tls_capath);
				lwcb->tls_capath = NULL;
			}
			if(lwcb->tls_certfile){
				_lwcb_free(lwcb->tls_certfile);
				lwcb->tls_capath = NULL;
			}
			return LWCB_ERR_INVAL;
		}
		lwcb->tls_keyfile = _lwcb_strdup(keyfile);
		if(!lwcb->tls_keyfile){
			return LWCB_ERR_NOMEM;
		}
	}else{
		if(lwcb->tls_keyfile) _lwcb_free(lwcb->tls_keyfile);
		lwcb->tls_keyfile = NULL;
	}

	lwcb->tls_pw_callback = pw_callback;


	return LWCB_ERR_SUCCESS;
#else
	return LWCB_ERR_NOT_SUPPORTED;

#endif
}

int lwcb_tls_opts_set(struct lwcb *lwcb, int cert_reqs, const char *tls_version, const char *ciphers)
{
#ifdef WITH_TLS
	if(!lwcb) return LWCB_ERR_INVAL;

	lwcb->tls_cert_reqs = cert_reqs;
	if(tls_version){
		if(!strcasecmp(tls_version, "tlsv1")){
			lwcb->tls_version = _lwcb_strdup(tls_version);
			if(!lwcb->tls_version) return LWCB_ERR_NOMEM;
		}else{
			return LWCB_ERR_INVAL;
		}
	}else{
		lwcb->tls_version = _lwcb_strdup("tlsv1");
		if(!lwcb->tls_version) return LWCB_ERR_NOMEM;
	}
	if(ciphers){
		lwcb->tls_ciphers = _lwcb_strdup(ciphers);
		if(!lwcb->tls_ciphers) return LWCB_ERR_NOMEM;
	}else{
		lwcb->tls_ciphers = NULL;
	}


	return LWCB_ERR_SUCCESS;
#else
	return LWCB_ERR_NOT_SUPPORTED;

#endif
}


int lwcb_tls_psk_set(struct lwcb *lwcb, const char *psk, const char *identity, const char *ciphers)
{
#if defined(WITH_TLS) && defined(WITH_TLS_PSK)
	if(!lwcb || !psk || !identity) return LWCB_ERR_INVAL;

	/* Check for hex only digits */
	if(strspn(psk, "0123456789abcdefABCDEF") < strlen(psk)){
		return LWCB_ERR_INVAL;
	}
	lwcb->tls_psk = _lwcb_strdup(psk);
	if(!lwcb->tls_psk) return LWCB_ERR_NOMEM;

	lwcb->tls_psk_identity = _lwcb_strdup(identity);
	if(!lwcb->tls_psk_identity){
		_lwcb_free(lwcb->tls_psk);
		return LWCB_ERR_NOMEM;
	}
	if(ciphers){
		lwcb->tls_ciphers = _lwcb_strdup(ciphers);
		if(!lwcb->tls_ciphers) return LWCB_ERR_NOMEM;
	}else{
		lwcb->tls_ciphers = NULL;
	}

	return LWCB_ERR_SUCCESS;
#else
	return LWCB_ERR_NOT_SUPPORTED;
#endif
}


int lwcb_loop(struct lwcb *lwcb, int timeout, int max_packets)
{
#ifdef HAVE_PSELECT
	struct timespec local_timeout;
#else
	struct timeval local_timeout;
#endif
	fd_set readfds, writefds;
	int fdcount;
	int rc;

	if(!lwcb || max_packets < 1) return LWCB_ERR_INVAL;
	if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;

	FD_ZERO(&readfds);
	FD_SET(lwcb->sock, &readfds);
	FD_ZERO(&writefds);
	pthread_mutex_lock(&lwcb->out_packet_mutex);
	if(lwcb->out_packet || lwcb->current_out_packet){
		FD_SET(lwcb->sock, &writefds);
#ifdef WITH_TLS
	}else if(lwcb->ssl && lwcb->want_write){
		FD_SET(lwcb->sock, &writefds);
#endif
	}
	pthread_mutex_unlock(&lwcb->out_packet_mutex);
	if(timeout >= 0){
		local_timeout.tv_sec = timeout/1000;
#ifdef HAVE_PSELECT
		local_timeout.tv_nsec = (timeout-local_timeout.tv_sec*1000)*1e6;
#else
		local_timeout.tv_usec = (timeout-local_timeout.tv_sec*1000)*1000;
#endif
	}else{
		local_timeout.tv_sec = 1;
#ifdef HAVE_PSELECT
		local_timeout.tv_nsec = 0;
#else
		local_timeout.tv_usec = 0;
#endif
	}

#ifdef HAVE_PSELECT
	fdcount = pselect(lwcb->sock+1, &readfds, &writefds, NULL, &local_timeout, NULL);
#else
	fdcount = select(lwcb->sock+1, &readfds, &writefds, NULL, &local_timeout);
#endif
	if(fdcount == -1){
#ifdef WIN32
		errno = WSAGetLastError();
#endif
		if(errno == EINTR){
			return LWCB_ERR_SUCCESS;
		}else{
			return LWCB_ERR_ERRNO;
		}
	}else{
		if(FD_ISSET(lwcb->sock, &readfds)){
			rc = lwcb_loop_read(lwcb, max_packets);
			if(rc || lwcb->sock == INVALID_SOCKET){
				return rc;
			}
		}
		if(FD_ISSET(lwcb->sock, &writefds)){
			rc = lwcb_loop_write(lwcb, max_packets);
			if(rc || lwcb->sock == INVALID_SOCKET){
				return rc;
			}
		}
	}
	return lwcb_loop_misc(lwcb);
}

int lwcb_loop_forever(struct lwcb *lwcb, int timeout, int max_packets)
{
	int run = 1;
	int rc;

	if(!lwcb) return LWCB_ERR_INVAL;

	if(lwcb->state == lwcb_cs_connect_async){
		lwcb_reconnect(lwcb);
	}

	while(run){
		do{
			rc = lwcb_loop(lwcb, timeout, max_packets);
		}while(rc == LWCB_ERR_SUCCESS);
		if(errno == EPROTO){
			return rc;
		}

		if(lwcb->state == lwcb_cs_disconnecting){
			run = 0;
		}else{
#ifdef WIN32
			Sleep(lwcb->reconn_interval*1000);
#else
			sleep(lwcb->reconn_interval);
#endif
			lwcb_reconnect(lwcb);
		}
	}
	return rc;
}

int lwcb_loop_misc(struct lwcb *lwcb)
{
	time_t now = time(NULL);
	int rc;

	if(!lwcb) return LWCB_ERR_INVAL;
	if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;
	_lwcb_check_keepalive(lwcb);
	if(lwcb->last_retry_check+1 < now){
		_lwcb_message_retry_check(lwcb);
		lwcb->last_retry_check = now;
	}
	if(lwcb->ping_t && now - lwcb->ping_t >= lwcb->keepalive){
		/* lwcb->ping_t != 0 means we are waiting for a pingresp.
		 * This hasn't happened in the keepalive time so we should disconnect.
		 */
		_lwcb_socket_close(lwcb);
		pthread_mutex_lock(&lwcb->state_mutex);
		if(lwcb->state == lwcb_cs_disconnecting){
			rc = LWCB_ERR_SUCCESS;
		}else{
			rc = 1;
		}
		pthread_mutex_unlock(&lwcb->state_mutex);
		pthread_mutex_lock(&lwcb->callback_mutex);
		if(lwcb->on_disconnect){
			lwcb->in_callback = true;
			lwcb->on_disconnect(lwcb, lwcb->userdata, rc);
			lwcb->in_callback = false;
		}
		pthread_mutex_unlock(&lwcb->callback_mutex);
		return LWCB_ERR_CONN_LOST;
	}
	return LWCB_ERR_SUCCESS;
}

int lwcb_get_state(struct lwcb *lwcb) {
	int state;
	pthread_mutex_lock(&lwcb->state_mutex);
	state = lwcb->state;
	pthread_mutex_unlock(&lwcb->state_mutex);
	return state;
}

static int _lwcb_loop_rc_handle(struct lwcb *lwcb, int rc)
{
	if(rc){
		_lwcb_socket_close(lwcb);
		pthread_mutex_lock(&lwcb->state_mutex);
		if(lwcb->state == lwcb_cs_disconnecting){
			rc = LWCB_ERR_SUCCESS;
		}
		pthread_mutex_unlock(&lwcb->state_mutex);
		pthread_mutex_lock(&lwcb->callback_mutex);
		if(lwcb->on_disconnect){
			lwcb->in_callback = true;
			lwcb->on_disconnect(lwcb, lwcb->userdata, rc);
			lwcb->in_callback = false;
		}
		pthread_mutex_unlock(&lwcb->callback_mutex);
		return rc;
	}
	return rc;
}

int lwcb_on_lost_connect(struct lwcb *lwcb) {
	return _lwcb_loop_rc_handle(lwcb, LWCB_ERR_CONN_LOST);
}

int lwcb_loop_read(struct lwcb *lwcb, int max_packets)
{
	int rc;
	int i;
	if(max_packets < 1) return LWCB_ERR_INVAL;

	max_packets = lwcb->queue_len;
	if(max_packets < 1) max_packets = 1;
	/* Queue len here tells us how many messages are awaiting processing and
	 * have QoS > 0. We should try to deal with that many in this loop in order
	 * to keep up. */
	for(i=0; i<max_packets; i++){
		rc = _lwcb_packet_read(lwcb);
		if(rc || errno == EAGAIN || errno == COMPAT_EWOULDBLOCK){
			return _lwcb_loop_rc_handle(lwcb, rc);
		}
	}
	return rc;
}

int lwcb_loop_write(struct lwcb *lwcb, int max_packets)
{
	int rc;
	int i;
	if(max_packets < 1) return LWCB_ERR_INVAL;

	max_packets = lwcb->queue_len;
	if(max_packets < 1) max_packets = 1;
	/* Queue len here tells us how many messages are awaiting processing and
	 * have QoS > 0. We should try to deal with that many in this loop in order
	 * to keep up. */
	for(i=0; i<max_packets; i++){
		rc = _lwcb_packet_write(lwcb);
		if(rc || errno == EAGAIN || errno == COMPAT_EWOULDBLOCK){
			return _lwcb_loop_rc_handle(lwcb, rc);
		}
	}
	return rc;
}

bool lwcb_want_write(struct lwcb *lwcb)
{
	if(lwcb->out_packet){
		return true;
	}else{
		return false;
	}
}

void lwcb_connect_callback_set(struct lwcb *lwcb, void (*on_connect)(struct lwcb *, void *, int))
{
	pthread_mutex_lock(&lwcb->callback_mutex);
	lwcb->on_connect = on_connect;
	pthread_mutex_unlock(&lwcb->callback_mutex);
}

void lwcb_disconnect_callback_set(struct lwcb *lwcb, void (*on_disconnect)(struct lwcb *, void *, int))
{
	pthread_mutex_lock(&lwcb->callback_mutex);
	lwcb->on_disconnect = on_disconnect;
	pthread_mutex_unlock(&lwcb->callback_mutex);
}

void lwcb_publish_callback_set(struct lwcb *lwcb, void (*on_publish)(struct lwcb *, void *, int))
{
	pthread_mutex_lock(&lwcb->callback_mutex);
	lwcb->on_publish = on_publish;
	pthread_mutex_unlock(&lwcb->callback_mutex);
}

void lwcb_message_callback_set(struct lwcb *lwcb, void (*on_message)(struct lwcb *, void *, const struct lwcb_message *))
{
	pthread_mutex_lock(&lwcb->callback_mutex);
	lwcb->on_message = on_message;
	pthread_mutex_unlock(&lwcb->callback_mutex);
}

void lwcb_subscribe_callback_set(struct lwcb *lwcb, void (*on_subscribe)(struct lwcb *, void *, int, int, const int *))
{
	pthread_mutex_lock(&lwcb->callback_mutex);
	lwcb->on_subscribe = on_subscribe;
	pthread_mutex_unlock(&lwcb->callback_mutex);
}

void lwcb_unsubscribe_callback_set(struct lwcb *lwcb, void (*on_unsubscribe)(struct lwcb *, void *, int))
{
	pthread_mutex_lock(&lwcb->callback_mutex);
	lwcb->on_unsubscribe = on_unsubscribe;
	pthread_mutex_unlock(&lwcb->callback_mutex);
}

void lwcb_log_callback_set(struct lwcb *lwcb, void (*on_log)(struct lwcb *, void *, int, const char *))
{
	pthread_mutex_lock(&lwcb->log_callback_mutex);
	lwcb->on_log = on_log;
	pthread_mutex_unlock(&lwcb->log_callback_mutex);
}

void lwcb_user_data_set(struct lwcb *lwcb, void *userdata)
{
	if(lwcb){
		lwcb->userdata = userdata;
	}
}

const char *lwcb_strerror(int lwcb_errno)
{
	switch(lwcb_errno){
		case LWCB_ERR_SUCCESS:
			return "No error.";
		case LWCB_ERR_NOMEM:
			return "Out of memory.";
		case LWCB_ERR_PROTOCOL:
			return "A network protocol error occurred when communicating with the broker.";
		case LWCB_ERR_INVAL:
			return "Invalid function arguments provided.";
		case LWCB_ERR_NO_CONN:
			return "The client is not currently connected.";
		case LWCB_ERR_CONN_REFUSED:
			return "The connection was refused.";
		case LWCB_ERR_NOT_FOUND:
			return "Message not found (internal error).";
		case LWCB_ERR_CONN_LOST:
			return "The connection was lost.";
		case LWCB_ERR_TLS:
			return "A TLS error occurred.";
		case LWCB_ERR_PAYLOAD_SIZE:
			return "Payload too large.";
		case LWCB_ERR_NOT_SUPPORTED:
			return "This feature is not supported.";
		case LWCB_ERR_AUTH:
			return "Authorisation failed.";
		case LWCB_ERR_ACL_DENIED:
			return "Access denied by ACL.";
		case LWCB_ERR_UNKNOWN:
			return "Unknown error.";
		case LWCB_ERR_ERRNO:
			return "Error defined by errno.";
		default:
			return "Unknown error.";
	}
}

const char *lwcb_connack_string(int connack_code)
{
	switch(connack_code){
		case 0:
			return "Connection Accepted.";
		case 1:
			return "Connection Refused: unacceptable protocol version.";
		case 2:
			return "Connection Refused: identifier rejected.";
		case 3:
			return "Connection Refused: broker unavailable.";
		case 4:
			return "Connection Refused: bad user name or password.";
		case 5:
			return "Connection Refused: not authorised.";
		default:
			return "Connection Refused: unknown reason.";
	}
}

const char *lwcb_sock_localaddress(struct lwcb *lwcb) {
    return lwcb->address;
}


int lwcb_sub_topic_tokenise(const char *subtopic, char ***topics, int *count)
{
	int len;
	int hier_count = 1;
	int start, stop;
	int hier;
	int tlen;
	int i, j;

	if(!subtopic || !topics || !count) return LWCB_ERR_INVAL;

	len = strlen(subtopic);

	for(i=0; i<len; i++){
		if(subtopic[i] == '/'){
			while(i<len && subtopic[i] == '/'){
				/* Ignore duplicate separators. */
				i++;
			}
			if(i >= len-1){
				/* Separator at end of line */
			}else{
				hier_count++;
			}
		}
	}

	(*topics) = _lwcb_calloc(hier_count, sizeof(char *));
	if(!(*topics)) return LWCB_ERR_NOMEM;

	start = 0;
	stop = 0;
	hier = 0;

	for(i=0; i<len+1; i++){
		if(subtopic[i] == '/' || subtopic[i] == '\0'){
			if(i>0 && subtopic[i] == '/' && subtopic[i-1] == '/'){
				start = i+1;
				continue;
			}
			stop = i;
			if(start != stop){
				tlen = stop-start + 1;
				(*topics)[hier] = _lwcb_calloc(tlen, sizeof(char));
				if(!(*topics)[hier]){
					for(i=0; i<hier_count; i++){
						if((*topics)[hier]){
							_lwcb_free((*topics)[hier]);
						}
					}
					_lwcb_free((*topics));
					return LWCB_ERR_NOMEM;
				}
				for(j=start; j<stop; j++){
					(*topics)[hier][j-start] = subtopic[j];
				}
			}
			start = i+1;
			hier++;
		}
	}

	*count = hier_count;

	return LWCB_ERR_SUCCESS;
}

int lwcb_sub_topic_tokens_free(char ***topics, int count)
{
	int i;

	if(!topics || !(*topics) || count<1) return LWCB_ERR_INVAL;

	for(i=0; i<count; i++){
		if((*topics)[i]) _lwcb_free((*topics)[i]);
	}
	_lwcb_free(*topics);

	return LWCB_ERR_SUCCESS;
}


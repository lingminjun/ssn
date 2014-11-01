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
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#ifndef WIN32
#include <netdb.h>
#include <sys/socket.h>

#include <unistd.h>
#else
#include <winsock2.h>
#include <ws2tcpip.h>
#endif

#ifdef __Android__
#  include <netinet/in.h>
#  include <arpa/inet.h>
#endif

#ifdef __APPLE__
#  include <netinet/in.h>
#  include <arpa/inet.h>
#endif

#ifdef __FreeBSD__
#  include <netinet/in.h>
#  include <arpa/inet.h>
#endif

#ifdef __SYMBIAN32__
#  include <netinet/in.h>
#  include <arpa/inet.h>
#endif

#ifdef __QNX__
#ifndef AI_ADDRCONFIG
#define AI_ADDRCONFIG 0
#endif
#include <net/netbyte.h>
#include <netinet/in.h>
#endif

#ifdef WITH_TLS
#include <openssl/err.h>
#endif

#ifdef WITH_BROKER
#  include <lwcb_broker.h>
   extern uint64_t g_bytes_received;
   extern uint64_t g_bytes_sent;
   extern unsigned long g_msgs_received;
   extern unsigned long g_msgs_sent;
   extern unsigned long g_pub_msgs_received;
   extern unsigned long g_pub_msgs_sent;
#else
#  include <lwcb_read_handle.h>
#endif

#include "lwcb_logging.h"
#include <lwcb_memory.h>
#include <lwcb_protocol.h>
#include <lwcb_net.h>
#include <lwcb_util.h>

#ifdef WITH_TLS
static int tls_ex_index_lwcb = -1;
#endif

void _lwcb_net_init(void)
{
#ifdef WIN32
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2,2), &wsaData);
#endif

#ifdef WITH_TLS
	SSL_load_error_strings();
	SSL_library_init();
	OpenSSL_add_all_algorithms();
	if(tls_ex_index_lwcb == -1){
		tls_ex_index_lwcb = SSL_get_ex_new_index(0, "client context", NULL, NULL, NULL);
	}
#endif
}

void _lwcb_net_cleanup(void)
{
#ifdef WITH_TLS
	ERR_free_strings();
	EVP_cleanup();
#endif

#ifdef WIN32
	WSACleanup();
#endif
}

void _lwcb_packet_cleanup(struct _lwcb_packet *packet)
{
    if(!packet) return;

    /* Free data and reset values */
    packet->command = 0;
    packet->have_remaining = 0;
    packet->remaining_count = 0;
    packet->remaining_mult = 1;
    packet->remaining_length = 0;
    if(packet->payload) _lwcb_free(packet->payload);
    packet->payload = NULL;
    packet->to_process = 0;
    packet->pos = 0;
}

int _lwcb_packet_queue(struct lwcb *lwcb, struct _lwcb_packet *packet)
{
    struct _lwcb_packet *tail;

    assert(lwcb);
    assert(packet);

    packet->pos = 0;
    packet->to_process = packet->packet_length;

    packet->next = NULL;
    pthread_mutex_lock(&lwcb->out_packet_mutex);
    if(lwcb->out_packet){
        tail = lwcb->out_packet;
        while(tail->next){
            tail = tail->next;
        }
        tail->next = packet;
    }else{
        lwcb->out_packet = packet;
    }
    pthread_mutex_unlock(&lwcb->out_packet_mutex);
#ifdef WITH_BROKER
	return _lwcb_packet_write(lwcb);
#else
    if(lwcb->in_callback == false){
        return _lwcb_packet_write(lwcb);
    }else{
        return LWCB_ERR_SUCCESS;
    }
#endif
}

/* Close a socket associated with a context and set it to -1.
 * Returns 1 on _failure (context is NULL)
 * Returns 0 on success.
 */
int _lwcb_socket_close(struct lwcb *lwcb)
{
    int rc = 0;

    assert(lwcb);
#ifdef WITH_TLS
	if(lwcb->ssl){
		SSL_shutdown(lwcb->ssl);
		SSL_free(lwcb->ssl);
		lwcb->ssl = NULL;
	}
	if(lwcb->ssl_ctx){
		SSL_CTX_free(lwcb->ssl_ctx);
		lwcb->ssl_ctx = NULL;
	}
#endif

    if(lwcb->sock != INVALID_SOCKET){
        rc = COMPAT_CLOSE(lwcb->sock);
        lwcb->sock = INVALID_SOCKET;
    }

    return rc;
}

#ifdef WITH_TLS_PSK
static unsigned int psk_client_callback(SSL *ssl, const char *hint,
		char *identity, unsigned int max_identity_len,
		unsigned char *psk, unsigned int max_psk_len)
{
	struct lwcb *lwcb;
	int len;

	lwcb = SSL_get_ex_data(ssl, tls_ex_index_lwcb);
	if(!lwcb) return 0;

	snprintf(identity, max_identity_len, "%s", lwcb->tls_psk_identity);

	len = _lwcb_hex2bin(lwcb->tls_psk, psk, max_psk_len);
	if (len < 0) return 0;
	return len;
}
#endif

char *_lwcb_socket_local_address(int sock) {
    struct sockaddr_in local_addr;
    socklen_t local_addrlen = sizeof(local_addr);
    getsockname(sock, (struct sockaddr*)&local_addr, &local_addrlen);
    //(int)ntohs(local_addr.sin_port)
    return inet_ntoa(local_addr.sin_addr);
}

/* Create a socket and connect it to 'ip' on port 'port'.
 * Returns -1 on _failure (ip is NULL, socket creation/connection error)
 * Returns sock number on success.
 */
int _lwcb_socket_connect(struct lwcb *lwcb, const char *host, uint16_t port)
{
    _lwcb_socket_close(lwcb);
    int sock = INVALID_SOCKET;
#ifndef WIN32
    int opt;
#endif
    struct addrinfo hints;
    struct addrinfo *ainfo, *rp;
    int s;
    struct timeval conn_timeout;
#ifdef WIN32
	uint32_t val = 1;
#endif
#ifdef WITH_TLS
	int ret;
	BIO *bio;
#endif

    if(!lwcb || !host || !port) return LWCB_ERR_INVAL;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = PF_UNSPEC;
    hints.ai_flags = AI_ADDRCONFIG;
    hints.ai_socktype = SOCK_STREAM;

    s = getaddrinfo(host, NULL, &hints, &ainfo);
    if(s) return LWCB_ERR_UNKNOWN;
    for(rp = ainfo; rp != NULL; rp = rp->ai_next){
        sock = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);

        if(sock == INVALID_SOCKET) continue;

        if(rp->ai_family == PF_INET){
            ((struct sockaddr_in *)rp->ai_addr)->sin_port = htons(port);
        }else if(rp->ai_family == PF_INET6){
            ((struct sockaddr_in6 *)rp->ai_addr)->sin6_port = htons(port);
        }else{
            continue;
        }
        // add timeout set default 5s
        conn_timeout.tv_sec = 4;
        conn_timeout.tv_usec = 0;
        //setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &conn_timeout, sizeof(conn_timeout));

        /* Set non-blocking */
#ifndef WIN32
        opt = fcntl(sock, F_GETFL, 0);
        if(opt == -1 || fcntl(sock, F_SETFL, opt | O_NONBLOCK) == -1){
#ifdef WITH_TLS
            if(lwcb->ssl){
                SSL_shutdown(lwcb->ssl);
                SSL_free(lwcb->ssl);
                lwcb->ssl = NULL;
            }
            if(lwcb->ssl_ctx){
                SSL_CTX_free(lwcb->ssl_ctx);
                lwcb->ssl_ctx = NULL;
            }
#endif
            COMPAT_CLOSE(sock);
            freeaddrinfo(ainfo);
            if(!rp){
                return LWCB_ERR_ERRNO;
            }
        }
#else
        if(ioctlsocket(sock, FIONBIO, &val)){
            errno = WSAGetLastError();
#ifdef WITH_TLS
            if(lwcb->ssl){
                SSL_shutdown(lwcb->ssl);
                SSL_free(lwcb->ssl);
                lwcb->ssl = NULL;
            }
            if(lwcb->ssl_ctx){
                SSL_CTX_free(lwcb->ssl_ctx);
                lwcb->ssl_ctx = NULL;
            }
#endif
            errno = WSAGetLastError();
            COMPAT_CLOSE(sock);
            freeaddrinfo(ainfo);
            if(!rp){
                return LWCB_ERR_ERRNO;
            }
        }
#endif

        if(connect(sock, rp->ai_addr, rp->ai_addrlen) != -1) { //&& errno!=EINPROGRESS) {
            break;
        } else {
            fd_set set;
            FD_ZERO(&set);
            FD_SET(sock, &set);
            if(select(sock+1, NULL, &set, NULL, &conn_timeout) > 0) {
                int error=0, len;
                getsockopt(sock, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&len);
                if(error == 0) break;
            } else {
                errno = ETIMEDOUT;
                break;
            }
        }

#ifdef WIN32
		errno = WSAGetLastError();
#endif
        COMPAT_CLOSE(sock);
    }

    freeaddrinfo(ainfo);
    if(!rp){
        return LWCB_ERR_ERRNO;
    }

#ifdef WITH_TLS
	if(lwcb->tls_cafile || lwcb->tls_capath || lwcb->tls_psk){
		if(!lwcb->tls_version || !strcmp(lwcb->tls_version, "tlsv1")){
			lwcb->ssl_ctx = SSL_CTX_new(TLSv1_client_method());
			if(!lwcb->ssl_ctx){
				_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to create TLS context.");
				COMPAT_CLOSE(sock);
				return LWCB_ERR_TLS;
			}
		}else{
			COMPAT_CLOSE(sock);
			return LWCB_ERR_INVAL;
		}

#if OPENSSL_VERSION_NUMBER >= 0x10000000
		/* Disable compression */
		SSL_CTX_set_options(lwcb->ssl_ctx, SSL_OP_NO_COMPRESSION);
#endif
#ifdef SSL_MODE_RELEASE_BUFFERS
			/* Use even less memory per SSL connection. */
			SSL_CTX_set_mode(lwcb->ssl_ctx, SSL_MODE_RELEASE_BUFFERS);
#endif

		if(lwcb->tls_ciphers){
			ret = SSL_CTX_set_cipher_list(lwcb->ssl_ctx, lwcb->tls_ciphers);
			if(ret == 0){
				_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to set TLS ciphers. Check cipher list \"%s\".", lwcb->tls_ciphers);
				COMPAT_CLOSE(sock);
				return LWCB_ERR_TLS;
			}
		}
		if(lwcb->tls_cafile || lwcb->tls_capath){
			ret = SSL_CTX_load_verify_locations(lwcb->ssl_ctx, lwcb->tls_cafile, lwcb->tls_capath);
			if(ret == 0){
#ifdef WITH_BROKER
				if(lwcb->tls_cafile && lwcb->tls_capath){
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load CA certificates, check bridge_cafile \"%s\" and bridge_capath \"%s\".", lwcb->tls_cafile, lwcb->tls_capath);
				}else if(lwcb->tls_cafile){
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load CA certificates, check bridge_cafile \"%s\".", lwcb->tls_cafile);
				}else{
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load CA certificates, check bridge_capath \"%s\".", lwcb->tls_capath);
				}
#else
				if(lwcb->tls_cafile && lwcb->tls_capath){
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load CA certificates, check cafile \"%s\" and capath \"%s\".", lwcb->tls_cafile, lwcb->tls_capath);
				}else if(lwcb->tls_cafile){
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load CA certificates, check cafile \"%s\".", lwcb->tls_cafile);
				}else{
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load CA certificates, check capath \"%s\".", lwcb->tls_capath);
				}
#endif
				COMPAT_CLOSE(sock);
				return LWCB_ERR_TLS;
			}
			if(lwcb->tls_cert_reqs == 0){
				SSL_CTX_set_verify(lwcb->ssl_ctx, SSL_VERIFY_NONE, NULL);
			}else{
				SSL_CTX_set_verify(lwcb->ssl_ctx, SSL_VERIFY_PEER, NULL);
			}

			if(lwcb->tls_pw_callback){
				SSL_CTX_set_default_passwd_cb(lwcb->ssl_ctx, lwcb->tls_pw_callback);
				SSL_CTX_set_default_passwd_cb_userdata(lwcb->ssl_ctx, lwcb);
			}

			if(lwcb->tls_certfile){
				ret = SSL_CTX_use_certificate_file(lwcb->ssl_ctx, lwcb->tls_certfile, SSL_FILETYPE_PEM);
				if(ret != 1){
#ifdef WITH_BROKER
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load client certificate, check bridge_certfile \"%s\".", lwcb->tls_certfile);
#else
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load client certificate \"%s\".", lwcb->tls_certfile);
#endif
					COMPAT_CLOSE(sock);
					return LWCB_ERR_TLS;
				}
			}
			if(lwcb->tls_keyfile){
				ret = SSL_CTX_use_PrivateKey_file(lwcb->ssl_ctx, lwcb->tls_keyfile, SSL_FILETYPE_PEM);
				if(ret != 1){
#ifdef WITH_BROKER
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load client key file, check bridge_keyfile \"%s\".", lwcb->tls_keyfile);
#else
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Unable to load client key file \"%s\".", lwcb->tls_keyfile);
#endif
					COMPAT_CLOSE(sock);
					return LWCB_ERR_TLS;
				}
				ret = SSL_CTX_check_private_key(lwcb->ssl_ctx);
				if(ret != 1){
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "Error: Client certificate/key are inconsistent.");
					COMPAT_CLOSE(sock);
					return LWCB_ERR_TLS;
				}
			}
#ifdef WITH_TLS_PSK
		}else if(lwcb->tls_psk){
			SSL_CTX_set_psk_client_callback(lwcb->ssl_ctx, psk_client_callback);
#endif
		}

		lwcb->ssl = SSL_new(lwcb->ssl_ctx);
		if(!lwcb->ssl){
			COMPAT_CLOSE(sock);
			return LWCB_ERR_TLS;
		}
		SSL_set_ex_data(lwcb->ssl, tls_ex_index_lwcb, lwcb);
		bio = BIO_new_socket(sock, BIO_NOCLOSE);
		if(!bio){
			COMPAT_CLOSE(sock);
			return LWCB_ERR_TLS;
		}
		SSL_set_bio(lwcb->ssl, bio, bio);

		ret = SSL_connect(lwcb->ssl);
		if(ret != 1){
			ret = SSL_get_error(lwcb->ssl, ret);
			if(ret == SSL_ERROR_WANT_READ){
				lwcb->want_read = true;
			}else if(ret == SSL_ERROR_WANT_WRITE){
				lwcb->want_write = true;
			}else{
				COMPAT_CLOSE(sock);
				return LWCB_ERR_TLS;
			}
		}
	}
#endif

    lwcb->sock = sock;
    if(lwcb->address) _lwcb_free(lwcb->address);
    lwcb->address = _lwcb_strdup(_lwcb_socket_local_address(sock));
    //_lwcb_log_printf(lwcb, LWCB_LOG_INFO, "sock local address: %s", lwcb->address);
    return LWCB_ERR_SUCCESS;
}

int _lwcb_read_byte(struct _lwcb_packet *packet, uint8_t *byte)
{
    assert(packet);
    if(packet->pos+1 > packet->remaining_length) return LWCB_ERR_PROTOCOL;

    *byte = packet->payload[packet->pos];
    packet->pos++;

    return LWCB_ERR_SUCCESS;
}

void _lwcb_write_byte(struct _lwcb_packet *packet, uint8_t byte)
{
    assert(packet);
    assert(packet->pos+1 <= packet->packet_length);

    packet->payload[packet->pos] = byte;
    packet->pos++;
}

int _lwcb_read_bytes(struct _lwcb_packet *packet, void *bytes, uint32_t count)
{
    assert(packet);
    if(packet->pos+count > packet->remaining_length) return LWCB_ERR_PROTOCOL;

    memcpy(bytes, &(packet->payload[packet->pos]), count);
    packet->pos += count;

    return LWCB_ERR_SUCCESS;
}

void _lwcb_write_bytes(struct _lwcb_packet *packet, const void *bytes, uint32_t count)
{
    assert(packet);
    assert(packet->pos+count <= packet->packet_length);

    memcpy(&(packet->payload[packet->pos]), bytes, count);
    packet->pos += count;
}

int _lwcb_read_string(struct _lwcb_packet *packet, char **str)
{
    uint16_t len;
    int rc;

    assert(packet);
    rc = _lwcb_read_uint16(packet, &len);
    if(rc) return rc;

    if(packet->pos+len > packet->remaining_length) return LWCB_ERR_PROTOCOL;

    *str = _lwcb_calloc(len+1, sizeof(char));
    if(*str){
        memcpy(*str, &(packet->payload[packet->pos]), len);
        packet->pos += len;
    }else{
        return LWCB_ERR_NOMEM;
    }

    return LWCB_ERR_SUCCESS;
}

void _lwcb_write_string(struct _lwcb_packet *packet, const char *str, uint16_t length)
{
    assert(packet);
    _lwcb_write_uint16(packet, length);
    _lwcb_write_bytes(packet, str, length);
}

int _lwcb_read_uint16(struct _lwcb_packet *packet, uint16_t *word)
{
    uint8_t msb, lsb;

    assert(packet);
    if(packet->pos+2 > packet->remaining_length) return LWCB_ERR_PROTOCOL;

    msb = packet->payload[packet->pos];
    packet->pos++;
    lsb = packet->payload[packet->pos];
    packet->pos++;

    *word = (msb<<8) + lsb;

    return LWCB_ERR_SUCCESS;
}

void _lwcb_write_uint16(struct _lwcb_packet *packet, uint16_t word)
{
    _lwcb_write_byte(packet, LWCB_MSB(word));
    _lwcb_write_byte(packet, LWCB_LSB(word));
}

ssize_t _lwcb_net_read(struct lwcb *lwcb, void *buf, size_t count)
{
#ifdef WITH_TLS
	int ret;
	int err;
	char ebuf[256];
	unsigned long e;
#endif
    assert(lwcb);
    errno = 0;
#ifdef WITH_TLS
	if(lwcb->ssl){
		ret = SSL_read(lwcb->ssl, buf, count);
		if(ret <= 0){
			err = SSL_get_error(lwcb->ssl, ret);
			if(err == SSL_ERROR_WANT_READ){
				ret = -1;
				lwcb->want_read = true;
				errno = EAGAIN;
			}else if(err == SSL_ERROR_WANT_WRITE){
				ret = -1;
				lwcb->want_write = true;
				errno = EAGAIN;
			}else{
				e = ERR_get_error();
				while(e){
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "OpenSSL Error: %s", ERR_error_string(e, ebuf));
					e = ERR_get_error();
				}
				errno = EPROTO;
			}
		}
		return (ssize_t )ret;
	}else{
		/* Call normal read/recv */

#endif

#ifndef WIN32
    return read(lwcb->sock, buf, count);
#else
	return recv(lwcb->sock, buf, count, 0);
#endif

#ifdef WITH_TLS
	}
#endif
}

ssize_t _lwcb_net_write(struct lwcb *lwcb, void *buf, size_t count)
{
#ifdef WITH_TLS
	int ret;
	int err;
	char ebuf[256];
	unsigned long e;
#endif
    assert(lwcb);

    errno = 0;
#ifdef WITH_TLS
	if(lwcb->ssl){
		ret = SSL_write(lwcb->ssl, buf, count);
		if(ret < 0){
			err = SSL_get_error(lwcb->ssl, ret);
			if(err == SSL_ERROR_WANT_READ){
				ret = -1;
				lwcb->want_read = true;
				errno = EAGAIN;
			}else if(err == SSL_ERROR_WANT_WRITE){
				ret = -1;
				lwcb->want_write = true;
				errno = EAGAIN;
			}else{
				e = ERR_get_error();
				while(e){
					_lwcb_log_printf(lwcb, LWCB_LOG_ERR, "OpenSSL Error: %s", ERR_error_string(e, ebuf));
					e = ERR_get_error();
				}
				errno = EPROTO;
			}
		}
		return (ssize_t )ret;
	}else{
		/* Call normal write/send */
#endif

#ifndef WIN32
    return write(lwcb->sock, buf, count);
#else
	return send(lwcb->sock, buf, count, 0);
#endif

#ifdef WITH_TLS
	}
#endif
}

int _lwcb_packet_write(struct lwcb *lwcb)
{
    ssize_t write_length;
    struct _lwcb_packet *packet;

    if(!lwcb) return LWCB_ERR_INVAL;
    if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;

    pthread_mutex_lock(&lwcb->current_out_packet_mutex);
    pthread_mutex_lock(&lwcb->out_packet_mutex);
    if(lwcb->out_packet && !lwcb->current_out_packet){
        lwcb->current_out_packet = lwcb->out_packet;
        lwcb->out_packet = lwcb->out_packet->next;
    }
    pthread_mutex_unlock(&lwcb->out_packet_mutex);

    while(lwcb->current_out_packet){
        packet = lwcb->current_out_packet;

        while(packet->to_process > 0){
            write_length = _lwcb_net_write(lwcb, &(packet->payload[packet->pos]), packet->to_process);
            if(write_length > 0){
#ifdef WITH_BROKER
				g_bytes_sent += write_length;
#endif
                packet->to_process -= write_length;
                packet->pos += write_length;
            }else{
#ifdef WIN32
				errno = WSAGetLastError();
#endif
                if(errno == EAGAIN || errno == COMPAT_EWOULDBLOCK){
                    pthread_mutex_unlock(&lwcb->current_out_packet_mutex);
                    return LWCB_ERR_SUCCESS;
                }else{
                    pthread_mutex_unlock(&lwcb->current_out_packet_mutex);
                    switch(errno){
                        case COMPAT_ECONNRESET:
                            return LWCB_ERR_CONN_LOST;
                        default:
                            return LWCB_ERR_ERRNO;
                    }
                }
            }
        }

#ifdef WITH_BROKER
		g_msgs_sent++;
		if(((packet->command)&0xF6) == PUBLISH){
			g_pub_msgs_sent++;
		}
#else
        if(((packet->command)&0xF6) == PUBLISH){
            pthread_mutex_lock(&lwcb->callback_mutex);
            if(lwcb->on_publish){
                /* This is a QoS=0 message */
                lwcb->in_callback = true;
                lwcb->on_publish(lwcb, lwcb->userdata, packet->mid);
                lwcb->in_callback = false;
            }
            pthread_mutex_unlock(&lwcb->callback_mutex);
        }
#endif

        /* Free data and reset values */
        pthread_mutex_lock(&lwcb->out_packet_mutex);
        lwcb->current_out_packet = lwcb->out_packet;
        if(lwcb->out_packet){
            lwcb->out_packet = lwcb->out_packet->next;
        }
        pthread_mutex_unlock(&lwcb->out_packet_mutex);

        _lwcb_packet_cleanup(packet);
        _lwcb_free(packet);

        pthread_mutex_lock(&lwcb->msgtime_mutex);
        lwcb->last_msg_out = time(NULL);
        pthread_mutex_unlock(&lwcb->msgtime_mutex);
    }
    pthread_mutex_unlock(&lwcb->current_out_packet_mutex);
    return LWCB_ERR_SUCCESS;
}

#ifdef WITH_BROKER
int _lwcb_packet_read(struct lwcb_db *db, struct lwcb *lwcb)
#else
int _lwcb_packet_read(struct lwcb *lwcb)
#endif
{
    uint8_t byte;
    ssize_t read_length;
    int rc = 0;

    if(!lwcb) return LWCB_ERR_INVAL;
    if(lwcb->sock == INVALID_SOCKET) return LWCB_ERR_NO_CONN;
    /* This gets called if pselect() indicates that there is network data
     * available - ie. at least one byte.  What we do depends on what data we
     * already have.
     * If we've not got a command, attempt to read one and save it. This should
     * always work because it's only a single byte.
     * Then try to read the remaining length. This may fail because it is may
     * be more than one byte - will need to save data pending next read if it
     * does fail.
     * Then try to read the remaining payload, where 'payload' here means the
     * combined variable header and actual payload. This is the most likely to
     * fail due to longer length, so save current data and current position.
     * After all data is read, send to _lwcb_handle_packet() to deal with.
     * Finally, free the memory and reset everything to starting conditions.
     */
    if(!lwcb->in_packet.command){
        read_length = _lwcb_net_read(lwcb, &byte, 1);
        if(read_length == 1){
            lwcb->in_packet.command = byte;
#ifdef WITH_BROKER
			g_bytes_received++;
			/* Clients must send CONNECT as their first command. */
			if(!(lwcb->bridge) && lwcb->state == lwcb_cs_new && (byte&0xF0) != CONNECT) return LWCB_ERR_PROTOCOL;
#endif
        }else{
            if(read_length == 0) return LWCB_ERR_CONN_LOST; /* EOF */
#ifdef WIN32
			errno = WSAGetLastError();
#endif
            if(errno == EAGAIN || errno == COMPAT_EWOULDBLOCK){
                return LWCB_ERR_SUCCESS;
            }else{
                switch(errno){
                    case COMPAT_ECONNRESET:
                        return LWCB_ERR_CONN_LOST;
                    default:
                        return LWCB_ERR_ERRNO;
                }
            }
        }
    }
    if(!lwcb->in_packet.have_remaining){
        /* Read remaining
         * Algorithm for decoding taken from pseudo code at
         * http://publib.boulder.ibm.com/infocenter/wmbhelp/v6r0m0/topic/com.ibm.etools.mft.doc/ac10870_.htm
         */
        do{
            read_length = _lwcb_net_read(lwcb, &byte, 1);
            if(read_length == 1){
                lwcb->in_packet.remaining_count++;
                /* Max 4 bytes length for remaining length as defined by protocol.
                 * Anything more likely means a broken/malicious client.
                 */
                if(lwcb->in_packet.remaining_count > 4) return LWCB_ERR_PROTOCOL;

#ifdef WITH_BROKER
				g_bytes_received++;
#endif
                lwcb->in_packet.remaining_length += (byte & 127) * lwcb->in_packet.remaining_mult;
                lwcb->in_packet.remaining_mult *= 128;
            }else{
                if(read_length == 0) return LWCB_ERR_CONN_LOST; /* EOF */
#ifdef WIN32
				errno = WSAGetLastError();
#endif
                if(errno == EAGAIN || errno == COMPAT_EWOULDBLOCK){
                    return LWCB_ERR_SUCCESS;
                }else{
                    switch(errno){
                        case COMPAT_ECONNRESET:
                            return LWCB_ERR_CONN_LOST;
                        default:
                            return LWCB_ERR_ERRNO;
                    }
                }
            }
        }while((byte & 128) != 0);

        if(lwcb->in_packet.remaining_length > 0){
            lwcb->in_packet.payload = _lwcb_malloc(lwcb->in_packet.remaining_length*sizeof(uint8_t));
            if(!lwcb->in_packet.payload) return LWCB_ERR_NOMEM;
            lwcb->in_packet.to_process = lwcb->in_packet.remaining_length;
        }
        lwcb->in_packet.have_remaining = 1;
    }
    while(lwcb->in_packet.to_process>0){
        read_length = _lwcb_net_read(lwcb, &(lwcb->in_packet.payload[lwcb->in_packet.pos]), lwcb->in_packet.to_process);
        if(read_length > 0){
#ifdef WITH_BROKER
			g_bytes_received += read_length;
#endif
            lwcb->in_packet.to_process -= read_length;
            lwcb->in_packet.pos += read_length;
        }else{
#ifdef WIN32
			errno = WSAGetLastError();
#endif
            if(errno == EAGAIN || errno == COMPAT_EWOULDBLOCK){
                return LWCB_ERR_SUCCESS;
            }else{
                switch(errno){
                    case COMPAT_ECONNRESET:
                        return LWCB_ERR_CONN_LOST;
                    default:
                        return LWCB_ERR_ERRNO;
                }
            }
        }
    }

    /* All data for this packet is read. */
    lwcb->in_packet.pos = 0;
#ifdef WITH_BROKER
	g_msgs_received++;
	if(((lwcb->in_packet.command)&0xF5) == PUBLISH){
		g_pub_msgs_received++;
	}
	rc = mqtt3_packet_handle(db, lwcb);
#else
    rc = _lwcb_packet_handle(lwcb);
#endif

    /* Free data and reset values */
    _lwcb_packet_cleanup(&lwcb->in_packet);

    pthread_mutex_lock(&lwcb->msgtime_mutex);
    lwcb->last_msg_in = time(NULL);
    pthread_mutex_unlock(&lwcb->msgtime_mutex);
    return rc;
}


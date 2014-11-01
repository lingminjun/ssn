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
#include <time.h>

#ifdef WIN32
#include <winsock2.h>
#endif

#if defined(WITH_TLS) && defined(WITH_TLS_PSK)
#include <openssl/ssl.h>
#endif

#include <lwcb.h>
#include <lwcb_memory.h>
#include <lwcb_net.h>
#include <lwcb_send.h>
#include <lwcb_util.h>

#ifdef WITH_BROKER
#include <lwcb_broker.h>
#endif

int _lwcb_packet_alloc(struct _lwcb_packet *packet)
{
	uint8_t remaining_bytes[5], byte;
	uint32_t remaining_length;
	int i;

	assert(packet);

	remaining_length = packet->remaining_length;
	packet->payload = NULL;
	packet->remaining_count = 0;
	do{
		byte = remaining_length % 128;
		remaining_length = remaining_length / 128;
		/* If there are more digits to encode, set the top bit of this digit */
		if(remaining_length > 0){
			byte = byte | 0x80;
		}
		remaining_bytes[packet->remaining_count] = byte;
		packet->remaining_count++;
	}while(remaining_length > 0 && packet->remaining_count < 5);
	if(packet->remaining_count == 5) return LWCB_ERR_PAYLOAD_SIZE;
	packet->packet_length = packet->remaining_length + 1 + packet->remaining_count;
	packet->payload = _lwcb_malloc(sizeof(uint8_t)*packet->packet_length);
	if(!packet->payload) return LWCB_ERR_NOMEM;

	packet->payload[0] = packet->command;
	for(i=0; i<packet->remaining_count; i++){
		packet->payload[i+1] = remaining_bytes[i];
	}
	packet->pos = 1 + packet->remaining_count;

	return LWCB_ERR_SUCCESS;
}

void _lwcb_check_keepalive(struct lwcb *lwcb)
{
	time_t last_msg_out;
	time_t last_msg_in;
	time_t now = time(NULL);
#ifndef WITH_BROKER
	int rc;
#endif

	assert(lwcb);
#if defined(WITH_BROKER) && defined(WITH_BRIDGE)
	/* Check if a lazy bridge should be timed out due to idle. */
	if(lwcb->bridge && lwcb->bridge->start_type == bst_lazy
				&& lwcb->sock != INVALID_SOCKET
				&& now - lwcb->last_msg_out >= lwcb->bridge->idle_timeout){

		_lwcb_log_printf(NULL, LWCB_LOG_NOTICE, "Bridge connection %s has exceeded idle timeout, disconnecting.", lwcb->id);
		_lwcb_socket_close(lwcb);
		return;
	}
#endif
	pthread_mutex_lock(&lwcb->msgtime_mutex);
	last_msg_out = lwcb->last_msg_out;
	last_msg_in = lwcb->last_msg_in;
	pthread_mutex_unlock(&lwcb->msgtime_mutex);

	if(lwcb->sock != INVALID_SOCKET &&
			(now - last_msg_out >= lwcb->keepalive || now - last_msg_in >= lwcb->keepalive)){

		if(lwcb->state == lwcb_cs_connected && lwcb->ping_t == 0){
			_lwcb_send_pingreq(lwcb);
			/* Reset last msg times to give the server time to send a pingresp */
			pthread_mutex_lock(&lwcb->msgtime_mutex);
			lwcb->last_msg_in = now;
			lwcb->last_msg_out = now;
			pthread_mutex_unlock(&lwcb->msgtime_mutex);
		}else{
#ifdef WITH_BROKER
			if(lwcb->listener){
				lwcb->listener->client_count--;
				assert(lwcb->listener->client_count >= 0);
			}
			lwcb->listener = NULL;
#endif
			_lwcb_socket_close(lwcb);
#ifndef WITH_BROKER
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
#endif
		}
	}
}

/* Convert ////some////over/slashed///topic/etc/etc//
 * into some/over/slashed/topic/etc/etc
 */
int _lwcb_fix_sub_topic(char **subtopic)
{
	char *fixed = NULL;
	char *token;
	char *saveptr = NULL;

	assert(subtopic);
	assert(*subtopic);

	if(strlen(*subtopic) == 0) return LWCB_ERR_SUCCESS;
	/* size of fixed here is +1 for the terminating 0 and +1 for the spurious /
	 * that gets appended. */
	fixed = _lwcb_calloc(strlen(*subtopic)+2, 1);
	if(!fixed) return LWCB_ERR_NOMEM;

	if((*subtopic)[0] == '/'){
		fixed[0] = '/';
	}
	token = strtok_r(*subtopic, "/", &saveptr);
	while(token){
		strcat(fixed, token);
		strcat(fixed, "/");
		token = strtok_r(NULL, "/", &saveptr);
	}

	fixed[strlen(fixed)-1] = '\0';
	_lwcb_free(*subtopic);
	*subtopic = fixed;
	return LWCB_ERR_SUCCESS;
}

uint16_t _lwcb_mid_generate(struct lwcb *lwcb)
{
	assert(lwcb);

	lwcb->last_mid++;
	if(lwcb->last_mid == 0) lwcb->last_mid++;
	
	return lwcb->last_mid;
}

/* Search for + or # in a topic. Return LWCB_ERR_INVAL if found.
 * Also returns LWCB_ERR_INVAL if the topic string is too long.
 * Returns LWCB_ERR_SUCCESS if everything is fine.
 */
int _lwcb_topic_wildcard_len_check(const char *str)
{
	int len = 0;
	while(str && str[0]){
		if(str[0] == '+' || str[0] == '#'){
			return LWCB_ERR_INVAL;
		}
		len++;
		str = &str[1];
	}
	if(len > 65535) return LWCB_ERR_INVAL;

	return LWCB_ERR_SUCCESS;
}

/* Does a topic match a subscription? */
int lwcb_topic_matches_sub(const char *sub, const char *topic, bool *result)
{
	char *local_sub, *local_topic;
	int slen, tlen;
	int spos, tpos;
	int rc;
	bool multilevel_wildcard = false;

	if(!sub || !topic || !result) return LWCB_ERR_INVAL;

	local_sub = _lwcb_strdup(sub);
	if(!local_sub) return LWCB_ERR_NOMEM;
	rc = _lwcb_fix_sub_topic(&local_sub);
	if(rc){
		_lwcb_free(local_sub);
		return rc;
	}

	local_topic = _lwcb_strdup(topic);
	if(!local_topic){
		_lwcb_free(local_sub);
		return LWCB_ERR_NOMEM;
	}
	rc = _lwcb_fix_sub_topic(&local_topic);
	if(rc){
		_lwcb_free(local_sub);
		_lwcb_free(local_topic);
		return rc;
	}

	slen = strlen(local_sub);
	tlen = strlen(local_topic);

	spos = 0;
	tpos = 0;

	while(spos < slen && tpos < tlen){
		if(local_sub[spos] == local_topic[tpos]){
			spos++;
			tpos++;
			if(spos == slen && tpos == tlen){
				*result = true;
				break;
			}
		}else{
			if(local_sub[spos] == '+'){
				spos++;
				while(tpos < tlen && local_topic[tpos] != '/'){
					tpos++;
				}
				if(tpos == tlen && spos == slen){
					*result = true;
					break;
				}
			}else if(local_sub[spos] == '#'){
				multilevel_wildcard = true;
				if(spos+1 != slen){
					*result = false;
					break;
				}else{
					*result = true;
					break;
				}
			}else{
				*result = false;
				break;
			}
		}
		if(tpos == tlen-1){
			/* Check for e.g. foo matching foo/# */
			if(spos == slen-3 
					&& local_sub[spos+1] == '/'
					&& local_sub[spos+2] == '#'){
				*result = true;
				multilevel_wildcard = true;
				break;
			}
		}
	}
	if(multilevel_wildcard == false && (tpos < tlen || spos < slen)){
		*result = false;
	}

	_lwcb_free(local_sub);
	_lwcb_free(local_topic);
	return LWCB_ERR_SUCCESS;
}

#if defined(WITH_TLS) && defined(WITH_TLS_PSK)
int _lwcb_hex2bin(const char *hex, unsigned char *bin, int bin_max_len)
{
	BIGNUM *bn = NULL;
	int len;

	if(BN_hex2bn(&bn, hex) == 0){
		if(bn) BN_free(bn);
		return 0;
	}
	if(BN_num_bytes(bn) > bin_max_len){
		BN_free(bn);
		return 0;
	}

	len = BN_bn2bin(bn, bin);
	BN_free(bn);
	return len;
}
#endif

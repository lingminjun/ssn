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

#ifndef _LWCB_H_
#define _LWCB_H_

#ifdef __cplusplus
extern "C" {
#endif

#if defined(WIN32) && !defined(WITH_BROKER)
#	ifdef liblwcb_EXPORTS
#		define liblwcb_EXPORT  __declspec(dllexport)
#	else
#		define liblwcb_EXPORT  __declspec(dllimport)
#	endif
#else
#	define liblwcb_EXPORT
#endif

#if defined(WIN32)
#	ifndef __cplusplus
#		define bool char
#		define true 1
#		define false 0
#	endif
#else
#	ifndef __cplusplus
#		include <stdbool.h>
#	endif
#endif

#define LIBLWCB_MAJOR 1
#define LIBLWCB_MINOR 0
#define LIBLWCB_REVISION 0
#define LIBLWCB_VERSION_NUMBER (LIBLWCB_MAJOR*1000000+LIBLWCB_MINOR*1000+LIBLWCB_REVISION)

/* Log types */
#define LWCB_LOG_NONE 0x00
#define LWCB_LOG_INFO 0x01
#define LWCB_LOG_NOTICE 0x02
#define LWCB_LOG_WARNING 0x04
#define LWCB_LOG_ERR 0x08
#define LWCB_LOG_DEBUG 0x10
#define LWCB_LOG_ALL 0xFF

/* Error values */
enum lwcb_err_t {
	LWCB_ERR_SUCCESS = 0,
	LWCB_ERR_NOMEM = 1,
	LWCB_ERR_PROTOCOL = 2,
	LWCB_ERR_INVAL = 3,
	LWCB_ERR_NO_CONN = 4,
	LWCB_ERR_CONN_REFUSED = 5,
	LWCB_ERR_NOT_FOUND = 6,
	LWCB_ERR_CONN_LOST = 7,
	LWCB_ERR_TLS = 8,
	LWCB_ERR_PAYLOAD_SIZE = 9,
	LWCB_ERR_NOT_SUPPORTED = 10,
	LWCB_ERR_AUTH = 11,
	LWCB_ERR_ACL_DENIED = 12,
	LWCB_ERR_UNKNOWN = 13,
	LWCB_ERR_ERRNO = 14
};

/* MQTT specification restricts client ids to a maximum of 23 characters */
#define LWCB_CLIENT_ID_MAX_LENGTH 256

struct lwcb_message{
	int mid;
	char *topic;
	void *payload;
	int payloadlen;
	int qos;
	bool retain;
};

struct lwcb;

/*
 * Topic: Threads
 *	liblwcb provides thread safe operation. 
 */
/***************************************************
 * Important note
 * 
 * The following functions that deal with network operations will return
 * LWCB_ERR_SUCCESS on success, but this does not mean that the operation has
 * taken place. An attempt will be made to write the network data, but if the
 * socket is not available for writing at that time then the packet will not be
 * sent. To ensure the packet is sent, call lwcb_loop() (which must also
 * be called to process incoming network data).
 * This is especially important when disconnecting a client that has a will. If
 * the broker does not receive the DISCONNECT command, it will assume that the
 * client has disconnected unexpectedly and send the will.
 *
 * lwcb_connect()
 * lwcb_disconnect()
 * lwcb_subscribe()
 * lwcb_unsubscribe()
 * lwcb_publish()
 ***************************************************/

/*
 * Function: lwcb_lib_version
 *
 * Can be used to obtain version information for the lwcb library.
 * This allows the application to compare the library version against the
 * version it was compiled against by using the LIBLWCBUITTO_MAJOR,
 * LIBLWCBUITTO_MINOR and LIBLWCBUITTO_REVISION defines.
 *
 * Parameters:
 *  major -    an integer pointer. If not NULL, the major version of the
 *             library will be returned in this variable.
 *  minor -    an integer pointer. If not NULL, the minor version of the
 *             library will be returned in this variable.
 *  revision - an integer pointer. If not NULL, the revision of the library will
 *             be returned in this variable.
 *
 * Returns:
 *	LIBLWCBUITTO_VERSION_NUMBER, which is a unique number based on the major,
 *		minor and revision values.
 * See Also:
 * 	<lwcb_lib_cleanup>, <lwcb_lib_init>
 */
liblwcb_EXPORT int lwcb_lib_version(int *major, int *minor, int *revision);

/*
 * Function: lwcb_lib_init
 *
 * Must be called before any other lwcb functions.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - always
 *
 * See Also:
 * 	<lwcb_lib_cleanup>, <lwcb_lib_version>
 */
liblwcb_EXPORT int lwcb_lib_init(void);

/*
 * Function: lwcb_lib_cleanup
 *
 * Call to free resources associated with the library.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - always
 *
 * See Also:
 * 	<lwcb_lib_init>, <lwcb_lib_version>
 */
liblwcb_EXPORT int lwcb_lib_cleanup(void);

/*
 * Function: lwcb_new
 *
 * Create a new lwcb client instance.
 *
 * Parameters:
 * 	id -            String to use as the client id. If NULL, a random client id
 * 	                will be generated. If id is NULL, clean_session must be true.
 * 	clean_session - set to true to instruct the broker to clean all messages
 *                  and subscriptions on disconnect, false to instruct it to
 *                  keep them. See the man page mqtt(7) for more details.
 *                  Note that a client will never discard its own outgoing
 *                  messages on disconnect. Calling <lwcb_connect> or
 *                  <lwcb_reconnect> will cause the messages to be resent.
 *                  Use <lwcb_reinitialise> to reset a client to its
 *                  original state.
 *                  Must be set to true if the id parameter is NULL.
 * 	obj -           A user pointer that will be passed as an argument to any
 *                  callbacks that are specified.
 *
 * Returns:
 * 	Pointer to a struct lwcb on success.
 * 	NULL on _failure. Interrogate errno to determine the cause for the _failure:
 *      - ENOMEM on out of memory.
 *      - EINVAL on invalid input parameters.
 *
 * See Also:
 * 	<lwcb_reinitialise>, <lwcb_destroy>, <lwcb_user_data_set>
 */
liblwcb_EXPORT struct lwcb *lwcb_new(const char *id, bool clean_session, void *obj);

/* 
 * Function: lwcb_destroy
 *
 * Use to free memory associated with a lwcb client instance.
 *
 * Parameters:
 * 	lwcb - a struct lwcb pointer to free.
 *
 * See Also:
 * 	<lwcb_new>, <lwcb_reinitialise>
 */
liblwcb_EXPORT void lwcb_destroy(struct lwcb *lwcb);

/*
 * Function: lwcb_reinitialise
 *
 * This function allows an existing lwcb client to be reused. Call on a
 * lwcb instance to close any open network connections, free memory
 * and reinitialise the client with the new parameters. The end result is the
 * same as the output of <lwcb_new>.
 *
 * Parameters:
 * 	lwcb -          a valid lwcb instance.
 * 	id -            string to use as the client id. If NULL, a random client id
 * 	                will be generated. If id is NULL, clean_session must be true.
 * 	clean_session - set to true to instruct the broker to clean all messages
 *                  and subscriptions on disconnect, false to instruct it to
 *                  keep them. See the man page mqtt(7) for more details.
 *                  Must be set to true if the id parameter is NULL.
 * 	obj -           A user pointer that will be passed as an argument to any
 *                  callbacks that are specified.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 *
 * See Also:
 * 	<lwcb_new>, <lwcb_destroy>
 */
liblwcb_EXPORT int lwcb_reinitialise(struct lwcb *lwcb, const char *id, bool clean_session, void *obj);

/* 
 * Function: lwcb_will_set
 *
 * Configure will information for a lwcb instance. By default, clients do
 * not have a will.  This must be called before calling <lwcb_connect>.
 *
 * Parameters:
 * 	lwcb -       a valid lwcb instance.
 * 	topic -      the topic on which to publish the will.
 * 	payloadlen - the size of the payload (bytes). Valid values are between 0 and
 *               268,435,455.
 * 	payload -    pointer to the data to send. If payloadlen > 0 this must be a
 *               valid memory location.
 * 	qos -        integer value 0, 1 or 2 indicating the Quality of Service to be
 *               used for the will.
 * 	retain -     set to true to make the will a retained message.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS -      on success.
 * 	LWCB_ERR_INVAL -        if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -        if an out of memory condition occurred.
 * 	LWCB_ERR_PAYLOAD_SIZE - if payloadlen is too large.
 */
liblwcb_EXPORT int lwcb_will_set(struct lwcb *lwcb, const char *topic, int payloadlen, const void *payload, int qos, bool retain);

/* 
 * Function: lwcb_will_clear
 *
 * Remove a previously configured will. This must be called before calling
 * <lwcb_connect>.
 *
 * Parameters:
 * 	lwcb - a valid lwcb instance.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 */
liblwcb_EXPORT int lwcb_will_clear(struct lwcb *lwcb);

/*
 * Function: lwcb_username_pw_set
 *
 * Configure username and password for a lwcbn instance. This is only
 * supported by brokers that implement the MQTT spec v3.1. By default, no
 * username or password will be sent.
 * If username is NULL, the password argument is ignored.
 * This must be called before calling lwcb_connect().
 *
 * This is must be called before calling <lwcb_connect>.
 *
 * Parameters:
 * 	lwcb -     a valid lwcb instance.
 * 	username - the username to send as a string, or NULL to disable
 *             authentication.
 * 	password - the password to send as a string. Set to NULL when username is
 * 	           valid in order to send just a username.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 */
liblwcb_EXPORT int lwcb_username_pw_set(struct lwcb *lwcb, const char *username, const char *password);


/*
 * Function: lwcb_keepalive_set
 *
 * Configure keepalive for a lwcb instance.
 *
 * Parameters:
 * 	lwcb -     a valid lwcb instance.
 * 	keepalive - the number of seconds after which the broker should send a PING
 *              message to the client if no other messages have been exchanged
 *              in that time.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 */
liblwcb_EXPORT int lwcb_keepalive_set(struct lwcb *lwcb, int keepalive);

/*
 * Function: lwcb_keepalive_set
 *
 * Configure host and port for a lwcb instance.
 *
 * Parameters:
 * 	lwcb -     a valid lwcb instance.
 * 	host -      the hostname or ip address of the broker to connect to.
 * 	port -      the network port to connect to. Usually 1883.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 */
liblwcb_EXPORT int lwcb_host_port_set(struct lwcb *lwcb, const char *host, int port);


/*
 * Function: lwcb_connect
 *
 * Connect to an MQTT broker.
 *
 * Parameters:
 * 	lwcb -      a valid lwcb instance.
 * 	host -      the hostname or ip address of the broker to connect to.
 * 	port -      the network port to connect to. Usually 1883.
 * 	keepalive - the number of seconds after which the broker should send a PING
 *              message to the client if no other messages have been exchanged
 *              in that time.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_ERRNO -   if a system call returned an error. The variable errno
 *                     contains the error code, even on Windows.
 *                     Use strerror_r() where available or FormatMessage() on
 *                     Windows.
 *
 * See Also:
 * 	<lwcb_connect_async>, <lwcb_reconnect>, <lwcb_disconnect>, <lwcb_tls_set>
 */
liblwcb_EXPORT int lwcb_connect(struct lwcb *lwcb, const char *host, int port, int keepalive);

/*
 * Function: lwcb_connect_async
 *
 * Connect to an MQTT broker. This is a non-blocking call. If you use
 * <lwcb_connect_async> your client must use the threaded interface
 * <lwcb_loop_start>. If you need to use <lwcb_loop>, you must use
 * <lwcb_connect> to connect the client.
 *
 * May be called before or after <lwcb_loop_start>.
 *
 * Parameters:
 * 	lwcb -      a valid lwcb instance.
 * 	host -      the hostname or ip address of the broker to connect to.
 * 	port -      the network port to connect to. Usually 1883.
 * 	keepalive - the number of seconds after which the broker should send a PING
 *              message to the client if no other messages have been exchanged
 *              in that time.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_ERRNO -   if a system call returned an error. The variable errno
 *                     contains the error code, even on Windows.
 *                     Use strerror_r() where available or FormatMessage() on
 *                     Windows.
 *
 * See Also:
 * 	<lwcb_connect>, <lwcb_reconnect>, <lwcb_disconnect>, <lwcb_tls_set>
 */
liblwcb_EXPORT int lwcb_connect_async(struct lwcb *lwcb, const char *host, int port, int keepalive);

/*
 * Function: lwcb_reconnect
 *
 * Reconnect to a broker.
 *
 * This function provides an easy way of reconnecting to a broker after a
 * connection has been lost. It uses the values that were provided in the
 * <lwcb_connect> call. It must not be called before
 * <lwcb_connect>.
 * 
 * Parameters:
 * 	lwcb - a valid lwcb instance.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_ERRNO -   if a system call returned an error. The variable errno
 *                     contains the error code, even on Windows.
 *                     Use strerror_r() where available or FormatMessage() on
 *                     Windows.
 *
 * See Also:
 * 	<lwcb_connect>, <lwcb_disconnect>
 */
liblwcb_EXPORT int lwcb_reconnect(struct lwcb *lwcb);

/*
 * Function: lwcb_disconnect
 *
 * Disconnect from the broker.
 *
 * Parameters:
 *	lwcb - a valid lwcb instance.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NO_CONN -  if the client isn't connected to a broker.
 */
liblwcb_EXPORT int lwcb_disconnect(struct lwcb *lwcb);

liblwcb_EXPORT int lwcb_on_lost_connect(struct lwcb *lwcb);
/* 
 * Function: lwcb_publish
 *
 * Publish a message on a given topic.
 * 
 * Parameters:
 * 	lwcb -       a valid lwcb instance.
 * 	mid -        pointer to an int. If not NULL, the function will set this
 *               to the message id of this particular message. This can be then
 *               used with the publish callback to determine when the message
 *               has been sent.
 *               Note that although the MQTT protocol doesn't use message ids
 *               for messages with QoS=0, liblwcb assigns them message ids
 *               so they can be tracked with this parameter.
 * 	payloadlen - the size of the payload (bytes). Valid values are between 0 and
 *               268,435,455.
 * 	payload -    pointer to the data to send. If payloadlen > 0 this must be a
 *               valid memory location.
 * 	qos -        integer value 0, 1 or 2 indicating the Quality of Service to be
 *               used for the message.
 * 	retain -     set to true to make the message retained.
 *
 * Returns:
 * 	LWCB_ERR_SUCCESS -      on success.
 * 	LWCB_ERR_INVAL -        if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -        if an out of memory condition occurred.
 * 	LWCB_ERR_NO_CONN -      if the client isn't connected to a broker.
 *	LWCB_ERR_PROTOCOL -     if there is a protocol error communicating with the
 *                          broker.
 * 	LWCB_ERR_PAYLOAD_SIZE - if payloadlen is too large.
 */
liblwcb_EXPORT int lwcb_publish(struct lwcb *lwcb, int *mid, const char *topic, int payloadlen, const void *payload, int qos, bool retain);

/*
 * Function: lwcb_subscribe
 *
 * Subscribe to a topic.
 *
 * Parameters:
 *	lwcb - a valid lwcb instance.
 *	mid -  a pointer to an int. If not NULL, the function will set this to
 *	       the message id of this particular message. This can be then used
 *	       with the subscribe callback to determine when the message has been
 *	       sent.
 *	sub -  the subscription pattern.
 *	qos -  the requested Quality of Service for this subscription.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 * 	LWCB_ERR_NO_CONN - if the client isn't connected to a broker.
 */
liblwcb_EXPORT int lwcb_subscribe(struct lwcb *lwcb, int *mid, const char *sub, int qos);
liblwcb_EXPORT int lwcb_subscribes(struct lwcb *lwcb, int *mid, int count, const char *sub[], unsigned char qos[]);
/*
 * Function: lwcb_unsubscribe
 *
 * Unsubscribe from a topic.
 *
 * Parameters:
 *	lwcb - a valid lwcb instance.
 *	mid -  a pointer to an int. If not NULL, the function will set this to
 *	       the message id of this particular message. This can be then used
 *	       with the unsubscribe callback to determine when the message has been
 *	       sent.
 *	sub -  the unsubscription pattern.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 * 	LWCB_ERR_NO_CONN - if the client isn't connected to a broker.
 */
liblwcb_EXPORT int lwcb_unsubscribe(struct lwcb *lwcb, int *mid, const char *sub);
liblwcb_EXPORT int lwcb_unsubscribes(struct lwcb *lwcb, int *mid, int count, const char *sub[]);


liblwcb_EXPORT int lwcb_pingreq(struct lwcb *lwcb);

/*
 * Function: lwcb_message_copy
 *
 * Copy the contents of a lwcb message to another message.
 * Useful for preserving a message received in the on_message() callback.
 *
 * Parameters:
 *	dst - a pointer to a valid lwcb_message struct to copy to.
 *	src - a pointer to a valid lwcb_message struct to copy from.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 *
 * See Also:
 * 	<lwcb_message_free>
 */
liblwcb_EXPORT int lwcb_message_copy(struct lwcb_message *dst, const struct lwcb_message *src);

/*
 * Function: lwcb_message_free
 * 
 * Completely free a lwcb_message struct.
 *
 * Parameters:
 *	message - pointer to a lwcb_message pointer to free.
 *
 * See Also:
 * 	<lwcb_message_copy>
 */
liblwcb_EXPORT void lwcb_message_free(struct lwcb_message **message);

/*
 * Function: lwcb_loop
 *
 * The main network loop for the client. You must call this frequently in order
 * to keep communications between the client and broker working. If incoming
 * data is present it will then be processed. Outgoing commands, from e.g.
 * <lwcb_publish>, are normally sent immediately that their function is
 * called, but this is not always possible. <lwcb_loop> will also attempt
 * to send any remaining outgoing messages, which also includes commands that
 * are part of the flow for messages with QoS>0.
 *
 * An alternative approach is to use <lwcb_loop_start> to run the client
 * loop in its own thread.
 *
 * This calls select() to monitor the client network socket. If you want to
 * integrate lwcb client operation with your own select() call, use
 * <lwcb_socket>, <lwcb_loop_read>, <lwcb_loop_write> and
 * <lwcb_loop_misc>.
 *
 * Threads:
 *	
 * Parameters:
 *	lwcb -        a valid lwcb instance.
 *	timeout -     Maximum number of milliseconds to wait for network activity
 *	              in the select() call before timing out. Set to 0 for instant
 *	              return.  Set negative to use the default of 1000ms.
 *	max_packets - this parameter is currently unused.
 * 
 * Returns:
 *	LWCB_ERR_SUCCESS -   on success.
 * 	LWCB_ERR_INVAL -     if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -     if an out of memory condition occurred.
 * 	LWCB_ERR_NO_CONN -   if the client isn't connected to a broker.
 *  LWCB_ERR_CONN_LOST - if the connection to the broker was lost.
 *	LWCB_ERR_PROTOCOL -  if there is a protocol error communicating with the
 *                       broker.
 * 	LWCB_ERR_ERRNO -     if a system call returned an error. The variable errno
 *                       contains the error code, even on Windows.
 *                       Use strerror_r() where available or FormatMessage() on
 *                       Windows.
 * See Also:
 *	<lwcb_loop_forever>, <lwcb_loop_start>, <lwcb_loop_stop>
 */
liblwcb_EXPORT int lwcb_loop(struct lwcb *lwcb, int timeout, int max_packets);

/*
 * Function: lwcb_loop_forever
 *
 * This function call loop() for you in an infinite blocking loop. It is useful
 * for the case where you only want to run the MQTT client loop in your
 * program.
 *
 * It handles reconnecting in case server connection is lost. If you call
 * lwcb_disconnect() in a callback it will return.
 *
 * Parameters:
 *  lwcb - a valid lwcb instance.
 *	timeout -     Maximum number of milliseconds to wait for network activity
 *	              in the select() call before timing out. Set to 0 for instant
 *	              return.  Set negative to use the default of 1000ms.
 *	max_packets - this parameter is currently unused.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS -   on success.
 * 	LWCB_ERR_INVAL -     if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -     if an out of memory condition occurred.
 * 	LWCB_ERR_NO_CONN -   if the client isn't connected to a broker.
 *  LWCB_ERR_CONN_LOST - if the connection to the broker was lost.
 *	LWCB_ERR_PROTOCOL -  if there is a protocol error communicating with the
 *                       broker.
 * 	LWCB_ERR_ERRNO -     if a system call returned an error. The variable errno
 *                       contains the error code, even on Windows.
 *                       Use strerror_r() where available or FormatMessage() on
 *                       Windows.
 *
 * See Also:
 *	<lwcb_loop>, <lwcb_loop_start>
 */
liblwcb_EXPORT int lwcb_loop_forever(struct lwcb *lwcb, int timeout, int max_packets);

/*
 * Function: lwcb_loop_start
 *
 * This is part of the threaded client interface. Call this once to start a new
 * thread to process network traffic. This provides an alternative to
 * repeatedly calling <lwcb_loop> yourself.
 *
 * Parameters:
 *  lwcb - a valid lwcb instance.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS -       on success.
 * 	LWCB_ERR_INVAL -         if the input parameters were invalid.
 *	LWCB_ERR_NOT_SUPPORTED - if thread support is not available.
 *
 * See Also:
 *	<lwcb_connect_async>, <lwcb_loop>, <lwcb_loop_forever>, <lwcb_loop_stop>
 */
liblwcb_EXPORT int lwcb_loop_start(struct lwcb *lwcb);

liblwcb_EXPORT int lwcb_get_state(struct lwcb *lwcb);

/*
 * Function: lwcb_loop_stop
 *
 * This is part of the threaded client interface. Call this once to stop the
 * network thread previously created with <lwcb_loop_start>. This call
 * will block until the network thread finishes. For the network thread to end,
 * you must have previously called <lwcb_disconnect> or have set the force
 * parameter to true.
 *
 * Parameters:
 *  lwcb - a valid lwcb instance.
 *	force - set to true to force thread cancellation. If false,
 *	        <lwcb_disconnect> must have already been called.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS -       on success.
 * 	LWCB_ERR_INVAL -         if the input parameters were invalid.
 *	LWCB_ERR_NOT_SUPPORTED - if thread support is not available.
 *
 * See Also:
 *	<lwcb_loop>, <lwcb_loop_start>
 */
liblwcb_EXPORT int lwcb_loop_stop(struct lwcb *lwcb, bool force);

/*
 * Function: lwcb_socket
 *
 * Return the socket handle for a lwcb instance. Useful if you want to
 * include a lwcb client in your own select() calls.
 *
 * Parameters:
 *	lwcb - a valid lwcb instance.
 *
 * Returns:
 *	The socket for the lwcb client or -1 on _failure.
 */
liblwcb_EXPORT int lwcb_socket(struct lwcb *lwcb);

/*
 * Function: lwcb_loop_read
 *
 * Carry out network read operations.
 * This should only be used if you are not using lwcb_loop() and are
 * monitoring the client network socket for activity yourself.
 *
 * Parameters:
 *	lwcb -        a valid lwcb instance.
 *	max_packets - this parameter is currently unused.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS -   on success.
 * 	LWCB_ERR_INVAL -     if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -     if an out of memory condition occurred.
 * 	LWCB_ERR_NO_CONN -   if the client isn't connected to a broker.
 *  LWCB_ERR_CONN_LOST - if the connection to the broker was lost.
 *	LWCB_ERR_PROTOCOL -  if there is a protocol error communicating with the
 *                       broker.
 * 	LWCB_ERR_ERRNO -     if a system call returned an error. The variable errno
 *                       contains the error code, even on Windows.
 *                       Use strerror_r() where available or FormatMessage() on
 *                       Windows.
 *
 * See Also:
 *	<lwcb_socket>, <lwcb_loop_write>, <lwcb_loop_misc>
 */
liblwcb_EXPORT int lwcb_loop_read(struct lwcb *lwcb, int max_packets);

/*
 * Function: lwcb_loop_write
 *
 * Carry out network write operations.
 * This should only be used if you are not using lwcb_loop() and are
 * monitoring the client network socket for activity yourself.
 *
 * Parameters:
 *	lwcb -        a valid lwcb instance.
 *	max_packets - this parameter is currently unused.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS -   on success.
 * 	LWCB_ERR_INVAL -     if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -     if an out of memory condition occurred.
 * 	LWCB_ERR_NO_CONN -   if the client isn't connected to a broker.
 *  LWCB_ERR_CONN_LOST - if the connection to the broker was lost.
 *	LWCB_ERR_PROTOCOL -  if there is a protocol error communicating with the
 *                       broker.
 * 	LWCB_ERR_ERRNO -     if a system call returned an error. The variable errno
 *                       contains the error code, even on Windows.
 *                       Use strerror_r() where available or FormatMessage() on
 *                       Windows.
 *
 * See Also:
 *	<lwcb_socket>, <lwcb_loop_read>, <lwcb_loop_misc>, <lwcb_want_write>
 */
liblwcb_EXPORT int lwcb_loop_write(struct lwcb *lwcb, int max_packets);

/*
 * Function: lwcb_loop_misc
 *
 * Carry out miscellaneous operations required as part of the network loop.
 * This should only be used if you are not using lwcb_loop() and are
 * monitoring the client network socket for activity yourself.
 *
 * This function deals with handling PINGs and checking whether messages need
 * to be retried, so should be called fairly frequently.
 *
 * Parameters:
 *	lwcb - a valid lwcb instance.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS -   on success.
 * 	LWCB_ERR_INVAL -     if the input parameters were invalid.
 * 	LWCB_ERR_NO_CONN -   if the client isn't connected to a broker.
 *
 * See Also:
 *	<lwcb_socket>, <lwcb_loop_read>, <lwcb_loop_write>
 */
liblwcb_EXPORT int lwcb_loop_misc(struct lwcb *lwcb);

/*
 * Function: lwcb_want_write
 *
 * Returns true if there is data ready to be written on the socket.
 *
 * Parameters:
 *	lwcb - a valid lwcb instance.
 *
 * See Also:
 *	<lwcb_socket>, <lwcb_loop_read>, <lwcb_loop_write>
 */
liblwcb_EXPORT bool lwcb_want_write(struct lwcb *lwcb);

/*
 * Function: lwcb_tls_set
 *
 * Configure the client for certificate based SSL/TLS support. Must be called
 * before <lwcb_connect>.
 *
 * Cannot be used in conjunction with <lwcb_tls_psk_set>.
 *
 * Define the Certificate Authority certificates to be trusted (ie. the server
 * certificate must be signed with one of these certificates) using cafile.
 *
 * If the server you are connecting to requires clients to provide a
 * certificate, define certfile and keyfile with your client certificate and
 * private key. If your private key is encrypted, provide a password callback
 * function or you will have to enter the password at the command line.
 *
 * Parameters:
 *  lwcb -        a valid lwcb instance.
 *  cafile -      path to a file containing the PEM encoded trusted CA
 *                certificate files. Either cafile or capath must not be NULL.
 *  capath -      path to a directory containing the PEM encoded trusted CA
 *                certificate files. See lwcb.conf for more details on
 *                configuring this directory. Either cafile or capath must not
 *                be NULL.
 *  certfile -    path to a file containing the PEM encoded certificate file
 *                for this client. If NULL, keyfile must also be NULL and no
 *                client certificate will be used.
 *  keyfile -     path to a file containing the PEM encoded private key for
 *                this client. If NULL, certfile must also be NULL and no
 *                client certificate will be used.
 *  pw_callback - if keyfile is encrypted, set pw_callback to allow your client
 *                to pass the correct password for decryption. If set to NULL,
 *                the password must be entered on the command line.
 *                Your callback must write the password into "buf", which is
 *                "size" bytes long. The return value must be the length of the
 *                password. "userdata" will be set to the calling lwcb
 *                instance.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 *
 * See Also:
 *	<lwcb_tls_opts_set>, <lwcb_tls_psk_set>
 */
liblwcb_EXPORT int lwcb_tls_set(struct lwcb *lwcb,
		const char *cafile, const char *capath,
		const char *certfile, const char *keyfile,
		int (*pw_callback)(char *buf, int size, int rwflag, void *userdata));

/*
 * Function: lwcb_tls_opts_set
 *
 * Set advanced SSL/TLS options. Must be called before <lwcb_connect>.
 *
 * Parameters:
 *  lwcb -        a valid lwcb instance.
 *	cert_reqs -   an integer defining the verification requirements the client
 *	              will impose on the server. This can be one of:
 *	              * SSL_VERIFY_NONE (0): the server will not be verified in any way.
 *	              * SSL_VERIFY_PEER (1): the server certificate will be verified
 *	                and the connection aborted if the verification fails.
 *	              The default and recommended value is SSL_VERIFY_PEER.
 *	tls_version - the version of the SSL/TLS protocol to use as a string. If NULL,
 *	              the default value is used. Currently the only available
 *	              version is "tlsv1". 
 *	ciphers -     a string describing the ciphers available for use. See the
 *	              "openssl ciphers" tool for more information. If NULL, the
 *	              default ciphers will be used.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 *
 * See Also:
 *	<lwcb_tls_set>
 */
liblwcb_EXPORT int lwcb_tls_opts_set(struct lwcb *lwcb, int cert_reqs, const char *tls_version, const char *ciphers);

/*
 * Function: lwcb_tls_psk_set
 *
 * Configure the client for pre-shared-key based TLS support. Must be called
 * before <lwcb_connect>.
 *
 * Cannot be used in conjunction with <lwcb_tls_set>.
 *
 * Parameters:
 *  lwcb -     a valid lwcb instance.
 *  psk -      the pre-shared-key in hex format with no leading "0x".
 *  identity - the identity of this client. May be used as the username
 *             depending on the server settings.
 *	ciphers -  a string describing the PSK ciphers available for use. See the
 *	           "openssl ciphers" tool for more information. If NULL, the
 *	           default ciphers will be used.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success.
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 *
 * See Also:
 *	<lwcb_tls_set>
 */
liblwcb_EXPORT int lwcb_tls_psk_set(struct lwcb *lwcb, const char *psk, const char *identity, const char *ciphers);

/* 
 * Function: lwcb_connect_callback_set
 *
 * Set the connect callback. This is called when the broker sends a CONNACK
 * message in response to a connection.
 *
 * Parameters:
 *  lwcb -       a valid lwcb instance.
 *  on_connect - a callback function in the following form:
 *               void callback(struct lwcb *lwcb, void *obj, int rc)
 *
 * Callback Parameters:
 *  lwcb - the lwcb instance making the callback.
 *  obj - the user data provided in <lwcb_new>
 *  rc -  the return code of the connection response, one of:
 *
 * * 0 - success
 * * 1 - connection refused (unacceptable protocol version)
 * * 2 - connection refused (identifier rejected)
 * * 3 - connection refused (broker unavailable)
 * * 4-255 - reserved for future use
 */
liblwcb_EXPORT void lwcb_connect_callback_set(struct lwcb *lwcb, void (*on_connect)(struct lwcb *, void *, int));

/*
 * Function: lwcb_disconnect_callback_set
 *
 * Set the disconnect callback. This is called when the broker has received the
 * DISCONNECT command and has disconnected the client.
 * 
 * Parameters:
 *  lwcb -          a valid lwcb instance.
 *  on_disconnect - a callback function in the following form:
 *                  void callback(struct lwcb *lwcb, void *obj)
 *
 * Callback Parameters:
 *  lwcb - the lwcb instance making the callback.
 *  obj -  the user data provided in <lwcb_new>
 *  rc -   integer value indicating the reason for the disconnect. A value of 0
 *         means the client has called <lwcb_disconnect>. Any other value
 *         indicates that the disconnect is unexpected.
 */
liblwcb_EXPORT void lwcb_disconnect_callback_set(struct lwcb *lwcb, void (*on_disconnect)(struct lwcb *, void *, int));
 
/*
 * Function: lwcb_publish_callback_set
 *
 * Set the publish callback. This is called when a message initiated with
 * <lwcb_publish> has been sent to the broker successfully.
 * 
 * Parameters:
 *  lwcb -       a valid lwcb instance.
 *  on_publish - a callback function in the following form:
 *               void callback(struct lwcb *lwcb, void *obj, int mid)
 *
 * Callback Parameters:
 *  lwcb - the lwcb instance making the callback.
 *  obj -  the user data provided in <lwcb_new>
 *  mid -  the message id of the sent message.
 */
liblwcb_EXPORT void lwcb_publish_callback_set(struct lwcb *lwcb, void (*on_publish)(struct lwcb *, void *, int));

/*
 * Function: lwcb_message_callback_set
 *
 * Set the message callback. This is called when a message is received from the
 * broker.
 * 
 * Parameters:
 *  lwcb -       a valid lwcb instance.
 *  on_message - a callback function in the following form:
 *               void callback(struct lwcb *lwcb, void *obj, const struct lwcb_message *message)
 *
 * Callback Parameters:
 *  lwcb -    the lwcb instance making the callback.
 *  obj -     the user data provided in <lwcb_new>
 *  message - the message data. This variable and associated memory will be
 *            freed by the library after the callback completes. The client
 *            should make copies of any of the data it requires.
 *
 * See Also:
 * 	<lwcb_message_copy>
 */
liblwcb_EXPORT void lwcb_message_callback_set(struct lwcb *lwcb, void (*on_message)(struct lwcb *, void *, const struct lwcb_message *));

/*
 * Function: lwcb_subscribe_callback_set
 *
 * Set the subscribe callback. This is called when the broker responds to a
 * subscription request.
 * 
 * Parameters:
 *  lwcb -         a valid lwcb instance.
 *  on_subscribe - a callback function in the following form:
 *                 void callback(struct lwcb *lwcb, void *obj, int mid, int qos_count, const int *granted_qos)
 *
 * Callback Parameters:
 *  lwcb -        the lwcb instance making the callback.
 *  obj -         the user data provided in <lwcb_new>
 *  mid -         the message id of the subscribe message.
 *  qos_count -   the number of granted subscriptions (size of granted_qos).
 *  granted_qos - an array of integers indicating the granted QoS for each of
 *                the subscriptions.
 */
liblwcb_EXPORT void lwcb_subscribe_callback_set(struct lwcb *lwcb, void (*on_subscribe)(struct lwcb *, void *, int, int, const int *));

/*
 * Function: lwcb_unsubscribe_callback_set
 *
 * Set the unsubscribe callback. This is called when the broker responds to a
 * unsubscription request.
 * 
 * Parameters:
 *  lwcb -           a valid lwcb instance.
 *  on_unsubscribe - a callback function in the following form:
 *                   void callback(struct lwcb *lwcb, void *obj, int mid)
 *
 * Callback Parameters:
 *  lwcb - the lwcb instance making the callback.
 *  obj -  the user data provided in <lwcb_new>
 *  mid -  the message id of the unsubscribe message.
 */
liblwcb_EXPORT void lwcb_unsubscribe_callback_set(struct lwcb *lwcb, void (*on_unsubscribe)(struct lwcb *, void *, int));

/*
 * Function: lwcb_log_callback_set
 *
 * Set the logging callback. This should be used if you want event logging
 * information from the client library.
 *
 *  lwcb -   a valid lwcb instance.
 *  on_log - a callback function in the following form:
 *           void callback(struct lwcb *lwcb, void *obj, int level, const char *str)
 *
 * Callback Parameters:
 *  lwcb -  the lwcb instance making the callback.
 *  obj -   the user data provided in <lwcb_new>
 *  level - the log message level from the values:
 *	        LWCB_LOG_INFO
 *	        LWCB_LOG_NOTICE
 *	        LWCB_LOG_WARNING
 *	        LWCB_LOG_ERR
 *	        LWCB_LOG_DEBUG
 *	str -   the message string.
 */
liblwcb_EXPORT void lwcb_log_callback_set(struct lwcb *lwcb, void (*on_log)(struct lwcb *, void *, int, const char *));

/*
 * Function: lwcb_message_retry_set
 *
 * Set the number of seconds to wait before retrying messages. This applies to
 * publish messages with QoS>0. May be called at any time.
 * 
 * Parameters:
 *  lwcb -          a valid lwcb instance.
 *  message_retry - the number of seconds to wait for a response before
 *                  retrying. Defaults to 20.
 */
liblwcb_EXPORT void lwcb_message_retry_set(struct lwcb *lwcb, unsigned int message_retry);

/*
 * Function: lwcb_user_data_set
 *
 * When <lwcb_new> is called, the pointer given as the "obj" parameter
 * will be passed to the callbacks as user data. The <lwcb_user_data_set>
 * function allows this obj parameter to be updated at any time. This function
 * will not modify the memory pointed to by the current user data pointer. If
 * it is dynamically allocated memory you must free it yourself.
 *
 * Parameters:
 *  lwcb - a valid lwcb instance.
 * 	obj -  A user pointer that will be passed as an argument to any callbacks
 * 	       that are specified.
 */
liblwcb_EXPORT void lwcb_user_data_set(struct lwcb *lwcb, void *obj);


/* =============================================================================
 *
 * Utility functions
 *
 * =============================================================================
 */

/*
 * Function lwcb_strerror
 *
 * Call to obtain a const string description of a lwcb error number.
 *
 * Parameters:
 *	lwcb_errno - a lwcb error number.
 *
 * Returns:
 *	A constant string describing the error.
 */
liblwcb_EXPORT const char *lwcb_strerror(int lwcb_errno);

/*
 * Function lwcb_connack_string
 *
 * Call to obtain a const string description of an MQTT connection result.
 *
 * Parameters:
 *	connack_code - an MQTT connection result.
 *
 * Returns:
 *	A constant string describing the result.
 */
liblwcb_EXPORT const char *lwcb_connack_string(int connack_code);

/*
 * Function lwcb_sock_localaddress
 *
 * Call to obtain a const string description a lwcb socket's local address
 *
 * Returns:
 *	A constant string describing the socket's local address.
 */
liblwcb_EXPORT const char *lwcb_sock_localaddress(struct lwcb *lwcb);

/*
 * Function lwcb_sub_topic_tokenise
 *
 * Tokenise a topic or subscription string into an array of strings
 * representing the topic hierarchy.
 *
 * For example:
 *
 * subtopic: "a/deep/topic/hierarchy"
 *
 * Would result in:
 *
 * topics[0] = "a"
 * topics[1] = "deep"
 * topics[2] = "topic"
 * topics[3] = "hierarchy"
 *
 * and:
 *
 * subtopic: "/a/deep/topic/hierarchy/"
 *
 * Would result in:
 *
 * topics[0] = NULL
 * topics[1] = "a"
 * topics[2] = "deep"
 * topics[3] = "topic"
 * topics[4] = "hierarchy"
 *
 * Parameters:
 *	subtopic - the subscription/topic to tokenise
 *	topics -   a pointer to store the array of strings
 *	count -    an int pointer to store the number of items in the topics array.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 *
 * Example:
 *
 * > char **topics;
 * > int topic_count;
 * > int i;
 * > 
 * > lwcb_sub_topic_tokenise("$SYS/broker/uptime", &topics, &topic_count);
 * >
 * > for(i=0; i<token_count; i++){
 * >     printf("%d: %s\n", i, topics[i]);
 * > }
 *
 * See Also:
 *	<lwcb_sub_topic_tokens_free>
 */
liblwcb_EXPORT int lwcb_sub_topic_tokenise(const char *subtopic, char ***topics, int *count);

/*
 * Function lwcb_sub_topic_tokens_free
 *
 * Free memory that was allocated in <lwcb_sub_topic_tokenise>.
 *
 * Parameters:
 *	topics - pointer to string array.
 *	count - count of items in string array.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 *
 * See Also:
 *	<lwcb_sub_topic_tokenise>
 */
liblwcb_EXPORT int lwcb_sub_topic_tokens_free(char ***topics, int count);

/*
 * Function lwcb_topic_matches_sub
 *
 * Check whether a topic matches a subscription.
 *
 * For example:
 *
 * foo/bar would match the subscription foo/# or +/bar
 * non/matching would not match the subscription non/+/+
 *
 * Parameters:
 *	sub - subscription string to check topic against.
 *	topic - topic to check.
 *	result - bool pointer to hold result. Will be set to true if the topic
 *	         matches the subscription.
 *
 * Returns:
 *	LWCB_ERR_SUCCESS - on success
 * 	LWCB_ERR_INVAL -   if the input parameters were invalid.
 * 	LWCB_ERR_NOMEM -   if an out of memory condition occurred.
 */
liblwcb_EXPORT int lwcb_topic_matches_sub(const char *sub, const char *topic, bool *result);

#ifdef __cplusplus
}
#endif

#endif

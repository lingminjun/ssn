//
//  inet.h
//  ssn
//
//  Created by lingminjun on 14-8-20.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__inet__
#define __ssn__inet__

#include <string.h>
#include <pthread.h>
#include <netinet/in.h>
#include <poll.h>
#include <vector>

#include "lock.h"
#include "buffer.h"

#if DEBUG
#ifdef ANDROID_OS_DEBUG
#define inet_log(s, ...) __android_log_print(ANDROID_LOG_INFO, "printf", s)
#else
#define inet_log(s, ...) printf(s, ##__VA_ARGS__)
#endif
#else
#define inet_log(s, ...) ((void)0)
#endif

#define SSN_INET_OK 0
#define SSN_INET_ERROR -1

namespace ssn
{

typedef enum
{
    inet_noconnect,  // no connect
    inet_connecting, // connecting
    inet_connected,  // connected
} inet_connect_state;

class inet;

typedef void (*connect_callback_function)(inet &inet, const inet_connect_state state, void *context);
typedef void (*read_callback_function)(inet &inet, const unsigned char *bytes, const unsigned long &size,
                                       const unsigned int &tag, void *context);
typedef void (*write_callback_function)(inet &inet, const unsigned char *bytes, const unsigned long &size,
                                        const unsigned int &tag, void *context);
typedef void (*read_timeout_function)(inet &inet, const unsigned char *bytes, const unsigned long &size,
                                      const unsigned int &tag, void *context);

/**
 asyn socket implementation.
 inet don't support copy.
 */
extern void *inet_thread_main(void *arg);
class inet
{
  public:
    /**
     construction
     the host may be a domain name (e.g. "soulshan.com") or an IP address string (e.g. "192.168.0.2").
     */
    inet();
    inet(const std::string &host, const unsigned short port = 443);

    /**
     set the host and port,not change connecting state,Until finally the connect access to take effect.
     the host may be a domain name (e.g. "soulshan.com") or an IP address string (e.g. "192.168.0.2").
     */
    void set_server_address(const std::string &host, const unsigned short port = 443)
    {
        scopedlock<recursivelock> tmplock(_lock);
        _host = host;
        _port = port;

        // need reset addre_in
        _reset_addr = true;
    }

    /**
     begin connect to server,if host is empty will return SSN_INET_ERROR. return SSN_INET_OK is success.
     try to connect the address of server until the timeout.
     */
    int start_connect(const long interval_sec = 5, const long timeout_sec = 0);

    /**
     disconnect,if connect state is inet_connecting, will stop connect loop.
     */
    int stop_connect();

    /**
     destory
     */
    ~inet();

    /**
     sync write data to socket.
     */
    int async_write(const unsigned char *bytes, const unsigned long &size, const unsigned int &tag);

    /**
     async read data. If size is 0, as long as there is data on the socket will trigger read_callback callback;
     otherwise, only when the socket is read to the specified size length data will trigger read_callback after callback.
     time out will diconnect.
     */
    int async_read(const unsigned long &size, const unsigned int &tag, const long long &timeout_sec);

    /**
     inet connect state
     */
    inet_connect_state connect_state(void)
    {
        return _state;
    }

    /**
     inet port
     */
    unsigned short port()
    {
        scopedlock<recursivelock> tmplock(_lock);
        return _port;
    }

    /**
     inet host
     */
    std::string host()
    {
        scopedlock<recursivelock> tmplock(_lock);
        return _host;
    }

    /**
     using call back context
     */
    void set_callback_context(void *context)
    {
        scopedlock<recursivelock> tmplock(_lock);
        _context = context;
    }

  public:
    void set_connect_callback(connect_callback_function connect_callback)
    {
        scopedlock<recursivelock> tmplock(_lock);
        _connect_callback = connect_callback;
    }
    void set_read_callback(read_callback_function read_callback)
    {
        scopedlock<recursivelock> tmplock(_lock);
        _read_callback = read_callback;
    }
    void set_write_callback(write_callback_function write_callback)
    {
        scopedlock<recursivelock> tmplock(_lock);
        _write_callback = write_callback;
    }

    void set_read_timeout(read_timeout_function read_timeout)
    {
        scopedlock<recursivelock> tmplock(_lock);
        _read_timeout = read_timeout;
    }

  private:
    friend void *inet_thread_main(void *arg);

  private:
    // connect state call back. the net changed will call back
    connect_callback_function _connect_callback;

    // read and write call back
    read_callback_function _read_callback;
    write_callback_function _write_callback;

    // read time out
    read_timeout_function _read_timeout;

  private:
    bool _isIPv6; // isIPv6 == true AF_INET6
    int _socket;
    struct pollfd _pollfd[1];
    long _connect_timeout;
    long _connect_interval;
    inet_connect_state _state;
    bool _reset_addr;
    unsigned short _port;
    pthread_t _thread;
    recursivelock _lock;
    std::string _host; // The host may be a domain name (e.g. "soulshan.com") or an IP address string (e.g.
                       // "192.168.0.2").

    void *_context;

    // does not support deep copy,please use the pointer
    typedef struct
    {
        long long timeout;
        unsigned int tag;
        unsigned long size;
        buffer buffer;
    } event;

    std::vector<event *> _write_events;
    std::vector<event *> _read_events;
};
}

#endif /* defined(__ssn__inet__) */

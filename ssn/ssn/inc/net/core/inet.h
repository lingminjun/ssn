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

typedef void (*connect_callback_function)(inet &inet, const inet_connect_state state);
typedef void (*read_callback_function)(inet &inet, const unsigned char *bytes, const unsigned long &size,
                                       const unsigned int &tag);
typedef void (*write_callback_function)(inet &inet, const unsigned char *bytes, const unsigned long &size,
                                        const unsigned int &tag);
typedef void (*read_timeout_function)(inet &inet, const unsigned char *bytes, const unsigned long &size,
                                      const unsigned int &tag);

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
     the host may be a domain name (e.g. "deusty.com") or an IP address string (e.g. "192.168.0.2").
     */
    inet() : _lock()
    {
        _isIPv6 = false; // isIPv6 == true AF_INET6
        _socket = -1;
        _connect_timeout = 0;
        _connect_interval = 5;
        _state = inet_noconnect;
        _thread = NULL;
        _reset_addr = true;

        _connect_callback = NULL;
        _read_callback = NULL;
        _write_callback = NULL;
        _read_timeout = NULL;

        pthread_create(&_thread, NULL, &inet_thread_main, this);
    }
    inet(const std::string &host, const unsigned short port = 443) : _lock(), _host(host), _port(port)
    {
        _isIPv6 = false; // isIPv6 == true AF_INET6
        _socket = -1;
        _connect_timeout = 0;
        _connect_interval = 5;
        _state = inet_noconnect;
        _thread = NULL;
        _reset_addr = true;

        _connect_callback = NULL;
        _read_callback = NULL;
        _write_callback = NULL;
        _read_timeout = NULL;

        pthread_create(&_thread, NULL, &inet_thread_main, this);
    }

    /**
     set the host and port,not change connecting state,Until finally the connect access to take effect.
     the host may be a domain name (e.g. "deusty.com") or an IP address string (e.g. "192.168.0.2").
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
    ~inet()
    {
        // stop connect
        stop_connect();

        void *retval = NULL;
        if (_thread != NULL && pthread_kill(_thread, 0) == 0)
        {
#ifdef ANDROID_OS_DEBUG
            pthread_kill(_thread, SIGALRM);
#else
            pthread_cancel(_thread);
#endif
            pthread_join(_thread, &retval);
            inet_log("exit inet thread code:%d\n", retval);
        }
    }

    /**
     sync write data to socket.
     */
    int async_write(const unsigned char *bytes, const unsigned long &size, const unsigned int &tag);

    /**
     async read data. if the socket has data to read will call back read_callback.
     time out will diconnect.
     */
    int async_read(const unsigned long &size, const unsigned int &tag, const long long &timeout_sec);

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
    std::string _host; // The host may be a domain name (e.g. "deusty.com") or an IP address string (e.g.
                       // "192.168.0.2").
    buffer _write_buffer;
    std::vector<unsigned int> _write_tags;
    std::vector<unsigned int> _read_tags;
};
}

#endif /* defined(__ssn__inet__) */

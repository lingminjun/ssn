//
//  inet.h
//  ssn
//
//  Created by lingminjun on 14-8-20.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__inet__
#define __ssn__inet__

#include <string>
#include <pthread.h>

#include "lock.h"

#if DEBUG
#ifdef ANDROID_OS_DEBUG
#define inet_log(s, ...) __android_log_print(ANDROID_LOG_INFO, "printf", s)
#else
#define inet_log(s, ...) printf(s, ##__VA_ARGS__)
#endif
#else
#define inet_log(s, ...) ((void)0)
#endif

namespace ssn
{

typedef enum
{
    inet_noconnect,  // no connect
    inet_connecting, // connecting
    inet_connected,  // connected
} inet_connect_state;

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
     */
    inet() : _lock()
    {
        pthread_create(&_thread, NULL, &inet_thread_main, this);
    }
    inet(const std::string &host, const unsigned short port = 443) : _lock(), _host(host), _port(port)
    {
        pthread_create(&_thread, NULL, &inet_thread_main, this);
    }
    ~inet()
    {
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
     set host and port
     */
    void set_server_address(const std::string &host, const unsigned short port = 443)
    {
    }

    /**
     begin connect to server,if host is empty will return -1. return 0 is success.
     try to connect the address of server until the timeout.
     */
    int start_connect(const long interval_sec = 5, const long timeout_sec = 0);

  private:
    int _socket4fd;
    int _socket6fd;
    unsigned short _port;
    pthread_t _thread;
    recursivelock _lock;
    std::string _host;
};
}

#endif /* defined(__ssn__inet__) */

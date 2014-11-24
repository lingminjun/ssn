//
//  inet.cpp
//  ssn
//
//  Created by lingminjun on 14-8-20.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "inet.h"

#include <fcntl.h>
#include <sys/socket.h>

#include <netdb.h>

#include <stdio.h>
#include <stdlib.h>

#include <arpa/inet.h>

#include <map>

#include <unistd.h>

#include <sys/errno.h>

//#include <netinet/in.h>
//#import <arpa/inet.h>
//#import <fcntl.h>
//#import <ifaddrs.h>
//#import <netdb.h>
//#import <netinet/in.h>
//#import <net/if.h>
//#import <sys/socket.h>
//#import <sys/types.h>
//#import <sys/ioctl.h>
//#import <sys/poll.h>
//#import <sys/uio.h>
//#import <unistd.h>

namespace ssn
{

void inet_sleep(const unsigned int &sec, const unsigned int &ms)
{
    usleep(sec * 1000000 + ms * 1000);
}

void inet_a_nap()
{
    struct timeval tvs;
    tvs.tv_sec = 0;
    tvs.tv_usec = 1000 * 100;
    select(0, NULL, NULL, NULL, &tvs);
    inet_log("inet_a_nap\n");
}

long long inet_now_usec(const long long &timeval_usec)
{
    struct timeval tem_timeval;
    gettimeofday(&tem_timeval, NULL);
    long long tem_usec = tem_timeval.tv_sec * 1000000 + tem_timeval.tv_usec + timeval_usec;
    return tem_usec;
}

bool inet_connect(int &sockfd, struct sockaddr *address, socklen_t address_len, int timeout)
{
    int ret = 0;
    struct timeval tv;
    fd_set mask;

    // 非阻塞connect
    int flags = fcntl(sockfd, F_GETFL, 0);
    fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

    ret = connect(sockfd, address, address_len);
    if (-1 == ret)
    {
        if (errno != EINPROGRESS)
        {
            inet_log("connect error\n");
            return false;
        }

        // the socket is EPIPE connect
        if (timeout > 0)
        {
            inet_log("connecting ...\n");

            FD_ZERO(&mask);
            FD_SET(sockfd, &mask);
            tv.tv_sec = timeout;
            tv.tv_usec = 0;

            if (select(sockfd + 1, NULL, &mask, NULL, &tv) > 0)
            {
                int error = 0;
                socklen_t tmpLen = sizeof(int);
                int retopt = getsockopt(sockfd, SOL_SOCKET, SO_ERROR, &error, &tmpLen);
                if (retopt != -1)
                {
                    if (0 == error)
                    {
                        inet_log("hard connected \n");
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    inet_log("socket connect error：%d\n", error);
                    return false;
                }
            }
            else
            {
                return false;
            }
        }
    }
    inet_log("has connected\n");
    return true;
}

bool inet_set_address(const char *hname, const char *sname, struct sockaddr_in *sap, const char *protocol)
{
    struct servent *sp = NULL;
    struct hostent *hp = NULL;
    short port = 0;

    memset(sap, 0, sizeof(*sap));
    sap->sin_family = AF_INET;
    if (hname != NULL && strlen(hname) > 0)
    {
        if (!inet_aton(hname, &sap->sin_addr))
        {
            hp = gethostbyname(hname);
            if (hp == NULL)
            {
                inet_log("gethostbyname hname %s failed.\n", hname);
                return false;
            }
            else
            {
                char *ipstr = (char *)inet_ntoa(*(struct in_addr *)(hp->h_addr));
                inet_log("gethostbyname hname %s ==> ip %s\n", hname, ipstr);
                sap->sin_addr = *(struct in_addr *)hp->h_addr;
            }
        }
    }
    else
    {
        sap->sin_addr.s_addr = htonl(INADDR_ANY);
    }

    port = atoi(sname);

    if (port > 0)
        sap->sin_port = htons(port);
    else
    {
        sp = getservbyname(sname, protocol);
        if (sp == NULL)
        {
            return false;
        }
        sap->sin_port = sp->s_port;
    }

    return true;
}

void inet_close_socket(int &socket, struct pollfd *pollfd)
{
    close(socket);
    socket = -1;

    if (pollfd)
    {
        pollfd->events = 0;
        pollfd->revents = 0;
        pollfd->fd = -1;
    }
    inet_log("close socket!\n");
}

#define inet_call_connect_callback(t, s, c)                                                                            \
    if (t->_connect_callback)                                                                                          \
    {                                                                                                                  \
        t->_connect_callback(*(t), s, c);                                                                              \
    }

#define inet_call_write_callback(t, b, s, g, c)                                                                        \
    if (t->_write_callback)                                                                                            \
    {                                                                                                                  \
        t->_write_callback(*(t), b, s, g, c);                                                                          \
    }

#define inet_call_read_callback(t, b, s, g, c)                                                                         \
    if (t->_read_callback)                                                                                             \
    {                                                                                                                  \
        t->_read_callback(*(t), b, s, g, c);                                                                           \
    }

#define inet_call_read_timeout(t, b, s, g, c)                                                                          \
    if (t->_read_timeout)                                                                                              \
    {                                                                                                                  \
        t->_read_callback(*(t), b, s, g, c);                                                                           \
    }

void inet_set_socket_nonblocking(int &socket)
{
    int opts = -1;
    while (true)
    {
        opts = fcntl(socket, F_GETFL);
        if (-1 == opts && errno == EINTR)
            continue;
        break;
    }
    if (opts < 0)
    {
        int err = errno;
        (void)err;
        return;
        // assert(0);
    }
    opts = opts | O_NONBLOCK;
    // if(fcntl(sock,F_SETFL,opts)<0)
    while (true)
    {
        opts = fcntl(socket, F_SETFL, opts);
        if (-1 == opts && errno == EINTR)
            continue;
        break;
    }
    if (opts < 0)
    {
        int err = errno;
        (void)err;
        // assert(0);
    }
}

void inet_set_socket_blocking(int &socket)
{
    int opts = -1;
    while (true)
    {
        opts = fcntl(socket, F_GETFL);
        if (-1 == opts && errno == EINTR)
            continue;
        break;
    }
    if (opts < 0)
    {
        int err = errno;
        (void)err;
        return;
        // assert(0);
    }
    opts = opts & (~O_NONBLOCK);
    while (true)
    {
        opts = fcntl(socket, F_SETFL, opts);
        if (-1 == opts && errno == EINTR)
            continue;
        break;
    }
    if (opts < 0)
    {
        int err = errno;
        (void)err;
        // assert(0);
    }
}

long inet_tcp_recv(int &fd, unsigned char *msg, const unsigned long &msglen)
{
    long ret = -1;
    do
    {
        // ret = recv(fd,msg,msglen,MSG_NOSIGNAL);
        ret = read(fd, msg, msglen);
    } while (ret == -1 && (errno == EINTR));
    return ret;
}

long inet_tcp_send(int &fd, const unsigned char *msg, const unsigned long &datalen)
{
    long ret = -1;
    do
    {
        // ret=send(fd,msg,datalen,MSG_NOSIGNAL);
        ret = write(fd, msg, datalen);
    } while (-1 == ret && EINTR == errno);
    return ret;
}

bool inet_set_pollfd_event(struct pollfd &pfd, const bool &read_event, const bool &write_event)
{
    pfd.events = POLLERR | POLLHUP;
    if (write_event)
    {
        pfd.events |= POLLOUT;
    }
    if (read_event)
    {
        pfd.events |= POLLIN | POLLPRI;
    }
    return true;
}

int inet_create_socket(const std::string &host, const unsigned short &port, struct sockaddr_in *addr_in)
{
    char strport[64];
    sprintf(strport, "%d", port);
    if (!inet_set_address(host.c_str(), strport, addr_in, "tcp"))
    {
        inet_log("You must set up the host address or domain name\n");
        return -1;
    }

    //最好是pin下ip
    //    char *ipstr = (char *)inet_ntoa(*(struct in_addr *)(host->h_addr));
    //
    //    if (inet_pton(AF_INET, ipstr, &servaddr.sin_addr) <= 0)
    //    {
    //        printf("创建网络连接失败,本线程即将终止--inet_pton error!\n");
    //        return false;
    //    };

    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd == -1)
    {
        inet_log("You must set up the host address or domain name\n");
        return fd;
    }

    const int rcvBuffSize = 128 * 1024;
    if (setsockopt(fd, SOL_SOCKET, SO_RCVBUF, &rcvBuffSize, sizeof(rcvBuffSize)))
    {
        inet_log("set receive buff size error!\n");
        inet_close_socket(fd, NULL);
        return fd;
    }

    const int sendBuffSize = 128 * 1024;
    if (setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &sendBuffSize, sizeof(sendBuffSize)))
    {
        inet_log("set send buff size error!\n");
        inet_close_socket(fd, NULL);
        return fd;
    }

    // Since we're going to be binding to a specific port,
    // we should turn on reuseaddr to allow us to override sockets in time_wait.

    int reuseOn = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuseOn, sizeof(reuseOn)))
    {
        inet_log("set SO_REUSEADDR error!\n");
        inet_close_socket(fd, NULL);
        return fd;
    }

    // bind local ip
    //    int result = bind(fd, interfaceAddr, (socklen_t)[connectInterface length]);
    //    if (result != 0)
    //    {
    //        inet_log("set bind address error!\n");
    //        inet_close_socket(fd,NULL);
    //        return fd;
    //    }

    int nosigpipe = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe)))
    {
        inet_log("set SO_NOSIGPIPE error!\n");
        inet_close_socket(fd, NULL);
        return fd;
    }

    return fd;
}

bool inet_check_time(const long long &t1, const long long &t2, const long &drift)
{
    if (t1 >= t2)
    {
        if (t1 - t2 < drift)
        {
            return true;
        }
    }
    else
    {
        if (t2 - t1 < drift)
        {
            return true;
        }
    }
    return false;
}

void *inet_thread_main(void *arg)
{
    ssn::inet *inet = (ssn::inet *)arg;
    inet_log("enter inet thread!\n");
    char thread_name[30] = {'\0'};
    sprintf(thread_name, "inet_%p_thread_main", arg);
    pthread_setname_np(thread_name);

    while (true)
    {
        // loop
        inet_log("inet loop ...\n");

        // switch state
        inet_connect_state state;
        {
            scopedlock<recursivelock> tmplock(inet->_lock);
            state = inet->_state;
        }

        struct sockaddr_in peer;

        switch (state)
        {
        case inet_connecting:
        {
            // socket init
            {
                scopedlock<recursivelock> tmplock(inet->_lock);
                inet_call_connect_callback(inet, state, inet->_context);

                // host to addr ip
                if (inet->_reset_addr)
                {
                    // close pre socket
                    inet->_reset_addr = false;
                    if (inet->_socket != -1)
                    {
                        inet_close_socket(inet->_socket, &(inet->_pollfd[0]));
                    }

                    inet->_socket = inet_create_socket(inet->_host, inet->_port, &peer);

                    // create socket err!
                    if (inet->_socket == -1)
                    {
                        inet->_state = inet_noconnect;
                        inet->_reset_addr = true;
                        inet_call_connect_callback(inet, inet_noconnect, inet->_context);
                        break;
                    }
                }
            }

            // get time out
            long connect_timeout = 0;
            long connect_interval = 5;
            {
                scopedlock<recursivelock> tmplock(inet->_lock);
                connect_timeout = inet->_connect_timeout;
                connect_interval = inet->_connect_interval;
            }

            // connecting
            long long now_usec = inet_now_usec(0);
            long long interval_usec = now_usec + connect_interval * 1000000;
            long long timeout_usec = now_usec + connect_timeout * 1000000;

            bool is_connencted = false;
            bool try_connect = true;
            do
            {

                if (try_connect)
                {
                    scopedlock<recursivelock> tmplock(inet->_lock);
                    if (inet->_state == inet_noconnect)
                    { // state has changed
                        inet_call_connect_callback(inet, inet->_state, inet->_context);
                        inet_close_socket(inet->_socket, &(inet->_pollfd[0]));
                        break;
                    }

                    if (inet_connect(inet->_socket, (struct sockaddr *)&peer, sizeof(peer), 0))
                    {
                        is_connencted = true;

                        inet_log("inet connected!\n");
                        inet->_state = inet_connected;

                        inet->_pollfd[0].events = 0;
                        inet->_pollfd[0].revents = 0;
                        inet->_pollfd[0].fd = inet->_socket;
                        inet_set_pollfd_event(inet->_pollfd[0], true, true);

                        inet_call_connect_callback(inet, inet->_state, inet->_context);

                        break;
                    }
                    else
                    {
                        inet_log("ient connecting ...\n");
                        inet_call_connect_callback(inet, inet->_state, inet->_context);
                    }
                }

                inet_a_nap();
                now_usec = inet_now_usec(0);
                if (try_connect)
                {
                    interval_usec = now_usec + connect_interval * 1000000;
                }
                try_connect = inet_check_time(now_usec, interval_usec, 10);
            } while (now_usec < timeout_usec);

            // stop connecting !
            if (!is_connencted)
            {
                scopedlock<recursivelock> tmplock(inet->_lock);
                inet->_state = inet_noconnect;
                inet_call_connect_callback(inet, inet->_state, inet->_context);
                inet_close_socket(inet->_socket, &(inet->_pollfd[0]));
                inet_log("stop connecting !\n");
            }
        }
        break;
        case inet_connected:
        {
            bool run_flag = true;
            do
            {
                // checkout timeout event
                {
                    scopedlock<recursivelock> tmplock(inet->_lock);
                    long long now_usec = inet_now_usec(0);
                    std::vector<inet::event *>::iterator iter = inet->_read_events.begin();
                    while (iter != inet->_read_events.end())
                    {
                        inet::event *pevt = (*iter);
                        long long timeout = pevt->timeout;
                        if (timeout > 0 && timeout <= now_usec)
                        { // time out
                            iter = inet->_read_events.erase(iter);
                            inet_log("inet tag = %d read event time out !\n", pevt->tag);
                            inet_call_read_timeout(inet, NULL, pevt->size, pevt->tag, inet->_context);
                            delete pevt;
                        }
                        else
                        {
                            iter++;
                        }
                    }
                }

                int retevts = -1;
                int timeout_msec = 100; // 100ms

                do
                {
                    {
                        scopedlock<recursivelock> tmplock(inet->_lock);
                        if (inet->_state == inet_noconnect)
                        { // state has changed
                            inet_call_connect_callback(inet, inet->_state, inet->_context);
                            inet_close_socket(inet->_socket, &(inet->_pollfd[0]));
                            run_flag = false;
                            break;
                        }

                        retevts = poll(inet->_pollfd, 1, timeout_msec);
                        inet_log("%lld poll fd result = %d\n", inet_now_usec(0), retevts);
                    }
                } while (-1 == retevts && EINTR == errno);

                if (retevts < 0)
                {
                    inet_a_nap();
                    continue;
                }

                // read and write
                int what = inet->_pollfd[0].revents;
                if ((what & (POLLHUP | POLLERR)) && (what & (POLLIN | POLLOUT)) == 0)
                {
                    what |= POLLIN | POLLOUT;
                }

                if (what & POLLOUT)
                {
                    inet_log("the socket will write data\n");

                    {
                        scopedlock<recursivelock> tmplock(inet->_lock);
                        if (inet->_state == inet_noconnect)
                        { // state has changed
                            inet_call_connect_callback(inet, inet->_state, inet->_context);
                            inet_close_socket(inet->_socket, &(inet->_pollfd[0]));
                            run_flag = false;
                            break;
                        }

                        if (!inet->_write_events.empty())
                        {
                            unsigned int tag = 0;

                            inet::event *pevt = inet->_write_events.back();
                            inet->_write_events.pop_back();
                            tag = pevt->tag;

                            unsigned long buffsize = 0;
                            const unsigned char *outbuffer = pevt->buffer.read_data(buffsize);

                            long wlen = inet_tcp_send(inet->_socket, outbuffer, buffsize);
                            inet_log("inet_tcp_send %ld,data, fd=%d , error=%d\n", wlen, inet->_socket, errno);

                            if (wlen > 0)
                            {
                                inet_call_write_callback(inet, outbuffer, wlen, tag, inet->_context);
                            }
                            else if (wlen == 0)
                            {
                                inet_log("set the socket no writed data\n");
                                inet_set_pollfd_event(inet->_pollfd[0], true, false);
                            }
                            else
                            {
                                inet_log("inet send data error, close the socket = %d\n", inet->_socket);
                                inet_close_socket(inet->_socket, &(inet->_pollfd[0]));
                                run_flag = false;
                                // break;
                            }

                            delete pevt;
                        }
                        else
                        {
                            inet_log("set the socket no writed data.\n");
                            inet_set_pollfd_event(inet->_pollfd[0], true, false);
                        }
                    }
                }

                if (what & POLLIN)
                {
                    inet_log("the socket will read data\n");
                    {
                        scopedlock<recursivelock> tmplock(inet->_lock);
                        if (inet->_state == inet_noconnect)
                        { // state has changed
                            inet_call_connect_callback(inet, inet->_state, inet->_context);
                            inet_close_socket(inet->_socket, &(inet->_pollfd[0]));
                            run_flag = false;
                            break;
                        }

                        inet::event *pevt = NULL;
                        if (!inet->_read_events.empty())
                        {
                            pevt = inet->_read_events.back();
                            inet->_read_events.pop_back();
                        }
                        else
                        { // If there is no read event, will always stay reading matters
                            pevt = new inet::event;
                            pevt->tag = 0;
                            pevt->timeout = 0;
                            pevt->size = 0;
                        }

                        unsigned long buffsize = 128 * 1024; // default read buffer
                        if (pevt->size > 0)
                        {
                            buffsize = pevt->size;
                        }
                        unsigned char *tmpreadbuff = new unsigned char[buffsize];

                        long rlen = 0;
                        unsigned long target_read_length = buffsize;
                        do
                        {
                            memset(tmpreadbuff, 0, buffsize);

                            rlen = inet_tcp_recv(inet->_socket, tmpreadbuff, target_read_length);
                            inet_log("inet_tcp_recv %ld, fd=%d, error=%d\n", rlen, inet->_socket, errno);

                            if (rlen > 0)
                            {

                                pevt->buffer.append(tmpreadbuff, rlen);

                                if (pevt->size > 0)
                                {
                                    target_read_length -= rlen;
                                }
                                else
                                { // There are no limit to read about the length of the
                                    target_read_length = 0;
                                }
                            }
                            else if (rlen == 0)
                            {
                                if (pevt->size > 0)
                                {
                                    inet_log("continue try read data, socket = %d\n", inet->_socket);
                                }
                                else
                                {
                                    target_read_length = 0;
                                }
                            }
                            else
                            {
                                target_read_length = 0; // break to loop
                                inet_log("inet read data error, set the socket = %d no read\n", inet->_socket);
                                inet_set_pollfd_event(inet->_pollfd[0], false, true);
                            }
                        } while (target_read_length > 0);//continue waiting read target_read_length

                        delete tmpreadbuff;

                        if (pevt->buffer.size() > 0)
                        {
                            unsigned long tsize = 0;
                            const unsigned char *read_buff = pevt->buffer.read_data(tsize);
                            inet_call_read_callback(inet, read_buff, tsize, pevt->tag, inet->_context);
                        }

                        delete pevt;
                    }
                }

            } while (run_flag);
        }
        break;
        default:
        {
            inet_a_nap();
        }
        break;
        }
    }
    return NULL;
}

inet::inet() : _lock()
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

    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    pthread_create(&_thread, &attr, &inet_thread_main, this);
    pthread_attr_destroy(&attr);
}

inet::inet(const std::string &host, const unsigned short port) : _lock(), _host(host), _port(port)
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

    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    pthread_create(&_thread, &attr, &inet_thread_main, this);
    pthread_attr_destroy(&attr);
}

inet::~inet()
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
        inet_log("exit inet thread code:%d\n", *((int *)retval));
    }
}

int inet::start_connect(const long interval_sec, const long timeout_sec)
{
    {
        scopedlock<recursivelock> tmplock(_lock);
        if (_host.empty())
        {
            inet_log("You must set up the host address or domain name\n");
            return SSN_INET_ERROR;
        }

        if (_state != inet_noconnect)
        {
            inet_log("Have entered the connect state!\n");
            _connect_interval = interval_sec;
            _connect_timeout = timeout_sec;
            return SSN_INET_OK;
        }

        inet_log("Changed the connect state to connecting !\n");
        _state = inet_connecting;
    }

    return SSN_INET_OK;
}

int inet::stop_connect()
{
    {
        scopedlock<recursivelock> tmplock(_lock);
        if (_state == inet_noconnect)
        {
            inet_log("Current state is inet_noconnect!\n");
            return SSN_INET_OK;
        }

        inet_log("Changed the connect state to inet_noconnect !\n");
        _state = inet_noconnect;
    }
    return SSN_INET_OK;
}

int inet::async_write(const unsigned char *bytes, const unsigned long &size, const unsigned int &tag)
{
    if (size <= 0)
    {
        return SSN_INET_ERROR;
    }

    {
        scopedlock<recursivelock> tmplock(_lock);
        if (_state != inet_connected)
        {
            inet_log("Current state is not inet_connected! write data will ignore\n");
            return SSN_INET_ERROR;
        }

        event *pevt = new event; //
        pevt->buffer.append(bytes, size);
        pevt->size = size;
        pevt->timeout = 0; // the write operation don't need a timeout
        pevt->tag = tag;
        _write_events.insert(_write_events.begin(), pevt);

        // change zhe socket
        inet_set_pollfd_event(_pollfd[0], true, true);
    }

    return SSN_INET_OK;
}

int inet::async_read(const unsigned long &size, const unsigned int &tag, const long long &timeout_sec)
{
    {
        scopedlock<recursivelock> tmplock(_lock);
        if (_state == inet_noconnect)
        {
            inet_log("Current state is inet_noconnect! read data will ignore\n");
            return SSN_INET_ERROR;
        }

        event *pevt = new event; //
        if (timeout_sec > 0)
        {
            pevt->timeout = inet_now_usec(timeout_sec * 1000000);
        }
        else
        {
            pevt->timeout = 0;
        }
        pevt->tag = tag;
        pevt->size = size;
        _read_events.insert(_read_events.begin(), pevt);
    }

    return SSN_INET_OK;
}
}

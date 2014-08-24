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

void inet_sleep(unsigned int sec, unsigned int ms)
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

void inet_close_socket(int &socket)
{
    close(socket);
    socket = -1;
    inet_log("close socket!\n");
}

#define inet_call_connect_callback(t, s)                                                                               \
    if (t->_connect_callback)                                                                                          \
    {                                                                                                                  \
        t->_connect_callback(*(t), s);                                                                                 \
    }

#define inet_call_write_callback(t, b, s, g)                                                                           \
    if (t->_write_callback)                                                                                            \
    {                                                                                                                  \
        t->_write_callback(*(t), b, s, g);                                                                             \
    }

#define inet_call_read_callback(t, b, s, g)                                                                            \
    if (t->_read_callback)                                                                                             \
    {                                                                                                                  \
        t->_read_callback(*(t), b, s, g);                                                                              \
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
        inet_close_socket(fd);
        return fd;
    }

    const int sendBuffSize = 128 * 1024;
    if (setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &sendBuffSize, sizeof(sendBuffSize)))
    {
        inet_log("set send buff size error!\n");
        inet_close_socket(fd);
        return fd;
    }

    // Since we're going to be binding to a specific port,
    // we should turn on reuseaddr to allow us to override sockets in time_wait.

    int reuseOn = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuseOn, sizeof(reuseOn)))
    {
        inet_log("set SO_REUSEADDR error!\n");
        inet_close_socket(fd);
        return fd;
    }

    // bind local ip
    //    int result = bind(fd, interfaceAddr, (socklen_t)[connectInterface length]);
    //    if (result != 0)
    //    {
    //        inet_log("set bind address error!\n");
    //        inet_close_socket(fd);
    //        return fd;
    //    }

    int nosigpipe = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe)))
    {
        inet_log("set SO_NOSIGPIPE error!\n");
        inet_close_socket(fd);
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
                inet_call_connect_callback(inet, state);

                // host to addr ip
                if (inet->_reset_addr)
                {
                    // close pre socket
                    inet->_reset_addr = false;
                    if (inet->_socket != -1)
                    {
                        inet_close_socket(inet->_socket);
                        inet->_pollfd[0].events = 0;
                        inet->_pollfd[0].revents = 0;
                        inet->_pollfd[0].fd = -1;
                    }

                    inet->_socket = inet_create_socket(inet->_host, inet->_port, &peer);

                    // create socket err!
                    if (inet->_socket == -1)
                    {
                        inet->_state = inet_noconnect;
                        inet->_reset_addr = true;
                        inet_call_connect_callback(inet, inet_noconnect);
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
            struct timeval tem_timeval;
            gettimeofday(&tem_timeval, NULL);

            // connecting
            long long now_usec = tem_timeval.tv_sec * 1000000 + tem_timeval.tv_usec;
            long long interval_usec = (tem_timeval.tv_sec + connect_interval) * 1000000 + tem_timeval.tv_usec;
            long long timeout_usec = (tem_timeval.tv_sec + connect_timeout) * 1000000 + tem_timeval.tv_usec;

            bool is_connencted = false;
            bool try_connect = true;
            do
            {

                if (try_connect)
                {
                    scopedlock<recursivelock> tmplock(inet->_lock);
                    if (inet->_state == inet_noconnect)
                    { // state has changed
                        inet_call_connect_callback(inet, inet->_state);
                        inet_close_socket(inet->_socket);
                        inet->_pollfd[0].events = 0;
                        inet->_pollfd[0].revents = 0;
                        inet->_pollfd[0].fd = -1;
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

                        inet_call_connect_callback(inet, inet->_state);

                        break;
                    }
                    else
                    {
                        inet_log("ient connecting ...\n");
                        inet_call_connect_callback(inet, inet->_state);
                    }
                }

                inet_a_nap();
                gettimeofday(&tem_timeval, NULL);
                now_usec = tem_timeval.tv_sec * 1000000 + tem_timeval.tv_usec;
                if (try_connect)
                {
                    interval_usec = (tem_timeval.tv_sec + connect_interval) * 1000000 + tem_timeval.tv_usec;
                }
                try_connect = inet_check_time(now_usec, interval_usec, 10);
            } while (now_usec < timeout_usec);

            // stop connecting !
            if (!is_connencted)
            {
                scopedlock<recursivelock> tmplock(inet->_lock);
                inet->_state = inet_noconnect;
                inet_call_connect_callback(inet, inet->_state);
                inet_close_socket(inet->_socket);
                inet->_pollfd[0].events = 0;
                inet->_pollfd[0].revents = 0;
                inet->_pollfd[0].fd = -1;
                inet_log("stop connecting !\n");
            }
        }
        break;
        case inet_connected:
        {
            /*
            //struct pollfd pfd[1];
             inet->_pollfd[0].events = 0
            inet->_pollfd[0].revents = 0;


            {
                scopedlock<recursivelock> tmplock(inet->_lock);
                if (inet->_state == inet_noconnect)
                { // state has changed
                    inet_call_connect_callback(inet, inet->_state);
                    inet_close_socket(inet->_socket);
                    break;
                }

                // set attention event
                pfd[0].fd = inet->_socket;
                inet_set_pollfd_event(inet->_pollfd[0], true, true);
            }
            */
            int retevts = -1;
            int timeout_msec = 100; // 100ms

            bool run_flag = true;
            do
            {
                do
                {
                    {
                        scopedlock<recursivelock> tmplock(inet->_lock);
                        if (inet->_state == inet_noconnect)
                        { // state has changed
                            inet_call_connect_callback(inet, inet->_state);
                            inet_close_socket(inet->_socket);
                            inet->_pollfd[0].events = 0;
                            inet->_pollfd[0].revents = 0;
                            inet->_pollfd[0].fd = -1;
                            run_flag = false;
                            break;
                        }
                    }

                    retevts = poll(inet->_pollfd, 1, timeout_msec);
                    inet_log("poll fd result = %d\n", retevts);
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
                            inet_call_connect_callback(inet, inet->_state);
                            inet_close_socket(inet->_socket);
                            inet->_pollfd[0].events = 0;
                            inet->_pollfd[0].revents = 0;
                            inet->_pollfd[0].fd = -1;
                            run_flag = false;
                            break;
                        }

                        if (inet->_write_buffer.size() > 0)
                        {
                            unsigned long buffsize = 0;
                            const unsigned char *outbuffer = inet->_write_buffer.read_data(buffsize);
                            long wlen = inet_tcp_send(inet->_socket, outbuffer, buffsize);
                            inet_log("inet_tcp_send %ld,data, fd=%d , error=%d\n", wlen, inet->_socket, errno);

                            if (wlen > 0)
                            {
                                unsigned int tag = 0;
                                if (!inet->_read_tags.empty())
                                {
                                    tag = inet->_read_tags.back();
                                    inet->_read_tags.pop_back();
                                }
                                inet->_write_buffer.writed_size(wlen);
                                inet_call_write_callback(inet, outbuffer, wlen, tag);
                            }
                            else if (wlen == 0)
                            {
                                inet_set_pollfd_event(inet->_pollfd[0], true, false);
                            }
                        }
                    }
                }

                if (what & POLLIN)
                {
                    inet_log("the socket will read data\n");
                    {
                        const int buffsize = 128 * 1024;
                        unsigned char *tmpreadbuff = new unsigned char[buffsize];

                        scopedlock<recursivelock> tmplock(inet->_lock);
                        if (inet->_state == inet_noconnect)
                        { // state has changed
                            inet_call_connect_callback(inet, inet->_state);
                            inet_close_socket(inet->_socket);
                            inet->_pollfd[0].events = 0;
                            inet->_pollfd[0].revents = 0;
                            inet->_pollfd[0].fd = -1;
                            run_flag = false;
                            break;
                        }

                        long rlen = inet_tcp_recv(inet->_socket, tmpreadbuff, buffsize);
                        printf("inet_tcp_recv %ld, fd=%d, error=%d\n", rlen, inet->_socket, errno);
                        if (rlen > 0)
                        {
                            unsigned int tag = 0;
                            if (!inet->_write_tags.empty())
                            {
                                tag = inet->_write_tags.back();
                                inet->_write_tags.pop_back();
                            }
                            inet_call_read_callback(inet, tmpreadbuff, rlen, tag);
                        }
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
    {
        scopedlock<recursivelock> tmplock(_lock);
        if (_state != inet_connected)
        {
            inet_log("Current state is not inet_connected! write data will ignore\n");
            return SSN_INET_ERROR;
        }

        _write_buffer.append(bytes, size);
        _write_tags.insert(_write_tags.begin(), tag);

        // change zhe socket
        inet_set_pollfd_event(_pollfd[0], true, true);
    }

    return SSN_INET_OK;
}

int inet::async_read(const unsigned long &size, const unsigned int &tag, const long long &timeout_sec)
{
    {
        scopedlock<recursivelock> tmplock(_lock);
        if (_state != inet_connected)
        {
            inet_log("Current state is not inet_connected! read data will ignore\n");
            return SSN_INET_ERROR;
        }

        _read_tags.insert(_read_tags.begin(), tag);
    }

    return SSN_INET_OK;
}
}

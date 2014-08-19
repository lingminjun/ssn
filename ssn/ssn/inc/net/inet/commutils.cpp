#include <iostream>
#include <assert.h>
#include <unistd.h>
#include <fcntl.h>
#include "commutils.h"

#include <map>

#include <sys/socket.h>

#ifdef ANDROID_OS_DEBUG
#include <android/log.h>
#endif

#ifdef ANDROID_OS_DEBUG
#define printf(format...) __android_log_print(ANDROID_LOG_INFO, "printf", format)
#endif

bool set_address(const char *hname, const char *sname, struct sockaddr_in *sap, const char *protocol)
{
    struct servent *sp = NULL;
    struct hostent *hp = NULL;
    char *endptr = NULL;
    short port = 0;

    static std::map<std::string, std::string> hosts;
    if (hosts.size() <= 0)
    {
        hosts.insert(std::map<std::string, std::string>::value_type("ims.im.hupan.com", "121.0.19.246"));
        hosts.insert(std::map<std::string, std::string>::value_type("sdkims.wangxin.taobao.com", "42.120.142.23"));
    }

    memset(sap, 0, sizeof(*sap));
    sap->sin_family = AF_INET;
    if (hname != NULL && strlen(hname) > 0)
    {
        if (!inet_aton(hname, &sap->sin_addr))
        {
            hp = gethostbyname(hname);
            if (hp == NULL)
            {
                printf("gethostbyname hname %s failed.\n", hname);
                std::map<std::string, std::string>::iterator it = hosts.find(hname);
                if (it != hosts.end())
                {
                    printf("gethostbyname failed, hosts, %s -> %s\n", hname, (it->second).c_str());
                    if (!inet_aton((it->second).c_str(), &sap->sin_addr))
                    {
                        printf("inet_aton failed.");
                        return false;
                    }
                }
                else
                {
                    printf("host not found.\n");
                    return false;
                }
            }
            else
            {
                sap->sin_addr = *(struct in_addr *)hp->h_addr;
            }
        }
    }
    else
    {
        sap->sin_addr.s_addr = htonl(INADDR_ANY);
    }
    port = (short)strtol(sname, &endptr, 10);
    if (*endptr == '\0')
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

int tcp_server(const char *hostIp, const char *hostPort)
{
    struct sockaddr_in local;
    int fd;
    if (!set_address(hostIp, hostPort, &local, "tcp"))
    {
        return -1;
    }

    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
    {
        return -1;
    }

    int on = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)))
    {
        ::close(fd);
        return -1;
    }

    int trynum = 1;
    int iret = 0;
TRYAGAIN:
    iret = bind(fd, (struct sockaddr *)&local, sizeof(local));
    if (iret && errno == EADDRINUSE && trynum < 5)
    {
        trynum++;
        sleep(trynum);
        std::cout << "tcp_server bind failed tryagain errno is " << errno << std::endl;
        goto TRYAGAIN;
    }
    if (iret)
    {
        std::cout << "tcp_server bind failed errno is " << errno << std::endl;
        ::close(fd);
        assert(0);
        return -1;
    }

    if (listen(fd, 500))
    {
        std::cout << "tcp_server listen failed! errno is " << errno << std::endl;
        ::close(fd);
        assert(0);
        return -1;
    }

    return fd;
}

int tcp_client(const char *hostIp, const char *hostPort)
{
    struct sockaddr_in peer;
    int fd;

    if (!set_address(hostIp, hostPort, &peer, "tcp"))
    {
        std::cout << "tcp_client set_address call failed!" << errno << std::endl;
        return -1;
    }

    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
    {
        std::cout << "tcp_client socket call failed! errno is " << errno << std::endl;
        return -1;
    }

    //	struct timeval timeout;
    //	timeout.tv_sec = TCP_SEND_TIMEOUT;
    //	timeout.tv_usec = 0;
    //	if( setsockopt( fd, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout)))
    //	{
    //		TRACEX_LOCK(LEVEL_CRITICAL);
    //		TRACEX(LEVEL_CRITICAL)<<"tcp_server setsockopt failed! errno is "<<errno<<std::endl;
    //		TRACEX_UNLOCK(LEVEL_CRITICAL);
    //		::close( fd );				//added by helq.
    //		return -1;
    //	}
    if (connect(fd, (struct sockaddr *)&peer, sizeof(peer)))
    {
        std::cout << "tcp_client connect failed! errno is " << errno << std::endl;
        ::close(fd); // added by helq.
        return -1;
    }

    return fd;
}

int tcp_client(const char *hostIp, uint16_t port)
{
    struct sockaddr_in peer;

    memset(&peer, 0, sizeof(struct sockaddr_in));
    peer.sin_family = AF_INET;
    inet_aton(hostIp, &peer.sin_addr);
    peer.sin_port = htons(port);

    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
    {
        std::cout << "tcp_client socket call failed! errno is " << errno << std::endl;
        return -1;
    }

    if (connect(fd, (struct sockaddr *)&peer, sizeof(peer)))
    {
        std::cout << "tcp_client connect failed! errno is " << errno << std::endl;
        close(fd);
        return -1;
    }

    return fd;
}
int tcp_client2(const char *hostIp, const char *hostPort)
{
    struct sockaddr_in peer;
    int fd;

    if (!set_address(hostIp, hostPort, &peer, "tcp"))
    {
        std::cout << "tcp_client set_address call failed!" << std::endl;
        return -1;
    }

    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
    {
        std::cout << "tcp_client socket call failed! errno is " << errno << std::endl;
        return -1;
    }
    int rcvBuffSize = 128 * 1024 * 10;

    if (setsockopt(fd, SOL_SOCKET, SO_RCVBUF, &rcvBuffSize, sizeof(rcvBuffSize)))
    {
        std::cout << "tcp_client setsockopt failed! errno is " << errno << std::endl;
        close(fd);
        return -1;
    }

    const int sendBuffSize = 128 * 1024 * 10;
    if (setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &sendBuffSize, sizeof(sendBuffSize)))
    {
        std::cout << "tcp_client setsockopt failed! errno is " << errno << std::endl;
        close(fd);
        return -1;
    }

    if (connect(fd, (struct sockaddr *)&peer, sizeof(peer)))
    {
        std::cout << "tcp_client connect failed! errno is " << errno << std::endl;
        ::close(fd); // added by helq.
        return -1;
    }

    return fd;
}

int tcp_clienttimeout(const char *hostIp, const char *hostPort, size_t timeoutms)
{
    struct sockaddr_in peer;
    int fd;

    if (!set_address(hostIp, hostPort, &peer, "tcp"))
    {
        std::cout << "tcp_client set_address call failed!" << std::endl;
        return -1;
    }

    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
    {
        std::cout << "tcp_client socket call failed! errno is " << errno << std::endl;
        return -1;
    }
    int rcvBuffSize = 128 * 1024;

    if (setsockopt(fd, SOL_SOCKET, SO_RCVBUF, &rcvBuffSize, sizeof(rcvBuffSize)))
    {
        std::cout << "tcp_client setsockopt failed! errno is " << errno << std::endl;
        close(fd);
        return -1;
    }

    const int sendBuffSize = 128 * 1024;
    if (setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &sendBuffSize, sizeof(sendBuffSize)))
    {
        std::cout << "tcp_client setsockopt failed! errno is " << errno << std::endl;
        close(fd);
        return -1;
    }

    if (nb_connect(fd, (struct sockaddr *)&peer, sizeof(peer), timeoutms))
    {
        std::cout << "tcp_client connect failed! errno is " << errno << std::endl;
        ::close(fd); // added by helq.
        return -1;
    }

    return fd;
}
int nb_connect(int fd, struct sockaddr *peer, size_t peerlen, size_t timeoutms)
{
    if (timeoutms <= 0)
        return connect(fd, peer, peerlen);

    //	    assert(FD_SETSIZE>65500);
    setnonblocking(fd);

    if (timeoutms > 0)
    {
        setnonblocking(fd);
    }
    int rc = -1;
    do
    {
        rc = connect(fd, peer, peerlen);
    } while (rc == -1 && (errno == EINTR));

    if ((rc == -1) && (errno == EINPROGRESS || errno == EALREADY) && (timeoutms > 0))
    {
        fd_set wfdset;
        struct timeval tv;
        socklen_t rclen = (socklen_t)sizeof(rc);

        FD_ZERO(&wfdset);
        FD_SET(fd, &wfdset);
        tv.tv_sec = timeoutms / 1000;
        tv.tv_usec = (timeoutms % 1000) * 1000;
        rc = select(fd + 1, NULL, &wfdset, NULL, &tv);
        if (rc <= 0)
        {
            /* Save errno */
            int err = errno;
            (void)err;
            // fix crash bug, when in EINPROGRESS, fctnl will fail always
            // setblocking(fd);
            // errno = err;
            return -1;
        }
        rc = 0;
        //#ifdef SO_ERROR
        if (!FD_ISSET(fd, &wfdset) || (getsockopt(fd, SOL_SOCKET, SO_ERROR, (char *)&rc, &rclen) < 0) || rc)
        {
            if (rc)
                errno = rc;
            rc = -1;
        }
        //#endif /* SO_ERROR */
    }
    /* Not sure we can be already connected */
    if (rc == -1 && errno == EISCONN)
        rc = 0;
    setblocking(fd);
    return rc;
}

// udp appended 2010-03-05
int udp_server(const char *hostIp, const char *hostPort)
{
    int fd;
    struct sockaddr_in remote;
    if (!set_address(hostIp, hostPort, &remote, "udp"))
    {
        return -1;
    }

    fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0)
    {
        return -1;
    }

    int on = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)))
    {
        ::close(fd);
        return -1;
    }

    int trynum = 1;
    int iret = 0;
TRYAGAIN:
    iret = bind(fd, (struct sockaddr *)&remote, sizeof(struct sockaddr));
    if (iret && errno == EADDRINUSE && trynum < 5)
    {
        trynum++;
        sleep(trynum);
        std::cout << "udp_server bind failed tryagain errno is " << errno << std::endl;
        goto TRYAGAIN;
    }
    if (iret)
    {
        std::cout << "udp_server bind failed errno is " << errno << std::endl;
        ::close(fd);
        assert(0);
        return -1;
    }

    return fd;
}

int udp_client(const char *hostIp, const char *hostPort, struct sockaddr_in *local)
{
    int fd;

    if (!set_address(hostIp, hostPort, local, "udp"))
    {
        std::cout << "tcp_client set_address call failed!" << errno << std::endl;
        return -1;
    }

    fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0)
    {
        std::cout << "udp_client socket call failed! errno is " << errno << std::endl;
        return -1;
    }

    return fd;
}
int udp_sendto(int fd, const char *buffer, int length, const struct sockaddr_in *to)
{
    // assert(length>0 && length<1400);
    int len = sendto(fd, buffer, length, 0, (struct sockaddr *)to, sizeof(struct sockaddr));
    return len;
}

int udp_recvfrom(int fd, char *buffer, int length, struct sockaddr_in *from, int *addrlen)
{
    memset(buffer, 0, length);
    int len = -1;
    do
    {
        len = recvfrom(fd, buffer, length, 0, (sockaddr *)from, (socklen_t *)addrlen);
    } while (-1 == len && (EINTR == errno));
    return len;
}

int TcpSendBlockAll(int fd, const char *msg, int msglen)
{
    int ret = 0;
    int left_length = msglen;
    const char *pmsg = msg;
    while (left_length > 0)
    {
        do
        {
            // ret = send(fd,pmsg,left_length,MSG_NOSIGNAL);
            ret = write(fd, pmsg, left_length);
        } while (ret == -1 && (errno == EINTR));

        if (ret < 0)
        {
            return ret;
        }
        left_length -= ret;
        pmsg += ret;
        if (left_length == 0)
            break;
        usleep(10000);
    }
    return msglen;
}

int TcpRecv(int fd, char *msg, int msglen)
{
    int ret = -1;

    do
    {
        // ret = recv(fd,msg,msglen,MSG_NOSIGNAL);
        ret = read(fd, msg, msglen);
    } while (ret == -1 && (errno == EINTR));
    return ret;
}
int TcpSend(int fd, const char *msg, size_t datalen)
{
    int ret = -1;
    do
    {
        // ret=send(fd,msg,datalen,MSG_NOSIGNAL);
        ret = write(fd, msg, datalen);
    } while (-1 == ret && EINTR == errno);
    return ret;
}
int TcpRecvBlockTimeout(int fd, char *buffer, size_t buflength, int32_t timeoutms)
{
    struct timeval TimeOut;
    TimeOut.tv_sec = timeoutms / 1000;
    TimeOut.tv_usec = timeoutms * 1000 - TimeOut.tv_sec * 1000000;

    fd_set fdset;
    int fd_max = fd + 1;
    FD_ZERO(&fdset);
    FD_SET(fd, &fdset);
    int sel_ret = 0, recv_ret = 0;
    do
    {
        sel_ret = select(fd_max, &fdset, NULL, NULL, &TimeOut);
    } while (sel_ret == -1 && (errno == EINTR));

    if (sel_ret == 0)
    {
        return -1;
    }
    if (sel_ret < 0)
        return -2;

    do
    {
        // recv_ret= recv(fd, buffer, buflength, MSG_NOSIGNAL);
        recv_ret = read(fd, buffer, buflength);
    } while (recv_ret == -1 && (errno == EINTR));

    if (recv_ret <= 0)
    {
        if (0 == recv_ret)
            return 0;
        return -3;
    }
    return recv_ret;
}
void setnonblocking(int sock)
{
    int opts = -1;
    while (true)
    {
        opts = fcntl(sock, F_GETFL);
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
        opts = fcntl(sock, F_SETFL, opts);
        if (-1 == opts && errno == EINTR)
            continue;
        break;
    }
    if (opts < 0)
    {
        int err = errno;
        (void)err;
        assert(0);
    }
}

void setblocking(int sock)
{
    int opts = -1;
    while (true)
    {
        opts = fcntl(sock, F_GETFL);
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
        opts = fcntl(sock, F_SETFL, opts);
        if (-1 == opts && errno == EINTR)
            continue;
        break;
    }
    if (opts < 0)
    {
        int err = errno;
        (void)err;
        assert(0);
    }
}
int TcpSendNonBlockTimeout(int fd, const char *buffer, int length, int32_t timeoutms)
{
    int left_length = length;

    int send_ret = 0;
    int iret = 0;
    // int  sleeplimit=timeoutms/1000+1;
    int sleeplimit = timeoutms;
    int sleepcount = 0;
    try
    {
        while (left_length > 0)
        {
            do
            {
                // send_ret = send(fd, buffer, left_length, MSG_NOSIGNAL);
                send_ret = write(fd, buffer, left_length);
            } while (send_ret == -1 && (errno == EINTR));

            if (send_ret > 0)
            {
                left_length -= send_ret;
                buffer += send_ret;

                if (left_length == 0)
                {
                    break;
                }
            }
            else if (send_ret == -1 && (errno != EAGAIN && EWOULDBLOCK != errno))
            {
                iret = -1;
                break;
            }
            usleep(1000);
            sleepcount++;
            if (sleepcount > sleeplimit)
                break;
        }
    }
    catch (...)
    {
        assert(0);
    }
    if (iret != 0)
        return iret;
    return (left_length < 0) ? length : length - left_length;
}

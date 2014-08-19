#ifndef _H_ZUS_COMMON_BASEUTILS_COMMUTILS_H
#define _H_ZUS_COMMON_BASEUTILS_COMMUTILS_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/un.h>


    bool set_address(const char* hname, const char* sname, struct sockaddr_in* sap, const char* protocol);
    int tcp_server(const char* hostIp, const char* hostPort);
    int tcp_client( const char* hostIp,  const char* hostPort);
    int tcp_client(const char* hostIp, uint16_t port);
    int tcp_client2( const char* hostIp,  const char* hostPort);
    int tcp_clienttimeout( const char* hostIp,  const char* hostPort,size_t timeoutms);
    int nb_connect(int fd,struct sockaddr * peer, size_t peerlen, size_t timeoutms);
    int udp_server(const char* hostIp, const char* hostPort);
    int udp_client( const char* hostIp,  const char* hostPort, struct sockaddr_in* local);
    int udp_sendto(int fd, const char* buffer, int length, const struct sockaddr_in* to);
    int udp_recvfrom(int fd, char* buffer, int length, struct sockaddr_in* from, int* addrlen);
    int TcpSendBlockAll(int fd, const char* msg, int msglen );
    int TcpRecv(int fd,char* msg, int msglen);
    int TcpSend(int fd, const char* msg, size_t datalen);
    int TcpRecvBlockTimeout(int fd, char* buffer, size_t buflength, int32_t timeoutms);
    void setnonblocking(int sock);
    void setblocking(int sock);
    int TcpSendNonBlockTimeout(int fd, const char* buffer, int length, int32_t timeoutms);



#endif

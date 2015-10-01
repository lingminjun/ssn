//
//  ssnping.c
//  ssn
//
//  Created by lingminjun on 15/8/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#include "ssnping.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <time.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <netinet/ip_icmp.h>

#define ICMP_PACKET_LEN 64
#define ICMP_DATA_LEN   56
#define ICMP_SEQ_START  4000

typedef struct {
    char *hostname;
    int rtt;
} alive;

extern unsigned short chksum(unsigned short *addr, int len);
extern void pack(int seq, char *packet);
extern bool unpack(char *buf, int len, struct timeval tvrecv, alive *alives);
extern struct sockaddr_in getaddrbyhostname(char* hostname);
static void tv_sub(struct timeval *out, struct timeval *in);
extern void ping(alive *alives, int count, struct timeval timeout, int try_times);
static void usage_with_exit();

unsigned short chksum(unsigned short *addr, int len) {
    int nleft = len;
    int sum = 0;
    unsigned short *w = addr;
    unsigned short answer = 0;
    
    /*把ICMP报头二进制数据以2字节为单位累加起来*/
    while (nleft > 1) {
        sum += *w++;
        nleft -= 2;
    }
    /*若ICMP报头为奇数个字节，会剩下最后一字节。把最后一个字节视为一个2字节数据的高字节，
     这个2字节数据的低字节为0，继续累加*/
    if (nleft == 1) {
        *(unsigned char *) (&answer) = *(unsigned char *) w;
        sum += answer;
    }
    sum = (sum >> 16) + (sum & 0xffff);
    sum += (sum >> 16);
    answer = ~sum;
    return answer;
}

void pack(int seq, char *packet) {
    int packsize;
    struct icmp *icmp;
    struct timeval *tval;
    icmp = (struct icmp*) packet;
    icmp->icmp_type = ICMP_ECHO;
    icmp->icmp_code = 0;
    icmp->icmp_cksum = 0;
    icmp->icmp_seq = seq;
    icmp->icmp_id = getpid();
    packsize = 8 + ICMP_DATA_LEN; //icmp_type 1, icmp_code1, cksum 2, seq 2, id, 2 共8字节
    tval = (struct timeval *) icmp->icmp_data;
    gettimeofday(tval, NULL);
    icmp->icmp_cksum = chksum((unsigned short *) icmp, packsize);
}

bool unpack(char *buf, int len, struct timeval tvrecv, alive *alives) {
    int iphdrlen;
    struct ip *ip;
    struct icmp *icmp;
    struct timeval *tvsend;
    double rtt;
    ip = (struct ip *) buf;
    iphdrlen = ip->ip_hl << 2; /*求ip报头长度,即ip报头的长度标志乘4*/
    icmp = (struct icmp *) (buf + iphdrlen); /*越过ip报头,指向ICMP报头*/
    len -= iphdrlen; /*ICMP报头及ICMP数据报的总长度*/
    if (len < 8) /*小于ICMP报头长度则不合理*/
    {
        return false;
    }
    /*确保所接收的是我所发的的ICMP的回应*/
    if ((icmp->icmp_type == ICMP_ECHOREPLY) && (icmp->icmp_id == getpid())) {
        tvsend = (struct timeval *) icmp->icmp_data;
        tv_sub(&tvrecv, tvsend);
        rtt = tvrecv.tv_sec * 1000 + tvrecv.tv_usec / 1000; /*以毫秒为单位计算rtt*/
        int seq = icmp->icmp_seq;
        if (alives[seq - ICMP_SEQ_START].rtt >= 0) {
            return false;
        }
        alives[seq - ICMP_SEQ_START].rtt = rtt;
        
        return true;
    }
    return false;
}

void tv_sub(struct timeval *out, struct timeval *in) {
    if ((out->tv_usec -= in->tv_usec) < 0) {
        --out->tv_sec;
        out->tv_usec += 1000000;
    }
    out->tv_sec -= in->tv_sec;
}

struct sockaddr_in getaddrbyhostname(char* hostname) {
    struct sockaddr_in addr;
    bzero(&addr, sizeof(addr));
    struct hostent *host;
    addr.sin_family = AF_INET;
    if ((host = gethostbyname(hostname)) == NULL) {
        addr.sin_addr.s_addr = 0;
    }else{
        addr.sin_addr = *((struct in_addr *) host->h_addr);
    }
    return addr;
}

void ping(alive *alives, int count, struct timeval timeout, int try_times) {
    struct protoent *proto = getprotobyname("icmp");
    int sockfd = socket(AF_INET, SOCK_RAW, proto->p_proto);
    int i;
    for (i = 0; i < count; i++) {
        struct sockaddr_in dest_addr = getaddrbyhostname(alives[i].hostname);
        if (dest_addr.sin_addr.s_addr == 0) continue;
        char buf[ICMP_PACKET_LEN];
        pack(ICMP_SEQ_START + i, buf);
        int times = try_times;
        while(times > 0){
            if (sendto(sockfd, buf, ICMP_PACKET_LEN, 0,
                       (struct sockaddr *) &dest_addr, sizeof(dest_addr)) < 0) {
                fprintf(stderr, "send error %s.\n", alives[i].hostname);
            }
            times--;
        }
        
    }
    time_t loop_start = time(NULL);
    
    fd_set fdset;
    FD_ZERO(&fdset);
    FD_SET(sockfd, &fdset);
    int matched = count;
    while (matched > 0) {
        if (select(sockfd + 1, &fdset, NULL, NULL, &timeout) == 0) {
            break;
        }
        if (!FD_ISSET(sockfd, &fdset)) {
            continue;
        }
        time_t current = time(NULL);
        if (current - loop_start > timeout.tv_sec * 1000) {
            break;
        }
        char buf[ICMP_PACKET_LEN];
        struct sockaddr_in from;
        size_t from_size = sizeof(from);
        int buflen = recvfrom(sockfd, buf, ICMP_PACKET_LEN, 0,
                              (struct sockaddr *) &from, &from_size);
        if (buflen < 0) {
            continue;
        }
        struct timeval tvrecv;
        gettimeofday(&tvrecv, NULL); /*记录接收时间*/
        if (unpack(buf, buflen, tvrecv, alives)) {
            matched--;
        }
    }
    
}

void usage_with_exit() {
    printf("Usage: pingx [-c count] [-t timeout] IP1 [IP2 [IP3]]\n");
    exit(EXIT_FAILURE);
}

int main(int argc, char **argv) {
    int arg_timeout = 3;
    int arg_count = 3;
    int c;
    while ((c = getopt(argc, argv, "ht:c:")) != -1)
        switch (c) {
            case 't':
                arg_timeout = atoi(optarg);
                break;
            case 'c':
                arg_count = atoi(optarg);
                break;
            case 'h':
                usage_with_exit();
                break;
            case '?':
                if (optopt == 'c' || optopt == 't')
                    fprintf(stderr, "Option -%c requires an argument.\n", optopt);
                else if (isprint(optopt))
                    fprintf(stderr, "Unknown option `-%c'.\n", optopt);
                else
                    fprintf(stderr, "Unknown option character `\\x%x'.\n", optopt);
                return 1;
            default:
                usage_with_exit();
        }
    if (arg_timeout <= 0 || arg_count <= 0) {
        usage_with_exit();
    }
    int host_count = argc - optind;
    if (host_count == 0) {
        usage_with_exit();
    }
    
    if (geteuid() != 0) {
        fprintf(stderr, "Permission Denied\n");
        exit(EXIT_FAILURE);
    }
    char** hostnames = &argv[optind];
    alive alives[host_count];
    int i;
    for (i = 0; i < host_count; i++) {
        alives[i].hostname = hostnames[i];
        alives[i].rtt = -1;
    }
    struct timeval tv;
    tv.tv_sec = arg_timeout;
    tv.tv_usec = 0;
    ping(alives, host_count, tv, arg_count);
    bool has_unreachable = false;
    for (i = 0; i < host_count; i++) {
        printf("%-20s\t%d\n", alives[i].hostname, alives[i].rtt);
        if (alives[i].rtt < 0) {
            has_unreachable = true;
        }
    }
    if (has_unreachable) {
        return EXIT_FAILURE;
    }else{
        return EXIT_SUCCESS;
    }
}
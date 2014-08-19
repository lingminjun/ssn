//
//  inetimpl.cpp
//  inettest
//
//  Created by jay on 11-10-14.
//  Copyright 2011__MyCompanyName__. All rights reserved.
//

#include "inetimpl.h"
#include "inet.h"
#include "protocmdheader.h"
#include "../commutils.h"
#include <iostream>
#include "../msc_head.h"
#include <assert.h>
#include "inetexception.h"

using namespace std;

static pthread_t gtid_eventthread = 0;
// inet.cpp中定义, 模块内直接使用
extern uint32_t gCurrenAccountBeginSeqId;

INetImpl *INetImpl::sharedInstance()
{
    static INetImpl s_ins;
    return &s_ins;
}
INetImpl::INetImpl()
{
    m_bInited = false;
    m_brun = false;
}
INetImpl::~INetImpl()
{
}
static void *RunEventThrFunc(void *parg)
{
    pthread_setname_np("RunEventThrFunc");
    INetImpl *pthis = (INetImpl *)parg;
    pthis->RunEvent();
    return NULL;
}

bool INetImpl::Init(map<string, string> &option)
{
    if (m_bInited)
        return true;
    m_bInited = true;
    m_brun = true;
    //    pthread_t tid;
    //    pthread_create(&tid,NULL,RunEventThrFunc,this);
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    pthread_create(&gtid_eventthread, &attr, RunEventThrFunc, this);
    pthread_attr_destroy(&attr);
    return true;
}

bool INetImpl::UnInit()
{
    m_brun = false;
//    struct timeval tvs;
//    tvs.tv_sec=1;
//    tvs.tv_usec=0;
//    select(0, NULL, NULL, NULL, &tvs);
#ifndef ANDROID_OS_DEBUG
    void *retval;
    pthread_join(gtid_eventthread, &retval);
    gtid_eventthread = 0;
#endif
    return true;
}
void INetImpl::closeFd(int fd)
{
    //::close(fd);
    saveCloseFd(fd);
    printf("enter INetImpl::closeFd,fd=%d\n", fd);
}
void INetImpl::saveCloseFd(int fd)
{
    TScopedLock<RecursiveMutex> tmplock(lock_);
    mNeedCloseFds[fd] = time(0);
}
void INetImpl::RegisterFd(int fd)
{
    printf("RegisterFd,fd=%d\n", fd);
    if (false == m_brun)
        assert(0);
    setnonblocking(fd);
    TScopedLock<RecursiveMutex> tmplock(lock_);
    typeof(fdmap_.begin()) itr = fdmap_.begin();
    for (; itr != fdmap_.end(); itr++)
    {
        closeFd(itr->first);
    }
    fdmap_.clear();
    ConnPollFDPtr fdconnptr(new ConnPollFD());
    fdconnptr->connptr.reset(new ProtoTcpConnect(fd));
    fdconnptr->pfd.fd = fd;
    fdmap_[fd] = fdconnptr;
    setEvent(fd, true, true);
}
void INetImpl::UnRegisterFd(int fd)
{
    if (fd < 0)
        return;
    printf("UnRegisterFd,fd=%d", fd);
    closeFd(fd);

    TScopedLock<RecursiveMutex> tmplock(lock_);
    typeof(fdmap_.begin()) itr = fdmap_.find(fd);
    if (itr == fdmap_.end())
        return;
    ProtoTcpConnectPtr conptr = itr->second->connptr;
    conptr->handleConnClosed();
    fdmap_.erase(fd);
    clearEvent(fd);
}

void INetImpl::UnRegisterFdNotNotify(int fd)
{
    printf("forceClose,fd=%d", fd);
    ::close(fd);

    TScopedLock<RecursiveMutex> tmplock(lock_);
    typeof(fdmap_.begin()) itr = fdmap_.find(fd);
    if (itr == fdmap_.end())
        return;
    ProtoTcpConnectPtr conptr = itr->second->connptr;
    //    conptr->handleConnClosed();
    fdmap_.erase(fd);
    clearEvent(fd);
}
void INetImpl::pushBufferedData()
{
    TScopedLock<RecursiveMutex> tmplock(lock_);
    while (false == mDeferMsgQ.IsEmpty())
    {
        SProtoMsgPtr msgptr;
        mDeferMsgQ.Get(msgptr);
        if (!msgptr)
            continue;

        PostMsg(msgptr->cmdtype, msgptr->cmdid, msgptr->seqid, msgptr->extrahead, msgptr->data, msgptr->bEncryed,
                msgptr->bCompressed, msgptr->timeoutts, msgptr->cc, msgptr->reserved);
    }
}
bool INetImpl::setEvent(int fd, bool bReadEvent, bool bWriteEvent)
{
    if (m_brun == false)
        return false;
    TScopedLock<RecursiveMutex> tmplock(lock_);
    typeof(fdmap_.begin()) itr = fdmap_.find(fd);

    if (itr == fdmap_.end())
    {
        return false;
    }
    ConnPollFDPtr &ppconfd = itr->second;

    ppconfd->pfd.events = POLLERR | POLLHUP;
    if (bWriteEvent)
        ppconfd->pfd.events |= POLLOUT;
    if (bReadEvent)
        ppconfd->pfd.events |= POLLIN | POLLPRI;
    // printf("setEvent,fd=%d,bRead=%d,bWrite=%d\n",fd,(int)bReadEvent,(int)bWriteEvent);
    return true;
}
void INetImpl::clearEvent(int fd)
{
    if (m_brun == false)
        return;
    TScopedLock<RecursiveMutex> tmplock(lock_);

    typeof(fdmap_.begin()) itr = fdmap_.find(fd);
    if (itr == fdmap_.end())
        return;
    fdmap_.erase(itr);
    printf("clearEvent,fd=%d\n", fd);

    return;
}
ProtoTcpConnectPtr INetImpl::GetConn()
{
    TScopedLock<RecursiveMutex> tmplock(lock_);
    typeof(fdmap_.begin()) itr = fdmap_.begin();
    if (itr == fdmap_.end())
        return ProtoTcpConnectPtr();
    return itr->second->connptr;
}

SProtoMsgPtr INetImpl::GetMsg(int timeoutms)
{
    SProtoMsgPtr msgptr;
    mMsgQ.Get(timeoutms, msgptr);
    return msgptr;
}
void INetImpl::PostMsg(EMsgCmdType cmdtype, uint32_t cmdid, uint32_t seqid, const string &extrahead,
                       const string &paramdata, bool bEncryed, bool bCompressed, uint32_t ts, uint16_t cc,
                       uint16_t reserved)
{
    printf("INetImp::PostMsg cmdid=0x%x,seqid=%d,cmdtype=%d\n", cmdid, seqid, cmdtype);
    if (false == m_brun)
        assert(0);

    //如果消息编号比登录账号登录时还要小则忽略.
    if (seqid < gCurrenAccountBeginSeqId)
    {
        SProtoMsgPtr msgptr(new SProtoMsg());
        msgptr->errcode = 0;
        msgptr->seqid = seqid;
        msgptr->cmdid = cmdid;
        msgptr->cmdtype = cmdtype;
        msgptr->bEncryed = bEncryed;
        msgptr->bCompressed = bCompressed;
        msgptr->extrahead = extrahead;
        msgptr->data = paramdata;
        msgptr->cc = cc;
        msgptr->reserved = reserved;
        msgptr->errcode = (int)EActionRspError_Timeout;
        mMsgQ.Put(msgptr);
        printf("====== seqid < gCurrenAccountBeginSeqId  cmdid=0x%x,seqid=%d,cmdtype=%d\n", cmdid, seqid, cmdtype);
        return;
    }

    // fix deadlock
    // TScopedLock<RecursiveMutex> tmplock(lock_);
    ProtoTcpConnectPtr connptr = GetConn();
    if (!connptr && cmdtype != EMsgCmdType_Notify)
    {

        SProtoMsgPtr msgptr(new SProtoMsg());
        msgptr->cmdtype = cmdtype;
        msgptr->extrahead = extrahead;
        msgptr->data = paramdata;
        msgptr->errcode = 0;
        msgptr->seqid = seqid;
        msgptr->cmdid = cmdid;
        msgptr->bEncryed = bEncryed;
        msgptr->bCompressed = bCompressed;
        msgptr->time = time(0);
        msgptr->timeoutts = ts;
        msgptr->cc = cc;
        msgptr->reserved = reserved;
        mDeferMsgQ.Put(msgptr);

        return;
    }
    CMscHead header;
    header.m_reserved = reserved;
    header.m_extdata = extrahead;
    header.m_cmd = cmdid;
    header.m_encrypt = bEncryed;
    header.m_compress = bCompressed;
    header.m_seq = seqid;
    header.m_msgtype = (uint8_t)cmdtype;
    header.m_cc = cc;
    header.m_len = paramdata.size() + header.SizeExt() - header.Size();

    string msgdata;
    header.PackData(msgdata);
    msgdata += paramdata;
    connptr->postData2Server(cmdtype, seqid, ts, msgdata);
    INetImpl::sharedInstance()->setEvent(connptr->getFd(), true, true);
}
void INetImpl::NotifyConnLost(uint32_t seqid, int errorCode)
{
    // fix deadlock
    // TScopedLock<RecursiveMutex> tmplock(lock_);
    SProtoMsgPtr msgptr(new SProtoMsg());
    msgptr->seqid = seqid;
    msgptr->cmdtype = EMsgCmdType_Rsp;
    msgptr->errcode = errorCode; // EActionRspError_NetConnLost;
    mMsgQ.Put(msgptr);
}
void INetImpl::NotifyNeedReconnect()
{
    // fix deadlock
    // TScopedLock<RecursiveMutex> tmplock(lock_);
    SProtoMsgPtr msgptr(new SProtoMsg());
    msgptr->cmdtype = EMsgCmdType_ConnLost;
    msgptr->errcode = EActionRspError_NetConnLost;
    mMsgQ.Put(msgptr);
}

void INetImpl::SaveRspMsg(EMsgCmdType cmdtype, uint32_t cmdid, uint32_t seqid, const string &extrahead,
                          const string &paramdata, bool bEncryed, bool bCompressed, uint16_t cc, uint16_t reserved)
{
    // fix deadlock
    // TScopedLock<RecursiveMutex> tmplock(lock_);

    SProtoMsgPtr msgptr(new SProtoMsg());
    msgptr->errcode = 0;
    msgptr->seqid = seqid;
    msgptr->cmdid = cmdid;
    msgptr->cmdtype = cmdtype;
    msgptr->bEncryed = bEncryed;
    msgptr->bCompressed = bCompressed;
    msgptr->extrahead = extrahead;
    msgptr->data = paramdata;
    msgptr->cc = cc;
    msgptr->reserved = reserved;
    mMsgQ.Put(msgptr);

    printf("INetImpl::SaveRspMsg - cmdid=0x%x,seqid=0x%x\n", cmdid, seqid);
}
void INetImpl::checkTimeoutDeferQ()
{
    time_t nowt = time(0);
    vector<ProtoTcpConnectPtr> tmpconns;

    {
        TScopedLock<RecursiveMutex> tmplock(lock_);
        while (mDeferMsgQ.IsEmpty() == false)
        {
            SProtoMsgPtr msgptr;
            mDeferMsgQ.Get(msgptr);
            if (!msgptr)
                break;
            if (msgptr->time + msgptr->timeoutts > nowt)
            {
                mDeferMsgQ.PutFront(msgptr);
                break;
            }
            msgptr->errcode = (int)EActionRspError_NetConnFail;
            mMsgQ.Put(msgptr);
        }
        typeof(fdmap_.begin()) itr;
        for (itr = fdmap_.begin(); itr != fdmap_.end(); itr++)
            tmpconns.push_back(itr->second->connptr);
    }
    for (size_t i = 0; i < tmpconns.size(); i++)
    {
        tmpconns[i]->clearTimeoutSeq();
    }
}
void INetImpl::closeTimeoutedFds()
{
    time_t nowt = time(0);

    typeof(mNeedCloseFds.begin()) itr = mNeedCloseFds.begin();
    for (; itr != mNeedCloseFds.end();)
    {
        if (itr->second + 10 < nowt)
        {
            ::close(itr->first);
            mNeedCloseFds.erase(itr);
            itr = mNeedCloseFds.begin();
        }
        else
        {
            itr++;
        }
    }
}
void INetImpl::clearDeferMsgQ()
{
    TScopedLock<RecursiveMutex> tmplock(lock_);
    while (mDeferMsgQ.IsEmpty() == false)
    {
        SProtoMsgPtr msgptr;
        mDeferMsgQ.Get(msgptr);
        if (!msgptr)
            break;

        msgptr->errcode = (int)EActionRspError_NetConnFail;
        mMsgQ.Put(msgptr);
    }
    closeTimeoutedFds();
}
void INetImpl::RunEvent()
{

    struct pollfd *events = new struct pollfd[8];
    int i, retevts; // 100ms
    const int buffsize = 128 * 1024;
    char *tmpreadbuff = new char[buffsize];

    int checkcount = 0;
    while (m_brun)
    {
        printf("==============================\n");

        checkcount++;
        if (checkcount > 10)
        {
            checkTimeoutDeferQ();
        }
        vector<pair<int, ProtoTcpConnectPtr> > tmpconnEvts;
        tmpconnEvts.reserve(128);

        int timeout = 100;
        retevts = -1;
        nfds_t nfds = 0;
        {
            TScopedLock<RecursiveMutex> tmplock(lock_);
            for (typeof(fdmap_.begin()) itr = fdmap_.begin(); itr != fdmap_.end() && nfds < 8; itr++, nfds++)
            {
                events[nfds] = itr->second->pfd;
                // if(events[nfds].events != 31)
                // printf("poll events, fd=%d,events=%d\n",events[nfds].fd,events[nfds].events);
            }
        }

        do
        {
            retevts = poll(events, nfds, timeout);
        } while (-1 == retevts && EINTR == errno);
        if (retevts < 0)
        {
            struct timeval tvs;
            tvs.tv_sec = 0;
            tvs.tv_usec = 1000 * 100;
            select(0, NULL, NULL, NULL, &tvs);
            continue;
        }
        tmpconnEvts.clear();
        {
            // to avoid deadlock
            TScopedLock<RecursiveMutex> tmplock(lock_);
            for (i = 0; i < nfds; i++)
            {
                int what = events[i].revents;
                if (what == 0)
                    continue;
                int fd = events[i].fd;
                typeof(fdmap_.begin()) itr = fdmap_.find(fd);
                if (itr == fdmap_.end())
                    continue;

                if ((what & (POLLHUP | POLLERR)) && (what & (POLLIN | POLLOUT)) == 0)
                {
                    what |= POLLIN | POLLOUT;
                }
                ProtoTcpConnectPtr connptr = itr->second->connptr;
                tmpconnEvts.push_back(pair<int, ProtoTcpConnectPtr>(what, connptr));
            }
        }
        // bool bret=true;
        for (size_t j = 0; j < tmpconnEvts.size(); j++)
        {
            int what = tmpconnEvts[j].first;
            ProtoTcpConnectPtr connptr = tmpconnEvts[j].second;
            if (what & POLLOUT)
            {
                int bOk = connptr->handleWriteEvt();
                // static int i = 0;
                // if(i++ > 10){
                //   bOk = -1;
                //   i=0;
                // }
                // printf("handleWriteEvt, i=%d", i);
                if (0 == bOk)
                {
                    INetImpl::sharedInstance()->setEvent(connptr->getFd(), true, false);
                }
                else if (-1 == bOk)
                {
                    // if error happend when writing, try re-send.
                    // printf("handleWriteEvt error,,,,,,,,");
                    // INetImpl::sharedInstance()->clearEvent(m_fd);
                    INetImpl::sharedInstance()->UnRegisterFdNotNotify(connptr->getFd());
                    connptr->handleConnClosed(EActionRspError_IoError);
                    INetImpl::sharedInstance()->NotifyNeedReconnect(); // jay
                }
            }
            if (what & POLLIN)
            {
                bool bOk = connptr->handleReadEvt(tmpreadbuff, buffsize);
                if (false == bOk)
                {
                    // INetImpl::sharedInstance()->clearEvent(m_fd);
                    // if error happend when writing, try re-send.
                    INetImpl::sharedInstance()->UnRegisterFdNotNotify(connptr->getFd());
                    connptr->handleConnClosed(EActionRspError_IoError);
                    INetImpl::sharedInstance()->NotifyNeedReconnect(); // jay
                }
            }
        }
        tmpconnEvts.clear();
    }
    delete[] events;
    delete[] tmpreadbuff;
    //执行到此处表示程序即将被kill掉, 可以不调用clear fd, 避免close fd crash问题.
    // clearDeferMsgQ();
}

ProtoTcpConnect::ProtoTcpConnect(int fd)
{
    m_fd = fd;
}
ProtoTcpConnect::~ProtoTcpConnect()
{
}
void ProtoTcpConnect::postData2Server(EMsgCmdType cmdtype, uint32_t seqid, uint32_t ts, const string &data)
{
    TScopedLock<RecursiveMutex> tmplock(lock_);
    if (ts > 100)
        ts = 100;
    if (ts == 0)
        ts = 1;
    if (cmdtype == EMsgCmdType_Req)
    {
        m_seqtsMap[seqid] = time(0) + ts;
    }
    m_outbuff.append(data);
}
void ProtoTcpConnect::clearTimeoutSeq()
{
    time_t nowt = time(0);
    vector<uint32_t> timeoutseqs;
    TScopedLock<RecursiveMutex> tmplock(lock_);
    typeof(m_seqtsMap.begin()) itr = m_seqtsMap.begin();
    for (; itr != m_seqtsMap.end(); itr++)
    {
        uint32_t seqid = itr->first;
        if (itr->second < nowt)
            timeoutseqs.push_back(seqid);
    }
    for (size_t i = 0; i < timeoutseqs.size(); i++)
    {
        uint32_t seqid = timeoutseqs[i];
        m_seqtsMap.erase(seqid);
        printf("ProtoTcpConnect::clearTimeoutSeq::NotifyConnLost,seqid=%d\n", seqid);
        INetImpl::sharedInstance()->NotifyConnLost(seqid, EActionRspError_NetConnLost);
    }
}
void ProtoTcpConnect::handleConnClosed()
{
    handleConnClosed(EActionRspError_IoError);
}

void ProtoTcpConnect::handleConnClosed(int errorCode)
{
    TScopedLock<RecursiveMutex> tmplock(lock_);
    typeof(m_seqtsMap.begin()) itr = m_seqtsMap.begin();
    for (; itr != m_seqtsMap.end(); itr++)
    {
        uint32_t seqid = itr->first;
        printf("ProtoTcpConnect::handleConnClosed::NotifyConnLost,seqid=%d,fd=%d\n", seqid, m_fd);
        INetImpl::sharedInstance()->NotifyConnLost(seqid, errorCode);
    }
    m_seqtsMap.clear();
}
bool ProtoTcpConnect::handleReadEvt(char *readbuff, size_t buffsize)
{

    int n = -1;
    do
    {
        n = read(m_fd, readbuff, buffsize);
    } while (-1 == n && EINTR == errno);
    if (n <= 0)
    {
        int ierr = errno;
        if (EAGAIN == ierr && -1 == n)
            return true;
        printf("handleReadEvt, fd=%d,read return n=%d,errno=%d\n", m_fd, n, errno);
        // fix deadlock
        //        handleConnClosed();
        //        //INetImpl::sharedInstance()->clearEvent(m_fd);
        //        INetImpl::sharedInstance()->UnRegisterFd(m_fd);
        //        INetImpl::sharedInstance()->NotifyNeedReconnect(); //jay
        return false;
    }
    printf("handleReadEvt, fd=%d,read return n=%d\n", m_fd, n);
    TScopedLock<RecursiveMutex> tmplock(lock_);
    m_inbuff.append(readbuff, n);

    bool bret = true;
    while (bret)
    {
        try
        {
            bret = ProcessMsgData(m_inbuff);
        }
        catch (...)
        {
            // LOG
            printf("catch exception within ProcesMsgData\n");
            // fix deadlock
            //            handleConnClosed();
            //            //::close(m_fd);
            //            INetImpl::sharedInstance()->UnRegisterFd(m_fd);
            //            INetImpl::sharedInstance()->NotifyNeedReconnect();
            return false;
        }
    }
    return true;
}
bool ProtoTcpConnect::ProcessMsgData(MemFile &tmprcvbuff)
{
    CMscHead header;
    uint32_t headsize = header.Size();
    if (tmprcvbuff.size() < headsize)
        return false;
    size_t data_len = 0;
    const char *msgdata = tmprcvbuff.getReadableData(data_len);

    string tmpdata;
    tmpdata.assign(msgdata, data_len);
    PACKRETCODE ret = header.UnpackData(tmpdata);
    if (PACK_LENGTH_ERROR == ret)
    {
        printf("ProcessMsgData UnPackHead Failed, ret=%d\n", ret);
        return false;
    }
    if (PACK_RIGHT != ret)
    {
        printf("ProcessMsgData UnPackHead Failed, invalid pack,ret=%d,msgdata=%s\n", ret, msgdata);
        throw INetException("invalid pack");
    }
    string extrahead = header.m_extdata;
    if (data_len < header.Size() + header.m_len)
    {
        printf("ProcessMsgData data_len=%lu < sizext=%d,+len=%d\n", data_len, header.Size(), header.m_len);
        return false;
    }
    size_t extlen = header.SizeExt() - header.Size();
    string paramdata;
    paramdata.assign(msgdata + header.SizeExt(), header.m_len - extlen);

    tmprcvbuff.writedSize(header.Size() + header.m_len);

    // put to client rsp queue

    bool bEncryed = false;
    bool bCompressed = false;
    if (header.m_encrypt)
    {
        bEncryed = true;
    }
    if (header.m_compress)
    {
        bCompressed = true;
    }
    m_seqtsMap.erase(header.m_seq);
    // printf("ProcessMsgData success,cmdid=0x%x, seqid=%d,msgtype=%d\n",header.m_cmd,header.m_seq,header.m_msgtype);

    INetImpl::sharedInstance()->SaveRspMsg((EMsgCmdType)header.m_msgtype, header.m_cmd, header.m_seq, extrahead,
                                           paramdata, bEncryed, bCompressed, header.m_cc, header.m_reserved);
    return true;
}
int ProtoTcpConnect::handleWriteEvt()
{
    TScopedLock<RecursiveMutex> tmplock(lock_);
    if (m_outbuff.size() == 0)
    {
        return 0;
    }

    size_t buffsize = 0;
    const char *outbuffer = m_outbuff.getReadableData(buffsize);

    int wlen = TcpSend(m_fd, outbuffer, buffsize);
    printf("TcpSended %d,data, fd=%d , error=%d\n", wlen, m_fd, errno);
    if (wlen > 0)
    {
        m_outbuff.writedSize(wlen);
        return wlen;
    }
    else
    {
        return -1;
    }
}

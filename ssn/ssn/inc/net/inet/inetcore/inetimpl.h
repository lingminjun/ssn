//
//  inetimpl.h
//  inettest
//
//  Created by jay on 11-10-14.
//  Copyright 2011骞�__MyCompanyName__. All rights reserved.
//

#ifndef inettest_inetimpl_h
#define inettest_inetimpl_h

#include <memory>

#include <map>
#include "lock.h"
#include "memfile.h"
#include "safequeue.h"
#include <poll.h>
#include <set>

using namespace std;

enum EMsgCmdType
{
    EMsgCmdType_Req = 0,
    EMsgCmdType_Rsp = 1,
    EMsgCmdType_Notify = 2,
    EMsgCmdType_LoginResult = 253,
    EMsgCmdType_ConnLost = 254,
};

enum EActionRspError
{
    EActionRspError_Success = 0,
    EActionRspError_NetFail = -1,
    EActionRspError_NetConnLost = -2,
    EActionRspError_NetConnFail = -3,
    EActionRspError_Timeout = -4,
    EActionRspError_IoError = -5,
};

enum LoginResultType
{
    LoginResultType_LoginSuccess,
    LoginResultType_LoginFail,
    LoginResultType_ReconnLoginSuccess,
    LoginResultType_Logining,
};

struct SLoginResult
{
    string account;
    string userId;
    string token;
    string imsips;
    string newestVer;
    string nickName;
    string newverUrl;
    string newverDesc;
    string errStr;
    string authUrl;
    long srvTime;
    int errCode;
    LoginResultType resultType; // 0:LoginSuccess  1:LoginFail  2:ReconnLoginSuccess 3:Logining
};
typedef std::shared_ptr<SLoginResult> SLoginResultPtr;

struct SProtoMsg
{
    EMsgCmdType cmdtype;
    bool bEncryed;
    bool bCompressed;
    int errcode;
    int fd;
    uint32_t cmdid;
    uint32_t seqid;
    uint32_t time;
    uint32_t timeoutts;
    string extrahead;
    string data;
    uint16_t cc;
    uint32_t reserved;
    SLoginResultPtr pLoginResult;

    SProtoMsg()
    {
        cmdtype = EMsgCmdType_Req;
        errcode = 0;
        fd = -1;

        cmdid = 0;
    }
};
typedef std::shared_ptr<SProtoMsg> SProtoMsgPtr;

class ProtoTcpConnect
{
  public:
    ProtoTcpConnect(int fd);
    ~ProtoTcpConnect();
    void postData2Server(EMsgCmdType cmdtype, uint32_t seqid, uint32_t ts, const string &data);
    bool handleReadEvt(char *readbuff, size_t buffsize);
    int handleWriteEvt();
    void clearTimeoutSeq();
    void clearTimeoutSeqAndRetry();
    void handleConnClosed();
    void handleConnClosed(int errorCode);
    int getFd()
    {
        return m_fd;
    }

  private:
    bool ProcessMsgData(MemFile &buff);

  private:
    MemFile m_outbuff;
    MemFile m_inbuff;
    RecursiveMutex lock_;
    map<uint32_t, uint32_t> m_seqtsMap;
    int m_fd;
};
typedef std::shared_ptr<ProtoTcpConnect> ProtoTcpConnectPtr;
struct ConnPollFD
{
    ProtoTcpConnectPtr connptr;
    pollfd pfd;
    ConnPollFD()
    {
        memset(&pfd, 0, sizeof(pfd));
        pfd.fd = -1;
    }
};

typedef std::shared_ptr<ConnPollFD> ConnPollFDPtr;
class INetImpl
{
  public:
    static INetImpl *sharedInstance();
    ~INetImpl();
    bool Init(map<string, string> &option);
    bool UnInit();
    void closeFd(int fd);
    void RegisterFd(int fd);
    void UnRegisterFd(int fd);
    void UnRegisterFdNotNotify(int fd);
    void forceClose(int fd);
    void pushBufferedData();
    void RunEvent();
    bool setEvent(int fd, bool bReadEvent, bool bWriteEvent);
    void clearEvent(int fd);

    SProtoMsgPtr GetMsg(int timeoutms);
    void PostMsg(EMsgCmdType cmdtype, uint32_t cmdid, uint32_t seqid, const string &extrahead, const string &paramdata,
                 bool bEncryed, bool bCompressed, uint32_t ts, uint16_t cc, uint16_t reserved = 1);
    void SaveRspMsg(EMsgCmdType cmdtype, uint32_t cmdid, uint32_t seqid, const string &extrahead,
                    const string &paramdata, bool bEncryed, bool bCompressed, uint16_t cc, uint16_t reserved = 1);
    void NotifyConnLost(uint32_t seqid, int i);
    void NotifyNeedReconnect();

  private:
    INetImpl();
    ProtoTcpConnectPtr GetConn();
    void checkTimeoutDeferQ();
    void clearDeferMsgQ();
    void saveCloseFd(int fd);
    void closeTimeoutedFds();

  private:
    int m_pollfd;
    std::map<int, ConnPollFDPtr> fdmap_;
    SafeQueue<SProtoMsgPtr> mMsgQ;
    SafeQueue<SProtoMsgPtr> mDeferMsgQ;
    std::map<int, time_t> mNeedCloseFds;
    RecursiveMutex lock_;
    bool m_brun, m_bInited;
};

#endif


//
//  inet.m
//  inettest
//
//  Created by jay on 11-10-13.
//  Copyright 2011Âπ?__MyCompanyName__. All rights reserved.
//

#include "inet.h"
#include <pthread.h>
#include <string>
#include <map>
#include "lock.h"
#include "../commutils.h"
#include "inetimpl.h"
#include "des.h"
#include "string_tool.h"
#include "../msc_head.h"
#include "../mimsc_pack.h"
#include "../mimsc_cmd.h"
#include "inetexception.h"
#include "../packdata.h"
#include <assert.h>
#include <fcntl.h>
#include <signal.h>
#include <algorithm>

using namespace std;

#define RENEWAL_DEBUG 0

static bool gTryLogin = true;
static bool gRun = true;
static bool g_bLogined = false;
static bool g_ConnLost = true;
static bool g_bLogout = false;
static int g_fd = -1;
static string gInstallUUID = "";
static string gExtraData = "";
static string gLoginUid; //! 改为长id
static string gLAccount;
uint32_t gCurrenAccountBeginSeqId = 0; //当前账号消息SeqId起始值, 该账号所有消息SeqId必须大于该值.
static string gLoginPw;
static string gLoginEncryKey;
static time_t g_LastSendTime;
static time_t g_LastRcvTime = time(0);
static string gLoginSrvHost;
static string gLastIp;
static vector<string> gLastSrvs;
static vector<string> gBackupIms;
static uint16_t gLoginSrvPort;
static bool g_bNeedAllot = true;
static int g_loginFailErrorCode = 0;
static string g_loginFailErrorStr;
static time_t g_SrvTime = 0;
static string gAllotSrv;
static uint8_t gAllotType = 0; // 0:线上  1:daily  2:预发
static string gCliVer;
static string gCheckCode;
static string gAuthCodeUrl;
static int gPwtype = 0; // xianzhen: 0:password, 1:wangxin token 0x80: auth  0x81:taobao ssotoken
static string gNickname;
static string gNewver;
static string gNewverurl;

static string gNewverDesc;
static string gUserId;

static string gOsver;
static string gOstype;
static string gImei;

static pthread_t gtid_loginthread = 0;
static bool gKillIsCalled;
#if RENEWAL_DEBUG
static string gLoginSessionId = "";
#endif

static IMNetAsyncNotifyBaseService *gIMNetNotifyService;
static time_t gStartTime = time(0);

uint32_t g_ClientIp;
string g_LoginToken;
string g_WebMd5Pw;
uint32_t g_lastClientip;
string g_bindid = "";

static bool bUseLastIp;
static bool bAllotSuccess = false;

static RecursiveMutex gLock;

struct SRpcActionResponse
{
    EMsgCmdType cmdtype;
    uint32_t seqid;
    uint32_t cmdid;
    string param;
    time_t acttime;
    uint32_t ts;
    void *callbackobj;
    WaitObjectPtr wait;
    int rspret;
    string rspdata;
    uint32_t appId;
    uint32_t bizId;

    SRpcActionResponse()
    {
        callbackobj = NULL;
        acttime = time(0);
        rspret = 0;
        bizId = 0;
        appId = 0;
    }
};
typedef std::shared_ptr<SRpcActionResponse> SRpcActionResponsePtr;

map<uint32_t, SRpcActionResponsePtr> gWaitCallRspMap;
SafeQueue<SProtoMsgPtr> gMsgRspQ, gNotyfyQ;
SafeQueue<SRpcActionResponsePtr> gDeferMsgQ;

void inetSleep(long sec, long ms)
{
    usleep(sec * 1000000 + ms * 1000);
    // ios下使用select造成高电量消耗.
    // struct timeval tvs;
    // tvs.tv_sec=sec;
    // tvs.tv_usec=ms*1000;
    // select(0,NULL,NULL,NULL,&tvs);
}

void enterThread(const char *s)
{
#ifdef ANDROID_OS_DEBUG
    pid_t pid, tid;

    pid = getpid();
    tid = gettid();
    printf("enter %s pid %u, tid %u\n", s, (unsigned int)pid, (unsigned int)tid);
#endif
}

void exitThread(const char *s)
{
#ifdef ANDROID_OS_DEBUG
    pid_t pid, tid;

    pid = getpid();
    tid = gettid();
    printf("exit %s pid %u, tid %u\n", s, (unsigned int)pid, (unsigned int)tid);
#endif
}

string packExtraHead(uint32_t appId, uint32_t bizId, uint16_t &reserved);
void *unpackExtraHead(string extraHead, uint16_t reserved);
void releaseExtraHeadPtr(void *extraHeadPtr, uint16_t reserved);

// string packExtraHead(uint32_t bizId, uint16_t& reserved){
//   return packExtraHead(IosNet::sharedInstance()->appId, bizId, reserved);
// }

string packExtraHead(uint32_t appId, uint32_t bizId, uint16_t &reserved)
{
    string
    extrahead; //老接口用loginuid（实际就是userid，带cnhhupan等前缀的）作为extrahead，新接口需要添加SScUserInfo类型的extrahead的
    if (0 == bizId)
    {
        extrahead = gLoginUid;
        reserved = 1;
    }
    else
    {
        SScUserInfo extData;
        extData.m_userId = gLoginUid;
        extData.m_fromApp = appId;
        extData.m_bizId = bizId;
        extData.m_notifyAppId = 0; //发送时不需要关注，随意填写，

        CPackData packData;
        packData.ResetOutBuff(extrahead);
        packData << extData;
        reserved = 3;
    }
    return extrahead;
};

//这里会new一个对象，并返回相应指针，需要外部自己去delete
void *unpackExtraHead(string extraHead, uint16_t reserved)
{
    void *retExtraHeadData = NULL;
    switch (reserved)
    {
    case 1:
    {
        retExtraHeadData = (void *)(new string(extraHead));
        break;
    }
    case 3:
    {
        SScUserInfo *extUserInfoData = new SScUserInfo;
        CPackData packData;
        packData.ResetInBuff(extraHead);
        packData >> *extUserInfoData;
        retExtraHeadData = (void *)extUserInfoData;
        break;
    }
    default:
        break;
    }
    return retExtraHeadData;
};

void releaseExtraHeadPtr(void *extraHeadPtr, uint16_t reserved)
{
    switch (reserved)
    {
    case 1:
    {
        delete (string *)extraHeadPtr;
        break;
    }
    case 3:
    {
        delete (SScUserInfo *)extraHeadPtr;
        break;
    }
    default:
        break;
    }
}

static void *clientServiceThrFunc(void *)
{
    printf("enter clientServiceThrFunc");
    enterThread("clientServiceThrFunc");
    pthread_setname_np("clientServiceThrFunc");
    while (gRun)
    {
        SProtoMsgPtr msgptr;
        gNotyfyQ.Get(msgptr);
        if (!msgptr)
            continue;

        //登录回调从登录线程转移到此线程中.
        if (msgptr->cmdtype == EMsgCmdType_LoginResult)
        {
            SLoginResultPtr result = msgptr->pLoginResult;
            switch (result->resultType)
            {
            case LoginResultType_LoginSuccess:
                gIMNetNotifyService->LoginSuccess(result->account, result->userId, result->token, result->imsips,
                                                  result->newestVer, result->srvTime, result->nickName,
                                                  result->newverUrl, result->newverDesc);
                break;
            case LoginResultType_LoginFail:
                gIMNetNotifyService->LoginFail(result->account, result->errCode, result->errStr, result->token,
                                               result->newestVer, result->newverUrl, result->newverDesc,
                                               result->authUrl);
                break;
            case LoginResultType_ReconnLoginSuccess:
                gIMNetNotifyService->ReconnLoginSuccess(result->account);
                break;
            case LoginResultType_Logining:
                gIMNetNotifyService->Logining(result->account);
                break;
            }
            continue;
        }

        if (g_bLogined == false)
        {
            gNotyfyQ.PutFront(msgptr);
            inetSleep(0, 100);
            continue;
        }
        printf("clientServiceThrFunc get one notify,cmdid=0x%x,seqid=%d", msgptr->cmdid, msgptr->seqid);
        string strrspdata;
        {
            TScopedLock<RecursiveMutex> tmplcok(gLock, 'a');
            if (msgptr->bEncryed)
            {
                DesEncrypt deKey;
                deKey.SetKey(gLoginEncryKey);
                strrspdata = deKey.Decrypt(msgptr->data);
            }
            else
            {
                // CImNtfForcedisconnect有可能定义为未加密
                strrspdata = msgptr->data;
            }
            if (msgptr->bCompressed)
            {
                if (false == CPackData::UncompressData2(strrspdata, 0))
                    continue;
            }
        }

        uint32_t cmdid = msgptr->cmdid;
        try
        {
            uint16_t reserved = msgptr->reserved;
            string extraHeadStr = msgptr->extrahead;

            void *extraHeadPtr = unpackExtraHead(extraHeadStr, reserved);
            gIMNetNotifyService->Notify(gLAccount, cmdid, strrspdata, extraHeadPtr, reserved);
            releaseExtraHeadPtr(extraHeadPtr, reserved);
        }
        catch (...)
        {
        }
    }
    exitThread("clientServiceThrFunc");
    return NULL;
}
static void clearTimeoutDeferedMsg()
{
    static time_t lastT = time(0);
    time_t nowt = time(0);
    if (nowt - lastT < 1)
        return;
    TScopedLock<RecursiveMutex> tmplock(gLock, 'b');

    SafeQueue<SRpcActionResponsePtr> tmpQ;

    while (gDeferMsgQ.IsEmpty() == false)
    {
        SRpcActionResponsePtr buffnode;
        gDeferMsgQ.Get(buffnode);

        if (buffnode->acttime + buffnode->ts < nowt)
        {
            // timeouted
            SProtoMsgPtr rspMsgPtr(new SProtoMsg());
            rspMsgPtr->errcode = EActionRspError_Timeout;
            rspMsgPtr->cmdid = buffnode->cmdid;
            rspMsgPtr->cmdtype = buffnode->cmdtype;
            rspMsgPtr->seqid = buffnode->seqid;
            uint16_t reserved = 1;
            string extraHead = packExtraHead(buffnode->appId, buffnode->bizId, reserved);
            rspMsgPtr->extrahead = extraHead;
            rspMsgPtr->reserved = reserved;

            gWaitCallRspMap[buffnode->seqid] = buffnode;
            gMsgRspQ.Put(rspMsgPtr);
        }
        else
        {
            tmpQ.Put(buffnode);
        }
    }
    gDeferMsgQ.Clear();
    while (tmpQ.IsEmpty() == false)
    {
        SRpcActionResponsePtr buffnode;
        tmpQ.Get(buffnode);
        gDeferMsgQ.Put(buffnode);
    }
}
static void *clearTimeoutThrFunc(void *)
{
    printf("enter clearTimeoutThrFunc");
    enterThread("clearTimeoutThrFunc");
    pthread_setname_np("clearTimeoutThrFunc");
    while (gRun)
    {
        inetSleep(2, 0);
        try
        {
            clearTimeoutDeferedMsg();
        }
        catch (...)
        {
        }
    }
    exitThread("clearTimeoutThrFunc");
    return NULL;
}
static void *clientAsyncCallbackThrFunc(void *)
{
    printf("enter clientAsyncCallbackThrFunc");
    enterThread("clientAsyncCallbackThrFunc");
    pthread_setname_np("clientAsyncCallbackThrFunc");
    while (gRun)
    {

        SProtoMsgPtr msgptr;
        gMsgRspQ.Get(msgptr);
        if (!msgptr)
            continue;
        printf("clientAsyncCallbackThrFunc get a msg, seqId:%d\n", msgptr->seqid);
        string strrspdata = msgptr->data;
        uint32_t seqid = msgptr->seqid;
        SRpcActionResponsePtr rsp;
        //	sleep(15);
        {
            TScopedLock<RecursiveMutex> tmplcok(gLock, 'c');
            typeof(gWaitCallRspMap.begin()) itr = gWaitCallRspMap.find(seqid);
            if (itr == gWaitCallRspMap.end())
                continue;
            rsp = itr->second;
            rsp->rspret = msgptr->errcode;
            if ((rsp->cmdid == 0x1000021 || rsp->cmdid == 0x1000022 || rsp->cmdid == 0x1000080) &&
                rsp->rspret == EActionRspError_IoError)
            {
                printf("clientAsyncCallbackThrFunc: IoError, resend protocol package,cmdid=%x, seqid=%d", rsp->cmdid,
                       seqid);
                IosNet::sharedInstance()->deferAsyncMsg(rsp->cmdid, rsp->seqid, rsp->param,
                                                        *(IMNetAsyncCallbackBaseService *)rsp->callbackobj, rsp->ts,
                                                        rsp->appId, rsp->bizId);
                continue;
            }
            if (rsp->rspret == 0)
            {
                if (msgptr->bEncryed)
                {
                    DesEncrypt deKey;
                    deKey.SetKey(gLoginEncryKey);
                    strrspdata = deKey.Decrypt(msgptr->data);
                }
                if (msgptr->bCompressed)
                {
                    bool bret = CPackData::UncompressData2(strrspdata, 0);
                    if (false == bret)
                    {
                        rsp->rspret = -1;
                    }
                }
            }

            if (!rsp->callbackobj)
            {
                if (rsp->wait)
                {
                    rsp->rspdata = strrspdata;
                    rsp->rspret = msgptr->errcode;
                    // while(true){
                    //   struct timeval tvs;
                    //   tvs.tv_sec=1;
                    //   tvs.tv_usec=0;
                    //   select(0,NULL,NULL,NULL,&tvs);
                    // }
                    rsp->wait->Signal();
                    printf("clientAsyncCallbackThrFunc get one SyncResponse, "
                           "Signal,cmdid=0x%x,seqid=%d,rspdatasize=%lu,errcode=%d",
                           msgptr->cmdid, seqid, msgptr->data.size(), msgptr->errcode);
                }
                else
                {
                    TScopedLock<RecursiveMutex> tmplcok(gLock, 'd');
                    gWaitCallRspMap.erase(itr);
                    printf("clientAsyncCallbackThrFunc get one SyncResponse, "
                           "nowait,cmdid=0x%x,seqid=%d,rspdatasize=%lu,errcode=%d",
                           msgptr->cmdid, seqid, msgptr->data.size(), msgptr->errcode);
                }

                continue;
            }

            gWaitCallRspMap.erase(itr);
        }

        uint32_t cmdid = rsp->cmdid;
        printf("clientAsyncCallbackThrFunc get one asyncResponse,cmdid=0x%x,seqid=%d", cmdid, seqid);
        try
        {
            uint16_t reserved = msgptr->reserved;
            string extraHeadStr = msgptr->extrahead;

            void *extraHeadPtr = unpackExtraHead(extraHeadStr, reserved);
            if (rsp->rspret == 0)
            {
                //为了避免串号, 直接设置错误
                if (rsp->seqid < gCurrenAccountBeginSeqId)
                {
                    ((IMNetAsyncCallbackBaseService *)(rsp->callbackobj))
                        ->ResponseFail(cmdid, rsp->param, EActionRspError_Timeout, extraHeadPtr, reserved);
                }
                else
                {
                    ((IMNetAsyncCallbackBaseService *)(rsp->callbackobj))
                        ->ResponseSuccess(cmdid, rsp->param, strrspdata, extraHeadPtr, reserved);
                }
            }
            else
            {
                ((IMNetAsyncCallbackBaseService *)(rsp->callbackobj))
                    ->ResponseFail(cmdid, rsp->param, rsp->rspret, extraHeadPtr, reserved);
            }
            releaseExtraHeadPtr(extraHeadPtr, reserved);
        }
        catch (...)
        {
        }
    }
    exitThread("clientAsyncCallbackThrFunc");
    return NULL;
}

string getIpString(vector<string> &ips)
{
    string ipstring;
    if (ips.size() <= 0)
        return ipstring;

    //去重
    //  sort(ips.begin(), ips.end()); 这个是服务器的任务
    std::vector<string>::iterator it = std::unique(ips.begin(), ips.end());
    ips.resize(std::distance(ips.begin(), it));

    for (std::vector<string>::iterator iter = ips.begin(); iter != ips.end(); iter++)
    {
        ipstring += *iter;
        ipstring += ",";
    }
    return ipstring;
}

vector<string> parseIps(const string &ips)
{
    vector<string> vips;

    if (ips.length() <= 0)
        return vips;

    int p = 0;
    int idx = 0;
    p = ips.find(",", idx);

    while (p > 0 && p < ips.length())
    {
        string server = ips.substr(idx, p - idx);
        int inp = 0;
        if (!server.empty())
        {
            inp = server.find(":", 0);
            if (inp <= 0 || inet_addr(server.substr(0, inp).c_str()) == INADDR_NONE)
                break;
            printf("add ip:%s", server.c_str());
            vips.push_back(server);
            idx = p + 1;
        }
        else
        {
            idx++;
        }
        p = ips.find(",", idx);
    }
    string server = ips.substr(idx, ips.length() - idx);
    int inp = 0;
    if (!server.empty())
    {
        inp = server.find(":", 0);
        if (inp <= 0 || inet_addr(server.substr(0, inp).c_str()) == INADDR_NONE)
            return vips;
        printf("add last ip:%s\n, inp=%d, ip=%s", server.c_str(), inp, server.substr(0, inp).c_str());
        vips.push_back(server);
    }

    return vips;
}

// TODO：以后需要考虑allot固定端口的情况。
static bool LoginAllot()
{
    string alloturl;
    {
        TScopedLock<RecursiveMutex> tmplock(gLock, 'e');
        if (g_bNeedAllot == false && gLastSrvs.size() > 0)
        {
            printf("LoginAllot not access server for bNeedAllot is false");
            return true;
        }
        alloturl = gAllotSrv;
    }
    printf("LoginAllot url:%s", alloturl.c_str());
    // 1: get loginsrvs from allotsrv
    string httpResult;
    int sockfd, ret, i, h;
    struct sockaddr_in servaddr;
    int port = 443;
    char str[1024], buf[4096];
    // socklen_t len;
    fd_set t_set1;
    fd_set mask;
    struct timeval tv;
    port = 443;

    int pos = alloturl.find_first_of(':', 0);
    if (pos != string::npos)
    {
        string p = alloturl.substr(pos + 1, alloturl.length() - pos);
        port = atoi(p.c_str());
        alloturl = alloturl.substr(0, pos);
    }

    //将域名转为ip地址
    struct hostent *host = gethostbyname(alloturl.c_str());

    if (host == NULL)
    {
        printf("allot gethostbyname return NULL.");
        return false;
    }
    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    char *ipstr = (char *)inet_ntoa(*(struct in_addr *)(host->h_addr));

    if (inet_pton(AF_INET, ipstr, &servaddr.sin_addr) <= 0)
    {
        printf("创建网络连接失败,本线程即将终止--inet_pton error!\n");
        return false;
    };

    while (true)
    {
        servaddr.sin_port = htons(port);
        // printf("allot ip:%s, port:%d\n", ipstr, port);

        if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        {
            printf("创建网络连接失败,本线程即将终止---socket error!\n");
            return false;
        };

        // 非阻塞connect
        int flags = fcntl(sockfd, F_GETFL, 0);
        fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

        ret = connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr));
        if (-1 == ret)
        {
            if (errno != EINPROGRESS)
            {
                perror("connect");
                close(sockfd);
                if (port == 443)
                {
                    port = 80;
                    continue;
                }
                return false;
            }
            printf("正在连接...\n");

            FD_ZERO(&mask);
            FD_SET(sockfd, &mask);
            tv.tv_sec = 5;
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
                        printf("has connect");
                    }
                    else
                    {
                        close(sockfd);
                        if (port == 443)
                        {
                            port = 80;
                            continue;
                        }
                        return false;
                    }
                }
                else
                {
                    printf("socket error：%d", error);
                    close(sockfd);
                    if (port == 443)
                    {
                        port = 80;
                        continue;
                    }
                    return false;
                }
            }
            else
            {
                close(sockfd);
                if (port == 443)
                {
                    port = 80;
                    continue;
                }
                return false;
            }
        }

        printf("has connect\n");

        memset(str, 0, sizeof(str));
        // http协议请求字符串，每一行的后面一定要加\n隔开
        sprintf(str, "GET /imlogingw/tcp60login?loginId=%s&ostype=%s&osver=%s&ver=%s HTTP/1.0\n\
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */* \n\
Accept-Language: zh-cn\n\
User-Agent: Mozilla/4.0\n\
Host:%s\n\
Connection: Keep-Alive\n\r\n\r\n",
                gLoginUid.c_str(), gOstype.c_str(), gOsver.c_str(), gCliVer.c_str(), alloturl.c_str());

        ret = write(sockfd, str, strlen(str));
        printf("allot, write socket:%s\n", str);

        if (ret < 0)
        {
            printf("发送失败！错误代码是%d，错误信息是'%s'\n", errno, strerror(errno));
            if (port == 443)
            {
                port = 80;
                continue;
            }
            return false;
        }
        else
        {
            printf("消息发送成功，共发送了%d个字节！\n\n", ret);
        }

        FD_ZERO(&t_set1);
        FD_SET(sockfd, &t_set1);

        while (1)
        {
            //设置超时为3秒，如果3秒还没有反应直接返回
            tv.tv_sec = 3;
            tv.tv_usec = 0;
            h = 0;
            memset(buf, 0, sizeof(buf));
            h = select(sockfd + 1, &t_set1, NULL, NULL, &tv);
            if (h == 0)
            {
                close(sockfd);
                break;
            }
            if (h < 0)
            {
                close(sockfd);
                printf("在读取数据报文时SELECT检测到异常，该异常导致线程终止！\n");
                break;
            };
            if (h > 0)
            {
                memset(buf, 0, sizeof(buf));

                i = read(sockfd, buf, sizeof(buf));

                if (i > 0)
                {
                    httpResult = httpResult + buf;
                }
                else
                {
                    if (httpResult.length() == 0)
                        break;
                    close(sockfd);
                    string httpHead = "\r\n\r\n";
                    int data = httpResult.find(httpHead);
                    httpResult = httpResult.substr(data + httpHead.size(), httpResult.size() - data - httpHead.size());
                    printf("%s", httpResult.c_str());

                    gLastSrvs = parseIps(httpResult);

                    if (gLastSrvs.size() <= 0)
                    {
                        printf("allot, gLastSrvs.size <= 0, allot false.");
                        break;
                    }
                    gBackupIms = gLastSrvs;

                    return true;
                }
            }
        }
        if (port == 443)
        {
            port = 80;
            continue;
        }

        close(sockfd);
        return false;
    }
    return false;
}
static void PushBufferedMsg()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'g');
    INetImpl *pNetImpl = INetImpl::sharedInstance();
    pNetImpl->pushBufferedData();
    time_t nowt = time(0);
    while (gDeferMsgQ.IsEmpty() == false)
    {
        SRpcActionResponsePtr buffnode;
        gDeferMsgQ.Get(buffnode);
        uint32_t cmdid = buffnode->cmdid;

        if (buffnode->ts < nowt - buffnode->acttime)
        {
            // put to timeout
            SProtoMsgPtr rspMsgPtr(new SProtoMsg());
            rspMsgPtr->errcode = EActionRspError_Timeout;
            rspMsgPtr->cmdid = buffnode->cmdid;
            rspMsgPtr->cmdtype = buffnode->cmdtype;
            rspMsgPtr->seqid = buffnode->seqid;

            uint16_t reserved = 1;
            string extraHead = packExtraHead(buffnode->appId, buffnode->bizId, reserved);
            rspMsgPtr->extrahead = extraHead;
            rspMsgPtr->reserved = reserved;

            gWaitCallRspMap[buffnode->seqid] = buffnode;
            gMsgRspQ.Put(rspMsgPtr);
            continue;
        }
        else
        {
            buffnode->ts -= nowt - buffnode->acttime;
        }
        if (buffnode->cmdtype == EMsgCmdType_Req)
        {
            IosNet::sharedInstance()->asyncCall(cmdid, buffnode->seqid, buffnode->param,
                                                *(IMNetAsyncCallbackBaseService *)(buffnode->callbackobj), buffnode->ts,
                                                buffnode->appId, buffnode->bizId);
        }
        else
        {
            IosNet::sharedInstance()->notifyCall(cmdid, buffnode->seqid, buffnode->param);
        }
    }
}
static int LoginToServer(const char *srvhost, uint16_t port, int &fd)
{
    fd = IosNet::sharedInstance()->conntoServer(srvhost, port, 2);
    if (fd < 0)
        return 99;
    INetImpl *pNetImpl = INetImpl::sharedInstance();
    string cliVer, passwd;
    {

        TScopedLock<RecursiveMutex> tmplock(gLock, 'h');
        if (gTryLogin == false)
        {
            INetImpl::sharedInstance()->UnRegisterFd(fd);
            return -1;
        }

        pNetImpl->RegisterFd(fd);
        g_fd = fd;

        cliVer = gCliVer;
        passwd = gLoginPw;
    }

// renewal
// TODO: online status.
#if RENEWAL_DEBUG
    if (!gLoginSessionId.empty() && !gUserId.empty())
    {
        if (IosNet::sharedInstance()->renewal(gUserId, gLoginSessionId))
        {
            return 0;
        }
        else
        {
            printf("renewal return 0, begin normal login,not close socket.");
            //        pNetImpl->UnRegisterFd(fd);
            //        return 1;
        }
    }
    printf("no renewal.");
#endif

    {
        TScopedLock<RecursiveMutex> tmplock(gLock, 'i');
        gLoginEncryKey = "";
    }

    uint32_t cmdid = IM_REQ_CHECKVERSION;
    string paramdata;

    CImReqCheckversion chkVer;
    chkVer.SetVersion(cliVer);
    chkVer.PackData(paramdata);

    // send checkversion
    string srvdeskey;
    try
    {
        printf("sending CheckVersion ");
        string strrsp = IosNet::sharedInstance()->syncCall(cmdid, paramdata, 5);
        printf("send CheckVersion Rsp");
        TScopedLock<RecursiveMutex> tmplock(gLock, 'j');
        CImRspCheckversion rspChkVer;
        PACKRETCODE pkRet = rspChkVer.UnpackData(strrsp);
        if (pkRet != PACK_RIGHT || 0 != rspChkVer.GetRetcode())
        {
            g_loginFailErrorCode = rspChkVer.GetRetcode();
            printf("send CheckVersion Rsp Failed, ret=%d,pkret=%d", g_loginFailErrorCode, pkRet);
            return -1;
        }
        gLoginEncryKey = rspChkVer.GetPubkey();
        srvdeskey = gLoginEncryKey;
    }
    catch (...)
    {
        printf("send CheckVersion Failed with exception");
        pNetImpl->UnRegisterFd(fd);
        return 1;
    }

    // send login
    CImReqLogin loginReq;
    loginReq.SetTokenFlag(gPwtype);
    loginReq.SetVersion(cliVer);
    loginReq.SetPassword(passwd);
    if (IosNet::sharedInstance()->getCheckCode().length() != 0)
    {
        loginReq.SetAuthcode(IosNet::sharedInstance()->getCheckCode());
    }
    if (IosNet::sharedInstance()->getAuthCodeUrl().length() != 0)
    {
        loginReq.SetAuthcodeurl(IosNet::sharedInstance()->getAuthCodeUrl());
    }
    loginReq.SetLanguage(0);
    loginReq.SetDevver(gOsver);
    loginReq.SetDevtype((uint8_t)IosNet::sharedInstance()->devtype);
    loginReq.SetDeviceid(gInstallUUID);
    loginReq.SetAppId((uint8_t)IosNet::sharedInstance()->appId);
    loginReq.SetExtradata(gExtraData);

    loginReq.PackData(paramdata);
    cmdid = IM_REQ_LOGIN;

    uint32_t clientIp;
    uint32_t serverTime;
    string pwtoken;
    string webmd5pw;
    uint32_t lastClientip;
    string bindid;
    string userid, nickname, newver;
    string newverurl, newverDesc;
    string loginSessionId;
    try
    {
        printf("begin send LoginPw");
        string strrsp = IosNet::sharedInstance()->syncCall(cmdid, paramdata, 5);
        printf("after send LoginPw");
        CImRspLogin rspLogin;
        PACKRETCODE pkRet = rspLogin.UnpackData(strrsp);
        if (pkRet != PACK_RIGHT)
        {
            printf("after send LoginPw,failed with unpack,ret=%d", pkRet);
            return 1;
        }

        if (rspLogin.GetRetcode() != 0)
        {
            TScopedLock<RecursiveMutex> tmplock(gLock, 'k');

            g_loginFailErrorCode = rspLogin.GetRetcode();
            g_loginFailErrorStr = rspLogin.GetRemark();
            gAuthCodeUrl = rspLogin.GetAuthcodeurl();
            g_LoginToken = rspLogin.GetPwtoken();
            gUserId = rspLogin.GetUserId();
            gNewver = rspLogin.GetNewVersion();
            ;
            gNewverurl = rspLogin.GetNewVersionUrl();
            gNewverDesc = rspLogin.GetVersionInfo();

#if RENEWAL_DEBUG
            gLoginSessionId = "";
#endif

            //            if( g_loginFailErrorCode == LOGON_FAIL_NO_TB_PHONE )
            //            {
            //                pwtoken=rspLogin.GetPwtoken();
            //                 g_LoginToken=pwtoken;
            //            }
            //!密码就别打印了 ,passwd.c_str()
            printf("after send LoginPw,failed with errcode=%d,pwtype=%d,passwd=******", g_loginFailErrorCode, gPwtype);
            return -1;
        }
        userid = rspLogin.GetUserId();
        nickname = rspLogin.GetNickName();
        newver = rspLogin.GetNewVersion();
        newverurl = rspLogin.GetNewVersionUrl();
        newverDesc = rspLogin.GetVersionInfo();

        srvdeskey = rspLogin.GetWorkKey();
        clientIp = rspLogin.GetClientIp();
        serverTime = rspLogin.GetServerTime();
        pwtoken = rspLogin.GetPwtoken();
        webmd5pw = rspLogin.GetWebmd5pw();
        lastClientip = rspLogin.GetLastClientip();
        bindid = rspLogin.GetBindid();
#if RENEWAL_DEBUG
        loginSessionId = rspLogin.GetSessionId();
#endif

        // xianzhen: 淘宝ssotoken登陆成功后，需及时将pwdtype换成token登陆类型
        //将登陆的token切换成旺信的token.
        gPwtype = 0x1;      //之后重登都采用旺信token登陆
        gLoginPw = pwtoken; //保存旺信token
        gExtraData = "";    //清空extraData,这个字段保存了之前登陆用的旺信ssotoken

        // uint8_t *pAddr = (uint8_t *)&clientIp;
        // printf("clientIp=%d.%d.%d.%d",pAddr[3],pAddr[2],pAddr[1],pAddr[0]);
    }
    catch (...)
    {
        printf("send LoginPw Failed with exception");
        pNetImpl->UnRegisterFd(fd);
        return 1;
    }

    TScopedLock<RecursiveMutex> tmplock(gLock, 'l');
    g_SrvTime = serverTime;
    g_ClientIp = clientIp;
    g_LoginToken = pwtoken;
    g_WebMd5Pw = webmd5pw;
    g_lastClientip = lastClientip;
    g_bindid = bindid;
    gLoginEncryKey = srvdeskey;
    gLoginSrvHost = srvhost;
    gLoginSrvPort = port;
    g_bLogined = true;
    gNickname = nickname;
    gNewver = newver;
    gNewverurl = newverurl;
    gNewverDesc = newverDesc;
    gUserId = userid;
#if RENEWAL_DEBUG
    gLoginSessionId = loginSessionId;
    if (!gLoginSessionId.empty())
    {
        printf("get a gLoginSessionId.");
    }
    else
    {
        printf("get a null gLoginSessionId.");
    }
#endif

    PushBufferedMsg();

    return 0;
}
static int LoginAuthPw()
{
    printf("try LoginAuthPw, bAllotSuccess=%d", bAllotSuccess);
    if (g_fd >= 0)
        INetImpl::sharedInstance()->UnRegisterFd(g_fd);
    g_fd = -1;

    // post login request to accesslogin server
    vector<string> loginsrvs = IosNet::sharedInstance()->getLastloginsrvs();
    //追加一个默认登陆地址，当allot失败或其他地址失败时，追加这个默认地址
    if (!bUseLastIp && !bAllotSuccess && gAllotType == 0)
    {
        APPID appid = IosNet::sharedInstance()->appId;
        printf("add default ims ip, appId=%d\n", appid);
        loginsrvs = gBackupIms;
        if (appid == APPID_WANGXIN)
        {
            loginsrvs.push_back("ims.im.hupan.com:443");
            loginsrvs.push_back("ims.im.hupan.com:80");
        }
        else
        {
            loginsrvs.push_back("sdkims.wangxin.taobao.com:443");
            loginsrvs.push_back("sdkims.wangxin.taobao.com:80");
        }
    }

    int size = loginsrvs.size();
    printf("loginsrvs size:%d", size);
    for (int i = 0; i < loginsrvs.size(); i++)
    {
        if (gTryLogin == false)
            break;
        string nssrvhost = loginsrvs[i];
        int p = nssrvhost.find(":");
        if (p < 0)
            continue;
        string host = nssrvhost.substr(0, p);
        string portstr = nssrvhost.substr(p + 1, nssrvhost.length() - (p + 1));

        const char *srvhost = host.c_str();
        uint16_t port = (uint16_t)atoi(portstr.c_str());

        int fd = -1;

        printf("login to ip %s:%d", srvhost, port);
        int iret = LoginToServer(srvhost, port, fd);

        //连接未成功
        if (iret == 99)
        {
            //重试下一个地址,无需移除无效地址，在成功后里有处理
            if (i < size)
            {
                continue;
            }
            // loginsrvs中的地址全部非法
            //清空gLastSrvs
            bUseLastIp = false;
            gLastSrvs.clear();
            return iret;
        }

        //其他错误需通知应用处理
        if (iret < 0)
        {
            return iret;
        }

        if (0 == iret)
        {
            g_fd = fd;
            gLastIp = nssrvhost;
            if (i != 0)
            {
                TScopedLock<RecursiveMutex> tmplock(gLock, 'm');
                vector<string> tSrvs;
                for (int j = i; j < loginsrvs.size(); j++)
                {
                    tSrvs.push_back(loginsrvs[j]);
                }
                gLastSrvs = tSrvs;
            }
            return 0;
        }
    }
    g_bNeedAllot = true;
    return 1;
}
static bool Login(int &beginstep)
{
    g_bLogined = false;
    switch (beginstep)
    {
    case 1:
    {
        bAllotSuccess = LoginAllot(); // allot
        beginstep = 2;
    }
    case 2:
    {
        int iret = LoginAuthPw(); // passcheck

        if (0 > iret)
        {
            beginstep = 10000;
            return false;
            break;
        }
        else if (0 < iret)
        {
            beginstep = 1;
            if (bUseLastIp)
            {
                bUseLastIp = false;
                gLastSrvs.clear();
            }
            break;
        }
        else
            return true;
    }
    default:
        break;
    }
    return false;
}

static void clearTimeoutWaitRsp()
{
}

// class Test{
// public:
//   Test(char c){
//     mChar = c;
//     printf("Test constructor, %c", mChar);
//   }
//   ~Test(){
//     printf("Test destructor, %c", mChar);
//   }
// private:
//   char mChar;
// };

static void *loginThreadFunc(void *parg)
{
    pthread_setname_np("loginThreadFunc");

    gKillIsCalled = false;
#ifndef ANDROID_OS_DEBUG
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
    pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
#endif
    enterThread("loginThreadFunc");
    bool reconnect = false;
    if (parg)
    {
        bool *breconn = (bool *)parg;
        reconnect = *breconn;
        delete breconn;
    }
    int failstep = 1;
    bool bLoginOk = false;
    int failcount = 0;
    {
        time_t nowt = time(0);
        TScopedLock<RecursiveMutex> tmplock(gLock, 'n');
        if (gLastSrvs.size() > 0 && (nowt - gStartTime < 86400))
            failstep = 2;
    }
    // static RecursiveMutex slock;
    // {
    //     TScopedLock<RecursiveMutex> tmplock(slock, '%');
    // 	printf("deadlock test 1");
    // 	sleep(16);
    // }
    //登陆过程，含重试
    while (true)
    {
        if (gKillIsCalled)
        {
            return NULL;
        }
        //        gIMNetNotifyService->Logining(gLAccount);
        {
            SProtoMsgPtr rspMsgPtr(new SProtoMsg());
            rspMsgPtr->cmdtype = EMsgCmdType_LoginResult;
            SLoginResultPtr result(new SLoginResult());
            result->resultType = LoginResultType_Logining;
            result->account = gLAccount;
            rspMsgPtr->pLoginResult = result;

            gNotyfyQ.Put(rspMsgPtr);
        }

        {
            TScopedLock<RecursiveMutex> tmplock(gLock, 'o');
            if (gRun == false || g_bLogout)
            {
                exitThread("loginThreadFunc");
                gtid_loginthread = 0;
                return NULL;
            }
        }
        printf("Before Login");
        // time_t t1=time(0);
        bLoginOk = Login(failstep);
        //        time_t t2=time(0);
        if (bLoginOk)
        {
            failcount = 0;
            printf("After Login Success");
            break;
        }

        //登陆除IO错误外，其他错误需要上报APP处理
        if (failstep > 10)
        {
            {
                TScopedLock<RecursiveMutex> tmplock(gLock, 'p');
                if (g_fd >= 0)
                {
                    INetImpl::sharedInstance()->UnRegisterFd(g_fd);
                    g_fd = -1;
                }
            }
            printf("login with failed");
            //            gIMNetNotifyService->LoginFail(gLAccount,
            //            g_loginFailErrorCode,g_loginFailErrorStr,g_LoginToken,gNewver,gNewverurl,gNewverDesc,gAuthCodeUrl);
            {
                SProtoMsgPtr rspMsgPtr(new SProtoMsg());
                rspMsgPtr->cmdtype = EMsgCmdType_LoginResult;
                SLoginResultPtr result(new SLoginResult());
                result->resultType = LoginResultType_LoginFail;
                result->account = gLAccount;
                result->errCode = g_loginFailErrorCode;
                result->errStr = g_loginFailErrorStr;
                result->token = g_LoginToken;
                result->newestVer = gNewver;
                result->newverUrl = gNewverurl;
                result->newverDesc = gNewverDesc;
                result->authUrl = gAuthCodeUrl;
                rspMsgPtr->pLoginResult = result;

                gNotyfyQ.Put(rspMsgPtr);
            }
            exitThread("loginThreadFunc");
            gtid_loginthread = 0;
            return NULL;
        }
        //        time_t difft=t2-t1;
        static int FAILCOUNT = 10; //第一步骤次数
        static int JUMP1 = 10;     //第一步骤时间系数
        static int JUMP2 = 60;     //第二步骤时间系数
        printf("loginThreadFunc appId = %d\n", IosNet::sharedInstance()->appId);
        if (IosNet::sharedInstance()->appId != 2)
        { // sdk登陆时，调整间隔时间.
            FAILCOUNT = 5;
            JUMP2 = 120;
        }

        int sec = 0;
        if (failcount++ < FAILCOUNT)
        {
            sec = JUMP1;
        }
        else
        {
            sec = JUMP2;
        }

        printf("sleep %d seconds.\n", sec);
        for (int i = 1; i < sec; i++)
        {
            inetSleep(1, 0);
            if (gKillIsCalled)
            {
                return NULL;
            }
        }
    }
    printf("Finished Login");
    g_bLogined = true;
    g_bNeedAllot = true;

    if (false == reconnect)
    {
        TScopedLock<RecursiveMutex> tmplock(gLock, 'q');
        IosNet *pNet = IosNet::sharedInstance();
        //        gIMNetNotifyService->LoginSuccess(gLAccount,pNet->getUserId(),g_LoginToken,gLastSrvs,gNewver,g_SrvTime,gNickname,gNewverurl,gNewverDesc);
        SProtoMsgPtr rspMsgPtr(new SProtoMsg());
        rspMsgPtr->cmdtype = EMsgCmdType_LoginResult;
        SLoginResultPtr result(new SLoginResult());
        result->resultType = LoginResultType_LoginSuccess;
        result->account = gLAccount;
        result->userId = pNet->getUserId();
        gLoginUid = pNet->getUserId();
        result->token = g_LoginToken;
        result->imsips = gLastIp + "," + getIpString(gBackupIms);
        result->newestVer = gNewver;
        result->srvTime = g_SrvTime;
        result->nickName = gNickname;
        result->newverUrl = gNewverurl;
        result->newverDesc = gNewverDesc;

        rspMsgPtr->pLoginResult = result;

        gNotyfyQ.Put(rspMsgPtr);
    }
    else
    {
        //        gIMNetNotifyService->ReconnLoginSuccess(gLAccount);
        SProtoMsgPtr rspMsgPtr(new SProtoMsg());
        rspMsgPtr->cmdtype = EMsgCmdType_LoginResult;
        SLoginResultPtr result(new SLoginResult());
        result->resultType = LoginResultType_ReconnLoginSuccess;
        result->account = gLAccount;
        rspMsgPtr->pLoginResult = result;

        gNotyfyQ.Put(rspMsgPtr);
    }

    g_ConnLost = false;

    INetImpl *pNetImpl = INetImpl::sharedInstance();

    inetSleep(0, 1000);

    //心跳包循环
    while (true)
    {
        if (gKillIsCalled)
        {
            return NULL;
        }
        {
            TScopedLock<RecursiveMutex> tmplock(gLock, 'r');
            if (gRun == false || g_bLogout)
            {
                printf("HealthCheck THread Exit with gRun==false or Logouted");
                exitThread("loginThreadFunc");
                gtid_loginthread = 0;
                return NULL;
            }
            if (g_ConnLost)
                break;
        }

        time_t nowt = time(0);
        IosNet::sharedInstance()->doHealthCheck();
        inetSleep(0, 1000);

        nowt = time(0);
        if (nowt - g_LastRcvTime > 145) // wujun:大于2*60+25秒，则重登
        {
            // wujun:再给次机会，检查socket连接是否是活着的.
            IosNet::sharedInstance()->doHealthCheck();
            for (int i = 0; i < 10; i++)
            {
                inetSleep(1, 0);
                if (gKillIsCalled)
                {
                    return NULL;
                }
            }
            //仍然没有收到有效数据，果断重登.
            nowt = time(0);
            if (nowt - g_LastRcvTime > 145)
            {
                printf("HealthCheck Timeouted,maybe network is down already");
                printf("nowt:%ld, g_LastRcvTime:%ld", nowt, g_LastRcvTime);
                pNetImpl->UnRegisterFd(g_fd);
                g_fd = -1;
                g_bNeedAllot = false;
                break;
            }
            else
            {
                printf("try again sccussefully. g_LastRcvTime:%ld", g_LastRcvTime);
            }
        }
    }

    if (gRun && g_bLogout == false)
    {
        // need relogin
        printf("connect with server failed, try restartlogin again");
        IosNet::sharedInstance()->restartLogin(true);
        exitThread("loginThreadFunc");
        // gtid_loginthread = 0; //不能设置
        return NULL;
    }
    exitThread("loginThreadFunc");
    gtid_loginthread = 0;
    return NULL;
}

static void *processCmdRspThrFunc(void *)
{
    enterThread("processCmdRspThrFunc");
    pthread_setname_np("processCmdRspThrFunc");
    INetImpl *pNetImpl = INetImpl::sharedInstance();

    bool bKickOffed = false;
    while (gRun)
    {

        time_t nowt = time(0);

        SProtoMsgPtr rspMsg = pNetImpl->GetMsg(1000);
        if (!rspMsg)
            continue;

        printf("INetImpl::GetMsg, seqid=%d,cmdid=%d,errcode=%d,msgtype=%d", rspMsg->seqid, rspMsg->cmdid,
               rspMsg->errcode, rspMsg->cmdtype);

        if (rspMsg->errcode == 0)
        {
            g_LastRcvTime = nowt;
        }

        uint32_t cmdid = rspMsg->cmdid;
        if (cmdid == IM_NTF_FORCEDISCONNECT)
        { // jay fix kickoff but relogin again
            rspMsg->cmdtype = EMsgCmdType_Notify;
            string strrspdata = rspMsg->data;
            {
                TScopedLock<RecursiveMutex> tmplcok(gLock, 's');
                if (rspMsg->bEncryed)
                {
                    DesEncrypt deKey;
                    deKey.SetKey(gLoginEncryKey);
                    strrspdata = deKey.Decrypt(rspMsg->data);
                }
                if (rspMsg->bCompressed)
                {
                    if (false == CPackData::UncompressData2(strrspdata, 0))
                        continue;
                }
                CImNtfForcedisconnect forceDisNtf;
                PACKRETCODE pkRet = forceDisNtf.UnpackData(strrspdata);
                if (pkRet != PACK_RIGHT)
                    continue;
                // avoid self kickoff self
                if ((!forceDisNtf.GetUuid().empty()) && gInstallUUID == forceDisNtf.GetUuid())
                    continue;
            }
            gNotyfyQ.Put(rspMsg);
            bKickOffed = true;
            //[[IosNet sharedInstance] logout];
            g_bLogout = true;
            continue;
        }
        if ((cmdid >> 16) & 0x02)
        {
            rspMsg->cmdtype = EMsgCmdType_Notify;
        }
        if (EMsgCmdType_Notify == rspMsg->cmdtype) // || EMsgCmdType_Req==rspMsg->cmdtype)
        {
            bKickOffed = false;
            gNotyfyQ.Put(rspMsg);
        }
        else if (EMsgCmdType_Rsp == rspMsg->cmdtype)
        {
            bKickOffed = false;
            gMsgRspQ.Put(rspMsg);
        }
        else if (EMsgCmdType_ConnLost == rspMsg->cmdtype)
        {
            if (bKickOffed)
                continue;
            TScopedLock<RecursiveMutex> tmplock(gLock, 't');
            g_ConnLost = true;
            pNetImpl->UnRegisterFd(g_fd);
            g_fd = -1;

            g_bNeedAllot = false;
        }
        else
        {
            bKickOffed = false;
            gMsgRspQ.Put(rspMsg);
        }
    }
    exitThread("processCmdRspThrFunc");
    return NULL;
}
IosNet::IosNet()
{
    this->healthcheckperiod = 2 * 60; // 2分钟
}

IosNet::~IosNet()
{
}
IosNet *IosNet::sharedInstance()
{
    static IosNet s_ins;
    return &s_ins;
}
uint32_t IosNet::getNextSeqId()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'u');
    static uint32_t g_seqid = 0;
    g_seqid++;
    //超过最大值
    if (g_seqid == 0)
    {
        gCurrenAccountBeginSeqId = 0;
    }
    return g_seqid;
}
void IosNet::setDevtype(EDEVTYPE type)
{
    devtype = type;
}

void IosNet::setAppId(APPID idValue)
{
    appId = idValue;
}

void IosNet::setOsver(const string &osver)
{
    gOsver = osver;
}

void IosNet::setOstype(const string &ostype)
{
    gOstype = ostype;
}

void IosNet::setAllotSrv(const string &alloturl)
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'v');
    gAllotSrv = alloturl;
}

void IosNet::setAllotSrv(const string &alloturl, uint8_t allotType)
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'v');
    gAllotSrv = alloturl;
    gAllotType = allotType;
}

void IosNet::setIMNetAsyncNotifyService(IMNetAsyncNotifyBaseService *netService)
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'w');
    if (gIMNetNotifyService != NULL)
        return;
    gIMNetNotifyService = netService;
}
void IosNet::setCliVersion(const string &ver)
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'x');
    gCliVer = ver;
}
string IosNet::getUserId()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'y');
    return gUserId;
}
string IosNet::getLoginUid()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'z');
    return gLoginUid;
}
string IosNet::getLAccount()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'z');
    return gLAccount;
}
string IosNet::getCheckCode()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, '0');
    return gCheckCode;
}
string IosNet::getToken()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, '1');
    return g_LoginToken;
}

string IosNet::getAuthCodeUrl()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, '2');
    return gAuthCodeUrl;
}
string IosNet::getNickname()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, '3');
    return gNickname;
}
string IosNet::getNewver()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, '4');
    return gNewver;
}
string IosNet::getNewverurl()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, '5');
    return gNewverurl;
    //! 给多分配几个字节防止它读人过多
    //	int maxLen = gNewverurl.length() + 4;
    //	char * utf8_buff = (char*)malloc(maxLen);
    //	memset(utf8_buff, 0, maxLen);
    //	memcpy(utf8_buff, gNewverurl.c_str(), gNewverurl.length());
    //
    //    NSString *ret = [NSString stringWithUTF8String:utf8_buff];
    //	if(ret == nil)
    //	{
    //		ret = [NSString stringWithString:@"??????"];
    //	}
    //
    //    free(utf8_buff);
    //
    //	return ret;
}
string IosNet::getNewverDesc()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, '6');
    return gNewverDesc;
}
vector<string> IosNet::getLastloginsrvs()
{
    TScopedLock<RecursiveMutex> tmplock(gLock, '7');
    return gLastSrvs;
}
int IosNet::getPwType()
{
    return gPwtype;
}

#ifdef ANDROID_OS_DEBUG
void alrm_signal(int signo)
{
    if (signo != SIGALRM)
    {
        printf("unexpect signal %d/n", signo);
        exit(1);
    }

    printf("/nSIGALRM has come. alrm_signal will kill thread");

    exitThread("loginThreadFunc");

    // g_bLoginThreadStarted = false;
    pthread_exit(0);

    printf("exit 0");
    return;
}

void setActionHandler()
{
    int rc;
    struct sigaction action;
    memset(&action, 0, sizeof(action));
    sigemptyset(&action.sa_mask);
    action.sa_flags = 0;
    action.sa_handler = alrm_signal;
    rc = sigaction(SIGALRM, &action, NULL);
    if (rc)
    {
        printf("sigaction error/n");
        exit(1);
    }
}
#endif

bool IosNet::initNet(uint16_t clientThreadNum)
{
    map<string, string> option;
    INetImpl::sharedInstance()->Init(option);

    // if(nil==alloturl || nil==uid ||nil == passwd || nil==pwtype )
    //     return false;
    gStartTime = time(0);
    if (clientThreadNum > 8)
        clientThreadNum = 8;
    if (0 == clientThreadNum)
        clientThreadNum = 1;
    pthread_t tid;
    for (uint16_t i = 0; i < clientThreadNum; i++)
    {

        pthread_create(&tid, NULL, clientServiceThrFunc, NULL);
        pthread_create(&tid, NULL, clientAsyncCallbackThrFunc, NULL);
        pthread_create(&tid, NULL, processCmdRspThrFunc, NULL);
    }
    pthread_create(&tid, NULL, clearTimeoutThrFunc, NULL);

#ifdef ANDROID_OS_DEBUG
    setActionHandler();
#endif

    return true;
}

void IosNet::startLoginWithLoginId(const string &loginId, const string &passwd, int pwtype, vector<string> &lastSrvs,
                                   const string &checkCode, const string &authCodeUrl, const string &uuid)
{
    startLoginWithLoginId(loginId, loginId, passwd, pwtype, lastSrvs, checkCode, authCodeUrl, uuid, "",
                          IosNet::sharedInstance()->appId);
}

void IosNet::startLoginWithLoginId(const string &lAccount, const string &loginId, const string &passwd, int pwtype,
                                   vector<string> &lastSrvs, const string &checkCode, const string &authCodeUrl,
                                   const string &uuid, const string &extraData, APPID appId)
{
    printf("startLogin, loginId=%s, checkcode=%s, appId=%d\n", loginId.c_str(), checkCode.c_str(), appId);
    {
        TScopedLock<RecursiveMutex> tmplock(gLock, '8');
        IosNet::sharedInstance()->setAppId(appId);
        //账号切换之后, 重置当前SeqId, 并清除掉未处理的通知, 避免串号.
        if (gLAccount.compare(lAccount) != 0)
        {
            gCurrenAccountBeginSeqId = getNextSeqId();
            gNotyfyQ.Clear();
        }

        gLAccount = lAccount;
        gExtraData = extraData;
        gTryLogin = true;
        g_bNeedAllot = true;
        gInstallUUID = uuid;
        gLoginUid = loginId;
        gLoginPw = passwd;
        gPwtype = pwtype;
        gBackupIms = lastSrvs;
        gLastSrvs.clear();
        gLastSrvs = lastSrvs;

        if (gLastSrvs.size() > 0)
        {
            bUseLastIp = true;
            printf("lastIp: %s", lastSrvs[0].c_str());
        }
        gCheckCode = "";
        gAuthCodeUrl = "";
        if (checkCode.length() != 0)
        {
            gCheckCode = checkCode;
        }
        if (authCodeUrl.length() != 0)
        {
            gAuthCodeUrl = authCodeUrl;
        }
        g_bLogout = false;
    }
    if (gtid_loginthread != 0)
    {
        void *retval;
        inetSleep(0, 100);

        if (gtid_loginthread != 0 && pthread_kill(gtid_loginthread, 0) == 0)
        {
            gKillIsCalled = true;
#ifdef ANDROID_OS_DEBUG
            pthread_kill(gtid_loginthread, SIGALRM);
#else
            pthread_cancel(gtid_loginthread);
#endif
            pthread_join(gtid_loginthread, &retval);
            gtid_loginthread = 0;
        }
    }

    printf("start loginThreadFunc ....... from login");
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    pthread_create(&gtid_loginthread, &attr, loginThreadFunc, NULL);
    pthread_attr_destroy(&attr);
}

#if RENEWAL_DEBUG
bool IosNet::renewal(const string &lid, const string &sessionId)
{
    CImReqRenewal req(lid);
    string paramdata;
    try
    {
        printf("begin send renewal ...");
        uint32_t cmdid = IM_REQ_RENEWAL;
        req.PackData(paramdata);
        printf("sessionid: %s", sessionId.c_str());
        string strrsp = IosNet::sharedInstance()->syncCall(cmdid, paramdata, sessionId, 5);
        printf("after send renewal");
        CImRspRenewal rsp;
        PACKRETCODE pkRet = rsp.UnpackData(strrsp);

        if (pkRet != PACK_RIGHT)
        {
            printf("after send renewal,failed with unpack,ret=%d", pkRet);
            return false;
        }
        else if (rsp.GetRetcode() == 0)
        {
            printf("renewal ok.");
            return true;
        }
        {
            TScopedLock<RecursiveMutex> tmplock(gLock, '~');
            gLoginSessionId = "";
        }
        printf("renewal return %d", rsp.GetRetcode());
    }
    catch (...)
    {
        printf("send renewal Failed with exception");
        return false;
    }

    return false;
}
#endif

void IosNet::restartLogin(bool self)
{
    printf("restartLogin, self=%d， gtid:%p", self, gtid_loginthread);
    {
        TScopedLock<RecursiveMutex> tmplock(gLock, '9');
        gTryLogin = true;
        g_bLogout = false;
    }
    if (gtid_loginthread != 0 && !self)
    {
        void *retval;
        inetSleep(0, 100);
        if (gtid_loginthread != 0 && pthread_kill(gtid_loginthread, 0) == 0)
        {
            gKillIsCalled = true;
#ifdef ANDROID_OS_DEBUG
            pthread_kill(gtid_loginthread, SIGALRM);
#else
            pthread_cancel(gtid_loginthread);
#endif
            pthread_join(gtid_loginthread, &retval);
            gtid_loginthread = 0;
        }
    }

    bool *brestart = new bool();
    *brestart = true;
    printf("start loginThreadFunc ....... from restarlogin");
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    pthread_create(&gtid_loginthread, &attr, loginThreadFunc, brestart);
    pthread_attr_destroy(&attr);
}

void IosNet::relogin(int state)
{
    restartLogin(false);
}

void IosNet::logout(int isCancle)
{
    {
        TScopedLock<RecursiveMutex> tmplock(gLock, 'A');
        g_bLogout = true;
#if RENEWAL_DEBUG
        // isCancle == 1, 用户主动logout, 清空快速登录sessionid.
        if (isCancle != 0)
        {
            gLoginSessionId = "";
        }
#endif
        if (gLoginUid.empty())
            return;
        uint32_t cmdid = IM_REQ_LOGOFF;
        CImReqLogoff logoffReq;

        string struid = gLoginUid;

        logoffReq.SetUid(struid);
        // 1代表注销
        // 0表示home
        logoffReq.SetIscancle(isCancle);
        string param;
        logoffReq.PackData(param);
        notifyCall(cmdid, param);

        gNotyfyQ.Clear();
        printf("logouted");
    }
    inetSleep(0, 300);

    INetImpl::sharedInstance()->UnRegisterFd(g_fd);
    g_fd = -1;
    inetSleep(0, 200);

    if (gtid_loginthread != 0)
    {
        void *retval;
        inetSleep(0, 100);
        if (gtid_loginthread != 0 && pthread_kill(gtid_loginthread, 0) == 0)
        {
            gKillIsCalled = true;
#ifdef ANDROID_OS_DEBUG
            pthread_kill(gtid_loginthread, SIGALRM);
#else
            pthread_cancel(gtid_loginthread);
#endif
            pthread_join(gtid_loginthread, &retval);
            printf("exit code:%d", retval);
            gtid_loginthread = 0;
        }
    }
}
void IosNet::enterBackLogout()
{
    {
        TScopedLock<RecursiveMutex> tmplock(gLock, 'B');
        g_bLogout = true;
        if (gLoginUid.empty())
            return;
        uint32_t cmdid = IM_REQ_LOGOFF;
        CImReqLogoff logoffReq;

        string struid = gLoginUid;

        logoffReq.SetUid(struid);
        string param;
        logoffReq.PackData(param);

        notifyCall(cmdid, param);
        printf("logouted");
    }

    inetSleep(0, 200);
}
void IosNet::doHealthCheck()
{
    time_t nowt = time(0);
    if (nowt - healthcheckperiod < g_LastSendTime)
        return;
    // TODO:
    uint32_t cmdid = IM_HELTH_CHECK;
    CImHelthCheck healthCk;

    string param;
    healthCk.PackData(param);

    try
    {
        notifyCall(cmdid, param);
        printf("IosNet::doHealthCheck()");
        return;
    }
    catch (...)
    {
        INetImpl::sharedInstance()->UnRegisterFd(g_fd);
        g_fd = -1;
    }
}
void IosNet::stop()
{
    gTryLogin = false;
    gRun = false;
    inetSleep(0, 300);
}

bool inet_connect(int sockfd, struct sockaddr *address, socklen_t address_len, int timeout)
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
            perror("connect");
            return false;
        }
        printf("正在连接ims...\n");

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
                    printf("has connect");
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                printf("socket error：%d", error);
                return false;
            }
        }
        else
        {
            return false;
        }
    }
    printf("has connect\n");
    return true;
}

int IosNet::conntoServer(const char *srvhost, uint16_t port, uint32_t timeoutseconds)
{
    time_t t1 = time(0);
    struct sockaddr_in peer;
    int fd;
    char strport[64];
    sprintf(strport, "%d", port);
    if (!set_address(srvhost, strport, &peer, "tcp"))
    {
        return -1;
    }

    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
    {
        return -1;
    }
    int rcvBuffSize = 128 * 1024;

    if (setsockopt(fd, SOL_SOCKET, SO_RCVBUF, &rcvBuffSize, sizeof(rcvBuffSize)))
    {
        ::close(fd);
        return -1;
    }

    const int sendBuffSize = 128 * 1024;
    if (setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &sendBuffSize, sizeof(sendBuffSize)))
    {
        ::close(fd);
        return -1;
    }
    int leftValue2 = 0;
#if defined __ANDROID__ && defined ANDROID_DADIAN
    {
        string tmp;
        leftValue2 = CallbackService::commitTBSEventIfDataNetworkLeft(
            (uint8_t)IosNet::sharedInstance()->appId, "ims2",
            tmp.append("begin connect ims:").append(srvhost).append(":").append(strport));
    }
#endif
    //    if ( connect( fd, ( struct sockaddr * )&peer, sizeof( peer ) ) )
    time_t btime = time(0);
    if (!inet_connect(fd, (struct sockaddr *)&peer, sizeof(peer), 10))
    {
        time_t etime = time(0);
        char dnstime[10];
        time_t dnsdiff = etime - btime;
        memset(dnstime, 0, sizeof(dnstime));
        sprintf(dnstime, ",connTime:%d", dnsdiff);

        printf("conn to server=%s:%d failed", srvhost, port);
        ::close(fd); // added by helq.
        fd = -1;
#if defined __ANDROID__ && defined ANDROID_DADIAN
        {
            string tmp;
            CallbackService::commitTBSEventIfDataNetworkRight(
                (uint8_t)IosNet::sharedInstance()->appId, "ims2",
                tmp.append("fail to connect ims:").append(srvhost).append(":").append(strport).append(dnstime),
                leftValue2);
        }
#endif
    }
    else
    {
#if defined __ANDROID__ && defined ANDROID_DADIAN
        {
            time_t etime = time(0);
            time_t dnsdiff = etime - btime;
            char dnstime[10];
            memset(dnstime, 0, sizeof(dnstime));
            sprintf(dnstime, ",connTime:%d", dnsdiff);

            string tmp;
            CallbackService::commitTBSEventIfDataNetworkRight(
                (uint8_t)IosNet::sharedInstance()->appId, "ims2",
                tmp.append("end connect ims:").append(srvhost).append(":").append(strport).append(dnstime), leftValue2);
        }
#endif
    }

    time_t t2 = time(0);
    if (fd == -1)
    {
        time_t difft = t2 - t1;
        if (difft < timeoutseconds)
        {
            inetSleep(timeoutseconds - difft, 0);
        }
    }
    printf("cost time=%ld seconds", t2 - t1);
    return fd;
}

uint32_t IosNet::deferAsyncMsg(uint32_t cmdid, uint32_t seqId, const string &param,
                               IMNetAsyncCallbackBaseService &callbackObj, uint32_t ts, uint32_t appId, uint32_t bizId)
{

    uint16_t reserved = 1;
    string extrahead = packExtraHead(appId, bizId, reserved);

    SRpcActionResponsePtr actionNode(new SRpcActionResponse());
    actionNode->cmdid = cmdid;
    actionNode->param = param;
    actionNode->callbackobj = (void *)(&callbackObj);
    actionNode->ts = ts;
    actionNode->acttime = time(0);
    actionNode->cmdtype = EMsgCmdType_Req;
    actionNode->seqid = seqId;
    actionNode->bizId = bizId;
    actionNode->appId = appId;

    if (gDeferMsgQ.Size() > 512)
    {
        gDeferMsgQ.Put(actionNode);
        SRpcActionResponsePtr node;
        gDeferMsgQ.Get(node);
        SProtoMsgPtr rspMsgPtr(new SProtoMsg());
        rspMsgPtr->errcode = EActionRspError_NetFail;
        rspMsgPtr->cmdid = node->cmdid;
        rspMsgPtr->cmdtype = node->cmdtype;
        rspMsgPtr->seqid = node->seqid;
        rspMsgPtr->extrahead = extrahead;
        rspMsgPtr->reserved = reserved;

        gWaitCallRspMap[node->seqid] = node;
        gMsgRspQ.Put(rspMsgPtr);
    }
    else
    {
        gDeferMsgQ.Put(actionNode);
    }
    return actionNode->seqid;
}

uint32_t IosNet::asyncCall(uint32_t cmdid, uint32_t seqId, const string &param,
                           IMNetAsyncCallbackBaseService &callbackObj, uint32_t ts, uint32_t appId, uint32_t bizId)
{
    if (ts == 0)
        ts = 100;
    if (&callbackObj == NULL)
    {
        abort();
    }

    {
        TScopedLock<RecursiveMutex> tmplock(gLock, 'C');
        if (g_bLogined == false)
        {
            return deferAsyncMsg(cmdid, seqId, param, callbackObj, ts, appId, bizId);
        }
    }

    string paramdata = param;

    TScopedLock<RecursiveMutex> tmplock(gLock, 'D');
    bool bCompress = false;
    if (paramdata.size() > 256)
    {
        bCompress = true;
        // Compress(paramdata);
        CPackData::CompressData2(paramdata, 0);
    }

    uint16_t reserved = 1;
    string extrahead = packExtraHead(appId, bizId, reserved);

    bool bEncry = false;
    uint16_t cc = CPackData::CalcCheckCode(paramdata, 0);
    if (gLoginEncryKey.size())
    {
        bEncry = true;
        DesEncrypt desKey;
        desKey.SetKey(gLoginEncryKey);
        string tmpdata = desKey.Encrypt(paramdata);
        paramdata = tmpdata;
    }

    g_LastSendTime = time(0);

    SRpcActionResponsePtr waitRsp(new SRpcActionResponse());
    waitRsp->seqid = seqId;
    waitRsp->cmdid = cmdid;
    waitRsp->param = param;
    waitRsp->ts = ts;
    waitRsp->callbackobj = (void *)&callbackObj;
    waitRsp->acttime = g_LastSendTime;
    waitRsp->bizId = bizId;
    waitRsp->appId = appId;

    gWaitCallRspMap[seqId] = waitRsp;
    // printf("asyncCall PostMsg, cmdid=0x%x,seqid=%d,ts=%d",cmdid,seqid,ts);
    INetImpl::sharedInstance()->PostMsg(EMsgCmdType_Req, cmdid, seqId, extrahead, paramdata, bEncry, bCompress, ts, cc,
                                        reserved);
    return seqId;
}
uint32_t IosNet::asyncCall(uint32_t cmdid, const string &param, IMNetAsyncCallbackBaseService &callbackObj, uint32_t ts,
                           uint32_t appId, uint32_t bizId)
{
    uint32_t seqid = getNextSeqId();
    return asyncCall(cmdid, seqid, param, callbackObj, ts, appId, bizId);
}

// uint32_t IosNet::asyncCall(uint32_t cmdid ,const string& param ,IMNetAsyncCallbackBaseService& callbackObj,uint32_t
// ts,uint32_t appId, uint32_t bizId)
// {
//   return _asyncCall(cmdid, param, callbackObj, ts, // IosNet::sharedInstance()->appId
// 		    appId, bizId);
// }

void IosNet::notifyCall(uint32_t cmdid, const string &param, uint32_t appId, uint32_t bizId)
{
    uint32_t seqid = getNextSeqId();
    notifyCall(cmdid, seqid, param, appId, bizId);
}

void IosNet::notifyCall(uint32_t cmdid, uint32_t seqId, const string &param, uint32_t appId, uint32_t bizId)
{
    {
        TScopedLock<RecursiveMutex> tmplock(gLock, 'E');
        if (g_bLogined == false)
        {
            return;
            SRpcActionResponsePtr actionNode(new SRpcActionResponse());
            actionNode->cmdid = cmdid;
            actionNode->param = param;
            actionNode->ts = 10;
            actionNode->acttime = time(0);
            actionNode->callbackobj = NULL;
            actionNode->cmdtype = EMsgCmdType_Notify;
            actionNode->bizId = bizId;
            actionNode->appId = appId;
            actionNode->seqid = seqId;
            gDeferMsgQ.Put(actionNode);
            return;
        }
    }

    string paramdata = param;
    // paramdata.assign((const char*)[param bytes],[param length]);

    TScopedLock<RecursiveMutex> tmplock(gLock, 'F');
    bool bCompress = false;
    if (paramdata.size() > 256)
    {
        bCompress = true;
        CPackData::CompressData2(paramdata, 0);
    }

    string extrahead =
        gLoginUid;         //老接口用loginuid（实际就是userid，带cnhhupan等前缀的）作为extrahead，新接口需要添加SScUserInfo类型的extrahead的
    uint16_t reserved = 1; //老接口默认用1
    extrahead = packExtraHead(appId, bizId, reserved);

    bool bEncry = false;
    uint16_t cc = CPackData::CalcCheckCode(paramdata, 0);
    if (gLoginEncryKey.size())
    {
        bEncry = true;
        DesEncrypt desKey;
        desKey.SetKey(gLoginEncryKey);
        string tmpdata = desKey.Encrypt(paramdata);
        paramdata = tmpdata;
    }

    g_LastSendTime = time(0);
    INetImpl::sharedInstance()->PostMsg(EMsgCmdType_Req, cmdid, seqId, extrahead, paramdata, bEncry, bCompress, 5, cc,
                                        reserved);
}

void unlock_waitobject(void *pArg)
{
    pthread_mutex_t *mutex = (pthread_mutex_t *)pArg;
    int ret = pthread_mutex_trylock(mutex);
    printf("unlock_waitobject trylock ret:%d\n", ret);
    pthread_mutex_unlock(mutex);
}

string IosNet::syncCall(uint32_t cmdid, const string &param, uint32_t ts, uint32_t appId, uint32_t bizId)
{
    if (ts == 0)
        ts = 100;
    uint32_t seqid = getNextSeqId();
    string paramdata = param;
    // paramdata.assign((const char*)[param bytes],[param length]);
    WaitObjectPtr wait(new WaitObject());
    bool bCompress = false;
    bool bEncry = false;
    if (paramdata.size() > 256)
    {
        bCompress = true;
        // Compress(paramdata);
        CPackData::CompressData2(paramdata, 0);
    }
    {
        TScopedLock<RecursiveMutex> tmplock(gLock, 'G');

        string extrahead =
            gLoginUid;         //老接口用loginuid（实际就是userid，带cnhhupan等前缀的）作为extrahead，新接口需要添加SScUserInfo类型的extrahead的
        uint16_t reserved = 1; //老接口默认用1
        extrahead = packExtraHead(appId, bizId, reserved);

        uint16_t cc = CPackData::CalcCheckCode(paramdata, 0);
        if (gLoginEncryKey.size())
        {
            bEncry = true;
            DesEncrypt desKey;
            desKey.SetKey(gLoginEncryKey);
            string tmpdata = desKey.Encrypt(paramdata);
            paramdata = tmpdata;
        }

        g_LastSendTime = time(0);

        SRpcActionResponsePtr waitRsp(new SRpcActionResponse());
        waitRsp->seqid = seqid;
        waitRsp->cmdid = cmdid;
        waitRsp->param = param;
        waitRsp->ts = ts;
        waitRsp->callbackobj = NULL;
        waitRsp->acttime = g_LastSendTime;
        waitRsp->wait = wait;
        waitRsp->bizId = bizId;
        waitRsp->appId = appId;

        gWaitCallRspMap[seqid] = waitRsp;

        INetImpl::sharedInstance()->PostMsg(EMsgCmdType_Req, cmdid, seqid, extrahead, paramdata, bEncry, bCompress, ts,
                                            cc, reserved);
    }
    printf("synccall before TimedWait=%d seconds,seqid=%d", ts, seqid);
    int iret = 0;
    pthread_cleanup_push(unlock_waitobject, (void *)&wait->get_pthread_mutex());
    iret = wait->TimedWait(ts * 1000, '#');
    pthread_cleanup_pop(0);
    printf("synccall  after TimedWait=%d seconds, ret=%d", ts, iret);
    TScopedLock<RecursiveMutex> tmplock(gLock, 'H');
    if (0 != iret)
    {
        gWaitCallRspMap.erase(seqid);
        printf("synccall calltimeout ,seqid=%d", seqid);
        throw INetException("call timeouted ");
    }
    typeof(gWaitCallRspMap.begin()) itr = gWaitCallRspMap.find(seqid);
    if (itr == gWaitCallRspMap.end())
    {
        gWaitCallRspMap.erase(itr);
        printf("synccall server has bug ,seqid is wrong ,seqid=%d", seqid);
        throw INetException("server has bug , seqid is wrong");
    }
    SRpcActionResponsePtr rsp = itr->second;
    if (rsp->rspret != 0)
    {
        printf("synccall  connlost or connfailed rspret not 0 ,seqid=%d", seqid);
        gWaitCallRspMap.erase(itr);
        throw INetException("connlost or connfailed rspret not 0");
    }
    string rspdata = rsp->rspdata;
    gWaitCallRspMap.erase(itr);

    return rspdata;
}

string IosNet::syncCall(uint32_t cmdid, const string &param, const string &extdata, uint32_t ts, uint32_t appId,
                        uint32_t bizId)
{
    if (ts == 0)
        ts = 100;
    uint32_t seqid = getNextSeqId();
    string paramdata = param;
    // paramdata.assign((const char*)[param bytes],[param length]);
    WaitObjectPtr wait(new WaitObject());
    bool bCompress = false;
    bool bEncry = false;
    if (paramdata.size() > 256)
    {
        bCompress = true;
        // Compress(paramdata);
        CPackData::CompressData2(paramdata, 0);
    }
    {
        TScopedLock<RecursiveMutex> tmplock(gLock, 'I');

        uint16_t cc = CPackData::CalcCheckCode(paramdata, 0);
        if (gLoginEncryKey.size())
        {
            bEncry = true;
            DesEncrypt desKey;
            desKey.SetKey(gLoginEncryKey);
            string tmpdata = desKey.Encrypt(paramdata);
            paramdata = tmpdata;
        }

        g_LastSendTime = time(0);

        SRpcActionResponsePtr waitRsp(new SRpcActionResponse());
        waitRsp->seqid = seqid;
        waitRsp->cmdid = cmdid;
        waitRsp->param = param;
        waitRsp->ts = ts;
        waitRsp->callbackobj = NULL;
        waitRsp->acttime = g_LastSendTime;
        waitRsp->wait = wait;

        gWaitCallRspMap[seqid] = waitRsp;
        INetImpl::sharedInstance()->PostMsg(EMsgCmdType_Req, cmdid, seqid, extdata, paramdata, bEncry, bCompress, ts,
                                            cc);
    }
    printf("synccall before TimedWait=%d seconds,seqid=%d", ts, seqid);
    int iret = 0;
    pthread_cleanup_push(unlock_waitobject, (void *)&wait->get_pthread_mutex());
    iret = wait->TimedWait(ts * 1000);
    pthread_cleanup_pop(0);
    printf("synccall  after TimedWait=%d seconds, ret=%d", ts, iret);
    TScopedLock<RecursiveMutex> tmplock(gLock, 'J');
    if (0 != iret)
    {
        gWaitCallRspMap.erase(seqid);
        printf("synccall calltimeout ,seqid=%d", seqid);
        throw INetException("call timeouted ");
    }
    typeof(gWaitCallRspMap.begin()) itr = gWaitCallRspMap.find(seqid);
    if (itr == gWaitCallRspMap.end())
    {
        gWaitCallRspMap.erase(itr);
        printf("synccall server has bug ,seqid is wrong ,seqid=%d", seqid);
        throw INetException("server has bug , seqid is wrong");
    }
    SRpcActionResponsePtr rsp = itr->second;
    if (rsp->rspret != 0)
    {
        printf("synccall  connlost or connfailed rspret not 0 ,seqid=%d", seqid);
        gWaitCallRspMap.erase(itr);
        throw INetException("connlost or connfailed rspret not 0");
    }
    string rspdata = rsp->rspdata;
    gWaitCallRspMap.erase(itr);

    return rspdata;
}

bool IosNet::isLoginThreadExist()
{
    return (gtid_loginthread != 0);
}

void IosNet::clearLastLoginServers()
{
    gLastSrvs.clear();
}

void IosNet::cancelAsyncCall(uint32_t seqId)
{
    TScopedLock<RecursiveMutex> tmplock(gLock, 'K');

    typeof gWaitCallRspMap.begin() itr = gWaitCallRspMap.find(seqId);
    if (itr == gWaitCallRspMap.end())
    {
        SafeQueue<SRpcActionResponsePtr> tmpQ;

        while (gDeferMsgQ.IsEmpty() == false)
        {
            SRpcActionResponsePtr buffnode;
            gDeferMsgQ.Get(buffnode);

            if (buffnode->seqid == seqId)
            {
            }
            else
            {
                tmpQ.Put(buffnode);
            }
        }
        gDeferMsgQ.Clear();
        while (tmpQ.IsEmpty() == false)
        {
            SRpcActionResponsePtr buffnode;
            tmpQ.Get(buffnode);
            gDeferMsgQ.Put(buffnode);
        }
    }
    else
    {
        SRpcActionResponsePtr waitRsp = itr->second;
        gWaitCallRspMap.erase(itr);
        if (waitRsp && waitRsp->wait)
        {
            waitRsp->wait->Signal();
        }
    }
}

//
//  File.h
//  Messenger
//
//  Created by li jianhui on 12-9-20.
//
//

#ifndef __Messenger__File__
#define __Messenger__File__

#include <iostream>
#include <vector>

using namespace std;
class IMNetAsyncCallbackBaseService
{
public:
    IMNetAsyncCallbackBaseService()
    {
    }
    ~IMNetAsyncCallbackBaseService()
    {
    }
    
    virtual void ResponseSuccess(uint32_t cmdid, const string& reqData ,const string& rspData, const void* extraHeadPtr = NULL, uint16_t reserved = 0) = 0;
    virtual void ResponseFail(uint32_t cmdid,const string& reqData ,int errorCode, const void* extraHeadPtr = NULL, uint16_t reserved = 0) = 0;
};

class IMNetAsyncNotifyBaseService
{
public:
    IMNetAsyncNotifyBaseService()
    {
    }
    ~IMNetAsyncNotifyBaseService()
    {
    }
    
    virtual void Notify(const string& lAccount, uint32_t cmdid, const string& param, const void* extraHeadPtr = NULL, uint16_t reserved = 0) = 0;
    
    virtual void LoginSuccess( const string& lAccount,const string& userId,const string& pwtoken,vector<string>&  loginsrvs,const string& newestVer,long srvtime,const string& nickName,const string& newverUrl,const string& newverDesc) = 0;
    virtual void LoginSuccess( const string& lAccount,const string& userId,const string& pwtoken,const string& lastIp,const string& newestVer,long srvtime,const string& nickName,const string& newverUrl,const string& newverDesc) = 0;
    virtual void LoginFail(const string& lAccount, int errcode, const string& errstr,const string& pwtoken, const string& newestVer, const string& newverUrl,const string& newverDesc, const string& authUrl) = 0;
    virtual void LogonKickedOff(const string& lAccount, unsigned char* type, const string& ip, const string& remark) = 0;
    virtual void ReconnLoginSuccess(const string& lAccount) = 0;
    virtual void Logining(const string& lAccount) = 0;

};
#endif /* defined(__Messenger__File__) */

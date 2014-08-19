//
//  IMNetService4iOS.h
//  Messenger
//
//  Created by li jianhui on 12-9-20.
//
//

#ifndef __Messenger__IMNetService4iOS__
#define __Messenger__IMNetService4iOS__

#import <Foundation/Foundation.h>
#include <iostream>
#include <vector>
#include "IMNetService.h"
#import "inetprotocol.h"

#define kIOSNetLoginSuccess         @"uiloginSuccess"
#define kIOSNetLoginFailed          @"uiloginFail"
#define kIOSNetReLoginSuccess       @"uiReLoginSuccess"
#define kIOSNetLogining             @"uiloginIng"
#define kIOSNetLoginSuccessByTaobao @"uiloginSuccessByTaobao"

#define kIOSNetKeyLoginId           @"kIOSNetKeyLoginId"
#define kIOSNetKeyUserId            @"kIOSNetKeyUserId"
#define kIOSNetKeyNickname          @"kIOSNetKeyNickname"
#define kIOSNetKeyBaseNumber        @"kIOSNetKeyBaseNumber"
#define kIOSNetKeyToken             @"kIOSNetKeyToken"
#define kIOSNetKeyNewestVersion     @"kIOSNetKeyNewestVersion"
#define kIOSNetKeyNewestVersionURL  @"kIOSNetKeyNewestVersionURL"
#define kIOSNetKeyNewestVersionDesc @"kIOSNetKeyNewestVersionDesc"

class IMNetAsyncCallbackService4iOS:public IMNetAsyncCallbackBaseService
{
protected:
    IMNetAsyncCallbackService4iOS();
    ~IMNetAsyncCallbackService4iOS();
    //禁止手动调用delete类对象
    void Release();
    
public:
    //必须通过CreateService创建类实例，并回调时内部调用Release释放
    static IMNetAsyncCallbackService4iOS* CreateService( id<AsyncCallbackBase> callbackObj );
    
    void ResponseSuccess(uint32_t cmdid, const string& reqData ,const string& rspData, const void* extraHeadPtr = NULL, uint16_t reserved = 0);
    
    void ResponseFail(uint32_t cmdid,const string& reqData ,int errorCode, const void* extraHeadPtr = NULL, uint16_t reserved = 0);
    
public:
    id<AsyncCallbackBase> asyncCallbackObj;
};

class IMNetAsyncNotifyService4iOS:public IMNetAsyncNotifyBaseService
{
public:
    //IMNetAsyncNotifyService4iOS();
    
    IMNetAsyncNotifyService4iOS( id<ClientAsyncNotifyServiceBase> callbackObj );
    ~IMNetAsyncNotifyService4iOS();
    
    
    
    void Notify(const string& lAccount, uint32_t cmdid, const string& param, const void* extraHeadPtr = NULL, uint16_t reserved = 0);
    
    void LoginSuccess( const string& lAccount,const string& userId,const string& pwtoken,vector<string>&  loginsrvs,const string& newestVer,long srvtime,const string& nickName,const string& newverUrl,const string& newverDesc);
    void LoginSuccess( const string& lAccount,const string& userId,const string& pwtoken,const string& lastIp,const string& newestVer,long srvtime,const string& nickName,const string& newverUrl,const string& newverDesc);
    void LoginFail(const string& lAccount, int errcode, const string& errstr,const string& pwtoken, const string& newestVer, const string& newverUrl,const string& newverDesc, const string& authUrl);
    void LogonKickedOff(const string& lAccount, unsigned char* type, const string& ip, const string& remark);
    void ReconnLoginSuccess(const string& lAccount);
    void Logining(const string& lAccount);

    
public:
    id<ClientAsyncNotifyServiceBase> notifyCallbackObj;
};
#endif /* defined(__Messenger__IMNetService4iOS__) */

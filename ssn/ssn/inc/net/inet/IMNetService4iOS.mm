//
//  IMNetService4iOS.cpp
//  Messenger
//
//  Created by li jianhui on 12-9-20.
//
//

#include "IMNetService4iOS.h"

#pragma mark - IMNetAsyncCallbackService4iOS

IMNetAsyncCallbackService4iOS::IMNetAsyncCallbackService4iOS()
{
}

IMNetAsyncCallbackService4iOS *IMNetAsyncCallbackService4iOS::CreateService(id<AsyncCallbackBase> callbackObj)
{
    return nil;
    //    IMNetAsyncCallbackService4iOS* service = new IMNetAsyncCallbackService4iOS();
    //    service->asyncCallbackObj = as_retain(callbackObj);
    //    return service;
}

IMNetAsyncCallbackService4iOS::~IMNetAsyncCallbackService4iOS()
{
//    if (asyncCallbackObj)
//        as_release(asyncCallbackObj);
}

void IMNetAsyncCallbackService4iOS::Release()
{
    delete this;
}

void IMNetAsyncCallbackService4iOS::ResponseSuccess(uint32_t cmdid, const string &reqData, const string &rspData,
                                                    const void *extraHeadPtr, uint16_t reserved)
{

//    as_autoreleasepool_start(tpool) NSData *reqparam = [NSData dataWithBytes:reqData.data() length:reqData.size()];
//    NSData *rspparam = [NSData dataWithBytes:rspData.data() length:rspData.size()];
//    as_retain(reqparam);
//    as_retain(rspparam);
//
//    as_retain(asyncCallbackObj);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        as_autoreleasepool_start(
//            pool)[asyncCallbackObj ResponseSuccess : cmdid forReqParam : reqparam forRspData : rspparam];
//        as_release(asyncCallbackObj);
//        Release();
//
//        as_autoreleasepool_end(pool) as_release(reqparam);
//        as_release(rspparam);
//    });
//    as_autoreleasepool_end(tpool)
}

void IMNetAsyncCallbackService4iOS::ResponseFail(uint32_t cmdid, const string &reqData, int errorCode,
                                                 const void *extraHeadPtr, uint16_t reserved)
{
//    as_autoreleasepool_start(tpool) NSData *reqparam = [NSData dataWithBytes:reqData.data() length:reqData.size()];
//    as_retain(reqparam);
//    NSError *error =
//        [NSError errorWithDomain:@"IMNetAsyncCallbackService4iOS ResponseFail" code:errorCode userInfo:nil];
//    as_retain(error);
//
//    as_retain(asyncCallbackObj);
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        as_autoreleasepool_start(pool)[asyncCallbackObj ResponseFail : cmdid forReqParam : reqparam forError : error];
//        as_release(asyncCallbackObj);
//
//        Release();
//
//        as_autoreleasepool_end(pool) as_release(reqparam);
//        as_release(error);
//    });
//    as_autoreleasepool_end(tpool)
}

#pragma mark - IMNetAsyncNotifyService4iOS

// IMNetAsyncNotifyService4iOS::IMNetAsyncNotifyService4iOS()
//{
//
//}
IMNetAsyncNotifyService4iOS::IMNetAsyncNotifyService4iOS(id<ClientAsyncNotifyServiceBase> callbackObj)
{
    //notifyCallbackObj = as_retain(callbackObj);
}

IMNetAsyncNotifyService4iOS::~IMNetAsyncNotifyService4iOS()
{
   // if (notifyCallbackObj)
//        as_release(notifyCallbackObj);
}

void IMNetAsyncNotifyService4iOS::Notify(const string &lAccount, uint32_t cmdid, const string &rspData,
                                         const void *extraHeadPtr, uint16_t reserved)
{

//    as_autoreleasepool_start(tpool) NSData *param = [NSData dataWithBytes:rspData.data() length:rspData.size()];
//    as_retain(param);
//
//    as_retain(notifyCallbackObj);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        as_autoreleasepool_start(pool)[notifyCallbackObj Notify : cmdid forParam : param];
//        as_release(notifyCallbackObj);
//
//        as_autoreleasepool_end(pool) as_release(param);
//    });
//    as_autoreleasepool_end(tpool)
}

void IMNetAsyncNotifyService4iOS::LoginSuccess(const string &lAccount, const string &userId, const string &pwtoken,
                                               vector<string> &loginsrvs, const string &newestVer, long srvtime,
                                               const string &nickName, const string &newverUrl,
                                               const string &newverDesc)
{
//    as_autoreleasepool_start(tpool) NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
//    {
//        NSString *token = [NSString stringWithUTF8String:pwtoken.c_str()];
//        long long base = srvtime;
//        base *= 10000;
//        NSNumber *baseNumber = [NSNumber numberWithLongLong:base];
//
//        [mdict setObject:token forKey:kIOSNetKeyToken];
//        [mdict setObject:baseNumber forKey:kIOSNetKeyBaseNumber];
//        [mdict setObject:[NSString stringWithUTF8String:lAccount.c_str()] forKey:kIOSNetKeyLoginId];
//        [mdict setObject:[NSString stringWithUTF8String:userId.c_str()] forKey:kIOSNetKeyUserId];
//        [mdict setObject:[NSString stringWithUTF8String:nickName.c_str()] forKey:kIOSNetKeyNickname];
//        [mdict setObject:[NSString stringWithUTF8String:newestVer.c_str()] forKey:kIOSNetKeyNewestVersion];
//        [mdict setObject:[NSString stringWithUTF8String:newverUrl.c_str()] forKey:kIOSNetKeyNewestVersionURL];
//        [mdict setObject:[NSString stringWithUTF8String:newverDesc.c_str()] forKey:kIOSNetKeyNewestVersionDesc];
//        as_retain(mdict);
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        as_autoreleasepool_start(
//            pool)[[NSNotificationCenter defaultCenter] postNotificationName : kIOSNetLoginSuccess object : mdict];
//        as_autoreleasepool_end(pool) as_release(mdict);
//    });
//
//    as_autoreleasepool_end(tpool)
}

void IMNetAsyncNotifyService4iOS::LoginSuccess(const string &lAccount, const string &userId, const string &pwtoken,
                                               const string &lastIp, const string &newestVer, long srvtime,
                                               const string &nickName, const string &newverUrl,
                                               const string &newverDesc)
{
//    as_autoreleasepool_start(tpool) NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
//    {
//        NSString *token = [NSString stringWithUTF8String:pwtoken.c_str()];
//        long long base = srvtime;
//        base *= 10000;
//        NSNumber *baseNumber = [NSNumber numberWithLongLong:base];
//
//        [mdict setObject:token forKey:kIOSNetKeyToken];
//        [mdict setObject:baseNumber forKey:kIOSNetKeyBaseNumber];
//        [mdict setObject:[NSString stringWithUTF8String:lAccount.c_str()] forKey:kIOSNetKeyLoginId];
//        [mdict setObject:[NSString stringWithUTF8String:userId.c_str()] forKey:kIOSNetKeyUserId];
//        [mdict setObject:[NSString stringWithUTF8String:nickName.c_str()] forKey:kIOSNetKeyNickname];
//        [mdict setObject:[NSString stringWithUTF8String:newestVer.c_str()] forKey:kIOSNetKeyNewestVersion];
//        [mdict setObject:[NSString stringWithUTF8String:newverUrl.c_str()] forKey:kIOSNetKeyNewestVersionURL];
//        [mdict setObject:[NSString stringWithUTF8String:newverDesc.c_str()] forKey:kIOSNetKeyNewestVersionDesc];
//        as_retain(mdict);
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        as_autoreleasepool_start(
//            pool)[[NSNotificationCenter defaultCenter] postNotificationName : kIOSNetLoginSuccess object : mdict];
//        as_autoreleasepool_end(pool) as_release(mdict);
//    });
//
//    as_autoreleasepool_end(tpool)
}

void IMNetAsyncNotifyService4iOS::LoginFail(const string &lAccount, int errcode, const string &errstr,
                                            const string &pwtoken, const string &newestVer, const string &newverUrl,
                                            const string &newverDesc, const string &authUrl)
{
//    as_autoreleasepool_start(tpool) NSError *error =
//        [NSError errorWithDomain:@"IMNetAsyncNotifyService4iOS::LoginFail" code:errcode userInfo:nil];
//    as_retain(error);
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        as_autoreleasepool_start(
//            pool)[[NSNotificationCenter defaultCenter] postNotificationName : kIOSNetLoginFailed object : error];
//        as_autoreleasepool_end(pool) as_release(error);
//    });
//    as_autoreleasepool_end(tpool)
}
void IMNetAsyncNotifyService4iOS::LogonKickedOff(const string &lAccount, unsigned char *type, const string &ip,
                                                 const string &remark)
{
}
void IMNetAsyncNotifyService4iOS::ReconnLoginSuccess(const string &lAccount)
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        as_autoreleasepool_start(
//            tpool)[[NSNotificationCenter defaultCenter] postNotificationName : kIOSNetReLoginSuccess object : nil];
//        as_autoreleasepool_end(tpool)
//    });
}
void IMNetAsyncNotifyService4iOS::Logining(const string &lAccount)
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        as_autoreleasepool_start(
//            tpool)[[NSNotificationCenter defaultCenter] postNotificationName : kIOSNetLogining object : nil];
//        as_autoreleasepool_end(tpool)
//    });
}
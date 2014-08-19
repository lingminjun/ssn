//
//  inet.h
//  inettest
//
//  Created by jay on 11-10-13.
//  Copyright 2011 _MyCompanyName__. All rights reserved.
//
#ifndef IosNet_h
#define IosNet_h

#include <string>
#include <vector>
#ifdef ANDROID_OS_DEBUG
#include <android/log.h>
#endif

#include "../IMNetService.h"

using namespace std;

#ifdef ANDROID_OS_DEBUG
#define printf(format...) __android_log_print(ANDROID_LOG_INFO, "printf", format)
#endif

enum EDEVTYPE
{
    EDEVTYPE_IPHONE                     = 1,    // 旺信ios老版本
    EDEVTYPE_ANDROIDPHONE               = 2,    // 旺信安卓老版本
    EDEVTYPE_IPHONE_QIANNIU             = 3,    // 牵牛ios版本
    EDEVTYPE_ANDROID_QIANNIU            = 4,    // 牵牛安卓版本
    EDEVTYPE_IPHONE_WIRELESS            = 5,    // 淘宝无线客户端ios版本
    EDEVTYPE_ANDROIDPHONE_WIRELESS      = 6,    // 淘宝无线客户端安卓版本
    EDEVTYPE_IPHONE_WANGWANG            = 7,    // 旺信ios版本
    EDEVTYPE_ANDROIDPHONE_WANGWANG      = 8,    // 旺信安卓版本
    EDEVTYPE_IPAD                       = 9,    // 旺信iPad版本
    EDEVTYPE_IPHONE_LVXING              = 11,   // 淘宝旅行ios版本
    EDEVTYPE_ANDROIDPHONE_LVXING        = 12,   // 淘宝旅行安卓版本
    EDEVTYPE_IPHONE_TMALL               = 13,   // 天猫ios版本
    EDEVTYPE_ANDROIDPHONE_TMALL         = 14,   // 天猫安卓版本
    EDEVTYPE_IPHONE_INTERNATIONTAL      = 65,   // 国际站ios版本
    EDEVTYPE_ANDROID_INTERNATIONTAL     = 66,   // 国际站安卓版本
    EDEVTYPE_IPHONE_CHINESE             = 67,   // 中文站ios版本
    EDEVTYPE_ANDROID_CHINESE            = 68,   // 中文站安卓版本
    
    EDEVTYPE_IPHONE_NEW                 = 80,   // iPhone版d
    EDEVTYPE_IPAD_NEW                   = 81,   // iPad版本
    EDEVTYPE_ANDROID_PHONE_NEW          = 82,   // 安卓Phone版
    EDEVTYPE_ANDROID_PAD_NEW            = 83,   // 安卓Pad版
    EDEVTYPE_WIN_PHONE_NEW              = 84,   // windows Phone版
    EDEVTYPE_WIN_PAD_NEW                = 85,   // windows Pad版
};

enum APPID
{
    APPID_DEFAULT               = 0,    // 默认应用，旺信老版本
    APPID_QIANNIU               = 1,    // 千牛
    APPID_WANGXIN               = 2,    // 旺信
    APPID_MOBILETAOBAO          = 3,    // 淘宝主客户端
    APPID_LOCALLIFEOFFER        = 4,    // 本地生活offer客户端（淘宝生活）
    APPID_WANGXINENTERPRISE     = 5,    // 旺信企业版
    APPID_PC_WANGWANG           = 6,    // PC旺旺客户端
    APPID_LVXING                = 7,    // 淘宝旅行客户端
    APPID_TMALL                 = 8,    // 天猫客户端
    APPID_INTERNATIONAL         = 31,   // 国际站
    APPID_CHINESE               = 32,   // 中文站
};

class IosNet
{
public:
    EDEVTYPE devtype;
    APPID appId;
    int healthcheckperiod;
    IosNet();
    ~IosNet();
    void setDevtype(EDEVTYPE type);
    void setAppId(APPID idValue);
    void setOstype(const string& ostype);
    void setOsver(const string& osver);
    //void setImei(const string& imei);
    void setAllotSrv(const string& alloturl);
    void setAllotSrv(const string& alloturl, uint8_t allotType);
    void setIMNetAsyncNotifyService(IMNetAsyncNotifyBaseService* netService);
    void setCliVersion(const string& ver);
    
    string getNickname();
    string getNewver();
    string getNewverurl();
    string getNewverDesc();
    vector<string> getLastloginsrvs();
    string getUserId();
    string getLAccount();
    string getLoginUid();
    string getCheckCode();
    string getAuthCodeUrl();
    string getToken();
    int getPwType();
    
    void stop();
    uint32_t getNextSeqId();
    
    static IosNet* sharedInstance();

    bool initNet(uint16_t clientThreadNum);
    void startLoginWithLoginId(const string& lAccount,
			       const string& loginId,
                                const string& passwd ,
                                int pwtype,
                                vector<string>& lastSrvs,
                                const string& checkCode,
                                const string& authCodeUrl,
			       const string& uuid,
			       const string& extraData,
			       APPID appId
			       );
    void startLoginWithLoginId(const string& loginId,
                                const string& passwd ,
                                int pwtype,
                                vector<string>& lastSrvs,
                                const string& checkCode,
                                const string& authCodeUrl,
                                const string& uuid);
    void logout(int isCancle);
    void relogin(int state);
    void enterBackLogout();
    uint32_t deferAsyncMsg(uint32_t cmdid , uint32_t seqId, const string& param ,IMNetAsyncCallbackBaseService& callbackObj,uint32_t ts, uint32_t appId = 0, uint32_t bizId = 0);
    /* uint32_t _asyncCall(uint32_t cmdid, */
    /*                    const string& param, */
    /*                    IMNetAsyncCallbackBaseService& callbackObj, */
    /*                    uint32_t ts, */
    /* 		       uint32_t appId = 0, */
    /*                    uint32_t bizId = 0);     //bizId默认为0，认为不需要设置bizId，那么底层走老协议，不带biz的协议 */
    uint32_t asyncCall(uint32_t cmdid,
                       const string& param,
                       IMNetAsyncCallbackBaseService& callbackObj,
                       uint32_t ts,
		       uint32_t appId =0,
                       uint32_t bizId = 0);     //bizId默认为0，认为不需要设置bizId，那么底层走老协议，不带biz的协议
    void notifyCall(uint32_t cmdid, const string& param, uint32_t appId = 0, uint32_t bizId = 0); //bizId默认为0，认为不需要设置bizId，那么底层走老协议，不带biz的协议
    string syncCall(uint32_t cmdid, const string& param, uint32_t ts, uint32_t appId = 0, uint32_t bizId = 0);     //bizId默认为0，认为不需要设置bizId，那么底层走老协议，不带biz的协议
    string syncCall(uint32_t cmdid, const string& param, const string& extdata, uint32_t ts, uint32_t appId = 0, uint32_t bizId = 0);
    int conntoServer(const char* srvhost, uint16_t port, uint32_t timeoutseconds);
    void doHealthCheck();
    bool isLoginThreadExist();

    void clearLastLoginServers();
    void cancelAsyncCall(uint32_t seqId);
    void restartLogin(bool isself);
    bool renewal(const string& lid, const string& sessionId);
    
    //添加seqId版本, 内部使用, private, 但static C函数有使用, 最好的方式是把C函数friend
    uint32_t asyncCall(uint32_t cmdid,
                       uint32_t seqId,
                       const string& param,
                       IMNetAsyncCallbackBaseService& callbackObj,
                       uint32_t ts,
                       uint32_t appId =0,
                       uint32_t bizId = 0);
     void notifyCall(uint32_t cmdid, uint32_t seqId, const string& param, uint32_t appId = 0, uint32_t bizId = 0);
};
#endif

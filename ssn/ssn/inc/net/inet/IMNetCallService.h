//
//  IMNetCallService.h
//  Messenger
//
//  Created by li jianhui on 12-9-21.
//
//

#import <Foundation/Foundation.h>
#import "inetprotocol.h"
#import "inet.h"
#import "IMNetService.h"

#include <string>

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

using namespace std;

@interface IMNetInterfaceService : NSObject

+(IMNetInterfaceService*) sharedInstance;

-(void) setDevtype:(EDEVTYPE) type;
-(void) setAppId:(APPID) idValue;
//-(void) setAllotSrv:(NSString*)alloturl;
-(void) setAllotSrv:(NSString*)alloturl allotType:(int)type;
-(void) setIMNetAsyncNotifyService:(IMNetAsyncNotifyBaseService*) netService;
-(void) setCliVersion:(NSString*)ver;
-(NSString*) getNickname;
-(NSString*) getNewver;
-(NSString*) getNewverurl;
-(NSString*) getNewverDesc;
-(NSArray*) getLastloginsrvs;
-(NSString*) getUserId;
-(NSString*) getLoginUid;
-(NSString*) getCheckCode;
-(NSString*) getAuthCodeUrl;
-(NSString*) getToken;
-(int) getPwType;


-(bool) initNet:(uint16_t) clientThreadNum;
-(void) unInitNet;
-(void) startLoginWithLoginId:(NSString*)loginId
					   withPw:(NSString*)passwd
				   withPwType:(int)pwtype
				  withLastSrv:(NSArray*)lastSrvs
				withCheckcode:(NSString*)checkCode
              withAuthCodeUrl:(NSString*)authCodeUrl
                withExtraData:(NSString *)aExtraData
					 withUUID:(NSString *) uuid;
-(void)enterBackLogout;
-(void) logout:(int)isCancle;
-(void) stop;
-(uint32_t) getNextSeqId;
-(uint32_t) asyncCall:(uint32_t) cmdid forParam:( const string&) param forCallback:(id<AsyncCallbackBase>) callbackObj forTimeout:(uint32_t) ts;
-(void) notifyCall:(uint32_t)cmdid forParam:( const string&) param;
-(string) syncCall:(uint32_t)cmdid forParam:( const string& ) param forTimeout:(uint32_t) ts;
-(int) conntoServer:(const char*) srvhost forPort:(uint16_t) port forTimeout:(uint32_t) timeoutseconds;
-(void) doHealthCheck;
-(bool)isLoginThreadExist;

-(void)clearLastLoginServers; // 为了切换内外网功能用的，其他地方不建议使用
-(void) cancelAsyncCall:(uint32_t)seqId;
-(void) restartLogin; 

@end

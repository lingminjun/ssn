//
//  IMNetCallService.m
//  Messenger
//
//  Created by li jianhui on 12-9-21.
//
//
#include <stdio.h>

#import "inet.h"
#import "IMNetCallService.h"
#import "IMNetService4iOS.h"
#import "packdata.h"


@implementation IMNetInterfaceService

+(IMNetInterfaceService*) sharedInstance;
{
    static IMNetInterfaceService* callService=nil;
    if(callService)
        return callService;
    callService=[[IMNetInterfaceService alloc] init];
    return callService;
}

-(uint32_t) asyncCall:(uint32_t) cmdid forParam:( const string&) param forCallback:(id<AsyncCallbackBase>) callbackObj forTimeout:(uint32_t) ts
{
    uint32_t retCode = 0;
    
    IMNetAsyncCallbackService4iOS* callbackService = IMNetAsyncCallbackService4iOS::CreateService(callbackObj);
    try
    {
        retCode = IosNet::sharedInstance()->asyncCall(cmdid,param,*callbackService,ts, APPID_WANGXIN);
    }
    catch (enum PACKRETCODE codeError)
    {
        printf("asyncCall-error:%d",codeError);
    }
    
    return retCode;
}

-(string) syncCall:(uint32_t)cmdid forParam:( const string& ) param forTimeout:(uint32_t) ts
{
    string strRet;
    try
    {
        strRet = IosNet::sharedInstance()->syncCall(cmdid,param,ts, APPID_WANGXIN);
    }
    catch (enum PACKRETCODE codeError)
    {
        printf("syncCall-error:%d",codeError);
    }
    
    return strRet;
}   

-(void) setDevtype:(EDEVTYPE)type
{
    IosNet::sharedInstance()->setDevtype(type);
}

-(void) setAppId:(APPID) idValue
{
    IosNet::sharedInstance()->setAppId(idValue);
}

/*
-(void) setAllotSrv:(NSString*)alloturl
{
    IosNet::sharedInstance()->setAllotSrv([alloturl UTF8String]);
}
*/

-(void) setAllotSrv:(NSString*)alloturl allotType:(int)type
{
    IosNet::sharedInstance()->setAllotSrv([alloturl UTF8String], type);
}

-(void) setIMNetAsyncNotifyService:(IMNetAsyncNotifyBaseService*) netService
{
    IosNet::sharedInstance()->setIMNetAsyncNotifyService(netService);
}

-(void) setCliVersion:(NSString*)ver
{
    IosNet::sharedInstance()->setCliVersion([ver UTF8String]);
}

-(NSString*) getNickname
{
    string userid =  IosNet::sharedInstance()->getNickname();
    return [NSString stringWithUTF8String:userid.c_str()];
}

-(NSString*) getNewver
{
    string ver =  IosNet::sharedInstance()->getNewver();
    return [NSString stringWithUTF8String:ver.c_str()];
}

-(NSString*) getNewverurl
{
    string url =  IosNet::sharedInstance()->getNewverurl();
    return [NSString stringWithUTF8String:url.c_str()];
}

-(NSString*) getNewverDesc
{
    string desc =  IosNet::sharedInstance()->getNewverDesc();
    return [NSString stringWithUTF8String:desc.c_str()];
}

-(NSArray*) getLastloginsrvs
{
    vector<string> lastLoginsrvs =  IosNet::sharedInstance()->getLastloginsrvs();
    NSMutableArray* lastSrvs=[NSMutableArray array];
    for(size_t i=0;i<lastLoginsrvs.size();i++)
    {
        NSString *srv = [NSString stringWithUTF8String:lastLoginsrvs[i].c_str()];
        if ([srv length] == 0)  continue;
        [lastSrvs addObject:srv];
    }

    return lastSrvs;
}

-(NSString*) getUserId
{
    string uid =  IosNet::sharedInstance()->getUserId();
    return [NSString stringWithUTF8String:uid.c_str()];
}

-(NSString*) getLoginUid
{
    string uid =  IosNet::sharedInstance()->getLoginUid();
    return [NSString stringWithUTF8String:uid.c_str()];
}

-(NSString*) getCheckCode
{
    string checkCode =  IosNet::sharedInstance()->getCheckCode();
    return [NSString stringWithUTF8String:checkCode.c_str()];
}

-(NSString*) getAuthCodeUrl
{
    string url =  IosNet::sharedInstance()->getAuthCodeUrl();
    return [NSString stringWithUTF8String:url.c_str()];
}

-(NSString*) getToken
{
    string token =  IosNet::sharedInstance()->getToken();
    return [NSString stringWithUTF8String:token.c_str()];
}

-(int) getPwType
{
    return IosNet::sharedInstance()->getPwType();
}


-(bool) initNet:(uint16_t) clientThreadNum
{
    NSString* devver=[[UIDevice currentDevice] systemVersion];
    devver = [NSString stringWithFormat:@"IPHONE_%@",devver];
    IosNet::sharedInstance()->setOsver([devver UTF8String]);
    
    return IosNet::sharedInstance()->initNet(clientThreadNum);
}

-(void) unInitNet
{
    //IosNet::sharedInstance()->UnInitNet();
    return;
}

static const char * SpecialGetUTF8String(NSString * str)
{
	if(str)
	{
		return [str UTF8String];
	}
	else
	{
		return "";
	}
}

-(void) startLoginWithLoginId:(NSString*)loginId
					   withPw:(NSString*)passwd
				   withPwType:(int)pwtype
				  withLastSrv:(NSArray*)lastSrvs
				withCheckcode:(NSString*)checkCode
              withAuthCodeUrl:(NSString*)authCodeUrl
                withExtraData:(NSString *)aExtraData
					 withUUID:(NSString *) uuid
{
    vector<string> servers;
    for (int i = 0 ; i < [lastSrvs count]; i++) {
        servers.push_back([[lastSrvs objectAtIndex:i] UTF8String]);
    }
    
    return IosNet::sharedInstance()->startLoginWithLoginId(SpecialGetUTF8String(loginId), SpecialGetUTF8String(loginId), SpecialGetUTF8String(passwd), pwtype, servers, SpecialGetUTF8String(checkCode), SpecialGetUTF8String(authCodeUrl), SpecialGetUTF8String(uuid), SpecialGetUTF8String(aExtraData), IosNet::sharedInstance()->appId);
}

-(void)enterBackLogout
{
    IosNet::sharedInstance()->enterBackLogout();
}

-(void) logout:(int)isCancle
{
    IosNet::sharedInstance()->logout(isCancle);
}

-(void) stop
{
    IosNet::sharedInstance()->stop();
}

-(uint32_t) getNextSeqId
{
    return IosNet::sharedInstance()->getNextSeqId();
}

-(void) notifyCall:(uint32_t)cmdid forParam:( const string&) param
{
    IosNet::sharedInstance()->notifyCall(cmdid, param, APPID_WANGXIN);
}

-(int) conntoServer:(const char*) srvhost forPort:(uint16_t) port forTimeout:(uint32_t) timeoutseconds
{
    return IosNet::sharedInstance()->conntoServer(srvhost, port, timeoutseconds);
}

-(void) doHealthCheck
{
    IosNet::sharedInstance()->doHealthCheck();
}

-(bool)isLoginThreadExist
{
    return IosNet::sharedInstance()->isLoginThreadExist();
}

-(void)clearLastLoginServers 
{
    IosNet::sharedInstance()->clearLastLoginServers();
}

-(void) cancelAsyncCall:(uint32_t)seqId
{
    IosNet::sharedInstance()->cancelAsyncCall(seqId);
}

-(void) restartLogin
{
    IosNet::sharedInstance()->restartLogin(NO);
}

@end

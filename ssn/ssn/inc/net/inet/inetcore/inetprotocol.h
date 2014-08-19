//
//  inetprotocol.h
//  inettest
//
//  Created by jay on 11-10-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AsyncCallbackBase <NSObject>

-(void) ResponseSuccess:(uint32_t) cmdid forReqParam:(NSData*) reqData forRspData:(NSData*) rspData;
-(void) ResponseFail:(uint32_t) cmdid forReqParam:(NSData*) reqData forError:(NSError*) error;

@end

@protocol ClientAsyncNotifyServiceBase <NSObject>

-(void) Notify:(uint32_t) cmdid forParam:(NSData*) param;

@end

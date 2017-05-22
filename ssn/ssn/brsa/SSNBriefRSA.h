//
//  SSNBriefRSA.h
//  ssn
//
//  Created by fengqu on 2017/5/21.
//  Copyright © 2017年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNBriefRSA : NSObject
+ (void)genRSA:(int64_t)from to:(int64_t)to;//生产一个from到to之间的基数生产的rsakey
+ (NSString *)sign:(NSString *)priKey data:(NSData *)data;//前面
+ (BOOL)verify:(NSString *)pubKey sign:(NSString *)sign data:(NSData *)data;//仍正签名
@end

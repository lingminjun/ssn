//
//  NSData+SSN.m
//  ssn
//
//  Created by lingminjun on 15/4/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSData+SSN.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (SSN)

- (NSString*)ssn_md5
{
    unsigned char result[16];
    CC_MD5(self.bytes, (CC_LONG)[self length], result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end

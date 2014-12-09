//
//  NSData+SSNBase64.m
//  ssn
//
//  Created by lingminjun on 14/12/9.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "NSData+SSNBase64.h"
#import "ssnbase64.h"

@implementation NSData (SSNBase64)

+ (instancetype)ssn_base64EncodedString:(NSString *)base64String {
    NSUInteger length = [base64String length];
    if (length == 0) {
        return nil;
    }
    unsigned long len = 0;
    unsigned char *bytes = ssn_base64_decode(NULL, (const unsigned char *)[base64String UTF8String], length, &len);
    if (!bytes) {
        return nil;
    }
    return [NSData dataWithBytesNoCopy:bytes length:len];
}

- (NSString *)ssn_base64 {
    unsigned long len = 0;
    unsigned char *base64 = ssn_base64_encode(NULL, (const unsigned char *)self.bytes, [self length], &len);
    if (base64) {
        return [[NSString alloc] initWithBytesNoCopy:(void *)base64 length:len encoding:NSUTF8StringEncoding freeWhenDone:YES];
    }
    return nil;
}

@end

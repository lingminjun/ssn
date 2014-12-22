//
//  NSData+SSNBase64.h
//  ssn
//
//  Created by lingminjun on 14/12/9.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SSNBase64)

+ (instancetype)ssn_base64EncodedString:(NSString *)base64String;//解码

- (NSString *)ssn_base64;//64编码

@end

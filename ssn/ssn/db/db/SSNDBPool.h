//
//  SSNDBPool.h
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNDB.h"

@interface SSNDBPool : NSObject

+ (instancetype)shareInstance;

- (SSNDB *)dbWithScope:(NSString *)scope;

@end

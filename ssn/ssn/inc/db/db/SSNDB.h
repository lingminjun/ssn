//
//  SSNDB.h
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNDB : NSObject

- (instancetype)initWithScop:(NSString *)scop;

- (NSString *)dbpath;

@end

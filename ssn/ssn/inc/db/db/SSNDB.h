//
//  SSNDB.h
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNDB : NSObject

@property (nonatomic, strong, readonly) NSString *dbpath;

//数据库已经被open
- (instancetype)initWithScop:(NSString *)scop;

@end

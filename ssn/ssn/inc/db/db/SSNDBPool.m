//
//  SSNDBPool.m
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBPool.h"
#import "SSNRigidCache.h"

@interface SSNDBPool ()

@property (nonatomic, strong) SSNRigidCache *cache;

@end

@implementation SSNDBPool

+ (instancetype)shareInstance
{
    static SSNDBPool *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ share = [[SSNDBPool alloc] init]; });
    return share;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        SSNConstructor constructor = ^id(id key, NSDictionary *userInfo) {
            NSString *scop = (NSString *)key;
            return [[SSNDB alloc] initWithScop:scop];
        };
        _cache = [[SSNRigidCache alloc] initWithConstructor:constructor];
    }
    return self;
}

- (SSNDB *)dbWithScop:(NSString *)scop
{
    if (nil == scop)
    {
        return nil;
    }

    return [_cache objectForKey:scop];
}

@end

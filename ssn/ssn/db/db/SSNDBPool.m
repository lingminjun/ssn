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
            NSString *scope = (NSString *)key;
            return [[SSNDB alloc] initWithScope:scope];
        };
        _cache = [[SSNRigidCache alloc] initWithConstructor:constructor];
    }
    return self;
}

- (SSNDB *)dbWithScope:(NSString *)scope
{
    if (nil == scope)
    {
        return nil;
    }

    return [_cache objectForKey:scope];
}

@end

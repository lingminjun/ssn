//
//  SSNDataStore+Factory.m
//  ssn
//
//  Created by lingminjun on 14/12/8.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDataStore+Factory.h"
#import "SSNRigidCache.h"

@implementation SSNDataStore (Factory)

/**
 @brief Documents/ssnstore/[scope]目录下缓存
 */
+ (instancetype)dataStoreWithScope:(NSString *)scope {
    if ([scope length] == 0) {
        return nil;
    }
    
    static SSNRigidCache *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[SSNRigidCache alloc] initWithConstructor:^id(NSString *key, NSDictionary *userInfo) {
            return [[SSNDataStore alloc] initWithScope:key isCacheDir:NO];
        }];
        [shared setCountLimit:1];//
    });
    
    return [shared objectForKey:scope];
}


/**
 @brief Library/Caches/ssnstore/[scope]目录下缓存
 */
+ (instancetype)cacheStoreWithScope:(NSString *)scope {
    if ([scope length] == 0) {
        return nil;
    }
    
    static SSNRigidCache *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[SSNRigidCache alloc] initWithConstructor:^id(NSString *key, NSDictionary *userInfo) {
            return [[SSNDataStore alloc] initWithScope:key isCacheDir:YES];
        }];
        [shared setCountLimit:1];//
    });
    
    return [shared objectForKey:scope];
}

@end

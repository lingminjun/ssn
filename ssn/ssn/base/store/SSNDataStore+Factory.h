//
//  SSNDataStore+Factory.h
//  ssn
//
//  Created by lingminjun on 14/12/8.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDataStore.h"

@interface SSNDataStore (Factory)

/**
 @brief Documents/ssnstore/[scope]目录下缓存
 */
+ (instancetype)dataStoreWithScope:(NSString *)scope;


/**
 @brief Library/Caches/ssnstore/[scope]目录下缓存
 */
+ (instancetype)cacheStoreWithScope:(NSString *)scope;


/**
 @brief tmp/ssnstore/[scope]目录下缓存
 */
+ (instancetype)temporaryStoreWithScope:(NSString *)scope;

@end

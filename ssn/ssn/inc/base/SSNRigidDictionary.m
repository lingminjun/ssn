//
//  SSNRigidDictionary.m
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNRigidDictionary.h"
#import <pthread.h>

@interface SSNRigidDictionary ()
{
    NSCache *_cache;
    pthread_mutex_t _mutex;

    SSNConstructor _constructor;
}

@end

@implementation SSNRigidDictionary

- (instancetype)initWithConstructor:(SSNConstructor)constructor
{
    NSAssert(constructor, @"SSNRigidDictionary 必须 传入正确的 构造器，不然生产的实例没有意义");
    self = [super init];
    if (self)
    {
        _constructor = constructor;
        pthread_mutex_init(&_mutex, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_mutex);
}

- (void)setCountLimit:(NSUInteger)lim
{
    [_cache setCountLimit:lim];
}

- (NSUInteger)countLimit
{
    return [_cache countLimit];
}

- (id)objectForKey:(id)key
{
    return [self objectForKey:key userInfo:nil];
}

- (id)objectForKey:(id)key userInfo:(NSDictionary *)userInfo
{
    id obj = [_cache objectForKey:key];
    if (!obj)
    {
        pthread_mutex_lock(&_mutex);
        obj = [_cache objectForKey:key];
        if (!obj)
        {
            if (_constructor)
            {
                obj = _constructor(key, userInfo);
            }
        }
        pthread_mutex_unlock(&_mutex);
    }
    return obj;
}

- (void)removeObjectForKey:(id)key
{
    pthread_mutex_lock(&_mutex);
    [_cache removeObjectForKey:key];
    pthread_mutex_unlock(&_mutex);
}

@end

//
//  SSNRigidDictionary.m
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNRigidDictionary.h"
#import <pthread.h>

@interface SSNRigidBox : NSObject
@property (nonatomic, strong) id<NSCopying> key;
@property (nonatomic, weak) id obj;
- (instancetype)initWithObject:(id)obj forKey:(id<NSCopying>)key;
+ (instancetype)boxWithObject:(id)obj forKey:(id<NSCopying>)key;
@end

@implementation SSNRigidBox

- (instancetype)initWithObject:(id)obj forKey:(id<NSCopying>)key
{
    self = [super init];
    if (self)
    {
        self.key = key;
        self.obj = obj;
    }
    return self;
}

+ (instancetype)boxWithObject:(id)obj forKey:(id<NSCopying>)key
{
    return [[self alloc] initWithObject:obj forKey:key];
}

#if DEBUG
- (NSString *)debugDescription
{
    return [_obj description];
}
#endif

@end

@interface SSNRigidDictionary ()
{
    NSCache *_cache;
    NSMutableDictionary *_trace;
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

        _trace = [[NSMutableDictionary alloc] initWithCapacity:1];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(memoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    pthread_mutex_destroy(&_mutex);
}

- (void)memoryWarning:(NSNotification *)notify
{
    __weak typeof(self) w_self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(w_self) self = w_self;
        if (!self)
        {
            return;
        }
        [self checkTraceObjects];
    });
}

- (void)setCountLimit:(NSUInteger)lim
{
    [_cache setCountLimit:lim];
}

- (NSUInteger)countLimit
{
    return [_cache countLimit];
}

- (id)objectForKey:(id<NSCopying>)key
{
    return [self objectForKey:key userInfo:nil];
}

- (id)constructorObjectWithKey:(id<NSCopying>)key userInfo:(NSDictionary *)userInfo
{
    id obj = nil;
    @autoreleasepool
    {
        obj = [_cache objectForKey:key];
        if (obj)
        {
            return obj;
        }
        SSNRigidBox *box = [_trace objectForKey:key];
        obj = box.obj;
        if (obj)
        {
            return obj;
        }

        if (_constructor)
        {
            obj = _constructor(key, userInfo);
        }

        if (obj)
        {
            [_cache setObject:obj forKey:key];

            box = [SSNRigidBox boxWithObject:obj forKey:key];
            [_trace setObject:box forKey:key];

            if (_cache.countLimit > 0 && [_trace count] > _cache.countLimit + 5)
            { //肯定存在不合理，limitcout设置存在非合理性，建议使用者修改
                NSAssert(YES, @"limitcout设置存在非合理性，请使用者修改limitcout");

                //非debug状态，需要对数据进行清理
                [self checkTraceObjects];
            }
        }
    }
    return obj;
}

- (id)objectForKey:(id<NSCopying>)key userInfo:(NSDictionary *)userInfo
{
    id obj = [_cache objectForKey:key];
    if (!obj)
    {
        pthread_mutex_lock(&_mutex);
        obj = [self constructorObjectWithKey:key userInfo:userInfo];
        pthread_mutex_unlock(&_mutex);
    }
    return obj;
}

- (void)removeObjectForKey:(id<NSCopying>)key
{
    pthread_mutex_lock(&_mutex);
    [_cache removeObjectForKey:key];
    pthread_mutex_unlock(&_mutex);

    //延迟释放跟踪数据，便于使用者不必确保当前栈区域是否释放对象本身
    __weak typeof(self) w_self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(w_self) self = w_self;
        if (!self)
        {
            return;
        }
        [self removeTraceObjectForKey:key];
    });
}

- (void)removeTraceObjectForKey:(id<NSCopying>)key
{
    pthread_mutex_lock(&_mutex);
    SSNRigidBox *box = [_trace objectForKey:key];
    id obj = box.obj;
    if (!obj)
    {
        [_trace removeObjectForKey:key];
    }
    pthread_mutex_unlock(&_mutex);
}

- (void)checkTraceObjects
{
    NSArray *boxs = [_trace allValues];
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:1];
    for (SSNRigidBox *box in boxs)
    {
        if (box.obj)
        {
            [keys addObject:box.key];
        }
    }
    [_trace removeObjectsForKeys:keys];
}

@end

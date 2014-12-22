//
//  SSNRigidCache.m
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNRigidCache.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@interface SSNRigidBox : NSObject
@property (nonatomic, strong) id<NSCopying> key;
@property (nonatomic, weak) id obj;
@property (nonatomic, weak) SSNRigidCache *dic;
- (instancetype)initWithObject:(id)obj forKey:(id<NSCopying>)key targetDictionary:(SSNRigidCache *)dic;
+ (instancetype)boxWithObject:(id)obj forKey:(id<NSCopying>)key targetDictionary:(SSNRigidCache *)dic;
@end

@interface SSNRigidCache ()
{
    NSCache *_cache;
    NSMutableDictionary *_trace;
    NSString *_name;
    dispatch_queue_t _queue;
    SSNConstructor _constructor;
    const char _trace_tag;
}

@end

@implementation SSNRigidCache

- (instancetype)initWithConstructor:(SSNConstructor)constructor
{
    NSAssert(constructor, @"SSNRigidCache 必须 传入正确的 构造器，不然生产的实例没有意义");
    self = [super init];
    if (self)
    {
        _constructor = constructor;
        _name = [NSString stringWithFormat:@"<RigidDictionary:%p", self];
        _queue = dispatch_queue_create([_name UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_queue, (__bridge const void *)_name, (__bridge void *)_name, NULL);
        _cache = [[NSCache alloc] init];

        CFDictionaryValueCallBacks valueCallBacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
        _trace = (__bridge_transfer NSMutableDictionary *)CFDictionaryCreateMutable(
            NULL, 0, &kCFTypeDictionaryKeyCallBacks, &valueCallBacks);
    }
    return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    if (_queue)
    {
        dispatch_release(_queue);
    }
#endif
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
            [_cache setObject:obj forKey:key]; //发生释放
            return obj;
        }

        if (_constructor)
        {
            obj = _constructor(key, userInfo);
        }

        if (obj)
        {
            [_cache setObject:obj forKey:key]; //发生释放

            box = [SSNRigidBox boxWithObject:obj forKey:key targetDictionary:self];
            [_trace setObject:box forKey:key];

            objc_setAssociatedObject(obj, &_trace_tag, box, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            // objc_getAssociatedObject(obj, &trace_box);
        }
    }
    return obj;
}

- (id)objectForKey:(id<NSCopying>)key userInfo:(NSDictionary *)userInfo
{
    __block id obj = [_cache objectForKey:key];
    if (!obj)
    {
        dispatch_block_t block = ^{ obj = [self constructorObjectWithKey:key userInfo:userInfo]; };
        if (dispatch_get_specific((__bridge const void *)_name))
        {
            block();
        }
        else
        {
            dispatch_sync(_queue, block);
        }
    }
    return obj;
}

- (oneway void)removeObjectForKey:(id<NSCopying>)key
{
    dispatch_async(_queue, ^{ [_cache removeObjectForKey:key]; });
}

- (void)removeTraceObjectForKey:(id<NSCopying>)key
{
    dispatch_block_t block = ^{
        SSNRigidBox *box = [_trace objectForKey:key];
        id obj = box.obj;
        if (!obj)
        {
            [_trace removeObjectForKey:key];
        }
    };
    if (dispatch_get_specific((__bridge const void *)_name))
    {
        block();
    }
    else
    {
        dispatch_sync(_queue, block);
    }
}

@end

@implementation SSNRigidBox

- (instancetype)initWithObject:(id)obj forKey:(id<NSCopying>)key targetDictionary:(SSNRigidCache *)dic
{
    self = [super init];
    if (self)
    {
        self.key = key;
        self.obj = obj;
        self.dic = dic;
    }
    return self;
}

+ (instancetype)boxWithObject:(id)obj forKey:(id<NSCopying>)key targetDictionary:(SSNRigidCache *)dic
{
    return [[self alloc] initWithObject:obj forKey:key targetDictionary:dic];
}

- (void)dealloc
{
    [_dic removeTraceObjectForKey:_key];
}

#if DEBUG
- (NSString *)debugDescription
{
    return [_obj description];
}
#endif

@end

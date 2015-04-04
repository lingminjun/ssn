//
//  SSNRPCInvocation.m
//  ssn
//
//  Created by lingminjun on 15/3/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//
#import "SSNRPCInvocation.h"
#import "SSNSeqGen.h"
#import "SSNSafeDictionary.h"
#import "NSObject+SSNBlock.h"
#import "NSThread+SSN.h"

#define SSNRPCManager [SSNRPCInvocationManager sharedInstance]

NSString *SSNRPCErrorDomain = @"SSNRPC";

@interface SSNRPCInvocationManager : NSObject

@property (nonatomic,strong) SSNSeqGen *gen;
@property (nonatomic,strong) SSNSafeDictionary *invs;

+ (instancetype)sharedInstance;

@end

@interface SSNRPCCacheItem: NSObject

@property (nonatomic,strong) id<SSNRPCCancelable> cancel;
@property (nonatomic,copy) void(^result)(SSNRPCInvokeSeqID seq,id result, NSError *error);

+ (instancetype)itemWithCancel:(id<SSNRPCCancelable>)cancel result:(void(^)(SSNRPCInvokeSeqID seq,id result, NSError *error))result;

@end


@interface SSNRPCInvocation ()

@property (nonatomic,copy) NSString *method;

@property (nonatomic,strong) NSMutableDictionary *args;

@end

@implementation SSNRPCInvocation

#pragma mark initialization
- (instancetype)init {
    return [self initWithMethod:nil];//Assert
}

- (instancetype)initWithMethod:(NSString *)method {
    NSAssert([method length], @"初始化无意义的method！请修复此bug");
    self = [super init];
    if (self) {
        _method = method;
        _args = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

+ (instancetype)invocationWithMethod:(NSString *)method {
    return [[[self class] alloc] initWithMethod:method];
}

#pragma mark args处理
- (id)argumentForKey:(NSString *)key {
    return [_args objectForKey:key];
}

- (void)setArgument:(id)argument forKey:(NSString *)key {
    if (!key) {
        return ;
    }
    
    if (argument) {
        [_args setObject:argument forKey:key];
    }
    else {
        [_args removeObjectForKey:key];
    }
}

- (void)removeArgumentForKey:(NSString *)key {
    if (!key) {
        return ;
    }
    
    [_args removeObjectForKey:key];
}

- (NSDictionary *)arguments {
    return [_args copy];
}

#pragma mark invoke实现
- (void)nothing {}

- (void)avoidRunloopNoLoopSource {
    
}

- (id)invokeWithTarget:(id<SSNRPCInvoker>)target timeout:(NSTimeInterval)timeout error:(NSError **)error {
    if (!target) {
        return nil;
    }
    
    NSTimeInterval time = timeout < 0.5f ? SSNRPCDefaultTimeout : timeout;
    
    NSUInteger seq = [SSNRPCManager.gen seq];
    
    /**
     *  finish变量暴露在多个线程中，但是此处不需要加锁
     *  因为finish的值仅仅会被修改一次，而且会反复check其值，
     *  即使某一次去掉脏数据，也无关紧要，下次就能正常work
     */
    __block BOOL finish = NO;
    __block id result = nil;
    __block NSError *inner_error = nil;//安全考虑，参数error不能带入block中
    
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRetain(runloop);
    
    void (^block)(id result, NSError *error) = ^(id ret, NSError *err) {
        if (finish) {//表示早已经超时处理过了
            return ;
        }
        
        //先处理结果
        result = ret;
        
        if (err) {
            inner_error = err;
        }
        
        //停止嵌套runloop
        finish = YES;
        
        CFRunLoopStop(runloop);
        CFRelease(runloop);
    };

    //此处注意，最终block必须调用，否则会造成runloop泄漏
    [target rpc_processInvocation:self seq:seq result:block];
    
    //等待block执行
    [NSThread ssn_runloopBlockUntilCondition:^SSNBreak{ return finish; } atSpellTime:time];
    
    //将error赋值
    if (error) {
        if (!finish) {
            *error = [[NSError alloc] initWithDomain:SSNRPCErrorDomain code:408 userInfo:@{NSLocalizedFailureReasonErrorKey:@"请求超时"}];
        }
        else {
            *error = inner_error;
        }
    }
    
    finish = YES;
    
    return result;
}

/**
 *  发起异步rpc
 *
 *  @param target  执行者
 *  @param timeout 超时时间，若超时错误，code = 408
 *  @param result  返回结果
 *
 *  @return 请求id
 */
- (SSNRPCInvokeSeqID)asynInvokeWithTarget:(id<SSNRPCInvoker>)target timeout:(NSTimeInterval)timeout result:(void(^)(SSNRPCInvokeSeqID seq,id result, NSError *error))result {
    if (!target) {
        return SSNRPCInvokeInvalidID;
    }
    
    NSTimeInterval time = timeout < 0.5f ? SSNRPCDefaultTimeout : timeout;
    
    NSUInteger seq = [SSNRPCManager.gen seq];
    
    __block char syncState = 0;
#define TheStateIsSync            (1)
#define TheStateIsAsync           (2)
    
    void (^block)(id result, NSError *error) = ^(id ret, NSError *err) {
        
        if (syncState == TheStateIsAsync) {//非同步，需要检查是否超时
            NSNumber *key = @(seq);
            if (![SSNRPCManager.invs objectForKey:key]) {//说明已经取消
                return ;
            }
            
            //移除超时记录
            [SSNRPCManager.invs removeObjectForKey:key];
        }
        else {//标记同步
            syncState = TheStateIsSync;
        }
        
        //处理结果
        if (result) {
            result(seq,ret,err);
        }
    };
    
    //超时
    [self ssn_mainThreadAfter:time block:^{
        NSNumber *key = @(seq);
        SSNRPCCacheItem *item = [SSNRPCManager.invs objectForKey:key];
        if (item) {
            [item.cancel rpc_cancel];
            [SSNRPCManager.invs removeObjectForKey:key];
            
            //处理结果
            NSError *error = [[NSError alloc] initWithDomain:SSNRPCErrorDomain code:408 userInfo:@{NSLocalizedFailureReasonErrorKey:@"请求超时"}];
            if (result) {
                result(seq,nil,error);
            }
        }
    }];
    
    //执行
    id<SSNRPCCancelable> cancelable = [target rpc_processInvocation:self seq:seq result:block];
    
    //是否同步，若同步，不在将seq加入到队列
    if (syncState == TheStateIsSync) {
        //do nothing
    }
    else {
        syncState = TheStateIsAsync;
        
        SSNRPCCacheItem *item = [SSNRPCCacheItem itemWithCancel:cancelable result:result];
        [SSNRPCManager.invs setObject:item forKey:@(seq)];
    }
    
    return seq;
}


+ (void)cancelInvocationWithSeq:(SSNRPCInvokeSeqID)seq {
    NSNumber *key = @(seq);
    SSNRPCCacheItem *item = [SSNRPCManager.invs objectForKey:key];
    if (item) {
        [item.cancel rpc_cancel];
        
        void(^result)(SSNRPCInvokeSeqID seq,id result, NSError *error) = item.result;
        
        [SSNRPCManager.invs removeObjectForKey:key];
        
        //处理结果
        NSError *error = [[NSError alloc] initWithDomain:SSNRPCErrorDomain code:426 userInfo:@{NSLocalizedFailureReasonErrorKey:@"请求已取消"}];
        if (result) {
            result(seq,nil,error);
        }
    }
}

@end

@implementation SSNRPCInvocationManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _gen = [[SSNSeqGen alloc] init];
        _invs = [[SSNSafeDictionary alloc] initWithCapacity:1];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static SSNRPCInvocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SSNRPCInvocationManager alloc] init];
    });
    return manager;
}

@end

@implementation SSNRPCCacheItem

+ (instancetype)itemWithCancel:(id<SSNRPCCancelable>)cancel result:(void(^)(SSNRPCInvokeSeqID seq,id result, NSError *error))result {
    SSNRPCCacheItem *item = [[SSNRPCCacheItem alloc] init];
    item.cancel = cancel;
    item.result = result;
    return item;
}

@end

/**
 *  一些方便的接口定义
 */
@implementation SSNRPCInvocation (Effective)

#pragma mark Subscript
- (id)objectForKeyedSubscript:(NSString *)key {
    return [self argumentForKey:key];
}
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [self setArgument:obj forKey:key];
}

#pragma mark Value Types
- (void)argumentBool:(BOOL)boolv forKey:(NSString *)key {
    [self setArgument:@(boolv) forKey:key];
}

- (void)argumentInt:(int)intv forKey:(NSString *)key {
    [self setArgument:@(intv) forKey:key];
}

- (void)argumentInt32:(int32_t)intv forKey:(NSString *)key {
    [self setArgument:@(intv) forKey:key];
}
- (void)argumentInt64:(int64_t)intv forKey:(NSString *)key {
    [self setArgument:@(intv) forKey:key];
}
- (void)argumentFloat:(float)realv forKey:(NSString *)key {
    [self setArgument:@(realv) forKey:key];
}
- (void)argumentDouble:(double)realv forKey:(NSString *)key {
    [self setArgument:@(realv) forKey:key];
}

- (BOOL)argumentBoolForKey:(NSString *)key {
    return [[self argumentForKey:key] boolValue];
}
- (int)argumentIntForKey:(NSString *)key {
    return [[self argumentForKey:key] intValue];
}
- (int32_t)argumentInt32ForKey:(NSString *)key {
    return [[self argumentForKey:key] intValue];
}
- (int64_t)argumentInt64ForKey:(NSString *)key {
    return [[self argumentForKey:key] longLongValue];
}
- (float)argumentFloatForKey:(NSString *)key {
    return [[self argumentForKey:key] floatValue];
}
- (double)argumentDoubleForKey:(NSString *)key {
    return [[self argumentForKey:key] doubleValue];
}

- (void)argumentInteger:(NSInteger)intv forKey:(NSString *)key {
    [self setArgument:@(intv) forKey:key];
}
- (NSInteger)argumentIntegerForKey:(NSString *)key {
    return [[self argumentForKey:key] integerValue];
}

@end



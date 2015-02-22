//
//  SSNMessageInterceptor.m
//  ssn
//
//  Created by lingminjun on 15/2/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNMessageInterceptor.h"

@interface SSNMessageWeakInterceptor : NSObject

@property (nonatomic,weak) id<SSNMessageInterceptorFilter> interceptor;

@end

@implementation SSNMessageWeakInterceptor
+ (instancetype)weakInterceptorWithInterceptor:(id<SSNMessageInterceptorFilter>)interceptor {
    SSNMessageWeakInterceptor *weakBox = [[SSNMessageWeakInterceptor alloc] init];
    weakBox.interceptor = interceptor;
    return weakBox;
}
@end

@interface SSNMessageInterceptor ()
@property (nonatomic,strong) NSMutableArray *itrs;
@end


@implementation SSNMessageInterceptor

- (NSArray *)interceptors {
    NSMutableArray *interceptors = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *removeItrs = [NSMutableArray arrayWithCapacity:1];
    [_itrs enumerateObjectsUsingBlock:^(SSNMessageWeakInterceptor *obj, NSUInteger idx, BOOL *stop) {
        id<SSNMessageInterceptorFilter> itr = obj.interceptor;
        if (itr) {
            [interceptors addObject:itr];
        }
        else {
            [removeItrs addObject:obj];
        }
    }];
    
    if ([removeItrs count]) {
        [_itrs removeObjectsInArray:removeItrs];
    }
    
    return interceptors;
}


/**
 *  拦截器初始化
 *
 *  @param interceptors 拦截者 @see id<SSNMessageInterceptorFilter> 类型对象
 *  @param receiver     接受者
 *
 *  @return 拦截器
 */
- (instancetype)initWithInterceptors:(NSArray *)interceptors receiver:(id)receiver {
    //NSAssert([interceptors count], @"没有拦截者,拦截器创建无意义");
    self = [super init];
    if (self) {
        _itrs = [[NSMutableArray alloc] initWithCapacity:1];
        [interceptors enumerateObjectsUsingBlock:^(id<SSNMessageInterceptorFilter> obj, NSUInteger idx, BOOL *stop) {
            SSNMessageWeakInterceptor *weakBox = [SSNMessageWeakInterceptor weakInterceptorWithInterceptor:obj];
            [_itrs addObject:weakBox];
        }];
        _receiver = receiver;
    }
    return self;
}

+ (instancetype)interceptorWithInterceptors:(NSArray *)interceptors receiver:(id)receiver {
    return [[[self class] alloc] initWithInterceptors:interceptors receiver:receiver];
}

/**
 *  添加拦截者
 *
 *  @param interceptor 添加拦截者
 */
- (void)addInterceptor:(id <SSNMessageInterceptorFilter>)interceptor {
    __block BOOL contained = NO;
    [_itrs enumerateObjectsUsingBlock:^(SSNMessageWeakInterceptor *obj, NSUInteger idx, BOOL *stop) {
        if (obj.interceptor == interceptor) {
            contained = YES;
            *stop  = YES;
        }
    }];
    
    if (!contained) {
        SSNMessageWeakInterceptor *weakBox = [SSNMessageWeakInterceptor weakInterceptorWithInterceptor:interceptor];
        [_itrs addObject:weakBox];
    }
}

/**
 *  删除拦截者
 *
 *  @param interceptor 需要删除的拦截者
 */
- (void)removeInterceptor:(id <SSNMessageInterceptorFilter>)interceptor {
    __block SSNMessageWeakInterceptor *box = nil;
    [_itrs enumerateObjectsUsingBlock:^(SSNMessageWeakInterceptor *obj, NSUInteger idx, BOOL *stop) {
        if (obj.interceptor == interceptor) {
            box = obj;
            *stop  = YES;
        }
    }];
    
    if (box) {
        [_itrs removeObject:box];
    }
}


#pragma mark - 消息转发
- (BOOL)respondsToSelector:(SEL)aSelector {
    NSArray *interceptors = [self interceptors];
    NSLog(@"%@",NSStringFromSelector(aSelector));
    BOOL isStop = NO;
    SEL stopSelector = @selector(ssn_stopRespondsToSelector:);
    for (id<SSNMessageInterceptorFilter> itr in interceptors) {
        BOOL responds = [itr respondsToSelector:aSelector];
        if (responds) {
            return responds;
        }
        
        if (!isStop && [itr respondsToSelector:stopSelector]) {
            isStop = [itr ssn_stopRespondsToSelector:aSelector];
        }
    }
    
    if (!isStop) {
        return [_receiver respondsToSelector:aSelector];
    }
    
    return [super respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSArray *interceptors = [self interceptors];
    
    BOOL isStop = NO;
    SEL stopSelector = @selector(ssn_stopRespondsToSelector:);
    for (id<SSNMessageInterceptorFilter> itr in interceptors) {
        NSMethodSignature *signature = [(NSObject *)itr methodSignatureForSelector:aSelector];
        if (signature) {
            return signature;
        }
        
        if (!isStop && [itr respondsToSelector:stopSelector]) {
            isStop = [itr ssn_stopRespondsToSelector:aSelector];
        }
    }
    
    if (!isStop) {
        return [_receiver methodSignatureForSelector:aSelector];
    }
    
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSArray *interceptors = [self interceptors];
    
    SEL aSelector = anInvocation.selector;
    
    BOOL isStop = NO;
    SEL stopSelector = @selector(ssn_stopRespondsToSelector:);
    
    for (id<SSNMessageInterceptorFilter> itr in interceptors) {
        
        if ([itr respondsToSelector:aSelector]) {
            [anInvocation invokeWithTarget:itr];
        }
        
        if (!isStop && [itr respondsToSelector:stopSelector]) {
            isStop = [itr ssn_stopRespondsToSelector:aSelector];
        }
    }
    
    if (isStop) {
        return ;
    }
    
    if ([_receiver respondsToSelector:aSelector]) {
        [anInvocation invokeWithTarget:_receiver];
    }
}

@end

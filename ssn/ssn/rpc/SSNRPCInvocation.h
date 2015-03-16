//
//  SSNRPCInvocation.h
//  ssn
//
//  Created by lingminjun on 15/3/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SSNRPCInvokeInvalidID (0)//无效的请求id号
#define SSNRPCDefaultTimeout  (120)//2分钟超时

FOUNDATION_EXTERN NSString *SSNRPCErrorDomain;

/**
 *  调用者协议
 */
@protocol SSNRPCInvoker,SSNRPCCancelable;

/**
 *  请求id号，如果为零表示无用id号
 */
typedef NSUInteger SSNRPCInvokeSeqID;


/**
 *  远程调用 NSInvocation
 */
@interface SSNRPCInvocation : NSObject

/**
 *  唯一初始化接口
 *
 *  @param method 远程方法名，也可以理解为API，或者理解为URI，不能为空或者空字符串
 *
 *  @return 返回Invovation实例
 */
- (instancetype)initWithMethod:(NSString *)method;

/**
 *  工程方法
 *
 *  @param method 远程方法名，也可以理解为API，或者理解为URI，不能为空或者空字符串
 *
 *  @return 返回Invovation实例
 */
+ (instancetype)invocationWithMethod:(NSString *)method;

/**
 *  方法名
 */
@property (nonatomic,copy,readonly) NSString *method;//方法名，非空

/**
 *  非请求相关信息，传递给委托供配置需要
 */
@property (nonatomic,copy) NSDictionary *userInfo;

/**
 *  获取设置的参数
 *
 *  @param key 参数的key
 *
 *  @return 返回参数
 */
- (id)argumentForKey:(NSString *)key;

/**
 *  设置参数
 *
 *  @param argument 参数
 *  @param key      参数key
 */
- (void)setArgument:(id)argument forKey:(NSString *)key;

/**
 *  删除某个参数
 *
 *  @param key 参数名字
 */

/**
 *  所有参数返回
 *
 *  @return 所有参数
 */
- (NSDictionary *)arguments;

/**
 *  发起rpc调用
 *
 *  @param target  方法执行者
 *  @param timeout 超时时间(秒)，若超时错误，code = 408
 *  @param error   返回的错误
 *
 *  @return 最终的结果
 */
- (id)invokeWithTarget:(id<SSNRPCInvoker>)target timeout:(NSTimeInterval)timeout error:(NSError **)error;

/**
 *  发起异步rpc
 *
 *  @param target  执行者
 *  @param timeout 超时时间(秒)，若超时错误，code = 408
 *  @param result  返回结果
 *
 *  @return 请求id
 */
- (SSNRPCInvokeSeqID)asynInvokeWithTarget:(id<SSNRPCInvoker>)target timeout:(NSTimeInterval)timeout result:(void(^)(SSNRPCInvokeSeqID seq,id result, NSError *error))result;

/**
 *  取消请求调用，主动取消，将返回错误，code = 426
 *
 *  @param seq 请求序列id
 */
+ (void)cancelInvocationWithSeq:(SSNRPCInvokeSeqID)seq;

@end

/**
 *  调用者协议
 */
@protocol SSNRPCInvoker <NSObject>

@required
/**
 *  最终调用者需要实现此方法，此时不需要考虑任何线程问题，只需要实现同步调用即可
 *
 *  @param anInvocation 一个请求可以被转发到多个执行者
 *  @param seq          调用流水id
 *  @param error        错误返回
 *  @return 返回可以取消本次请求
 */
- (id<SSNRPCCancelable>)rpc_processInvocation:(SSNRPCInvocation *)anInvocation seq:(SSNRPCInvokeSeqID)seq result:(void(^)(id result, NSError *error))result;

@end

/**
 *  取消请求协议
 */
@protocol SSNRPCCancelable <NSObject>

@required
/**
 *  取消请求
 */
- (void)rpc_cancel;

@end

/**
 *  一些方便的接口定义
 */
@interface SSNRPCInvocation (Effective)

#pragma mark Subscript
- (id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;

#pragma mark Value Types
- (void)argumentBool:(BOOL)boolv forKey:(NSString *)key;
- (void)argumentInt:(int)intv forKey:(NSString *)key;
- (void)argumentInt32:(int32_t)intv forKey:(NSString *)key;
- (void)argumentInt64:(int64_t)intv forKey:(NSString *)key;
- (void)argumentFloat:(float)realv forKey:(NSString *)key;
- (void)argumentDouble:(double)realv forKey:(NSString *)key;

- (BOOL)argumentBoolForKey:(NSString *)key;
- (int)argumentIntForKey:(NSString *)key;
- (int32_t)argumentInt32ForKey:(NSString *)key;
- (int64_t)argumentInt64ForKey:(NSString *)key;
- (float)argumentFloatForKey:(NSString *)key;
- (double)argumentDoubleForKey:(NSString *)key;

- (void)argumentInteger:(NSInteger)intv forKey:(NSString *)key;
- (NSInteger)argumentIntegerForKey:(NSString *)key;

@end




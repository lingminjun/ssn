//
//  SSNMessageInterceptor.h
//  ssn
//
//  Created by lingminjun on 15/2/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  拦截器方法过滤器，表示停止继续响应此方法
 */
@protocol SSNMessageInterceptorFilter <NSObject>

@optional
/**
 *  是否继续响应此方法（不实现表示不做拦截）
 *
 *  @param aSelector 方法
 *
 *  @return 是否停止响应
 */
- (BOOL)ssn_stopRespondsToSelector:(SEL)aSelector;

@end

/**
 *  消息拦截器
 */
@interface SSNMessageInterceptor : NSObject

/**
 *  拦截者 @see id<SSNMessageInterceptorFilter> 类型对象
 *
 *  @return 所有拦截者
 */
- (NSArray *)interceptors;

/**
 *  若接受者释放后，拦截器不在起作用
 */
@property (nonatomic, weak) id receiver;

/**
 *  拦截器初始化
 *
 *  @param interceptors 拦截者 @see id<SSNMessageInterceptorFilter> 类型对象
 *  @param receiver     接受者
 *
 *  @return 拦截器
 */
- (instancetype)initWithInterceptors:(NSArray *)interceptors receiver:(id)receiver;

/**
 *  拦截器工程方法
 *
 *  @param interceptors 拦截者 @see id<SSNMessageInterceptorFilter> 类型对象
 *  @param receiver     接受者
 *
 *  @return 拦截器
 */
+ (instancetype)interceptorWithInterceptors:(NSArray *)interceptors receiver:(id)receiver;

/**
 *  添加拦截者
 *
 *  @param interceptor 添加拦截者
 */
- (void)addInterceptor:(id <SSNMessageInterceptorFilter>)interceptor;

/**
 *  删除拦截者
 *
 *  @param interceptor 需要删除的拦截者
 */
- (void)removeInterceptor:(id <SSNMessageInterceptorFilter>)interceptor;

@end

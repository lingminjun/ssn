//
//  NSObject+SSNTracking.h
//  ssn
//
//  Created by lingminjun on 14-10-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SSNTracking)


/**
 *  设置需要采集的预置信息，将在每次打点发生时去用
 *
 *  @param  value       预置参数值
 *  @param  key         预置参数键值
 */
+ (void)setPresetValue:(NSString *)value forKey:(NSString *)key;


/**
 *  跟踪clazz类实例的selector方法，当这个方法被调用时将会被记录，记录会自动收集预置参数
 *
 *  @param  clazz       跟踪的类
 *  @param  selector    跟踪类实例的方法，方法返回值仅仅支持id，和void类型，其他类型还不支持，方法参数不支持可变参数和联合参数，
 *                      内部采用NSInvocation转发调用，所以自然依赖“NSInvocation does not support invocations of methods
 *                      with either variable numbers of arguments or union arguments.”
 */
+ (void)ssn_tracking_class:(Class)clazz selector:(SEL)selector;//实例跟踪此方法调用


/**
 *  跟踪clazz类实例的selector方法，当这个方法被调用时将会被记录，记录会自动收集预置参数
 *
 *  @param  clazz       跟踪的类
 *  @param  selector    跟踪类实例的方法，方法返回值仅仅支持id，和void类型，其他类型还不支持，方法参数不支持可变参数和联合参数，
 *                      内部采用NSInvocation转发调用，所以自然依赖“NSInvocation does not support invocations of methods
 *                      with either variable numbers of arguments or union arguments.”
 *  @param  ivarList    需要采集的当前实例属性值（若实例找不到属性将异常）
 */
+ (void)ssn_tracking_class:(Class)clazz selector:(SEL)selector collectIvarList:(NSArray *)ivarList;//实例跟踪此方法调用


@end

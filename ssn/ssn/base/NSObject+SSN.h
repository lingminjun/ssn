//
//  NSObject+SSN.h
//  ssn
//
//  Created by lingminjun on 15/4/4.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SSN)

/**
 *  返回一个对象的副本
 *
 *  @return 返回新的对象
 */
- (instancetype)ssn_copy;

/**
 *  用一个对象来重置当前对象（仅仅影响other有的key）
 *
 *  @param other 另一个对象
 */
- (void)ssn_setObject:(id)other;

/**
 *  所有属性名（readonly以及为声明getter和setter方法的都在其中）
 *
 *  @return 属性列表
 */
- (NSSet *)ssn_allProperties;

/**
 *  所有属性名（readonly以及为声明getter和setter方法的都在其中）
 *
 *  @return 属性列表
 */
+ (NSSet *)ssn_allProperties;

/**
 *  某个类的实例对象是否重载了selector，这里不描述父类实现
 *
 *  @param aSelector 被重写的方法
 *
 *  @return 是否重载
 */
+ (BOOL)ssn_instancesOverrideSelector:(SEL)aSelector;

@end

//
//  SSNRigidCache.h
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^SSNConstructor)(id key, NSDictionary *userInfo);//通用构造器定义

/**
 * 内部保证构造器调用线程安全,key暂时不做要求,
 */
@interface SSNRigidCache : NSObject

- (instancetype)initWithConstructor:(SSNConstructor)constructor;

- (void)setCountLimit:(NSUInteger)lim; // lim设置建议要符合构造器产生实例个数峰值
- (NSUInteger)countLimit;//限制不是精准的，凡是没有释放的对象都将被记录

- (id)objectForKey:(id<NSCopying>)key;
- (id)objectForKey:(id<NSCopying>)key userInfo:(NSDictionary *)userInfo;

- (oneway void)removeObjectForKey:(id<NSCopying>)key;//

@end

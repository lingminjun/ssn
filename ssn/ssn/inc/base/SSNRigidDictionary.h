//
//  SSNRigidDictionary.h
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^SSNConstructor)(id key, NSDictionary *userInfo);

/**
 * 内部保证单一构造器,key暂时不做要求,
 */
@interface SSNRigidDictionary : NSObject

- (instancetype)initWithConstructor:(SSNConstructor)constructor;

- (void)setCountLimit:(NSUInteger)lim; // lim设置一定要符合构造器产生实例个数峰值为好
- (NSUInteger)countLimit;

- (id)objectForKey:(id<NSCopying>)key;
- (id)objectForKey:(id<NSCopying>)key userInfo:(NSDictionary *)userInfo;
- (oneway void)removeObjectForKey:(id<NSCopying>)key;

@end

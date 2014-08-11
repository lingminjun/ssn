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
 * 内部保证单一构造器,key暂时不做邀请
 */
@interface SSNRigidDictionary : NSObject

- (instancetype)initWithConstructor:(SSNConstructor)constructor;

- (void)setCountLimit:(NSUInteger)lim;
- (NSUInteger)countLimit;

- (id)objectForKey:(id)key;
- (id)objectForKey:(id)key userInfo:(NSDictionary *)userInfo;
- (void)removeObjectForKey:(id)key;

@end

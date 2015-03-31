//
//  NSNotificationCenter+SSN.m
//  ssn
//
//  Created by lingminjun on 15/3/31.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSNotificationCenter+SSN.h"

@implementation NSNotificationCenter (SSN)

- (void)ssn_addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject {
    [self removeObserver:observer name:aName object:anObject];
    [self addObserver:observer selector:aSelector name:aName object:anObject];
}

/**
 *  在defaultCenter注册，如果已经注册，则删除后再注册
 *
 *  @param observer  监听者
 *  @param aSelector 回调方法
 *  @param aName     通知名
 *  @param anObject  通知发送者
 */
+ (void)ssn_defaultCenterAddObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject {
    [[self defaultCenter] ssn_addObserver:observer selector:aSelector name:aName object:anObject];
}

/**
 *  在defaultCenter 发送通知
 */
+ (void)ssn_defaultCenterPostNotification:(NSNotification *)notification {
    [[self defaultCenter] postNotification:notification];
}
+ (void)ssn_defaultCenterPostNotificationName:(NSString *)aName object:(id)anObject {
    [[self defaultCenter] postNotificationName:aName object:anObject];
}
+ (void)ssn_defaultCenterPostNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    [[self defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

/**
 *  在defaultCenter 移除订阅
 */
+ (void)ssn_defaultCenterRemoveObserver:(id)observer {
    [[self defaultCenter] removeObserver:observer];
}
+ (void)ssn_defaultCenterRemoveObserver:(id)observer name:(NSString *)aName object:(id)anObject {
    [[self defaultCenter] removeObserver:observer name:aName object:anObject];
}

@end

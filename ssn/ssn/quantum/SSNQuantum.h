//
//  SSNQuantum.h
//  ssn
//
//  Created by lingminjun on 14-11-16.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const SSNQuantumProcessorNotification;//delegate不设置情况将以通知形式
FOUNDATION_EXTERN NSString *const SSNQuantumObjectsKey;


@protocol SSNQuantumDelegate;

/**
 *  量子播发器
 */
@interface SSNQuantum : NSObject

@property (nonatomic, readonly) NSTimeInterval interval;//间隔时间
@property (nonatomic, readonly) NSUInteger maxCount;//最大播发量，播发可能超过此值，如果-pushObjects:调用此方法加入数据

@property (nonatomic, weak) id<SSNQuantumDelegate> delegate;

- (void)setExpressQueue:(dispatch_queue_t)queue;

- (instancetype)initWithInterval:(NSTimeInterval)interval maxCount:(NSUInteger)count;
- (instancetype)quantumWithInterval:(NSTimeInterval)interval maxCount:(NSUInteger)count;

- (void)pushObject:(id)object;//加入一个数据
- (void)pushObjects:(NSArray *)objects;//加入一组数据

- (void)express;//立马执行

@end


@protocol SSNQuantumDelegate <NSObject>

@optional
- (void)quantum:(SSNQuantum *)quantum objects:(NSArray *)objects;//执行动作

@end

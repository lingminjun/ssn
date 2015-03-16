//
//  NSThread+SSN.h
//  ssn
//
//  Created by lingminjun on 15/3/15.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL SSNBreak;

@interface NSThread (SSN)

/**
 *  防止当前runloop没有loopsource
 */
- (void)ssn_avoidEmptyLoopSource;

/**
 *  采用runloop阻塞当前线程，指导某个条件出现
 *
 *  @param condition 条件，返回yes表示跳出block
 *  @param time      超时时间，若time小于等于零，表示永不超时
 */
+ (void)ssn_runloopBlockUntilCondition:(SSNBreak (^)(void))condition atSpellTime:(NSTimeInterval)time;

@end

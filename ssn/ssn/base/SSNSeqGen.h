//
//  SSNSeqGen.h
//  ssn
//
//  Created by lingminjun on 15/3/15.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SSNSeqGenDefaultCycleSize   (999999)//默认训话尺

/**
 *  序列号生成器
 */
@interface SSNSeqGen : NSObject

/**
 *  默认循环尺度
 *
 *  @return gen
 */
- (instancetype)init;

/**
 *  初始化方法
 *
 *  @param size 表示序列号将在(0,size]中循环取值，若传入0则采用默认循环尺，不能超过NSUIntegerMax
 *
 *  @return gen
 */
- (instancetype)initWithCycleSize:(NSUInteger)size;

/**
 *  cycle size
 */
@property (nonatomic,readonly) NSUInteger cycleSize;

/**
 *  最近一次被取得的seq number
 *
 *  @return 返回最后一次被取得的seq number
 */
- (NSUInteger)seed;

/**
 *  获取新的seq number
 *
 *  @return seq number
 */
- (NSUInteger)seq;

@end

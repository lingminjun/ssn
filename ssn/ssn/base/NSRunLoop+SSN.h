//
//  NSRunLoop+SSN.h
//  ssn
//
//  Created by lingminjun on 15/4/1.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  runloop使得单线程能够处理多任务场景，但是loop source的执行顺序我们无法预测
 *  提供一个执行标记工具，你可以用来记录当前loop source执行是否还有依赖
 *  注意：NSRunloop非线程安全，故这些方法只适应于当线程使用
 */
@interface NSRunLoop (SSN)

/**
 *  打一个标签
 *
 *  @param tag 标签所属业务
 *
 *  @return 所打的标签，非零
 */
- (int64_t)ssn_push_flag_for_tag:(NSUInteger)tag;

/**
 *  去掉一个标签
 *
 *  @param tag 标签所属业务
 *
 *  @return 返回当前top标签，非零，若返回0没有标签
 */
- (int64_t)ssn_pop_flag_for_tag:(NSUInteger)tag;

/**
 *  查看当前业务线(tag)下所有标签总数
 *
 *  @param tag 标签所属业务
 *
 *  @return 返回标签总数
 */
- (NSUInteger)ssn_flag_count_for_tag:(NSUInteger)tag;

/**
 *  返回top标签
 *
 *  @param tag 标签所属业务
 *
 *  @return 返回top的标签，非零，若返回0没有标签
 */
- (int64_t)ssn_top_flag_for_tag:(NSUInteger)tag;

@end


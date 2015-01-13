//
//  NSObject+SSNBlock.h
//  ssn
//
//  Created by lingminjun on 15/1/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  主要替换如下过程：
 dispatch_async(dispatch_get_main_queue(), ^{
    //todo
 });
 
 这种方式在某种情况下存在风险，如果一个底层系统回调到主线程时，千万不要随意使用上面的方式
 这是一种不可预测的写法，可能造成main_queue阻断，如果block中又嵌套的runloop，
 将造成后续的block无法执行
 */
@interface NSObject (SSNBlock)

/**
 *  到主线程中同步执行block
 *
 *  @param block 执行的block
 */
- (void)ssn_mainThreadSyncBlock:(dispatch_block_t)block;

/**
 *  到主线程中异步执行block
 *
 *  @param block 执行的block
 */
- (void)ssn_mainThreadAsyncBlock:(dispatch_block_t)block;

@end

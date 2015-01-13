//
//  NSObject+SSNBlock.m
//  ssn
//
//  Created by lingminjun on 15/1/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSObject+SSNBlock.h"

@implementation NSObject (SSNBlock)

- (void)ssn_execute_block:(dispatch_block_t)block {
    block();
}

/**
 *  到主线程中同步执行block
 *
 *  @param block 执行的block
 */
- (void)ssn_mainThreadSyncBlock:(dispatch_block_t)block {
    if (block) {
        [self performSelectorOnMainThread:@selector(ssn_execute_block:) withObject:block waitUntilDone:YES];
    }
}

/**
 *  到主线程中异步执行block
 *
 *  @param block 执行的block
 */
- (void)ssn_mainThreadAsyncBlock:(dispatch_block_t)block {
    if (block) {
        [self performSelectorOnMainThread:@selector(ssn_execute_block:) withObject:block waitUntilDone:NO];
    }
}

@end

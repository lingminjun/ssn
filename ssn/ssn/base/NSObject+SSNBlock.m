//
//  NSObject+SSNBlock.m
//  ssn
//
//  Created by lingminjun on 15/1/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSObject+SSNBlock.h"

@interface SSNCancelable : NSObject <SSNCancelable>
@property (nonatomic,weak) id target;
@property (nonatomic,copy) dispatch_block_t block;
@end

@implementation NSObject (SSNBlock)

- (void)ssn_execute_block:(dispatch_block_t)block {
    block();
}

- (void)ssn_execute_cancelable_block:(SSNCancelable *)cancelable {
    if (cancelable.block) {
        cancelable.block();
    }
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

/**
 *  到主线程中异步执行block
 *
 *  @param block 执行的block
 */
- (id<SSNCancelable>)ssn_handlerMainThreadAsyncBlock:(dispatch_block_t)block {
    if (!block) {
        return nil;
    }
    
    SSNCancelable *obj = [[SSNCancelable alloc] init];
    obj.block = block;
    obj.target = self;
    [self performSelectorOnMainThread:@selector(ssn_execute_cancelable_block:) withObject:obj waitUntilDone:NO];
    return obj;
}

/**
 *  到主线程中延迟执行block
 *
 *  @param block 执行的block
 */
- (void)ssn_mainThreadAfter:(NSTimeInterval)after block:(dispatch_block_t)block {
    if (block) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
    }
}

@end


@implementation SSNCancelable

- (void)ssn_cancel {
    self.block = nil;
    
    id atarget = self.target;
    if (atarget) {
        [NSObject cancelPreviousPerformRequestsWithTarget:atarget selector:@selector(ssn_execute_cancelable_block:) object:self];
    }
}

@end


//
//  NSThread+SSN.m
//  ssn
//
//  Created by lingminjun on 15/3/15.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSThread+SSN.h"

NSString *const SSNAvoidEmptyLoopSourceFlag = @"SSNAvoidEmptyLoopSourceFlag";

@implementation NSThread (SSN)

- (void)ssn_avoidEmptyLoopSource {
    
    if ([self.threadDictionary objectForKey:SSNAvoidEmptyLoopSourceFlag]) {
        return ;
    }
    
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);

    //标记下
    [self.threadDictionary setObject:SSNAvoidEmptyLoopSourceFlag forKey:SSNAvoidEmptyLoopSourceFlag];
}

/**
 *  采用runloop阻塞当前线程，指导某个条件出现
 *
 *  @param condition 条件，返回yes表示跳出block
 *  @param time      超时时间
 */
+ (void)ssn_runloopBlockUntilCondition:(SSNBreak (^)(void))condition atSpellTime:(NSTimeInterval)time {
    if (!condition) {
        return ;
    }
    
    //先确保runloop非空
    [[NSThread currentThread] ssn_avoidEmptyLoopSource];
    
    //获取超时时间
    CFAbsoluteTime beginAt = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime endAt = 0.0f;
    if (time <= 0.0f) {
        endAt = [[NSDate distantFuture] timeIntervalSince1970];
    }
    else {
        endAt = beginAt + time;
    }
    
    BOOL isBreak = NO;
    
    // Add your sources or timers to the run loop and do any other setup.
    do
    {
        isBreak = condition();
        if (isBreak) {
            break ;
        }
        
        CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime seconds = endAt - now;
        if (seconds <= 0.0f) {
            break ;
        }
        
        @autoreleasepool {
            // Start the run loop but return after each source is handled.
            SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, seconds, YES);
            
            // If a source explicitly stopped the run loop, or if there are no
            // sources or timers, go ahead and exit.
            if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished) || (result == kCFRunLoopRunTimedOut)) {
                break;
            }
        }
    }
    while (YES);
}

@end

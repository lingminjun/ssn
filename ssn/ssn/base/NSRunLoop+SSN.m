//
//  NSRunLoop+SSN.m
//  ssn
//
//  Created by lingminjun on 15/4/1.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSRunLoop+SSN.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif
#import <sys/time.h>

@implementation NSRunLoop (SSN)

static void *ssn_flag_stack_key = NULL;
- (NSMutableArray *)ssn_flag_stack_for_tag:(NSNumber *)tag pop:(BOOL)pop read:(BOOL)read {
    
    if (!tag) {
        return nil;
    }
    
    NSMutableDictionary *stacks = objc_getAssociatedObject(self, &ssn_flag_stack_key);
    if (!stacks) {
        stacks = [[NSMutableDictionary alloc] initWithCapacity:1];
        objc_setAssociatedObject(self, &ssn_flag_stack_key, stacks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSMutableArray *stack = [stacks objectForKey:tag];
    
    if (!stack) {
        if (!pop && !read) {
            stack = [[NSMutableArray alloc] initWithCapacity:1];
            [stacks setObject:stack forKey:tag];
        }
    }
    else {
        if (pop && [stack count] <= 1) {
            [stacks removeObjectForKey:tag];
        }
    }
    
    return stack;
}


- (int64_t)ssn_usec_timestamp {
    struct timeval t;
    gettimeofday(&t, NULL);
    return t.tv_sec * USEC_PER_SEC + t.tv_usec;
}


/**
 *  打一个标签
 *
 *  @param tag 标签所属业务
 *
 *  @return 所打的标签
 */
- (int64_t)ssn_push_flag_for_tag:(NSUInteger)atag {
    NSNumber *tag = @(atag);
    int64_t flag = [self ssn_usec_timestamp];
    NSMutableArray *stack = [self ssn_flag_stack_for_tag:tag pop:NO read:NO];
    [stack addObject:@(flag)];
    return flag;
}

/**
 *  去掉一个标签
 *
 *  @param tag 标签所属业务
 *
 *  @return 返回当前top标签
 */
- (int64_t)ssn_pop_flag_for_tag:(NSUInteger)atag {
    NSNumber *tag = @(atag);
    NSMutableArray *stack = [self ssn_flag_stack_for_tag:tag pop:YES read:NO];
    int64_t flag = [[stack lastObject] longLongValue];
    [stack removeLastObject];
    return flag;
}

/**
 *  查看当前业务线(tag)下所有标签总数
 *
 *  @param tag 标签所属业务
 *
 *  @return 返回标签总数
 */
- (NSUInteger)ssn_flag_count_for_tag:(NSUInteger)atag {
    NSNumber *tag = @(atag);
    NSMutableArray *stack = [self ssn_flag_stack_for_tag:tag pop:NO read:YES];
    return [stack count];
}

/**
 *  返回top标签
 *
 *  @param tag 标签所属业务
 *
 *  @return 返回top的标签
 */
- (int64_t)ssn_top_flag_for_tag:(NSUInteger)atag {
    NSNumber *tag = @(atag);
    NSMutableArray *stack = [self ssn_flag_stack_for_tag:tag pop:NO read:YES];
    int64_t flag = [[stack lastObject] longLongValue];
    return flag;
}

@end

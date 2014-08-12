//
//  SSNCuteSerialQueue.h
//  ssn
//
//  Created by lingminjun on 14-8-12.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  对同步block做了优先执行和嵌套执行策略，对一些敏感事件，同步执行就非常重要
 */
@interface SSNCuteSerialQueue : NSObject

@property (nonatomic, strong, readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name;

- (void)async:(dispatch_block_t)block;

- (void)sync:(dispatch_block_t)block;

@end

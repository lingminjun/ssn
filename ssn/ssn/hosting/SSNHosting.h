//
//  SSNHosting.h
//  ssn
//
//  Created by lingminjun on 14/12/7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 @brief 提供托管服务触发器，
 */
@interface SSNHosting : NSObject

- (void)subscibeCMD:(NSString *)cmd object:(id)obj selector:(SEL)selector;

@end

//
//  SSNBound.h
//  ssn
//
//  Created by lingminjun on 14/12/13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSNSafeDictionary;

/**
 @brief 绑定器联合点，绑定器一定涉及两端端：绑定者和被绑定者
 */
@interface NSObject (SSNBound)

/**
 @brief 绑定器被影响端联合点
 */
- (SSNSafeDictionary *)ssn_bound_dictionary;


/**
 @brief 绑定器变化端联合点
 */
- (SSNSafeDictionary *)ssn_bound_dictionary_tail;


@end

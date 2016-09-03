//
//  FHTTPAccessor.h
//  ssn
//
//  Created by lingminjun on 16/9/2.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  HTTP/HTTPS读取器
 */
@interface FHTTPAccessor : NSObject

/**
 *  初始化方法
 */
- (instancetype)init;
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

//@property (nonatomic, strong) FSecurityPolicy *securityPolicy;

@end

//
//  NSURL+Router.h
//  ssn
//
//  Created by lingminjun on 14-7-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SSNRouter)

- (NSArray *)ssn_routerPaths;

- (NSDictionary *)ssn_queryInfo;//queryString + user/password (value被解码)

//components都是NSString，其中“..”表示上级目录，“.”表示当前目录，“~”表示根目录
- (NSURL *)ssn_relativeURLWithComponents:(NSArray *)components;//

@end

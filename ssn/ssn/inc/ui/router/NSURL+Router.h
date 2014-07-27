//
//  NSURL+Router.h
//  ssn
//
//  Created by lingminjun on 14-7-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SSNRouter)

- (NSArray *)routerPaths;

- (NSDictionary *)queryInfo;

@end

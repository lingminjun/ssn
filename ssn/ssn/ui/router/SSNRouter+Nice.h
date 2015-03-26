//
//  SSNRouter+Nice.h
//  ssn
//
//  Created by lingminjun on 15/3/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNRouter.h"

@interface SSNRouter (Nice)

/**
 * 仅仅支持完整路劲
 */
- (BOOL)open:(NSString *)url; //如果url query中没有animated，默认有动画，
- (BOOL)open:(NSString *)url query:(NSDictionary *)query;//如果url query中没有animated，默认有动画
- (BOOL)open:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated;

@end

@interface NSObject (SSNRouterNice)

/**
 * 支持相对路径打开
 */
- (BOOL)ssn_open:(NSString *)url; //如果url query中没有animated，默认有动画，
- (BOOL)ssn_open:(NSString *)url query:(NSDictionary *)query;//如果url query中没有animated，默认有动画
- (BOOL)ssn_open:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated;

@end

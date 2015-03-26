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
 * 支持相对路径打开，但是必须以".",".."开头才能被识别成相对路径
 */
- (BOOL)open:(NSString *)url; //如果url query中没有animated，默认有动画，
- (BOOL)open:(NSString *)url query:(NSDictionary *)query;//如果url query中没有animated，默认有动画
- (BOOL)open:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated;

@end

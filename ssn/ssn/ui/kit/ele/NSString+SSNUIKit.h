//
//  NSString+SSNUIKit.h
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (SSNUIKit)

/**
 *  返回一个string显示font需要的尺寸
 *
 *  @param font     字体大小
 *  @param maxWidth 最大宽度
 *
 *  @return 返回合适的尺寸
 */
- (CGSize)ssn_sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth;

@end

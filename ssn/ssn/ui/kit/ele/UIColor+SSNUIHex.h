//
//  UIColor+SSNUIHex.h
//  ssn
//
//  Created by lingminjun on 15/1/5.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SSNUIHex)

/**
 *  十六进制颜色描述翻译成一个UIColor
 *
 *  @param value 一个十六进制数，不透明
 *
 *  @return 返回对应的颜色
 */
+ (UIColor *)ssn_colorWithHex:(NSUInteger)value;

/**
 *  十六进制颜色描述翻译成一个UIColor
 *
 *  @param value 一个十六进制数
 *  @param alpha 透明度 0~1.0f
 *
 *  @return 返回对应的颜色
 */
+ (UIColor *)ssn_colorWithHex:(NSUInteger)value alpha:(CGFloat)alpha;

@end

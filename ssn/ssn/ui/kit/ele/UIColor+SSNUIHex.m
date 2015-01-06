//
//  UIColor+SSNUIHex.m
//  ssn
//
//  Created by lingminjun on 15/1/5.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIColor+SSNUIHex.h"

@implementation UIColor (SSNUIHex)

/**
 *  十六进制颜色描述翻译成一个UIColor
 *
 *  @param value 一个十六进制数，不透明
 *
 *  @return 返回对应的颜色
 */
+ (UIColor *)ssn_colorWithHex:(NSUInteger)value {
    return [self ssn_colorWithHex:value alpha:1.0f];
}

/**
 *  十六进制颜色描述翻译成一个UIColor
 *
 *  @param value 一个十六进制数
 *  @param alpha 透明度
 *
 *  @return 返回对应的颜色
 */
+ (UIColor *)ssn_colorWithHex:(NSUInteger)value alpha:(CGFloat)alpha {
    CGFloat r = ((value & 0x00FF0000) >> 16) / 255.0f;
    CGFloat g = ((value & 0x0000FF00) >> 8) / 255.0f;
    CGFloat b = (value & 0x000000FF) / 255.0f;
    return [self colorWithRed:r green:g blue:b alpha:alpha];
}

@end

//
//  UITextField+SSNUIKit.m
//  ssn
//
//  Created by lingminjun on 15/1/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UITextField+SSNUIKit.h"

@implementation UITextField (SSNUIKit)

/**
 *  输入框定义
 *
 *  @param size       尺寸，默认CGSize(180,40)
 *  @param font       字体大小，默认值为14
 *  @param color      字体颜色，默认值为黑色
 *  @param adjustFont 默认值NO
 *  @param minFont    默认值11
 *
 *  @return textField
 */
+ (instancetype)ssn_inputWithSize:(CGSize)size font:(UIFont *)font color:(UIColor *)color adjustFont:(BOOL)adjustFont minFont:(CGFloat)minFont {
    
    //主题读取
    UIFont *aFont = (nil == font ? [UIFont systemFontOfSize:14.0f] : font);
    UIColor *aColor = (nil == color ? [UIColor blackColor] : color);
    
    CGRect frame = CGRectZero;
    frame.size.width = (size.width <= 0.0f ? 180.0f : size.width);
    frame.size.height = (size.height <= 0.0f ? 40.0f : size.height);
    
    CGFloat aMinFont = (minFont < 0.0f ? 11.0f : minFont);
    
    UITextField *input = [[[UITextField class] alloc] initWithFrame:frame];
    input.font = aFont;
    input.textColor = aColor;
    input.adjustsFontSizeToFitWidth = adjustFont;
    input.backgroundColor = [UIColor clearColor];
    input.minimumFontSize = aMinFont;
    
    return input;
}

@end

//
//  UILabel+SSNUIKit.m
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UILabel+SSNUIKit.h"
#import "NSString+SSNUIKit.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif
#import "UIView+SSNUIKit.h"

@implementation UILabel (SSNUIKit)

//宽度是否可伸缩
ssn_uikit_value_synthesize(int, ssn_width_scalable, Ssn_width_scalable)

//最小宽度
ssn_uikit_value_synthesize(float,ssn_min_width,Ssn_min_width)

//最大宽度
ssn_uikit_value_synthesize(float,ssn_max_width,Ssn_max_width)

//行数可调整
ssn_uikit_value_synthesize(int,ssn_multi_line,Ssn_multi_line)

+ (instancetype)ssn_labelWithWidthMin:(CGFloat)min max:(CGFloat)max widthScalable:(BOOL)widthScalable font:(UIFont *)font color:(UIColor *)color backgroud:(UIColor *)backgroud alignment:(NSTextAlignment)alignment multiLine:(BOOL)multiLine {
    
    //主题读取
    UIFont *aFont = (nil == font ? [UIFont systemFontOfSize:14.0f] : font);
    UIColor *aColor = (nil == color ? [UIColor blackColor] : color);
    UIColor *aBackgroud = (nil == backgroud ? [UIColor whiteColor] : backgroud);
    
    CGRect frame = CGRectZero;
    
    CGFloat aMax = ssn_ceil( max < 0.0f ? 300.0f : max );
    frame.size.width = aMax;
    frame.size.height = ssn_ceil(aFont.lineHeight);
    
    UILabel *label = [[[UILabel class] alloc] initWithFrame:frame];
    label.font = aFont;
    label.textColor = aColor;
    label.backgroundColor = aBackgroud;
    label.textAlignment = alignment;
    
    label.ssn_width_scalable = widthScalable;
    label.ssn_multi_line = multiLine;
    if (multiLine) {
        label.numberOfLines = 0;
    }
    label.ssn_min_width = ssn_ceil(min > aMax ? aMax : min);
    label.ssn_max_width = ssn_ceil(max);
    
    return label;
}

/**
 *  返回一个宽度为width的label，
 *
 *  @param width     宽度，默认300
 *  @param font      默认值为14
 *  @param color     默认值为黑色
 *  @param backgroud 默认值为白色
 *  @param alignment 默认值为NSTextAlignmentLeft
 *  @param multiLine 默认值为NO，为yes时高度随内容调整
 *
 *  @return label
 */
+ (instancetype)ssn_labelWithWidth:(CGFloat)width font:(UIFont *)font color:(UIColor *)color backgroud:(UIColor *)backgroud alignment:(NSTextAlignment)alignment multiLine:(BOOL)multiLine {
    return [self ssn_labelWithWidthMin:width max:width widthScalable:NO font:font color:color backgroud:backgroud alignment:alignment multiLine:multiLine];
}

/**
 *  返回一个可变长度的label，根据内容调整宽度，调用
 *
 *  @param min       默认值为0
 *  @param max       默认值为300
 *  @param font      默认值为14
 *  @param color     默认值为黑色
 *  @param backgroud 默认值为白色
 *  @param alignment 默认值为NSTextAlignmentLeft
 *  @param multiLine 默认值为NO，为yes时高度随内容调整
 *
 *  @return label
 */
+ (instancetype)ssn_labelWithWidthMin:(CGFloat)min max:(CGFloat)max font:(UIFont *)font color:(UIColor *)color backgroud:(UIColor *)backgroud alignment:(NSTextAlignment)alignment multiLine:(BOOL)multiLine {
    return [self ssn_labelWithWidthMin:min max:max widthScalable:YES font:font color:color backgroud:backgroud alignment:alignment multiLine:multiLine];
}

/**
 *  重新改变尺寸
 */
- (void)ssn_sizeToFit {
    
    BOOL multiLine = [self ssn_multi_line];
    BOOL widthScalable = [self ssn_width_scalable];
    if (!multiLine && !widthScalable) {
        [self sizeToFit];
        return ;
    }
    CGRect frame = self.frame;
    
    CGFloat maxWidth = [self ssn_max_width];
    CGFloat minWidth = [self ssn_min_width];
    
    //可变字体和不可变字体都应该计算后取最大的
    CGSize size1 = CGSizeZero;
    if (self.attributedText) {
        size1 = [self.attributedText ssn_sizeWithMaxWidth:maxWidth];
    }
    
    NSString *text = self.text;
    if (!text) {
        text = @"";
    }
    CGSize size2 = [text ssn_sizeWithFont:self.font maxWidth:maxWidth];
    
    CGSize size = size1;
    if (size2.height > size.height) {
        size = size2;
    }
    
    if (widthScalable) {//宽度需要调整
        if (size.width < minWidth) {
            frame.size.width = minWidth;
        }
        else if (size.width > maxWidth){
            frame.size.width = maxWidth;
        }
        else {
            frame.size.width = size.width;
        }
    }
    
    //多行处理
    if (multiLine) {
        frame.size.height = size.height;
        self.numberOfLines = 0;
    }
    
    self.frame = frame;

}

@end

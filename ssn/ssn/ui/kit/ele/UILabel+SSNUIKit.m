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

@implementation UILabel (SSNUIKit)

//宽度是否可伸缩
static char *ssn_label_width_scalable_key = NULL;
- (BOOL)ssn_width_scalable {
    NSNumber *v = objc_getAssociatedObject(self, &ssn_label_width_scalable_key);
    return [v boolValue];
}
- (void)setSsn_width_scalable:(BOOL)ssn_width_scalable {
    objc_setAssociatedObject(self, &ssn_label_width_scalable_key, @(ssn_width_scalable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//最小宽度
static char *ssn_label_min_width_key = NULL;
- (CGFloat)ssn_min_width {
    NSNumber *v = objc_getAssociatedObject(self, &ssn_label_min_width_key);
    return [v floatValue];
}
- (void)setSsn_min_width:(CGFloat)ssn_min_width {
    objc_setAssociatedObject(self, &ssn_label_min_width_key, @(ssn_min_width), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//最大宽度
static char *ssn_label_max_width_key = NULL;
- (CGFloat)ssn_max_width {
    NSNumber *v = objc_getAssociatedObject(self, &ssn_label_max_width_key);
    return [v floatValue];
}
- (void)setSsn_max_width:(CGFloat)ssn_max_width {
    objc_setAssociatedObject(self, &ssn_label_max_width_key, @(ssn_max_width), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//行数可调整
static char *ssn_label_multi_line_key = NULL;
- (BOOL)ssn_multi_line {
    NSNumber *v = objc_getAssociatedObject(self, &ssn_label_multi_line_key);
    return [v boolValue];
}
- (void)setSsn_multi_line:(BOOL)ssn_multi_line {
    if (ssn_multi_line) {
        self.numberOfLines = 0;
    }
    objc_setAssociatedObject(self, &ssn_label_multi_line_key, @(ssn_multi_line), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (instancetype)ssn_labelWithWidthMin:(CGFloat)min max:(CGFloat)max widthScalable:(BOOL)widthScalable font:(UIFont *)font color:(UIColor *)color backgroud:(UIColor *)backgroud alignment:(NSTextAlignment)alignment multiLine:(BOOL)multiLine {
    
    //主题读取
    UIFont *aFont = (nil == font ? [UIFont systemFontOfSize:14.0f] : font);
    UIColor *aColor = (nil == color ? [UIColor blackColor] : color);
    UIColor *aBackgroud = (nil == backgroud ? [UIColor whiteColor] : backgroud);
    
    CGRect frame = CGRectZero;
    
    CGFloat aMax = ceilf( max < 0.0f ? 300.0f : max );
    frame.size.width = aMax;
    frame.size.height = ceilf(aFont.lineHeight);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = aFont;
    label.textColor = aColor;
    label.backgroundColor = aBackgroud;
    label.textAlignment = alignment;
    
    label.ssn_width_scalable = widthScalable;
    label.ssn_multi_line = multiLine;
    label.ssn_min_width = ceilf(min > aMax ? aMax : min);
    label.ssn_max_width = ceilf(max);
    
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
    
    NSNumber *v = objc_getAssociatedObject(self, &ssn_label_width_scalable_key);
    if (!v) {
        [self sizeToFit];
        return ;
    }
    
    NSString *text = self.text;
    if (!text) {
        text = @"";
    }
    
    CGRect frame = self.frame;
    
    CGFloat maxWidth = [self ssn_max_width];
    CGFloat minWidth = [self ssn_min_width];
    
    BOOL multiLine = [self ssn_multi_line];
    BOOL widthScalable = [self ssn_width_scalable];
    
    CGSize size = [text ssn_sizeWithFont:self.font maxWidth:maxWidth];
    
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
    }
    
    self.frame = frame;
}

@end

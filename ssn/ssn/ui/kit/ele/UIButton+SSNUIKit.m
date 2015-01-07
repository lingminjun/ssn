//
//  UIButton+SSNUIKit.m
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIButton+SSNUIKit.h"
#import "UIView+SSNUIKit.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif
#import "NSString+SSNUIKit.h"

@implementation UIButton (SSNUIKit)

//宽度是否可伸缩
ssn_uikit_value_synthesize(int, ssn_width_scalable, Ssn_width_scalable)

//最小宽度
ssn_uikit_value_synthesize(float,ssn_min_width,Ssn_min_width)

//最大宽度
ssn_uikit_value_synthesize(float,ssn_max_width,Ssn_max_width)

#define ssn_uikit_stret_image(image) [image stretchableImageWithLeftCapWidth:ceilf(image.size.width/2) topCapHeight:ceilf(image.size.width/2)]

+ (instancetype)ssn_buttonWithWidthMin:(CGFloat)min max:(CGFloat)max widthScalable:(BOOL)widthScalable height:(CGFloat)height font:(UIFont *)font color:(UIColor *)color selected:(UIColor *)selectedColor disabled:(UIColor *)disabledColor backgroud:(UIImage *)backgroud selected:(UIImage *)selectedBackgroud disabled:(UIImage *)disabledBackgroud {
    
    UIFont *aFont = (nil == font ? [UIFont systemFontOfSize:14.0f] : font);
    
    CGRect frame = CGRectZero;
    
    CGFloat aMax = ceilf( max < 0.0f ? 300.0f : max );
    frame.size.width = aMax;
    frame.size.height = ceilf( height < 0.0f ? 40.0f : height );
    
    UIButton *button = [[[UIButton class] alloc] initWithFrame:frame];
    button.titleLabel.font = aFont;
    
    if (color) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    
    if (selectedColor) {
        [button setTitleColor:selectedColor forState:UIControlStateHighlighted];
        [button setTitleColor:selectedColor forState:UIControlStateSelected];
        [button setTitleColor:selectedColor forState:UIControlStateHighlighted|UIControlStateSelected];
    }
    
    if (disabledColor) {
        [button setTitleColor:selectedColor forState:UIControlStateDisabled];
    }
    
    if (backgroud) {
        [button setBackgroundImage:ssn_uikit_stret_image(backgroud) forState:UIControlStateNormal];
    }
    
    if (selectedBackgroud) {
        [button setBackgroundImage:ssn_uikit_stret_image(selectedBackgroud) forState:UIControlStateHighlighted];
        [button setBackgroundImage:ssn_uikit_stret_image(selectedBackgroud) forState:UIControlStateSelected];
        [button setBackgroundImage:ssn_uikit_stret_image(selectedBackgroud) forState:UIControlStateHighlighted|UIControlStateSelected];
    }
    
    if (disabledBackgroud) {
        [button setBackgroundImage:ssn_uikit_stret_image(disabledBackgroud) forState:UIControlStateDisabled];
    }
    
    button.ssn_width_scalable = widthScalable;
    button.ssn_min_width = ceilf(min > aMax ? aMax : min);
    button.ssn_max_width = ceilf(max);
    
    return button;
}

/**
 *  生产一个button，可配置的主题
 *
 *  @param size              大小
 *  @param font              字体大小
 *  @param color             字体颜色
 *  @param selectedColor     字体选中颜色（兼高亮）
 *  @param disabledColor     不可用颜色
 *  @param backgroud         背景图
 *  @param selectedBackgroud 选中背景图
 *  @param disabledBackgroud 不可用背景图
 *
 *  @return button
 */
+ (instancetype)ssn_buttonWithSize:(CGSize)size font:(UIFont *)font color:(UIColor *)color selected:(UIColor *)selectedColor disabled:(UIColor *)disabledColor backgroud:(UIImage *)backgroud selected:(UIImage *)selectedBackgroud disabled:(UIImage *)disabledBackgroud {
    return [self ssn_buttonWithWidthMin:size.width max:size.width widthScalable:NO height:size.height font:font color:color selected:selectedColor disabled:disabledColor backgroud:backgroud selected:selectedBackgroud disabled:disabledBackgroud];
}

/**
 *  生产一个button，可配置的主题
 *
 *  @param min               最小宽度
 *  @param max               最大宽度
 *  @param height            高度
 *  @param font              字体大小
 *  @param color             字体颜色
 *  @param selectedColor     字体选中颜色（兼高亮）
 *  @param disabledColor     不可用颜色
 *  @param backgroud         背景图
 *  @param selectedBackgroud 选中背景图
 *  @param disabledBackgroud 不可用背景图
 *
 *  @return button
 */
+ (instancetype)ssn_buttonWithWidthMin:(CGFloat)min max:(CGFloat)max height:(CGFloat)height font:(UIFont *)font color:(UIColor *)color selected:(UIColor *)selectedColor disabled:(UIColor *)disabledColor backgroud:(UIImage *)backgroud selected:(UIImage *)selectedBackgroud disabled:(UIImage *)disabledBackgroud {
    return [self ssn_buttonWithWidthMin:min max:max widthScalable:YES height:height font:font color:color selected:selectedColor disabled:disabledColor backgroud:backgroud selected:selectedBackgroud disabled:disabledBackgroud];
}

/**
 *  重新改变尺寸
 */
- (void)ssn_sizeToFit {
    
    BOOL widthScalable = [self ssn_width_scalable];
    if (!widthScalable) {
        [self sizeToFit];
        return ;
    }
    
    NSString *text = self.currentTitle;
    if (!text) {
        text = @"";
    }
    
    CGRect frame = self.frame;
    
    CGFloat maxWidth = [self ssn_max_width];
    CGFloat minWidth = [self ssn_min_width];
    
    CGSize size = [text ssn_sizeWithFont:self.titleLabel.font maxWidth:maxWidth];
    
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
        
    self.frame = frame;
}

@end

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
#import "UIImage+SSNUIColor.h"

@implementation UIButton (SSNUIKit)

//宽度是否可伸缩
ssn_uikit_value_synthesize(int, ssn_width_scalable, Ssn_width_scalable)

//最小宽度
ssn_uikit_value_synthesize(float,ssn_min_width,Ssn_min_width)

//最大宽度
ssn_uikit_value_synthesize(float,ssn_max_width,Ssn_max_width)

//最大宽度
ssn_uikit_value_synthesize(float,ssn_edge_width,Ssn_edge_width)

#define ssn_uikit_stret_image(image) [image ssn_centerStretchImage]

+ (instancetype)ssn_buttonWithWidthMin:(CGFloat)min max:(CGFloat)max edge:(CGFloat)edge widthScalable:(BOOL)widthScalable height:(CGFloat)height font:(UIFont *)font color:(UIColor *)color selected:(UIColor *)selectedColor disabled:(UIColor *)disabledColor backgroud:(UIImage *)backgroud selected:(UIImage *)selectedBackgroud disabled:(UIImage *)disabledBackgroud {
    
    UIFont *aFont = (nil == font ? [UIFont systemFontOfSize:14.0f] : font);
    
    CGRect frame = CGRectZero;
    
    CGFloat aMax = ssn_ceil( max < 0.0f ? 300.0f : max );
    frame.size.width = aMax;
    frame.size.height = ssn_ceil( height < 0.0f ? 40.0f : height );
    
    UIButton *button = [[[self class] alloc] initWithFrame:frame];
    button.titleLabel.font = aFont;
    button.exclusiveTouch = YES;
    
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
    button.ssn_min_width = ssn_ceil(min > aMax ? aMax : min);
    button.ssn_max_width = ssn_ceil(max);
    if (widthScalable) {
        button.ssn_edge_width = ssn_ceil(edge < 0.0f ? 10.0f : edge);
    }
    
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
    return [self ssn_buttonWithWidthMin:size.width max:size.width edge:0.0f widthScalable:NO height:size.height font:font color:color selected:selectedColor disabled:disabledColor backgroud:backgroud selected:selectedBackgroud disabled:disabledBackgroud];
}

/**
 *  生产一个button，可配置的主题
 *
 *  @param min               最小宽度，默认值为0，若min大于max将被忽略
 *  @param max               最大宽度，默认值为300
 *  @param edge              边距宽度，默认值为10
 *  @param height            高度，默认值40
 *  @param font              字体大小，默认值为14
 *  @param color             字体颜色，默认值为黑色
 *  @param selectedColor     字体选中颜色（兼高亮），默认nil
 *  @param disabledColor     不可用颜色，默认nil
 *  @param backgroud         背景图，默认纯白
 *  @param selectedBackgroud 选中背景图，默认nil
 *  @param disabledBackgroud 不可用背景图，默认nil
 *
 *  @return button
 */
+ (instancetype)ssn_buttonWithWidthMin:(CGFloat)min max:(CGFloat)max edge:(CGFloat)edge height:(CGFloat)height font:(UIFont *)font color:(UIColor *)color selected:(UIColor *)selectedColor disabled:(UIColor *)disabledColor backgroud:(UIImage *)backgroud selected:(UIImage *)selectedBackgroud disabled:(UIImage *)disabledBackgroud {
    return [self ssn_buttonWithWidthMin:min max:max edge:edge widthScalable:YES height:height font:font color:color selected:selectedColor disabled:disabledColor backgroud:backgroud selected:selectedBackgroud disabled:disabledBackgroud];
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
        
        CGFloat edge = [self ssn_edge_width];
        
        if (size.width + 2*edge < minWidth) {
            frame.size.width = minWidth;
        }
        else if (size.width + 2*edge > maxWidth){
            frame.size.width = maxWidth;
        }
        else {
            frame.size.width = size.width + 2*edge;
        }
    }
        
    self.frame = frame;
}

static char * ssn_hit_edge_outsets_key = NULL;
@dynamic hitEdgeOutsets;
- (void)setHitEdgeOutsets:(UIEdgeInsets)hitEdgeOutsets
{
    NSValue *value = [NSValue valueWithUIEdgeInsets:hitEdgeOutsets];
    objc_setAssociatedObject(self, &ssn_hit_edge_outsets_key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)hitEdgeOutsets
{
    NSValue * value = objc_getAssociatedObject(self, &ssn_hit_edge_outsets_key);
    if(value) {
        return [value UIEdgeInsetsValue];
    }
    return UIEdgeInsetsZero;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.hitEdgeOutsets, UIEdgeInsetsZero) || !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    UIEdgeInsets edge = self.hitEdgeOutsets;
    edge.top = -edge.top;
    edge.bottom = -edge.bottom;
    edge.left = -edge.left;
    edge.right = -edge.right;
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, edge);
    return CGRectContainsPoint(hitFrame, point);
}

@end

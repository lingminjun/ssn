//
//  UIButton+SSNUIKit.h
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (SSNUIKit)

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
+ (instancetype)ssn_buttonWithSize:(CGSize)size font:(UIFont *)font color:(UIColor *)color selected:(UIColor *)selectedColor disabled:(UIColor *)disabledColor backgroud:(UIImage *)backgroud selected:(UIImage *)selectedBackgroud disabled:(UIImage *)disabledBackgroud;

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
+ (instancetype)ssn_buttonWithWidthMin:(CGFloat)min max:(CGFloat)max height:(CGFloat)height font:(UIFont *)font color:(UIColor *)color selected:(UIColor *)selectedColor disabled:(UIColor *)disabledColor backgroud:(UIImage *)backgroud selected:(UIImage *)selectedBackgroud disabled:(UIImage *)disabledBackgroud;

@end

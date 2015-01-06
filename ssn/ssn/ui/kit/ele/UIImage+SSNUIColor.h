//
//  UIImage+SSNUIColor.h
//  ssn
//
//  Created by lingminjun on 15/1/5.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SSNUIColor)

/**
 *  返回一像素（size(1,1)）这个color颜色的图片
 *
 *  @param color 一个颜色指标【不能为nil】
 *
 *  @return 图片
 */
+ (UIImage *)ssn_imageWithColor:(UIColor *)color;

/**
 *  返回一个size为给定size的color颜色图片
 *
 *  @param size   size大小
 *  @param color  填充色颜色
 *  @param radius 圆角半径
 *
 *  @return 图片
 */
+ (UIImage *)ssn_imageWithSize:(CGSize)size color:(UIColor *)color cornerRadius:(CGFloat)radius;

/**
 *  返回一个size为给定size的color颜色带with宽边线和borderColor颜色的图片
 *
 *  @param size        size大小
 *  @param color       填充色颜色
 *  @param width       边线宽度
 *  @param borderColor 边线颜色
 *  @param radius      圆角半径
 *
 *  @return 图片
 */
+ (UIImage *)ssn_imageWithSize:(CGSize)size color:(UIColor *)color border:(CGFloat)width color:(UIColor *)borderColor cornerRadius:(CGFloat)radius;

/**
 *  返回一个size为给定size的渐变颜色从from到to的图片
 *
 *  @param size   size大小
 *  @param from   起始颜色，位置在top
 *  @param to     终止颜色，位置在bottom
 *  @param radius 圆角半径
 *
 *  @return 图片
 */
+ (UIImage *)ssn_imageWithSize:(CGSize)size gradientColor:(UIColor *)from to:(UIColor *)to cornerRadius:(CGFloat)radius;

/**
 *  返回一个size为给定size的渐变颜色从from到to的带with宽边线和borderColor颜色的图片
 *
 *  @param size        size大小
 *  @param from        起始颜色，位置在top
 *  @param to          终止颜色，位置在bottom
 *  @param width       边线宽度
 *  @param borderColor 边线颜色
 *  @param radius      圆角半径
 *
 *  @return 图片
 */
+ (UIImage *)ssn_imageWithSize:(CGSize)size gradientColor:(UIColor *)from to:(UIColor *)to border:(CGFloat)width color:(UIColor *)borderColor cornerRadius:(CGFloat)radius;

/**
 *  返回一个size为给定size的渐变颜色从from到to的带with宽边线和borderColor颜色的图片
 *
 *  @param size        size大小
 *  @param from        起始颜色，位置在top
 *  @param to          终止颜色，位置在bottom
 *  @param width       边线宽度
 *  @param borderColor 边线颜色
 *  @param blendingWidth 边缘配色宽度，使得绘制出的图片渐变更自然
 *  @param blendingColor 边缘配色，使得绘制出的图片渐变更自然
 *  @param radius      圆角半径
 *
 *  @return 图片
 */
+ (UIImage *)ssn_imageWithSize:(CGSize)size gradientColor:(UIColor *)from to:(UIColor *)to border:(CGFloat)width color:(UIColor *)borderColor blending:(CGFloat)blendingWidth color:(UIColor *)blendingColor cornerRadius:(CGFloat)radius;

/**
 *  返回一个size为给定size的渐变颜色带with宽边线和borderColor颜色的图片
 *
 *  @param size         size大小
 *  @param colors       渐变颜色序列，元素为UIColor
 *  @param locations    渐变位置数组元素为CGFloat，取值[0~1]
 *  @param width         边框宽度
 *  @param borderColor   变宽颜色
 *  @param blendingWidth 配色宽度
 *  @param blendingColor 配色颜色
 *  @param radius        圆角半径
 *
 *  @return 图片
 */
+ (UIImage *)ssn_imageWithSize:(CGSize)size gradientColors:(NSArray *)colors gradientLocations:(const CGFloat [])locations border:(CGFloat)width color:(UIColor *)borderColor blending:(CGFloat)blendingWidth color:(UIColor *)blendingColor cornerRadius:(CGFloat)radius;

@end

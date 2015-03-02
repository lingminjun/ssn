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
 *  返回一个size(radius+3,radius+3)的color颜色图片，
 *
 *  @param size   size大小
 *  @param color  填充色颜色
 *  @param radius 圆角半径
 *
 *  @return 图片
 */
+ (UIImage *)ssn_imageWithColor:(UIColor *)color cornerRadius:(CGFloat)radius;

/**
 *  返回一个size(radius+width+3,radius+width+3)的color颜色带with宽边线和borderColor颜色的图片
 *
 *  @param color       填充色颜色
 *  @param width       边线宽度
 *  @param borderColor 边线颜色
 *  @param radius      圆角半径
 *
 *  @return 图片
 */
+ (UIImage *)ssn_imageWithColor:(UIColor *)color border:(CGFloat)width color:(UIColor *)borderColor cornerRadius:(CGFloat)radius;

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


/**
 *  一像素线图片，实际是1x2或者1x3的图片，根据屏幕scale决定
 *
 *  @param color       线的颜色
 *  @param orientation 透明像素填充方向
 *
 *  @return 一像素线图片
 */
+ (UIImage *)ssn_lineWithColor:(UIColor *)color orientation:(UIInterfaceOrientation)orientation;


/**
 *  绘制一个圆形线圈
 *
 *  @param diameter    直径
 *  @param width       线宽
 *  @param borderColor 线颜色
 *
 *  @return 绘制一个圆形线圈
 */
+ (UIImage *)ssn_circleLineWithDiameter:(CGFloat)diameter border:(CGFloat)width color:(UIColor *)borderColor;

#pragma mark other
/**
 *  中间拉伸图
 *
 *  @return 中间拉伸图
 */
- (UIImage *)ssn_centerStretchImage;


#pragma mark 绘制模糊玻璃
/**
 *  绘制毛玻璃
 *
 *  @return 绘制毛玻璃
 */
- (UIImage *)ssn_gaussianBlurImage;

/**
 *  绘制毛玻璃
 *
 *  @param complete 绘制完
 */
- (void)ssn_gaussianBlurImageComplete:(void(^)(UIImage *image))complete;

/**
 *  绘制毛玻璃
 *
 *  @param radius     渲染半径
 *  @param iterations 重复渲染次数
 *
 *  @return 渲染后图片
 */
- (UIImage *)ssn_gaussianBlurImageWithRadius:(NSUInteger)radius iterations:(NSUInteger)iterations;

/**
 *  绘制毛玻璃
 *
 *  @param radius     渲染半径
 *  @param iterations 重复渲染次数
 *  @param complete   渲染完成回调
 */
- (void)ssn_gaussianBlurImageWithRadius:(NSUInteger)radius iterations:(NSUInteger)iterations complete:(void(^)(UIImage *image))complete;

#pragma mark 绘制倒影
/**
 *  绘制倒影图片
 *
 *  @return 倒影
 */
- (UIImage *)ssn_mirroredImage;

@end

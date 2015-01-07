//
//  UIImageView+SSNUIKit.m
//  ssn
//
//  Created by lingminjun on 15/1/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIImageView+SSNUIKit.h"

@implementation UIImageView (SSNUIKit)

+ (instancetype)ssn_imageViewWithSize:(CGSize)size image:(UIImage *)image {
    
    CGRect frame = CGRectZero;
    frame.size.width = (size.width <= 0.0f ? 40.0f : size.width);
    frame.size.height = (size.height <= 0.0f ? 40.0f : size.height);
    
    UIImageView *imageView = [[[self class] alloc] initWithFrame:frame];
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = image;
    return imageView;
}

/**
 *  一个高宽都为width的imageView
 *
 *  @param width 边框，默认值40
 *
 *  @return imageView
 */
+ (instancetype)ssn_imageViewWithWidth:(CGFloat)width {
    return [self ssn_imageViewWithSize:CGSizeMake(width, width) image:nil];
}

/**
 *  一个图片
 *
 *  @param size 高宽，默认值CGSize(40,40)
 *
 *  @return imageView
 */
+ (instancetype)ssn_imageViewWithSize:(CGSize)size {
    return [self ssn_imageViewWithSize:size image:nil];
}

/**
 *  一个图片
 *
 *  @param image 设置的image，大小取image大小
 *
 *  @return imageView
 */
+ (instancetype)ssn_imageViewWithImage:(UIImage *)image {
    return [self ssn_imageViewWithSize:image.size image:image];
}

//
//+ (instancetype)ssn_lineWithWidth:(CGFloat)width color:(UIColor *)color orientation:(UIInterfaceOrientation)orientation {
////    CGRect frame = CGRectZero;
////    frame.size.width = (size.width <= 0.0f ? 40.0f : size.width);
////    frame.size.height = (size.height <= 0.0f ? 40.0f : size.height);
////    
////    UIImageView *imageView = [[[self class] alloc] initWithFrame:frame];
////    imageView.clipsToBounds = YES;
////    imageView.backgroundColor = [UIColor clearColor];
////    imageView.image = image;
////    return imageView;
//    return nil;
//}
//
///**
// *  一个一像素高度的线，内部根据当前分辨率扩充其透明线
// *
// *  @param width 边框，默认值1
// *  @param color 线的颜色
// *
// *  @return 一个线的view
// */
//+ (instancetype)ssn_upLineWithWidth:(CGFloat)width color:(UIColor *)color {
//    return [self ssn_lineWithWidth:width color:color orientation:UIInterfaceOrientationPortrait];
//}
//
///**
// *  一个一像素高度的线，内部根据当前分辨率扩充其透明线
// *
// *  @param width 边框，默认值1
// *  @param color 线的颜色
// *
// *  @return 一个线的view
// */
//+ (instancetype)ssn_downLineWithWidth:(CGFloat)width color:(UIColor *)color {
//    return [self ssn_lineWithWidth:width color:color orientation:UIInterfaceOrientationPortraitUpsideDown];
//}

@end

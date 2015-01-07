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

@end

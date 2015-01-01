//
//  UIView+SSNUIFrame.h
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SSNUIFrame)

/**
 *  view的大小，设置时不改变原点位置
 */
@property (nonatomic) CGSize ssn_size;

/**
 *  view的原点位置
 */
@property (nonatomic) CGPoint ssn_origin;

/**
 *  view的宽度
 */
@property (nonatomic) CGFloat ssn_width;

/**
 *  view的高度
 */
@property (nonatomic) CGFloat ssn_height;

/**
 *  view的origin.x
 */
@property (nonatomic) CGFloat ssn_x;

/**
 *  view的origin.y
 */
@property (nonatomic) CGFloat ssn_y;

/**
 *  view左边位置
 */
@property (nonatomic) CGFloat ssn_left;

/**
 *  view上边位置
 */
@property (nonatomic) CGFloat ssn_top;

/**
 *  view下边位置
 */
@property (nonatomic) CGFloat ssn_bottom;

/**
 *  view右边位置
 */
@property (nonatomic) CGFloat ssn_right;

/**
 *  view的center
 */
@property (nonatomic) CGPoint ssn_center;

/**
 *  view的center.x
 */
@property (nonatomic) CGFloat ssn_center_x;

/**
 *  view的center.y
 */
@property (nonatomic) CGFloat ssn_center_y;

/**
 *  view的左上角
 */
@property (nonatomic) CGPoint ssn_top_left_corner;

/**
 *  view的右上角
 */
@property (nonatomic) CGPoint ssn_top_right_corner;

/**
 *  view的右下角
 */
@property (nonatomic) CGPoint ssn_bottom_right_corner;

/**
 *  view的左下角
 */
@property (nonatomic) CGPoint ssn_bottom_left_corner;
@end

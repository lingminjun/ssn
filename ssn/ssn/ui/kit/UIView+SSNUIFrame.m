//
//  UIView+SSNUIFrame.m
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "UIView+SSNUIFrame.h"

@implementation UIView (SSNUIFrame)

- (CGSize)ssn_size {
    return self.frame.size;
}
- (void)setSsn_size:(CGSize)ssn_size {
    CGRect frame = self.frame;
    frame.size = ssn_size;
    self.frame = frame;
}

- (CGPoint)ssn_origin {
    return self.frame.origin;
}
- (void)setSsn_origin:(CGPoint)ssn_origin {
    CGRect frame = self.frame;
    frame.origin = ssn_origin;
    self.frame = frame;
}

- (CGFloat)ssn_width {
    return self.frame.size.width;
}
- (void)setSsn_width:(CGFloat)ssn_width {
    CGRect frame = self.frame;
    frame.size.width = ssn_width;
    self.frame = frame;
}

- (CGFloat)ssn_height {
    return self.frame.size.height;
}
- (void)setSsn_height:(CGFloat)ssn_height {
    CGRect frame = self.frame;
    frame.size.height = ssn_height;
    self.frame = frame;
}

- (CGFloat)ssn_x {
    return self.frame.origin.x;
}
- (void)setSsn_x:(CGFloat)ssn_x {
    CGRect frame = self.frame;
    frame.origin.x = ssn_x;
    self.frame = frame;
}

- (CGFloat)ssn_y {
    return self.frame.origin.y;
}
- (void)setSsn_y:(CGFloat)ssn_y {
    CGRect frame = self.frame;
    frame.origin.y = ssn_y;
    self.frame = frame;
}

- (CGFloat)ssn_left {
    return self.frame.origin.x;
}
- (void)setSsn_left:(CGFloat)ssn_left {
    CGRect frame = self.frame;
    frame.origin.x = ssn_left;
    self.frame = frame;
}

- (CGFloat)ssn_top {
    return self.frame.origin.y;
}
- (void)setSsn_top:(CGFloat)ssn_top {
    CGRect frame = self.frame;
    frame.origin.y = ssn_top;
    self.frame = frame;
}

- (CGFloat)ssn_bottom {
    return self.frame.origin.y + self.frame.size.height;
}
- (void)setSsn_bottom:(CGFloat)ssn_bottom {
    CGRect frame = self.frame;
    frame.origin.y = ssn_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)ssn_right {
    return self.frame.origin.x + self.frame.size.width;
}
- (void)setSsn_right:(CGFloat)ssn_right {
    CGRect frame = self.frame;
    frame.origin.x = ssn_right - frame.size.width;
    self.frame = frame;
}

- (CGPoint)ssn_center {
    return self.center;
}
- (void)setSsn_center:(CGPoint)ssn_center {
    self.center = ssn_center;
}

- (CGFloat)ssn_center_x {
    return self.center.x;
}
- (void)setSsn_center_x:(CGFloat)ssn_center_x {
    CGPoint center = self.center;
    center.x = ssn_center_x;
    self.center = center;
}

- (CGFloat)ssn_center_y {
    return self.center.y;
}
- (void)setSsn_center_y:(CGFloat)ssn_center_y {
    CGPoint center = self.center;
    center.y = ssn_center_y;
    self.center = center;
}

- (CGPoint)ssn_top_left_corner {
    return self.frame.origin;
}
- (void)setSsn_top_left_corner:(CGPoint)ssn_top_left_corner {
    CGRect frame = self.frame;
    frame.origin = ssn_top_left_corner;
    self.frame = frame;
}

- (CGPoint)ssn_top_right_corner {
    CGRect frame = self.frame;
    frame.origin.x += frame.size.width;
    return frame.origin;
}
- (void)setSsn_top_right_corner:(CGPoint)ssn_top_right_corner {
    CGRect frame = self.frame;
    frame.origin.x = ssn_top_right_corner.x - frame.size.width;
    frame.origin.y = ssn_top_right_corner.y;
    self.frame = frame;
}

- (CGPoint)ssn_bottom_right_corner {
    CGRect frame = self.frame;
    frame.origin.x += frame.size.width;
    frame.origin.y += frame.size.height;
    return frame.origin;
}
- (void)setSsn_bottom_right_corner:(CGPoint)ssn_bottom_right_corner {
    CGRect frame = self.frame;
    frame.origin.x = ssn_bottom_right_corner.x - frame.size.width;
    frame.origin.y = ssn_bottom_right_corner.y - frame.size.height;
    self.frame = frame;
}

- (CGPoint)ssn_bottom_left_corner {
    CGRect frame = self.frame;
    frame.origin.y += frame.size.height;
    return frame.origin;
}
- (void)setSsn_bottom_left_corner:(CGPoint)ssn_bottom_left_corner {
    CGRect frame = self.frame;
    frame.origin.x = ssn_bottom_left_corner.x;
    frame.origin.y = ssn_bottom_left_corner.y - frame.size.height;
    self.frame = frame;
}

@end

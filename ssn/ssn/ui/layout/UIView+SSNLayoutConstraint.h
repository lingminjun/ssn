//
//  UIView+SSNLayoutConstraint.h
//  ssn
//
//  Created by lingminjun on 15/10/17.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>



/**
 *  约束抽象体
 */
@protocol SSNLayoutConstraint;

/**
 *  参照https://github.com/SnapKit/Masonry
 *  http://www.cocoachina.com/ios/20141219/10702.html
 */
@interface UIView (SSNLayoutConstraint)

/**
 SSNLayoutConstraint	NSLayoutAttribute
 view.cnt_left          NSLayoutAttributeLeft
 view.cnt_right         NSLayoutAttributeRight
 view.cnt_top           NSLayoutAttributeTop
 view.cnt_bottom        NSLayoutAttributeBottom
 view.cnt_leading       NSLayoutAttributeLeading
 view.cnt_trailing      NSLayoutAttributeTrailing
 view.cnt_width         NSLayoutAttributeWidth
 view.cnt_height        NSLayoutAttributeHeight
 view.cnt_centerX       NSLayoutAttributeCenterX
 view.cnt_centerY       NSLayoutAttributeCenterY
 view.cnt_baseline      NSLayoutAttributeBaseline
 */
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_left;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_top;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_right;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_bottom;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_leading;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_trailing;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_width;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_height;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_centerX;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_centerY;
@property (nonatomic,strong) id<SSNLayoutConstraint> cnt_baseline;

/**
 *  闭包构造
 *
 *  @param block 请在block中构造
 */
+ (void)cnt_constraints:(dispatch_block_t)block;

@end


@protocol SSNLayoutConstraint <NSObject>
/**
 .equalTo                NSLayoutRelationEqual
 .lessThanOrEqualTo      NSLayoutRelationLessThanOrEqual
 .greaterThanOrEqualTo   NSLayoutRelationGreaterThanOrEqual
 */
- (void)equalTo:(id<SSNLayoutConstraint>)refer;//等于某个参照值
- (void)greaterThanOrEqualTo:(id<SSNLayoutConstraint>)refer;//不小于某个参照值
- (void)lessThanOrEqualTo:(id<SSNLayoutConstraint>)refer;//不大于某个参照值

- (void)offset:(int)offset;//偏移值，逻辑像素，不支持小数

@end

/**
 *  基本类型支持运算
 */
@interface NSNumber(SSNLayoutConstraint) <SSNLayoutConstraint>
@end

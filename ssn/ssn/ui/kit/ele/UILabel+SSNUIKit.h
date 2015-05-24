//
//  UILabel+SSNUIKit.h
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (SSNUIKit)


/**
 *  返回一个宽度为width的label，
 *
 *  @param width     宽度，默认300
 *  @param font      默认值为14
 *  @param color     默认值为黑色
 *  @param backgroud 默认值为白色
 *  @param alignment 默认值为NSTextAlignmentLeft
 *  @param multiLine 默认值为NO，为yes时高度随内容调整
 *
 *  @return label
 */
+ (instancetype)ssn_labelWithWidth:(CGFloat)width font:(UIFont *)font color:(UIColor *)color backgroud:(UIColor *)backgroud alignment:(NSTextAlignment)alignment multiLine:(BOOL)multiLine;

/**
 *  返回一个可变长度的label，根据内容调整宽度，调用
 *
 *  @param min       默认值为0，若min大于max将被忽略
 *  @param max       默认值为300
 *  @param font      默认值为14
 *  @param color     默认值为黑色
 *  @param backgroud 默认值为白色
 *  @param alignment 默认值为NSTextAlignmentLeft
 *  @param multiLine 默认值为NO，为yes时高度随内容调整
 *
 *  @return label
 */
+ (instancetype)ssn_labelWithWidthMin:(CGFloat)min max:(CGFloat)max font:(UIFont *)font color:(UIColor *)color backgroud:(UIColor *)backgroud alignment:(NSTextAlignment)alignment multiLine:(BOOL)multiLine;


/**
 *  重新改变尺寸
 */
- (void)ssn_sizeToFit;

/**
 *  使用这些属性必须了解其实现
 */
@property (nonatomic) int ssn_width_scalable;//宽度是否可变，在ssn_min_width~ssn_max_width之间变化
@property (nonatomic) float ssn_min_width;//最小宽度
@property (nonatomic) float ssn_max_width;//最大宽度
@property (nonatomic) int ssn_multi_line;//是否要显示多行

@end

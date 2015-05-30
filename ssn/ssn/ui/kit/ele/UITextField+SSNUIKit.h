//
//  UITextField+SSNUIKit.h
//  ssn
//
//  Created by lingminjun on 15/1/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (SSNUIKit)

/**
 *  输入框定义
 *
 *  @param size       尺寸，默认CGSize(180,40)
 *  @param font       字体大小，默认值为14
 *  @param color      字体颜色，默认值为黑色
 *  @param adjustFont 默认值NO
 *  @param minFont    默认值11
 *
 *  @return textField
 */
+ (instancetype)ssn_inputWithSize:(CGSize)size font:(UIFont *)font color:(UIColor *)color adjustFont:(BOOL)adjustFont minFont:(CGFloat)minFont;

/**
 *  输入框定义
 *
 *  @param size       尺寸，默认CGSize(180,40)
 *  @param font       字体大小，默认值为14
 *  @param color      字体颜色，默认值为黑色
 *  @param adjustFont 默认值NO
 *  @param minFont    默认值11
 *  @param maxLength  最大长度
 *  @param characterLimit  字符限制
 *
 *  @return textField
 */
+ (instancetype)ssn_inputWithSize:(CGSize)size font:(UIFont *)font color:(UIColor *)color adjustFont:(BOOL)adjustFont minFont:(CGFloat)minFont maxLength:(NSUInteger)maxLength characterLimit:(NSCharacterSet *)characterLimit;

/**
 *  输入的最大宽度
 */
@property (nonatomic) NSUInteger ssn_maxLength;

/**
 *  字符限定
 */
@property (nonatomic,copy) NSCharacterSet *ssn_characterLimit;

/**
 *  输入格式限定，如344，335
 */
@property (nonatomic,copy) NSString *(^ssn_format)(NSString *originText);

@end

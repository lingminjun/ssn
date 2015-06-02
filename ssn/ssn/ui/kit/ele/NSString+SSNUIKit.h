//
//  NSString+SSNUIKit.h
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSNAttributedStringSection;

@interface NSString (SSNUIKit)

/**
 *  返回一个string显示font需要的尺寸
 *
 *  @param font     字体大小
 *  @param maxWidth 最大宽度
 *
 *  @return 返回合适的尺寸
 */
- (CGSize)ssn_sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth;

@end


@interface NSAttributedString (SSNUIKit)

/**
 *  返回字体所占用得尺寸
 *
 *  @param maxWidth 最大宽度
 *
 *  @return 返回合适的尺寸
 */
- (CGSize)ssn_sizeWithMaxWidth:(CGFloat)maxWidth;

/**
 *  返回一个NSAttributedString
 *
 *  @param string      字符内容
 *  @param font        字体
 *  @param color       颜色
 *  @param lineSpacing 行距，输入0时忽略
 *
 *  @return NSAttributedString
 */
+ (instancetype)ssn_attributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color lineSpacing:(CGFloat)lineSpacing;

/**
 *  返回一个NSAttributedString
 *
 *  @param string      字符内容
 *  @param font        字体
 *  @param color       颜色
 *  @param underline   是否有下划线
 *  @param lineSpacing 行距，输入0时忽略
 *
 *  @return NSAttributedString
 */
+ (instancetype)ssn_attributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color underline:(BOOL)underline lineSpacing:(CGFloat)lineSpacing;

/**
 *  返回一个NSAttributedString
 *
 *  @param string      字符内容
 *  @param font        字体
 *  @param color       颜色
 *  @param strikethrough 是否有删除线
 *  @param lineSpacing 行距，输入0时忽略
 *
 *  @return NSAttributedString
 */
+ (instancetype)ssn_attributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color strikethrough:(BOOL)strikethrough lineSpacing:(CGFloat)lineSpacing;

/**
 *  生产一个多段配置的NSAttributedString
 *
 *  @param lineSpacing 行高，传入0忽略
 *  @param firstObj    第一个元素，后面的元素，后面元素同样是id<SSNAttributedStringSection>类型，以nil结尾
 *
 *  @return NSAttributedString
 */
+ (instancetype)ssn_attributedStringWithLineSpacing:(CGFloat)lineSpacing sections:(id<SSNAttributedStringSection>)firstSection, ... NS_REQUIRES_NIL_TERMINATION;

@end

FOUNDATION_EXTERN id<SSNAttributedStringSection> ssn_attributedStringSection(NSString *string, UIFont *font, UIColor *color, BOOL underline, BOOL strikethrough);

/**
 *  NSAttributedString字符串段
 */
@protocol SSNAttributedStringSection <NSObject,NSCopying>

@property (nonatomic,copy)   NSString *string;  //内容
@property (nonatomic,strong) UIFont *font;      //字体
@property (nonatomic,strong) UIColor *color;    //颜色
@property (nonatomic) BOOL underline;           //下划线
@property (nonatomic) BOOL strikethrough;       //删除线

@end
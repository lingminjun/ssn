//
//  UIButton+SSNUIKit.h
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (SSNUIKit)

/**
 *  生产一个button，可配置的主题
 *
 *  @param size              大小，默认值CGSize(60,40)
 *  @param font              字体大小，默认值为14
 *  @param color             字体颜色，默认值为黑色
 *  @param selectedColor     字体选中颜色（兼高亮），默认nil
 *  @param disabledColor     不可用颜色，默认nil
 *  @param backgroud         背景图，默认纯白
 *  @param selectedBackgroud 选中背景图，默认nil
 *  @param disabledBackgroud 不可用背景图，默认nil
 *
 *  @return button
 */
+ (instancetype)ssn_buttonWithSize:(CGSize)size font:(UIFont *)font color:(UIColor *)color selected:(UIColor *)selectedColor disabled:(UIColor *)disabledColor backgroud:(UIImage *)backgroud selected:(UIImage *)selectedBackgroud disabled:(UIImage *)disabledBackgroud;

/**
 *  生产一个button，可配置的主题
 *
 *  @param min               最小宽度，默认值为0，若min大于max将被忽略
 *  @param max               最大宽度，默认值为300
 *  @param edge              边距宽度，默认值为10
 *  @param height            高度，默认值40
 *  @param font              字体大小，默认值为14
 *  @param color             字体颜色，默认值为黑色
 *  @param selectedColor     字体选中颜色（兼高亮），默认nil
 *  @param disabledColor     不可用颜色，默认nil
 *  @param backgroud         背景图，默认纯白
 *  @param selectedBackgroud 选中背景图，默认nil
 *  @param disabledBackgroud 不可用背景图，默认nil
 *
 *  @return button
 */
+ (instancetype)ssn_buttonWithWidthMin:(CGFloat)min max:(CGFloat)max edge:(CGFloat)edge height:(CGFloat)height font:(UIFont *)font color:(UIColor *)color selected:(UIColor *)selectedColor disabled:(UIColor *)disabledColor backgroud:(UIImage *)backgroud selected:(UIImage *)selectedBackgroud disabled:(UIImage *)disabledBackgroud;


/**
 *  重新改变尺寸
 */
- (void)ssn_sizeToFit;

/**
 *  扩大按钮的点击范围（outsets表示自己frame向外延生部分，superview要足够大）
 */
@property(nonatomic) UIEdgeInsets ssn_hitEdgeOutsets;

/**
 *  设置normal下的title
 */
@property(nonatomic,copy) NSString *ssn_normalTitle;

/**
 *  设置normal下的titleColor
 */
@property(nonatomic,strong) UIColor *ssn_normalTitleColor;

/**
 *  设置normal下的image
 */
@property(nonatomic,strong) UIImage *ssn_normalImage;

/**
 *  设置normal下的backgroud image
 */
@property(nonatomic,strong) UIImage *ssn_normalBackgroundImage;

/**
 *  设置highlighted/selected下的title
 */
@property(nonatomic,copy) NSString *ssn_selectedTitle;

/**
 *  设置highlighted/selected下的titleColor
 */
@property(nonatomic,strong) UIColor *ssn_selectedTitleColor;

/**
 *  设置highlighted/selected下的image
 */
@property(nonatomic,strong) UIImage *ssn_selectedImage;

/**
 *  设置normal下的backgroud image
 */
@property(nonatomic,strong) UIImage *ssn_selectedBackgroundImage;

/**
 *  设置disabled下的title
 */
@property(nonatomic,copy) NSString *ssn_disabledTitle;

/**
 *  设置disabled下的titleColor
 */
@property(nonatomic,strong) UIColor *ssn_disabledTitleColor;

/**
 *  设置disabled下的image
 */
@property(nonatomic,strong) UIImage *ssn_disabledImage;

/**
 *  设置normal下的backgroud image
 */
@property(nonatomic,strong) UIImage *ssn_disabledBackgroundImage;

/**
 *  添加点击事件
 *
 *  @param target   事件执行者
 *  @param selector 事件方法
 */
- (void)ssn_addTarget:(id)target touchAction:(SEL)selector;

@end

//
//  UITextField+SSNUIKit.m
//  ssn
//
//  Created by lingminjun on 15/1/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UITextField+SSNUIKit.h"
#import "NSString+SSN.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@implementation UITextField (SSNUIKit)

static char * ssn_maxLength_key = NULL;
- (NSUInteger)ssn_maxLength {
    return [objc_getAssociatedObject(self, &ssn_maxLength_key) unsignedIntegerValue];
}
- (void)setSsn_maxLength:(NSUInteger)ssn_maxLength {
    if (ssn_maxLength > 0 && [self.text length] > ssn_maxLength) {
        self.text = [self.text substringToIndex:ssn_maxLength];
    }
    objc_setAssociatedObject(self, &ssn_maxLength_key, @( ssn_maxLength ), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char *ssn_characterLimit_key = NULL;
- (NSCharacterSet *)ssn_characterLimit {
    return objc_getAssociatedObject(self, &ssn_characterLimit_key);
}
- (void)setSsn_characterLimit:(NSCharacterSet *)ssn_characterLimit {
    NSCharacterSet *set = self.ssn_characterLimit;
    if ((set == nil && ssn_characterLimit == nil) || [set isEqual:ssn_characterLimit]) {
        return ;
    }
    
    //需要过来
    if (ssn_characterLimit && (!set || ![ssn_characterLimit isSupersetOfSet:set])) {
        self.text = [self.text ssn_substringMeetCharacterSet:ssn_characterLimit];
    }
    
    objc_setAssociatedObject(self, &ssn_characterLimit_key, ssn_characterLimit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 *  输入格式限定，如344，335
 */
static char *ssn_format_key = NULL;
- (NSString *(^)(NSString *originText))ssn_format {
    return objc_getAssociatedObject(self, &ssn_format_key);
}
- (void)setSsn_format:(NSString *(^)(NSString *))ssn_format {
    if (ssn_format) {
        @autoreleasepool {
            NSString *text = ssn_format(self.text);
            if ([text length] && ![text isEqualToString:self.text]) {
                self.text = text;
            }
        }
    }
    objc_setAssociatedObject(self, &ssn_format_key, ssn_format, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


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
+ (instancetype)ssn_inputWithSize:(CGSize)size font:(UIFont *)font color:(UIColor *)color adjustFont:(BOOL)adjustFont minFont:(CGFloat)minFont {
    return [self ssn_inputWithSize:size font:font color:color adjustFont:adjustFont minFont:minFont maxLength:0 characterLimit:nil];
}

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
+ (instancetype)ssn_inputWithSize:(CGSize)size font:(UIFont *)font color:(UIColor *)color adjustFont:(BOOL)adjustFont minFont:(CGFloat)minFont maxLength:(NSUInteger)maxLength characterLimit:(NSCharacterSet *)characterLimit {
    //主题读取
    UIFont *aFont = (nil == font ? [UIFont systemFontOfSize:14.0f] : font);
    UIColor *aColor = (nil == color ? [UIColor blackColor] : color);
    
    CGRect frame = CGRectZero;
    frame.size.width = (size.width <= 0.0f ? 180.0f : size.width);
    frame.size.height = (size.height <= 0.0f ? 40.0f : size.height);
    
    CGFloat aMinFont = (minFont < 0.0f ? 11.0f : minFont);
    
    UITextField *input = [[[self class] alloc] initWithFrame:frame];
    input.font = aFont;
    input.textColor = aColor;
    input.adjustsFontSizeToFitWidth = adjustFont;
    input.backgroundColor = [UIColor clearColor];
    input.minimumFontSize = aMinFont;
    input.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    if (maxLength > 0) {
        input.ssn_maxLength = maxLength;
    }
    
    if (characterLimit) {
        input.ssn_characterLimit = characterLimit;
    }
    
    [input addTarget:input action:@selector(sf_input_did_change_action:) forControlEvents:UIControlEventEditingChanged];
    
    return input;
}

/**
 *  输入框
 *  CGSize(kMainScreenWidth-2*kLeftPadding,44)
 *  字体：PING_HEI_14
 *  字色：COLOR_NORMAL_TEXT
 *  边框：1
 *  边色：COLOR_LINE
 *  背景：白色
 *  光标：kLeftPadding
 *
 *  @return 输入框
 */
- (void)sf_input_did_change_action:(id)sender { @autoreleasepool {
    NSString *text = self.text;
    if ([text length] == 0) {
        return ;
    }
    
    //字符长度限制
    NSUInteger max_length = self.ssn_maxLength;
    if (max_length > 0 && [text length] > max_length) {
        text = [text substringToIndex:max_length];
    }
    
    //先判断非法字符
    NSCharacterSet *set = self.ssn_characterLimit;
    if (set) {//非法字符判断
        NSString *result = [text stringByTrimmingCharactersInSet:set];
        
        if ([result length]) {//需要过滤
            text = [text ssn_substringMeetCharacterSet:set];
        }
    }
    
    //格式限定
    NSString *(^ssn_format)(NSString *originText) = self.ssn_format;
    if (ssn_format) {
        NSString *atext = ssn_format(text);
        if ([atext length]) {
            text = atext;
        }
    }
    
    //最后结果
    if (text != self.text && ![text isEqualToString:self.text]) {
        self.text = text;
    }
}}

@end

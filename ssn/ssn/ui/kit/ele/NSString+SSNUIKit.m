//
//  NSString+SSNUIKit.m
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSString+SSNUIKit.h"
#import "UIView+SSNUIKit.h"

@implementation NSString (SSNUIKit)

- (CGSize)ssn_sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    
    CGSize goal_size = CGSizeMake(maxWidth, 3000);
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary *attributes = @{ NSFontAttributeName:font };
        CGRect rect = [self boundingRectWithSize:goal_size
                                         options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
        return CGSizeMake(ssn_ceil(rect.size.width), ssn_ceil(rect.size.height));
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    CGSize size = [self sizeWithFont:font constrainedToSize:goal_size lineBreakMode:NSLineBreakByWordWrapping];
    return CGSizeMake(ssn_ceil(size.width), ssn_ceil(size.height));
#pragma clang diagnostic pop
    
}

@end


@implementation NSAttributedString (SSNUIKit)

- (CGSize)ssn_sizeWithMaxWidth:(CGFloat)maxWidth {
    CGSize goal_size = CGSizeMake(maxWidth, 3000);
    CGRect rect = [self boundingRectWithSize:goal_size
                                     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     context:nil];
    return CGSizeMake(ssn_ceil(rect.size.width), ssn_ceil(rect.size.height));
}


+ (instancetype)ssn_attributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color underline:(BOOL)underline strikethrough:(BOOL)strikethrough lineSpacing:(CGFloat)lineSpacing {
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:3];
    [attributes setValue:font forKey:NSFontAttributeName];
    [attributes setValue:color forKey:NSForegroundColorAttributeName];
    
    if (underline) {
        [attributes setValue:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    }
    
    if (strikethrough) {//默认就给细线，如果需要可以修改成NSUnderlineStyleThick
        [attributes setValue:@(NSUnderlineStyleSingle) forKey:NSStrikethroughStyleAttributeName];
    }
    
    if (lineSpacing > 0.0f) {
        //调整行间距
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.paragraphSpacing = 0;
        [paragraphStyle setLineSpacing:lineSpacing];
        [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    }
    
    return [[[self class] alloc] initWithString:string attributes:attributes];
}

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
+ (instancetype)ssn_attributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color lineSpacing:(CGFloat)lineSpacing {
    return [self ssn_attributedStringWithString:string font:font color:color underline:NO strikethrough:NO lineSpacing:lineSpacing];
}

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
+ (instancetype)ssn_attributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color underline:(BOOL)underline lineSpacing:(CGFloat)lineSpacing {
    return [self ssn_attributedStringWithString:string font:font color:color underline:underline strikethrough:NO lineSpacing:lineSpacing];
}

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
+ (instancetype)ssn_attributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color strikethrough:(BOOL)strikethrough lineSpacing:(CGFloat)lineSpacing {
    return [self ssn_attributedStringWithString:string font:font color:color underline:NO strikethrough:strikethrough lineSpacing:lineSpacing];
}

/**
 *  生产一个多段配置的NSAttributedString
 *
 *  @param lineSpacing 行高，传入0忽略
 *  @param firstObj    第一个元素，后面的元素，后面元素同样是id<SSNAttributedStringSection>类型，以nil结尾
 *
 *  @return NSAttributedString
 */
+ (instancetype)ssn_attributedStringWithLineSpacing:(CGFloat)lineSpacing sections:(id<SSNAttributedStringSection>)firstSection, ... NS_REQUIRES_NIL_TERMINATION {
    
    NSMutableArray *sections = [NSMutableArray array];
    
    if (firstSection) {
        [sections addObject:firstSection];
        
        va_list argumentList;
        va_start(argumentList, firstSection);
        id section;
        while ((section = va_arg(argumentList, id)))
        {
            [sections addObject:section];
        }
        va_end(argumentList);
    }
    
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    
    for (id <SSNAttributedStringSection>section in sections) {
        [attributeString appendAttributedString:[self ssn_attributedStringWithString:section.string font:section.font color:section.color underline:section.underline strikethrough:section.strikethrough lineSpacing:0.0f]];
    }
    
    if (lineSpacing > 0.0f) {
        //调整行间距
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.paragraphSpacing = 0;
        [paragraphStyle setLineSpacing:lineSpacing];
        
        //添加段落
        [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributeString length])];
    }
    
    return attributeString;
}

@end


@interface SSNAttributedStringSection : NSObject<SSNAttributedStringSection>
@end

@implementation SSNAttributedStringSection

@synthesize string;//内容
@synthesize font;//字体
@synthesize color;//颜色
@synthesize underline;           //下划线
@synthesize strikethrough;       //删除线

- (instancetype)copyWithZone:(NSZone *)zone {
    SSNAttributedStringSection *section = [[[self class] alloc] init];
    section.string = self.string;
    section.font = self.font;
    section.color = self.color;
    section.underline = self.underline;
    section.strikethrough = self.strikethrough;
    return section;
}

@end

id<SSNAttributedStringSection> ssn_attributedStringSection(NSString *string, UIFont *font, UIColor *color, BOOL underline, BOOL strikethrough) {
    SSNAttributedStringSection *section = [[SSNAttributedStringSection alloc] init];
    section.string = string;
    section.font = font;
    section.color = color;
    section.underline = underline;
    section.strikethrough = strikethrough;
    return section;
}


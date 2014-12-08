//
//  NSString+SSN.m
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "NSString+SSN.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SSN)

+ (NSString *)stringWithSuitableLength:(NSUInteger)length UTF8Format:(const char *)format, ...
{
    char *c_str = (char *)malloc(sizeof(char) * length);
    memset(c_str, 0x0, sizeof(sizeof(char) * length));

    va_list arg_ptr;
    va_start(arg_ptr, format);
    vsprintf(c_str, format, arg_ptr);
    va_end(arg_ptr);

    if (c_str)
    {
        NSString *subString = [NSString stringWithUTF8String:c_str];
        free(c_str);
        return subString;
    }
    else
    {
        return nil;
    }
}

+ (NSString *)stringWithUTF8Format:(const char *)format, ...
{

    char c_str[1024];
    memset(c_str, 0x0, sizeof(c_str));
    va_list arg_ptr;
    va_start(arg_ptr, format);
    vsprintf(c_str, format, arg_ptr);
    va_end(arg_ptr);
    if (c_str)
    {
        return [NSString stringWithUTF8String:c_str];
    }
    else
    {
        return nil;
    }
}

+ (NSString *)stringWithUTF8String:(const char *)cstring repeat:(NSInteger)time
{
    NSInteger sublength = strlen(cstring);
    NSInteger length = time * sublength;
    if (length == 0)
    {
        return nil;
    }

    char *c_str = (char *)malloc(sizeof(char) * length + 1);
    memset(c_str, 0x0, (sizeof(char) * length + 1));

    char *p_str = c_str;
    do
    {
        strncpy(p_str, cstring, sublength);
        p_str = (sizeof(char) * sublength) + p_str;
    } while (p_str != (c_str + length));

    if (c_str)
    {
        NSString *subString = [NSString stringWithUTF8String:c_str];
        free(c_str);
        return subString;
    }
    else
    {
        return nil;
    }
}

+ (NSString *)stringWithUTF8String:(const char *)cstring repeat:(NSInteger)time joinedUTF8String:(const char *)cjoined
{
    NSInteger sublength = strlen(cstring);
    NSInteger joinlength = strlen(cjoined);
    NSInteger length = time * sublength + (time - 1) * joinlength;
    if (length == 0)
    {
        return nil;
    }

    char *c_str = (char *)malloc(sizeof(char) * length + 1);
    memset(c_str, 0x0, (sizeof(char) * length + 1));

    char *p_str = c_str;
    do
    {
        if (p_str != c_str)
        { //非第一行加入join
            strncpy(p_str, cjoined, joinlength);
            p_str = (sizeof(char) * joinlength) + p_str;
        }

        strncpy(p_str, cstring, sublength);
        p_str = (sizeof(char) * sublength) + p_str;
    } while (p_str != (c_str + length));

    if (c_str)
    {
        NSString *subString = [NSString stringWithUTF8String:c_str];
        free(c_str);
        return subString;
    }
    else
    {
        return nil;
    }
}

+ (NSString *)componentsStringWithArray:(NSArray *)array
                        appendingString:(NSString *)append
                           joinedString:(NSString *)joined
{
    @autoreleasepool
    {
        NSMutableArray *temAry = [NSMutableArray arrayWithCapacity:1];
        for (NSString *str in array)
        {
            NSString *s = [str stringByAppendingString:append];
            [temAry addObject:s];
        }
        return [temAry componentsJoinedByString:joined];
    }
}

- (NSString *)ssn_md5 {
    const char *concat_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, (CC_LONG)strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}


- (NSString *)urlEncode
{
    NSString *resultString = self;
    NSString *temString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault, (CFStringRef)self, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    if ([temString length])
    {
        resultString = [NSString stringWithString:temString];
    }

    return temString;
}

- (NSString *)urlDecode
{
    NSString *resultString = self;
    NSString *temString = CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
        kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8));

    if ([temString length])
    {
        resultString = [NSString stringWithString:temString];
    }

    return temString;
}

- (NSRange)lastNestSubstringRange
{
    NSInteger beginIndex = 0;
    NSInteger endIndex = 0;
    NSRange searchRange = NSMakeRange(0, [self length]);
    BOOL nestFlag = NO;
    do
    {
        NSRange splitRange = [self rangeOfString:@"\"" options:NSBackwardsSearch range:searchRange];
        if (splitRange.length == 0)
        { //没有找到
            break;
        }

        if (!nestFlag)
        {                                             //说明是后面的回引号
            endIndex = splitRange.location;           //记录位置
            searchRange.length = splitRange.location; //缩小搜索范围
            nestFlag = YES;
            continue;
        }

        //下一个（往前）可能是引号的判断
        if (splitRange.location > 0)
        {
            unichar c = [self characterAtIndex:(splitRange.location - 1)];
            if (c == '\\')
            { //说明是进一步的嵌套，必须忽略，缩小搜索返回
                searchRange.length = splitRange.location - 1;
                continue;
            }
        }

        //说明是前引号
        beginIndex = splitRange.location + 1;
        break;

    } while (searchRange.length > 0);

    if (beginIndex > 0)
    {
        return NSMakeRange(beginIndex, (endIndex - beginIndex));
    }
    else
    {
        return NSMakeRange(NSNotFound, 0);
    }
}

- (BOOL)isJustNumberString
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSString *resultString = [self stringByTrimmingCharactersInSet:set];
    if ([resultString length] == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isString:(NSString *)str1 equalToString:(NSString *)str2
{
    if ([str1 isEqualToString:str2])
    {
        return YES;
    }

    if ([str1 length] == 0 && [str2 length] == 0)
    {
        return YES;
    }

    return NO;
}

#pragma mark predicate
+ (NSString *)predicateValue:(id)value key:(NSString *)key;
{
    if ([value isKindOfClass:[NSString class]])
    {
        return [NSString stringWithUTF8Format:"%s = '%s'", [key UTF8String], [(NSString *)value UTF8String]];
    }
    else if (value == nil || [value isEqual:[NSNull null]])
    {
        return [NSString stringWithUTF8Format:"%s IS NULL", [key UTF8String]];
    }
    else
    {
        return
            [NSString stringWithUTF8Format:"%s = %s", [key UTF8String], [[(NSObject *)value description] UTF8String]];
    }
}

+ (NSString *)predicateValues:(NSArray *)values keys:(NSArray *)keys
{
    NSMutableString *string = [NSMutableString stringWithCapacity:1];
    NSInteger index = 0;
    const NSUInteger values_count = [values count];
    for (NSString *key in keys)
    {

        id value = nil;
        if (index < values_count)
        {
            value = [values objectAtIndex:index];
        }

        if (index)
        {
            [string appendString:@" AND "];
        }

        NSString *temString = [self predicateValue:value key:key];
        [string appendString:temString];

        index++;
    }

    return string;
}

+ (NSString *)predicateKeyAndValues:(NSDictionary *)keyAndValues
{
    NSMutableString *string = [NSMutableString stringWithCapacity:1];

    BOOL isFirst = YES;
    for (NSString *key in [keyAndValues allKeys])
    {

        id value = [keyAndValues objectForKey:key];

        if (!isFirst)
        {
            [string appendString:@" AND "];
        }

        NSString *temString = [self predicateValue:value key:key];
        [string appendString:temString];

        isFirst = NO;
    }

    return string;
}

+ (NSString *)predicateStringKeyAndValues:(NSDictionary *)keyAndValues componentsJoinedByString:(NSString *)separator
{
    NSString *sep = separator;
    if ([sep length] == 0)
    {
        sep = @",";
    }

    NSMutableString *string = [NSMutableString stringWithCapacity:1];

    BOOL isFirst = YES;
    for (NSString *key in [keyAndValues allKeys])
    {

        id value = [keyAndValues objectForKey:key];

        if (!isFirst)
        {
            [string appendString:sep];
        }

        NSString *temString = [self predicateValue:value key:key];
        [string appendString:temString];

        isFirst = NO;
    }

    return string;
}

@end

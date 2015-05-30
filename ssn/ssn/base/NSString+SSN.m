//
//  NSString+SSN.m
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "NSString+SSN.h"
#import <CommonCrypto/CommonDigest.h>
#import "ssncrc64.h"

//暂时支持国家码识别
NSString *const SSNCNCountryCode = @"86";
NSString *const SSNHKCountryCode = @"852";  //香港
NSString *const SSNTWCountryCode = @"886";  //台湾
NSString *const SSNUSCountryCode = @"1";    //美国
NSString *const SSNGBCountryCode = @"44";   //英国
NSString *const SSNJPCountryCode = @"81";   //日本
NSString *const SSNRUCountryCode = @"7";    //俄罗斯
NSString *const SSNFRCountryCode = @"33";   //法国

#define SSNCountryCodes  \
@[\
SSNCNCountryCode,\
SSNHKCountryCode,\
SSNTWCountryCode,\
SSNUSCountryCode,\
SSNGBCountryCode,\
SSNJPCountryCode,\
SSNRUCountryCode,\
SSNFRCountryCode\
]

BOOL ssn_is_equal_to_string(NSString *str1, NSString *str2) {
    
    if (str1 == str2) {
        return YES;
    }
    
    NSUInteger len1 = [str1 length];
    NSUInteger len2 = [str2 length];
    
    if (len1 == 0 && len2 == 0)
    {
        return YES;
    }

    if (len1 != len2) {
        return NO;
    }
    
    return [str1 isEqualToString:str2];
}

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

- (NSString *)ssn_crc64 {
    const char * s = [self UTF8String];
    uint64_t crc = ssn_crc64(0,(const unsigned char *)s,strlen(s));
    return [NSString stringWithUTF8Format:"%qx",crc];
}

//全部符合集合的子字符串，若传入nil返回当前string copy
- (NSString *)ssn_substringMeetCharacterSet:(NSCharacterSet *)set {
    if (!set) {
        return [self copy];
    }
    @autoreleasepool {
        NSMutableString *sub = [NSMutableString string];
        NSString *text = [self copy];
        for (NSUInteger index = 0; index < [text length];index++) {
            unichar c = [text characterAtIndex:index];
            if ([set characterIsMember:c]) {
                [sub appendFormat:@"%C",c];
            }
        }
        return [sub copy];
    }
}

- (BOOL)ssn_containsChinese {
    if ([self length] == 0) {
        return NO;
    }
    NSString *match=@"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}


- (NSString *)ssn_urlEncode
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

- (NSString *)ssn_urlDecode
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

- (BOOL)ssn_non_empty {
    return [self length] > 0;
}

- (NSRange)ssn_lastNestSubstring
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

- (BOOL)ssn_isNumberString
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



/**
 * 去掉字符串两端的空白字符
 *
 **/
- (NSString *)ssn_trimWhitespace {
    if(nil == self){
        return nil;
    }
    NSMutableString *str = [NSMutableString stringWithString:self];
    CFStringTrimWhitespace((CFMutableStringRef)str);
    return str;
}

/**
 * 去掉字符串所有的空白字符
 *
 **/
- (NSString *)ssn_trimAllWhitespace {
    if(nil == self){
        return nil;
    }
    NSString *copy = [self copy];
    
    NSMutableString *str = [NSMutableString string];
    for (NSUInteger index = 0; index < [copy length]; index++) {
        unichar c = [copy characterAtIndex:index];
        if (c != ' ' && c != '\t' && c != '\r' && c != '\n') {
            [str appendFormat:@"%C",c];
        }
    }
    return str;
}

/**
 * 判断一个字符串是否全由字母组成
 *
 * @return NSString
 **/
- (BOOL)ssn_isLetters {
    NSString *regPattern = @"[a-zA-Z]+";
    NSPredicate *testResult = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regPattern];
    return [testResult evaluateWithObject:self];
}

/**
 * 忽略大小写比较两个字符串
 *
 * @return BOOL
 **/
- (BOOL)ssn_isEqualCaseInsensitive:(NSString *)str {
    if (nil == str) {
        return NO;
    }
    
    return [self compare:str options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

/* 是否包含特定字符串 */
- (BOOL)ssn_containsString:(NSString *)str {
    if (nil == str || [str length] == 0) {
        return NO;
    }
    
    return [self rangeOfString:str].length > 0;
}


//字符串是不是一个纯整数型
- (BOOL)ssn_isPureInteger {
    NSScanner* scan = [NSScanner scannerWithString:self];
    NSInteger val;
    return [scan scanInteger:&val] && [scan isAtEnd];
}

/* 获取 UTF8 编码的 NSData 值 */
- (NSData *)ssn_toUTF8Data {
    if ([self length] == 0) {
        return [NSData data];
    }
    
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

/**
 *  是否为电话号码，忽略格式【344】【443】【335】
 *
 *  @return 是否为号码
 */
- (BOOL)ssn_isValidMobileNumber {
    NSString *num = [self ssn_trimCountryCodePhoneNumber];
    if ([num length] != 11) {//最短亲情号，三位
        return NO;
    }
    
    NSString *pattern = @"^1[0-9]{10}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [regextestmobile evaluateWithObject:num];
}

- (NSString *)ssn_trimPhoneNumber {
    
    NSMutableString *countryCode = [NSMutableString string];
    NSMutableString *mobile = [NSMutableString string];
    
    NSInteger index = 0;
    NSInteger length = [self length];
    
    BOOL mayBeCountryCode = NO;
    if ([self hasPrefix:@"+"]) {
        mayBeCountryCode = YES;
        index = 1;
    }
    else if ([self hasPrefix:@"00"]) {
        mayBeCountryCode = YES;
        index = 2;
    }
    
    if (mayBeCountryCode) {//考虑计算国家吗，最长国家码7位
        
        [countryCode appendString:@"+"];
        
        const NSInteger max_cc_length = 7;//国家码最长
        
        NSInteger max_cc_location = index + max_cc_length + 1;//检查到国家码最长后一位，如果仍然没有分割符，就不算国家码
        
        for (; index < max_cc_location && index < length; index++) {
            
            unichar c = [self characterAtIndex:index];
            
            if ((c >= '0' && c <= '9')//数字
                || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')//字母也支持，
                || (c == '#' || c == '*')//“#”号也支持
                ) {
                NSString *charString = [NSString stringWithFormat:@"%c",c];
                [countryCode appendString:charString];
                [mobile appendString:charString];
            }
            else {//遇到非法字符，可以终止
                break ;
            }
        }
        
        if ([countryCode length] > 1 && [countryCode length] <= max_cc_length + 1) {//前面有个加号
            [mobile setString:@"-"];//增加减号连接符
        }
        else {
            //保留其加号
            [countryCode setString:@"+"];
        }
    }
    
    for (; index < length; index++) {
        
        unichar c = [self characterAtIndex:index];
        
        //合法字符
        if ((c >= '0' && c <= '9')//数字
            || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')//字母也支持，
            || (c == '#' || c == '*')//“#”号也支持
            ) {
            NSString *charString = [NSString stringWithFormat:@"%c",c];
            [mobile appendString:charString];
        }
        else {//遇到非法字符，可以终止
            continue ;
        }
    }
    
    if ([mobile isEqualToString:@"-"]) {//说明后面并没有找到多余号码
        [mobile setString:@""];
    }
    
    return [NSString stringWithFormat:@"%@%@",countryCode,mobile];
}

//去掉号码中包含的国家码，这里只对中国国家码做处理
- (NSString *)ssn_trimCountryCodePhoneNumber {
    NSString *num = [self ssn_trimPhoneNumber];
    if ([num hasPrefix:@"+86-"]) {
        return [num substringFromIndex:[@"+86-" length]];
    }
    else if ([num hasPrefix:@"+86"]) {
        return [num substringFromIndex:[@"+86" length]];
    }
    else {
        return num;
    }
}

- (NSString *)ssn_mobile344Format {
    return [self ssn_mobile344FormatSeparatedByCharacter:' '];
}

//344方式分割号码
- (NSString *)ssn_mobile344FormatSeparatedByCharacter:(unichar)character {
    unichar sep = character;
    if (sep == 0) {
        sep = ' ';
    }
    NSUInteger len = [self length];
    
    @autoreleasepool {
        NSMutableString *format = [NSMutableString string];
        NSUInteger mask = 0;
        for (NSUInteger idx = 0; idx < len; idx++) {
            unichar c = [self characterAtIndex:idx];
            if (c < '0' || c > '9') {
                continue ;
            }
            
            mask++;
            [format appendFormat:@"%C",c];
            
            if (mask % 4 == 3 && idx + 1 < len) {//非最后一个时
                [format appendFormat:@"%C",sep];
            }
        }
        
        return format;
    }
}

//是否是合法邮箱
- (BOOL)ssn_isValidEmail {
    NSString *txt = [self ssn_trimWhitespace];
    if ([txt length] < 5) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:txt];
}


- (BOOL)ssn_isValidIDCardNumber {
    NSString *txt = [self ssn_trimWhitespace];
    if (txt.length != 18) {
        return NO;
    }
    NSString *regex = @"^(\\d{17}x|\\d{18})$";
    return [[self ssn_substringForRegex:regex] count] != 0;
}

// 根据正则表达式截取字符串
- (NSArray *)ssn_substringForRegex:(NSString *)regex {
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:1];
    
    NSError * error;
    NSRegularExpression * expression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray * matches                = [expression matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    for (NSUInteger i = 0; i < matches.count; i++) {
        NSTextCheckingResult * result = [matches objectAtIndex:i];
        
        for (NSUInteger j = 0; j < result.numberOfRanges; j++) {
            NSRange range = [result rangeAtIndex:j];
            if (range.location == NSNotFound) {
                continue;
            }
            NSString * string = [self substringWithRange:range];
            [array addObject:string];
        }
    }
    
    return array;
}


// 将字符串中与正则表达式匹配的字符串替换成指定的字符串
- (NSString *)ssn_stringByReplaceRegex:(NSString *)regex withString:(NSString *)replace{
    NSError * error;
    NSRegularExpression * expression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString * string                = [expression stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:replace];
    
    return  string;
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

//比较应用程序版本大小如：1.0.0 和 1.2.0
- (NSComparisonResult)ssn_compareAppVersion:(NSString *)version {
    NSArray *selfComps = [self componentsSeparatedByString:@"."];
    NSArray *targComps = [version componentsSeparatedByString:@"."];
    
    NSUInteger self_count = [selfComps count];
    NSUInteger targ_count = [targComps count];
    
    if (self_count > 0 && targ_count > 0) {
        __block NSComparisonResult rt = NSOrderedSame;
        [selfComps enumerateObjectsUsingBlock:^(NSString *v, NSUInteger idx, BOOL *stop) {
            if (idx >= targ_count) {
                rt = NSOrderedDescending;
                *stop = YES;
                return ;
            }
            
            NSString *tv = [targComps objectAtIndex:idx];
            
            rt = [v compare:tv];
            if (rt != NSOrderedSame) {
                *stop = YES;
                return ;
            }
        }];
        
        return rt;
    }
    else if (self_count > 0) {
        return NSOrderedDescending;
    }
    else if (targ_count > 0) {
        return NSOrderedAscending;
    }
    
    return NSOrderedSame;
}

//对date格式支持
+ (NSString *)ssn_stringWithDate:(NSDate *)date formatter:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([dateFormat length]) {
        formatter.dateFormat = dateFormat;
    }
    return [formatter stringFromDate:date];
}

@end

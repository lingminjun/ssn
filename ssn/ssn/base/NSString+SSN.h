//
//  NSString+SSN.h
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

//除了字符串相等外，如下情况：nil == nil，"" == nil也相等
FOUNDATION_EXTERN BOOL ssn_is_equal_to_string(NSString *str1, NSString *str2);

@interface NSString (SSN)

//高效的format
+ (NSString *)stringWithSuitableLength:(NSUInteger)length UTF8Format:(const char *)format, ...;

//高效的format，长度保持在1024
+ (NSString *)stringWithUTF8Format:(const char *)format, ...;

+ (NSString *)stringWithUTF8String:(const char *)cstring repeat:(NSInteger)time;

+ (NSString *)stringWithUTF8String:(const char *)cstring repeat:(NSInteger)time joinedUTF8String:(const char *)cjoined;

+ (NSString *)componentsStringWithArray:(NSArray *)array
                        appendingString:(NSString *)append
                           joinedString:(NSString *)joined;

//小写
- (NSString *)ssn_md5;

//crc64
- (NSString *)ssn_crc64;

//全部符合集合的子字符串，若传入nil返回当前string copy
- (NSString *)ssn_substringMeetCharacterSet:(NSCharacterSet *)set;

//是否包含中文
- (BOOL)ssn_containsChinese;

// urlencode
- (NSString *)ssn_urlEncode;

// urldecode
- (NSString *)ssn_urlDecode;

//是否非空，不等于nil或者空字符串
- (BOOL)ssn_non_empty;

//嵌套子字符串寻找，如“ddddddd\"xxxxx\"ddddd”,其子字符为"xxxxx"
- (NSRange)ssn_lastNestSubstring; //最后一个内嵌字符串

//判断仅仅由号码组成的字符串
- (BOOL)ssn_isNumberString;

//去掉首位空白字符
- (NSString *)ssn_trimWhitespace;

//去掉字符串所有的空白字符
- (NSString *)ssn_trimAllWhitespace;

//判断一个字符串是否全由字母组成
- (BOOL)ssn_isLetters;

//忽略大小写比较
- (BOOL)ssn_isEqualCaseInsensitive:(NSString *)str;

//是否包含某个子串
- (BOOL)ssn_containsString:(NSString *)str;

//字符串是不是一个纯整数型
- (BOOL)ssn_isPureInteger;

/* 获取 UTF8 编码的 NSData 值 */
- (NSData *)ssn_toUTF8Data;

//是合法的手机号码（中国手机号，忽略格式【344】【443】【335】且各种分割符，以及+86 0086国家码前缀）
- (BOOL)ssn_isValidMobileNumber;

//返回+86-15888888888,+8615888888888或者15888888888，只是对号码做简单整理，过滤所有非法字符
- (NSString *)ssn_trimPhoneNumber;

//去掉号码中包含的国家码，这里只对中国国家码做处理
- (NSString *)ssn_trimCountryCodePhoneNumber;

//344方式分割号码,空格分割
- (NSString *)ssn_mobile344Format;

//344方式分割号码
- (NSString *)ssn_mobile344FormatSeparatedByCharacter:(unichar)character;

//是否是合法邮箱
- (BOOL)ssn_isValidEmail;

//是否为合法身份证号（中国）
- (BOOL)ssn_isValidIDCardNumber;

/*!
 @method
 @abstract      获取字符串中与初入正则表达式匹配规则符合的字符串数组
 @param         regex : 正则表达式
 @return        返回匹配正则表达式规则的字符串数组
 */
- (NSArray *)ssn_substringForRegex:(NSString *)regex;
/*!
 @method
 @abstract      将字符串中与正则表达式匹配的字符串替换成指定的字符串
 @param         regex : 正则表达式
 @param         replace : 替换字符串
 @return        返回替换后的新字符串对象
 */
- (NSString *)ssn_stringByReplaceRegex:(NSString *)regex withString:(NSString *)replace;


//对Predicate支持 key = value
+ (NSString *)predicateValue:(id)value key:(NSString *)key;

//对Predicate支持,顺序按照keys的顺序，values 少于 keys时，用null替代 key1 = value1 AND key2 = value2 AND key3 IS NULL
+ (NSString *)predicateValues:(NSArray *)values keys:(NSArray *)keys;

//对Predicate支持,顺序按照keys的顺序，
+ (NSString *)predicateKeyAndValues:(NSDictionary *)keyAndValues;

//对Predicate支持,顺序按照keys的顺序，默认使用逗号分隔
+ (NSString *)predicateStringKeyAndValues:(NSDictionary *)keyAndValues componentsJoinedByString:(NSString *)separator;

//比较应用程序版本大小如：1.0.0 和 1.2.0
- (NSComparisonResult)ssn_compareAppVersion:(NSString *)version;

//对date格式支持
+ (NSString *)ssn_stringWithDate:(NSDate *)date formatter:(NSString *)dateFormat;

@end

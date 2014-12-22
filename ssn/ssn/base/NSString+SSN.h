//
//  NSString+SSN.h
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

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


- (NSString *)ssn_md5;//小写

// urlencode
- (NSString *)urlEncode;

// urldecode
- (NSString *)urlDecode;

//嵌套子字符串寻找
- (NSRange)lastNestSubstringRange; //最后一个内嵌字符串

- (BOOL)isJustNumberString; //判断仅仅由号码组成的字符串

+ (BOOL)isString:(NSString *)str1
    equalToString:(NSString *)str2; //除了字符串相等外，如下情况：nil == nil，"" == nil也相等

//对Predicate支持 key = value
+ (NSString *)predicateValue:(id)value key:(NSString *)key;

//对Predicate支持,顺序按照keys的顺序，values 少于 keys时，用null替代 key1 = value1 AND key2 = value2 AND key3 IS NULL
+ (NSString *)predicateValues:(NSArray *)values keys:(NSArray *)keys;

//对Predicate支持,顺序按照keys的顺序，
+ (NSString *)predicateKeyAndValues:(NSDictionary *)keyAndValues;

//对Predicate支持,顺序按照keys的顺序，默认使用逗号分隔
+ (NSString *)predicateStringKeyAndValues:(NSDictionary *)keyAndValues componentsJoinedByString:(NSString *)separator;

@end

//
//  NSString+SSNPinyin.h
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SSNPinyin)

/**
 *  返回字符串的pinyin字符串，不支持多音字
 *
 *  @return 返回字符串的拼音字符串
 */
- (NSString *)ssn_pinyin;

/**
 *  返回首拼，仅仅中文有效，不支持多音字,如输入：“大长今”，返回：“DZJ”
 *
 *  @return 返回其首拼
 */
- (NSString *)ssn_firstSpell;

/**
 *  返回供查询的拼音组合，支持多音字以及首拼，如输入：“大长今”，返回：“DZJ,DCJ,dazhangjin,dachangjin,daizhangjin,daichangjin”
 *  原来字符建议不要太长，否则非常消耗
 *  非中不支持首拼
 *
 *  @return 返回供查询的拼音组合
 */
- (NSString *)ssn_searchPinyinString;

@end

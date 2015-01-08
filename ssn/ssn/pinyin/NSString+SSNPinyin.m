//
//  NSString+SSNPinyin.m
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "NSString+SSNPinyin.h"

NSString *const SSNUnicodeToPinyinKey = @"ssn";

@implementation NSString (SSNPinyin)

+ (NSDictionary *)unicodeToPinyinDictionary {
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
        [cache setCountLimit:1];
    });
    
    NSDictionary *dictionary = [cache objectForKey:SSNUnicodeToPinyinKey];
    if (!dictionary) { @autoreleasepool {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"unicode_to_pinyin" ofType:@"txt"];
        
        FILE *fp = NULL;
        fp = fopen([path UTF8String], "rt");
        if (fp == NULL)
        {
            abort();
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
#define SSNMaxPinyinCombineLength   (40)
        char line_str[SSNMaxPinyinCombineLength] = {'\0'};
        while (!feof(fp)) { @autoreleasepool {
            
            memset(line_str, 0, SSNMaxPinyinCombineLength);
            fgets(line_str, SSNMaxPinyinCombineLength, fp);
            
            NSString *line = [NSString stringWithUTF8String:line_str];
            NSArray *comps = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([comps count] < 2) {
                NSLog(@"err:[%@]",line);
                continue;
            }
            NSString *key = comps[0];
            NSString *value = comps[1];
            if ([value isEqualToString:@"none"]) {
                continue;
            }
            
            unichar c = strtol([key UTF8String], NULL, 16);
            
            NSArray *values = [value componentsSeparatedByString:@","];//暂时只支持首拼
            [dic setObject:values forKey:@(c)];
        }}
        
        fclose(fp);
        
        dictionary = [dic copy];
        [cache setObject:dictionary forKey:SSNUnicodeToPinyinKey];
    }}
    
    return dictionary;
}

- (NSString *)ssn_pinyin {
    @autoreleasepool {
        NSString *txt = [self copy];
        NSUInteger len = [txt length];
        NSDictionary *dic = [NSString unicodeToPinyinDictionary];
        NSMutableString *py = [NSMutableString string];
        for (NSUInteger idx = 0; idx < len; idx++) {
            unichar c = [txt characterAtIndex:idx];
            NSString *fpy = [dic objectForKey:@(c)][0];
            if (fpy) {
                [py appendString:fpy];
            }
            else {
                [py appendFormat:@"%C",c];//[py appendString:[txt substringWithRange:NSMakeRange(idx, 1)]];//防止iOS表情
            }
        }
        return [py copy];
    }
}



- (NSString *)ssn_firstSpell {
    @autoreleasepool {
        NSString *txt = [self copy];
        NSUInteger len = [txt length];
        NSDictionary *dic = [NSString unicodeToPinyinDictionary];
        NSMutableString *py = [NSMutableString string];
        for (NSUInteger idx = 0; idx < len; idx++) {
            unichar c = [txt characterAtIndex:idx];
            NSString *fpy = [dic objectForKey:@(c)][0];
            if (fpy) {
                [py appendString:[[fpy substringToIndex:1] uppercaseString]];
            }
            else {
                [py appendFormat:@"%C",c];//[py appendString:[txt substringWithRange:NSMakeRange(idx, 1)]];//防止iOS表情
            }
        }
        return [py copy];
    }
}

- (void)appendComp:(NSString *)comp depth:(NSUInteger)depth sources:(NSArray *)sources appendTo:(NSMutableString *)appendTo {
    if (depth >= [sources count]) {
        
        if ([appendTo length] > 0) {
            [appendTo appendFormat:@",%@",comp];
        }
        else {
            [appendTo appendString:comp];
        }
        
        return ;
    }
    
    @autoreleasepool {
        NSArray *comps = [sources objectAtIndex:depth];
        for (NSString *str in comps) {
            NSString *n_str = [comp stringByAppendingString:str];
            [self appendComp:n_str depth:(depth + 1) sources:sources appendTo:appendTo];
        }
    }
}

- (NSString *)ssn_searchPinyinString {
    @autoreleasepool {
        NSString *txt = [self copy];
        NSUInteger len = [txt length];
        NSDictionary *dic = [NSString unicodeToPinyinDictionary];
        
        NSMutableArray *comps = [NSMutableArray array];
        NSMutableArray *fscomps = [NSMutableArray array];
        NSMutableString *comp = nil;
        
        for (NSUInteger idx = 0; idx < len; idx++) { @autoreleasepool {
            unichar c = [txt characterAtIndex:idx];
            
            NSArray *pys = [dic objectForKey:@(c)];
            if (pys) {
                
                if (comp) {//处理非转拼音部分连续串
                    NSArray *compArray = @[comp];
                    [comps addObject:compArray];
                    [fscomps addObject:compArray];
                    comp = nil;
                }
                
                //再添加转拼音首次串
                [comps addObject:pys];
                
                //添加首拼
                NSMutableArray *fspys = [NSMutableArray arrayWithCapacity:[pys count]];
                for (NSString *py in pys) {
                    NSString *fpy = [[py substringToIndex:1] uppercaseString];
                    if (![fspys containsObject:fpy]) {
                        [fspys addObject:fpy];
                    }
                }
                [fscomps addObject:fspys];
            }
            else {
                
                if (!comp) {
                    comp = [NSMutableString string];
                }
                
                [comp appendFormat:@"%C",c];//[py appendString:[txt substringWithRange:NSMakeRange(idx, 1)]];//防止iOS表情
            }
        }}
        
        if (comp) {//处理最后一个comp
            NSArray *compArray = @[comp];
            [comps addObject:compArray];
            [fscomps addObject:compArray];
            comp = nil;
        }
    
        NSMutableString *py = [NSMutableString string];
        //先处理首拼
        if ([fscomps count]) {
            [self appendComp:@"" depth:0 sources:fscomps appendTo:py];
        }
                
        if ([comps count]) {
            [self appendComp:@"" depth:0 sources:comps appendTo:py];
        }
    
        return [py copy];
    }
}

@end

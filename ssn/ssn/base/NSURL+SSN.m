//
//  NSURL+SSN.m
//  ssn
//
//  Created by lingminjun on 15/3/28.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSURL+SSN.h"
#import "NSString+SSN.h"

@implementation NSURL (SSN)

- (NSDictionary *)ssn_queryStringToDictionaryWithURLDecode:(BOOL)decode {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    //query中的数据
    @autoreleasepool {
        NSString *queryString = [self query];
        
        if ([queryString length] == 0) {
            return dic;
        }
        
        NSString *string = [queryString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";?#"]];
        NSArray *params = [string componentsSeparatedByString:@"&"];
        
        for (NSString *param in params) {
            
            NSString *key = nil;
            NSString *value = nil;
            
            NSRange range = [param rangeOfString:@"="];
            if (range.length > 0) {
                key = [param substringToIndex:range.location];
                value = [param substringFromIndex:(range.location + range.length)];
            }
            else {
                key = param;
            }
            
            if (value == nil) {
                value = @"";
            }
            else {
                if (decode) {
                    value = [value ssn_urlDecode];
                }
            }
            
            id pre_value = [dic objectForKey:key];
            if (pre_value) {
                if ([pre_value isKindOfClass:[NSMutableArray class]]) {
                    [(NSMutableArray *)pre_value addObject:value];
                }
                else {
                    NSMutableArray *values = [NSMutableArray arrayWithCapacity:2];
                    [values addObject:pre_value];
                    [values addObject:value];
                    [dic setObject:values forKey:key];
                }
            }
            else {
                [dic setObject:value forKey:key];
            }
        }
    }
    
    return dic;
}

- (NSDictionary *)ssn_queryStringToDictionary {
    return [self ssn_queryStringToDictionaryWithURLDecode:YES];
}

- (BOOL)ssn_isEqualToURL:(NSURL *)url {
    
    if (!ssn_is_equal_to_string([self fragment],[url fragment])) {
        return NO;
    }
    
    return [self ssn_isEqualToURLNoFragment:url];
}

- (BOOL)ssn_isEqualToURLNoFragment:(NSURL *)url {
    if (!ssn_is_equal_to_string([self scheme], [url scheme])) {
        return NO;
    }
    
    if (!ssn_is_equal_to_string([self host],[url host])) {
        return NO;
    }
    
    if ([[self port] integerValue] != [[url port] integerValue]) {
        return NO;
    }
    
    if (!ssn_is_equal_to_string([self user],[url user])) {
        return NO;
    }
    
    if (!ssn_is_equal_to_string([self password],[url password])) {
        return NO;
    }
    
    if (!ssn_is_equal_to_string([self path],[url path])) {
        return NO;
    }
    
    if (!ssn_is_equal_to_string([self parameterString],[url parameterString])) {
        return NO;
    }
    
    NSDictionary *selfQuery = [self ssn_queryStringToDictionaryWithURLDecode:NO];//效率考虑
    NSDictionary *otherQuery = [url ssn_queryStringToDictionaryWithURLDecode:NO];//效率考虑
    if (![selfQuery isEqualToDictionary:otherQuery]) {
        return NO;
    }
    
    return YES;
}

- (NSURL *)ssn_resetURLWithPath:(NSString *)newPath appendQuery:(NSDictionary *)query  isExclusiveKey:(BOOL)exclusive needFragment:(BOOL)fragment {
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    if ([[self scheme] length] > 0) {
        NSString *schemeString = [NSString stringWithUTF8Format:"%s://",[[self scheme] UTF8String]];
        [result appendString:schemeString];
    }
    else {//默认才有http协议
        [result appendString:@"http://"];
    }
    
    if ([[self user] length] > 0 && [[self password] length] > 0) {
        NSString *loginString = [NSString stringWithUTF8Format:"%s:%s@",[[self user] UTF8String],[[self password] UTF8String]];
        [result appendString:loginString];
    }
    
    if ([[self host] length] > 0) {
        [result appendString:[self host]];
    }
    
    if ([[self port] integerValue] > 0) {
        NSString *portString = [NSString stringWithUTF8Format:":%d",[[self port] integerValue]];
        [result appendString:portString];
    }
    
    if ([newPath length] > 0) {
        if (![newPath hasPrefix:@"/"]) {
            newPath = [NSString stringWithSuitableLength:[newPath length]+2 UTF8Format:"/%s",[newPath UTF8String]];
        }
        [result appendString:newPath];
    }
    else {
        NSString *path = [self path];
        if ([path length] > 0) {
            [result appendString:path];
        }
    }
    
    NSString *parameterString = [self parameterString];
    if ([parameterString length] > 0) {
        NSString *paramString = [NSString stringWithUTF8Format:";%s",[parameterString UTF8String]];
        [result appendString:paramString];
    }
    
    //query
    NSMutableDictionary * temDic = [NSMutableDictionary dictionaryWithCapacity:1];
    if ([[self query] length] > 0) {
        NSDictionary *dic = [self ssn_queryStringToDictionaryWithURLDecode:NO];
        [temDic setDictionary:dic];
    }
    
    if ([query count] > 0) {
        for (NSString *key in query) {
            NSString *value = [query objectForKey:key];
            
            if (exclusive) {//独占key很好处理
                if ([value isKindOfClass:[NSArray class]]) {
                    value = [(NSArray *)value firstObject];
                }
                
                value = [value ssn_urlEncode];//必须对外部的参数进项encode
                [temDic setObject:value forKey:key];
            }
            else {
                NSString *oldValue = [temDic objectForKey:key];
                if ([oldValue isKindOfClass:[NSMutableArray class]]) {//因为前面能确定都是可变数组
                    if ([value isKindOfClass:[NSArray class]]) {
                        for (NSString *v in (NSArray *)value) {
                            //必须对外部的参数进项encode
                            [(NSMutableArray *)oldValue addObject:[v ssn_urlEncode]];
                        }
                        [(NSMutableArray *)oldValue addObjectsFromArray:(NSArray *)value];
                    }
                    else {
                        value = [value ssn_urlEncode];//必须对外部的参数进项encode
                        [(NSMutableArray *)oldValue addObject:value];
                    }
                }
                else if (oldValue != nil) {
                    NSMutableArray *array = [NSMutableArray arrayWithObject:oldValue];
                    if ([value isKindOfClass:[NSArray class]]) {
                        for (NSString *v in (NSArray *)value) {
                            //必须对外部的参数进项encode
                            [(NSMutableArray *)oldValue addObject:[v ssn_urlEncode]];
                        }
                    }
                    else {
                        [array addObject:[value ssn_urlEncode]];
                    }
                    [temDic setObject:array forKey:key];
                }
                else {
                    [temDic setObject:[value ssn_urlEncode] forKey:key];
                }
            }
            
        }
    }
    
    if ([temDic count] > 0) {
        NSString *queryString = [temDic ssn_toQueryStringWithURLEncode:NO];
        if ([queryString length] > 0) {
            [result appendString:@"?"];
            [result appendString:queryString];
        }
    }
    
    if (fragment) {//
        NSString *oldFragment = [self fragment];
        if ([oldFragment length] > 0) {
            NSString *fragmString = [NSString stringWithUTF8Format:"#%s",[oldFragment UTF8String]];
            [result appendString:fragmString];
        }
    }
    
    return [NSURL URLWithString:result];
}

//返回一个新的url，参数扩充
- (NSURL *)ssn_URLByAppendQuery:(NSDictionary *)query {
    return [self ssn_URLByAppendQuery:query isExclusiveKey:YES];
}

//返回一个新的url，参数扩充，每个key是否都唯一（原url某个key对应的values将随机取一个值）
- (NSURL *)ssn_URLByAppendQuery:(NSDictionary *)query isExclusiveKey:(BOOL)exclusive {
    return [self ssn_resetURLWithPath:nil appendQuery:query isExclusiveKey:exclusive needFragment:YES];
}

//重置url,path传入nil时保持不变，query传入nil时保持不变
- (NSURL *)ssn_resetURLForPath:(NSString *)path appendQuery:(NSDictionary *)query {
    return [self ssn_resetURLForPath:path appendQuery:query isExclusiveKey:YES];
}

- (NSURL *)ssn_resetURLForPath:(NSString *)path appendQuery:(NSDictionary *)query isExclusiveKey:(BOOL)exclusive {
    return [self ssn_resetURLWithPath:path appendQuery:query isExclusiveKey:exclusive needFragment:YES];
}

- (NSArray *)ssn_validPathComponents {
    NSArray *paths = [self pathComponents];
    if ([paths count]) {
        NSMutableArray *temAry = [NSMutableArray arrayWithArray:paths];
        [temAry removeObject:@"/"];
        return temAry;
    }
    else {
        return paths;
    }
}

- (BOOL)ssn_isHTTPURL {
    if ([[self scheme] rangeOfString:@"http" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)].length > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)ssn_isAppStoreURL {
    if ([[self scheme] rangeOfString:@"itms-apps" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 9)].length > 0) {
        return YES;
    }
    else {
        if ([[self host] rangeOfString:@"itunes.apple.com" options:NSCaseInsensitiveSearch].length > 0) {
            return YES;
        }
    }
    return NO;
}

@end


@implementation NSDictionary (SSNURL)

- (NSString *)ssn_toQueryStringWithURLEncode:(BOOL)encode {
    @autoreleasepool {
        NSDictionary *dic = [self copy];
        
        NSArray *keys = [dic allKeys];
        if ([keys count] == 0) {
            return nil;
        }
        
        keys = [keys sortedArrayUsingSelector:@selector(compare:)];
        
        NSMutableString *str = [NSMutableString stringWithCapacity:10];
        BOOL isFirst = YES;
        for (NSString *key in keys) {
            
            NSArray *values = [dic objectForKey:key];
            if (![values isKindOfClass:[NSArray class]]) {
                values = @[values];
            }
            else {
                values = [values sortedArrayUsingSelector:@selector(compare:)];
            }
            
            for (NSString *value in values) {
                
                NSString *v = value;
                if (encode) {
                    v = [value ssn_urlEncode];
                }
                
                if (isFirst) {
                    isFirst = NO;
                }
                else {
                    [str appendString:@"&"];
                }
                
                NSString *item = [NSString stringWithUTF8Format:"%s=%s",[key UTF8String],[v UTF8String]];
                [str appendString:item];
            }
        }
        
        return [NSString stringWithString:str];
    }
}

//转换成queryString,元素仅仅支持字符串内容，key升序，当一个key有多个values时，values升序
- (NSString *)ssn_toQueryString {
    return [self ssn_toQueryStringWithURLEncode:YES];
}

@end


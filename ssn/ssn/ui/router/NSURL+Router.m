//
//  NSURL+Router.m
//  ssn
//
//  Created by lingminjun on 14-7-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "NSURL+Router.h"

@implementation NSURL (SSNRouter)

#pragma mark 私有api实现
+ (NSString *)ssn_URLEncodeString:(NSString *)string {
    NSString *resultString = string;
    NSString *temString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                    (CFStringRef)string,
                                                                                    NULL,
                                                                                    (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                    kCFStringEncodingUTF8));
    if ([temString length])
    {
        resultString = [NSString stringWithString:temString];
    }
    
    return temString;
}

+ (NSString *)ssn_URLDecodeString:(NSString *)string {
    NSString *resultString = string;
    NSString *temString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                              (CFStringRef)string,
                                                                              CFSTR(""),
                                                                              kCFStringEncodingUTF8));
    
    if ([temString length]) {
        resultString = [NSString stringWithString:temString];
    }
    
    return temString;
}

+ (NSDictionary *)ssn_string:(NSString *)queryString toDictionaryDecode:(BOOL)decode {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    @autoreleasepool {
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
                value = [self ssn_URLDecodeString:value];
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


+ (NSString *)ssn_stringForDictionary:(NSDictionary *)dic encode:(BOOL)encode {
    NSArray *keys = [dic allKeys];
    if ([keys count] == 0) {
        return nil;
    }
    
    keys = [keys sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableString *str = [NSMutableString stringWithCapacity:10];
    @autoreleasepool {
        BOOL isFirst = YES;
        for (NSString *key in keys) {
            id obj = [dic objectForKey:key];
            if ([obj isKindOfClass:[NSArray class]]) {
                NSMutableArray *values = [NSMutableArray array];
                NSArray *temlist = (NSArray *)obj;
                for (NSString *value in temlist) {
                    NSString *rt = value;
                    if (encode) {
                        rt = [self ssn_URLEncodeString:value];
                    }
                    [values addObject:rt];
                }
                
                [values sortUsingSelector:@selector(compare:)];
                
                for (NSString *value in values) {
                    if (isFirst) {
                        isFirst = NO;
                    }
                    else {
                        [str appendString:@"&"];
                    }
                    
                    NSString *item = [NSString stringWithFormat:@"%@=%@",key,value];
                    [str appendString:item];
                }
            }
            else if ([obj isKindOfClass:[NSString class]]) {
                NSString *value = (NSString *)obj;
                
                if (encode) {
                    value = [self ssn_URLEncodeString:value];
                }
                
                if (isFirst) {
                    isFirst = NO;
                }
                else {
                    [str appendString:@"&"];
                }
                
                NSString *item = [NSString stringWithFormat:@"%@=%@",key,value];
                [str appendString:item];
            }
            else {
                NSString *value = [NSString stringWithFormat:@"%@",obj];
                if (encode) {
                    value = [self ssn_URLEncodeString:value];
                }
                
                if (isFirst) {
                    isFirst = NO;
                }
                else {
                    [str appendString:@"&"];
                }
                
                NSString *item = [NSString stringWithFormat:@"%@=%@",key,value];
                [str appendString:item];
            }
        }
    }
    
    return [NSString stringWithString:str];
}

- (NSURL *)ssn_resetURLForPath:(NSString *)newPath appendQuery:(NSDictionary *)queryInfo {
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    if ([[self scheme] length] > 0) {
        NSString *schemeString = [NSString stringWithFormat:@"%@://",[self scheme]];
        [result appendString:schemeString];
    }
    else {//默认才有http协议
        [result appendString:@"http://"];
    }
    
    if ([[self user] length] > 0 && [[self password] length] > 0) {
        NSString *loginString = [NSString stringWithFormat:@"%@:%@@",[self user],[self password]];
        [result appendString:loginString];
    }
    
    if ([[self host] length] > 0) {
        [result appendString:[self host]];
    }
    
    if ([[self port] integerValue] > 0) {
        NSString *portString = [NSString stringWithFormat:@":%ld",[[self port] integerValue]];
        [result appendString:portString];
    }
    
    if ([newPath length] > 0) {
        if (![newPath hasPrefix:@"/"]) {
            newPath = [NSString stringWithFormat:@"/%@",newPath];
        }
        [result appendString:newPath];
    }
    else {
        if ([[self path] length] > 0) {
            [result appendString:[self path]];
        }
    }
    
    if ([[self parameterString] length] > 0) {
        NSString *paramString = [NSString stringWithFormat:@";%@",[self parameterString]];
        [result appendString:paramString];
    }
    
    //query
    NSMutableString *queryString = [NSMutableString stringWithCapacity:1];
    if ([[self query] length] > 0) {
        [queryString setString:[self query]];
    }
    
    NSString *appendQueryString = [NSURL ssn_stringForDictionary:queryInfo encode:YES];
    if ([appendQueryString length] > 0) {
        if ([queryString length] > 0) {
            [queryString appendFormat:@"&%@",appendQueryString];
        }
        else {
            [queryString setString:appendQueryString];
        }
    }
    
    if ([queryString length] > 0) {
        [result appendString:@"?"];
        [result appendString:queryString];
    }
    
    //fragment
    NSString *fragmentString = [self fragment];
    if ([fragmentString length] > 0) {
        [result appendFormat:@"#%@",fragmentString];
    }
    
    return [NSURL URLWithString:result];
}

#pragma mark api实现

- (NSArray *)ssn_routerPaths {
    NSMutableArray *paths = [NSMutableArray array];
    NSString *url_host = [self host];
    if ([url_host length] && ![url_host isEqualToString:@"/"]) {
        [paths addObject:url_host];
    }
    
    NSArray *url_paths = [self pathComponents];
    for (NSString *url_path in url_paths) {
        if ([url_path length] && ![url_path isEqualToString:@"/"]) {
            [paths addObject:url_path];
        }
    }
    
    return paths;
}

- (NSDictionary *)ssn_queryInfo {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    //username和password
    @autoreleasepool {
        NSString *user = [self user];
        [dic setValue:user forKey:@"user"];
        
        NSString *password = [self password];
        [dic setValue:password forKey:@"password"];
    }
    
    //query中的数据
    @autoreleasepool {
        NSString *queryString = [self query];
        
        if ([queryString length] == 0) {
            return dic;
        }
        
        NSDictionary *querydic = [NSURL ssn_string:queryString toDictionaryDecode:YES];
        for (NSString *key in [querydic allKeys]) {
            id pre_value = [dic objectForKey:key];
            id value = [querydic objectForKey:key];
            if (pre_value) {
                if ([value isKindOfClass:[NSMutableArray class]]) {
                    [(NSMutableArray *)value addObject:pre_value];
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

//components都是NSString，其中“..”表示上级目录，“.”表示当前目录，“~”表示根目录
- (NSURL *)ssn_relativeURLWithComponents:(NSArray *)components {
    const NSInteger components_count = [components count];
    if (0 == components_count) {
        return [NSURL URLWithString:[self absoluteString]];
    }
    
    NSArray *base_paths = [self ssn_routerPaths];
    NSMutableArray *temAry = [NSMutableArray array];
    if (base_paths) {
        [temAry setArray:base_paths];
    }
    
    //对新增路径处理
    for (NSString *comp in components) {
        if ([comp isEqualToString:@"~"]) {//回到跟目录
            NSInteger count = [temAry count];
            if (count > 1) {
                [temAry removeObjectsInRange:NSMakeRange(1, count - 1)];
            }
        }
        else if ([comp isEqualToString:@".."]) {//回到上一级
            if ([temAry count] > 1) {//到了跟目录就不再操作了
                [temAry removeLastObject];
            }
        }
        else if ([comp isEqualToString:@"."]) {//忽略
        }
        else {
            [temAry addObject:comp];
        }
    }
    
    //去掉path的host
    NSString *first_comp = [temAry firstObject];
    if ([[self host] isEqualToString:first_comp]) {
        [temAry removeObjectAtIndex:0];
    }
    
    NSString *pathString = [NSString pathWithComponents:temAry];
    return [self ssn_resetURLForPath:pathString appendQuery:nil];
}



@end

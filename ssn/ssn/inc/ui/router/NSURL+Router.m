//
//  NSURL+Router.m
//  ssn
//
//  Created by lingminjun on 14-7-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "NSURL+Router.h"

@implementation NSURL (SSNRouter)

- (NSArray *)routerPaths {
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

- (NSString *)urlDecodeString:(NSString *)string {
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

- (NSDictionary *)queryInfo {
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
                value = [self urlDecodeString:value];
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

@end

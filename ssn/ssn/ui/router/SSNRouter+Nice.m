//
//  SSNRouter+Nice.m
//  ssn
//
//  Created by lingminjun on 15/3/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNRouter+Nice.h"
#import "NSURL+Router.h"

@implementation SSNRouter (Nice)

- (BOOL)open:(NSString *)url {
    return [self open:url query:nil];
}
- (BOOL)open:(NSString *)url query:(NSDictionary *)query {
    
    if ([url length] == 0) {
        return NO;
    }
    
    NSURL *u = [NSURL URLWithString:url];
    if (u == nil) {
        return NO;
    }
    
    BOOL animated = YES;
    
    NSString *an = [query objectForKey:@"animated"];
    if (!an) {
        NSURL *u = [NSURL URLWithString:url];
        if (u) {
            NSDictionary *url_query = [u ssn_queryInfo];
            an = [url_query objectForKey:@"animated"];
        }
    }
    
    if ([an length] > 0
        && ([an compare:@"no" options:NSCaseInsensitiveSearch] == NSOrderedSame
            || [an compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
        animated = [an boolValue];
    }
    
    return [self open:url query:query animated:animated];
}

- (BOOL)open:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated {
    
    if ([url hasPrefix:@"./"] || [url hasPrefix:@"../"] || [url hasPrefix:@"~/"] || [url hasPrefix:@"/"]) {
        return [self openRelativePath:url query:query animated:animated];
    }
    else{
        return [self openURL:[NSURL URLWithString:url] query:query animated:animated];
    }
    
}

@end

@implementation NSObject (SSNRouterNice)

/**
 * 支持相对路径打开
 */
- (BOOL)ssn_open:(NSString *)url {
    return [self ssn_open:url query:nil];
}
- (BOOL)ssn_open:(NSString *)url query:(NSDictionary *)query {
    BOOL animated = YES;
    
    NSString *an = [query objectForKey:@"animated"];
    if (!an) {
        NSURL *u = [NSURL URLWithString:url];
        if (u) {
            NSDictionary *url_query = [u ssn_queryInfo];
            an = [url_query objectForKey:@"animated"];
        }
    }
    
    if ([an length] > 0
        && ([an compare:@"no" options:NSCaseInsensitiveSearch] == NSOrderedSame
            || [an compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
            animated = [an boolValue];
    }
    return [self ssn_open:url query:query animated:animated];
}

- (BOOL)ssn_open:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated {
    if ([url hasPrefix:@"./"] || [url hasPrefix:@"../"] || [url hasPrefix:@"~/"] || [url hasPrefix:@"/"]) {
        return [self openRelativePath:url query:query animated:animated];
    }
    else{
        return [self openURL:[NSURL URLWithString:url] query:query animated:animated];
    }
}


@end

//
//  UIApplication+SSNCategory.m
//  ssn
//
//  Created by lingminjun on 15/2/10.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIApplication+SSNCategory.h"

@implementation UIApplication (SSNCategory)

#define SSN_SHARED_DICTIONARY_IMP(property) \
+ (NSMutableDictionary *)ssn_ ## property ## _Dictionary {            \
    static NSMutableDictionary *dic = nil;                      \
    static dispatch_once_t onceToken;                           \
    dispatch_once(&onceToken, ^{                                \
        dic = [[NSMutableDictionary alloc] initWithCapacity:1]; \
    });                                                         \
    return dic;                                                 \
}

#define SSN_SHARED_DICTIONARY_SET(value, key, condition, property, addImp, removeImp)        \
do { if (key) {                                                         \
    NSMutableDictionary *dic = [self ssn_ ## property ## _Dictionary];\
    if (condition) { [dic setObject: (value) forKey: (key)]; }       \
    else { [dic removeObjectForKey: (key) ]; }                       \
    if ([dic count]) { addImp; } else { removeImp; } }                      \
} while(NO)

#define SSN_SHARED_DICTIONARY_GET(key, property) [[self ssn_ ## property ## _Dictionary] objectForKey:(key)]
#define SSN_SHARED_DICTIONARY_COUNT(property) [[self ssn_ ## property ## _Dictionary] count]

#pragma mark networkActivityIndicatorVisible Category
SSN_SHARED_DICTIONARY_IMP(networkActivityIndicator)

+ (void)ssn_networkActivityIndicatorVisible:(BOOL)visible forKey:(NSString *)key {
    SSN_SHARED_DICTIONARY_SET(@(visible), key, visible, networkActivityIndicator, [UIApplication sharedApplication].networkActivityIndicatorVisible=YES, [UIApplication sharedApplication].networkActivityIndicatorVisible=NO);
}

+ (BOOL)ssn_isNetworkActivityIndicatorVisibleForKey:(NSString *)key {
    NSNumber *v = SSN_SHARED_DICTIONARY_GET(key, networkActivityIndicator);
    return [v boolValue];
}

+ (BOOL)ssn_isNetworkActivityIndicatorVisible {
    NSUInteger count = SSN_SHARED_DICTIONARY_COUNT(networkActivityIndicator);
    return count > 0;
}

#pragma mark ignoringInteractionEvents Category
SSN_SHARED_DICTIONARY_IMP(ignoringInteraction)

+ (void)ssn_ignoringInteractionEvents:(BOOL)ignoring forKey:(NSString *)key {
    SSN_SHARED_DICTIONARY_SET(@(ignoring), key, ignoring, ignoringInteraction, [[UIApplication sharedApplication] beginIgnoringInteractionEvents], [[UIApplication sharedApplication] endIgnoringInteractionEvents]);
}

+ (BOOL)ssn_isIgnoringInteractionEventsForKey:(NSString *)key {
    NSNumber *v = SSN_SHARED_DICTIONARY_GET(key, ignoringInteraction);
    return [v boolValue];
}

+ (BOOL)ssn_isIgnoringInteractionEvents {
    NSUInteger count = SSN_SHARED_DICTIONARY_COUNT(ignoringInteraction);
    return count > 0;
}

@end

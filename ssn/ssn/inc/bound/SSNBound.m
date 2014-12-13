//
//  SSNBound.m
//  ssn
//
//  Created by lingminjun on 14/12/13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNBound.h"
#import "SSNSafeDictionary.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@implementation NSObject (SSNBound)

static char *ssn_bound_dictionary_key = NULL;
- (SSNSafeDictionary *)ssn_bound_dictionary {
    
    SSNSafeDictionary *dic = objc_getAssociatedObject(self, ssn_bound_dictionary_key);
    if (dic) {
        return dic;
    }
    
    @synchronized(self) {
        if (!dic) {
            dic = [[SSNSafeDictionary alloc] initWithCapacity:1];
            objc_setAssociatedObject(self, ssn_bound_dictionary_key, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    return dic;
}

static char *ssn_bound_dictionary_tail_key = NULL;
- (SSNSafeDictionary *)ssn_bound_dictionary_tail {
    
    SSNSafeDictionary *dic = objc_getAssociatedObject(self, ssn_bound_dictionary_tail_key);
    if (dic) {
        return dic;
    }
    
    @synchronized(self) {
        if (!dic) {
            dic = [[SSNSafeDictionary alloc] initWithCapacity:1];
            objc_setAssociatedObject(self, ssn_bound_dictionary_tail_key, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    return dic;
}


@end

//
//  SSNMeta.m
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNMeta.h"
#import <pthread.h>
#import "ssnbase.h"

static pthread_mutex_t meta_mutex;

@implementation SSNMeta

@synthesize vls = _vls;
@synthesize tkey = _tkey;
@synthesize tcls = _tcls;
@synthesize opt = _opt;

#pragma mark 实现Meta 工程
+ (NSMutableDictionary *)metaPool {
    static CFMutableDictionaryRef pool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFDictionaryValueCallBacks valueCallBacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
        pool = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &valueCallBacks);
        pthread_mutex_init(&meta_mutex, NULL);
    });
    return (__bridge NSMutableDictionary *)pool;
}

+ (SSNMeta *)productWithModelClass:(id)tcl modelKey:(NSString *)key {
    NSMutableDictionary *pool = [self metaPool];
    
    //NSString *pkey = [NSString stringWithUTF8Format:"%p-%s",tcl,[key UTF8String]];
    SSNMeta *meta = [pool objectForKey:key];
    if (!meta) {
        pthread_mutex_lock(&meta_mutex);
        
        //在锁内部创建出meta对象
        meta = [pool objectForKey:key];
        if (!meta) {
            meta = [[self alloc] init];
            meta.vls = [[NSMutableDictionary alloc] init];
            meta.tkey = key;
            meta.tcls = tcl;
            meta.opt = 0;
            [pool setObject:meta forKey:key];
        }
        
        pthread_mutex_unlock(&meta_mutex);
    }
    
    return meta;
}

- (void)dealloc {
    NSMutableDictionary *pool = [SSNMeta metaPool];
    [pool removeObjectForKey:self.tkey];
}

//实现hash 便于数组集合
- (BOOL)isEqual:(SSNMeta *)other
{
    if ([other isKindOfClass:[SSNMeta class]]) {
        return [self.tkey isEqualToString:other.tkey];
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.tkey hash];
}



@end

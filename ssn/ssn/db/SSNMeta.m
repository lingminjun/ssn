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

@interface SSNMeta ()

@property (nonatomic,strong) NSMutableDictionary *  vls;
@property (nonatomic,strong) NSString            *  mkey;
@property (nonatomic,strong) NSString            *  tkey;
@property (nonatomic,strong) id tcls;
@property (nonatomic) NSUInteger opt;
@property (nonatomic) BOOL isFault;

@end

@implementation SSNMeta

@synthesize vls = _vls;
@synthesize tkey = _tkey;
@synthesize mkey = _mkey;
@synthesize tcls = _tcls;
@synthesize opt = _opt;
@synthesize isFault = _isFault;

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

+ (SSNMeta *)productWithModelClass:(id)tcl modelKey:(NSString *)modelKey {
    NSAssert(tcl && [modelKey length], @"meta创建必须有model class 其 model key");
    
    NSMutableDictionary *pool = [self metaPool];
    
    NSString *key = SSNCompositeMetaKey(tcl,modelKey);
    SSNMeta *meta = [pool objectForKey:key];
    if (!meta) {
        pthread_mutex_lock(&meta_mutex);
        
        //在锁内部创建出meta对象
        meta = [pool objectForKey:key];
        if (!meta) {
            meta = [[self alloc] init];
            meta.vls = [[NSMutableDictionary alloc] init];
            meta.tkey = key;
            meta.mkey = modelKey;
            meta.tcls = tcl;
            meta.opt = 0;
            [pool setObject:meta forKey:key];
        }
        
        pthread_mutex_unlock(&meta_mutex);
    }
    
    return meta;
}

#pragma mark 数据生命周期函数
- (id)init {
    self = [super init];
    if (self) {
        _isFault = YES;
    }
    return self;
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

#pragma mark 数据加载 实现

//加载全部数据
+ (BOOL)loadMeta:(SSNMeta *)meta datas:(NSDictionary *)datas {
    if (![datas count]) {
        return NO;
    }
    
    [meta.vls setDictionary:datas];
    meta.isFault = NO;
    
    return YES;
}

//加载主键数据，仍然是isFault状态
+ (BOOL)loadMeta:(SSNMeta *)meta keyDatas:(NSDictionary *)keyDatas {
    if (!meta.isFault) {
        return NO;
    }
    
    if (![keyDatas count]) {
        return NO;
    }
    
    [meta.vls setDictionary:keyDatas];
    
    return YES;
}

@end

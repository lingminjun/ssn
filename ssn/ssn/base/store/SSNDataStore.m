//
//  SSNDataStore.m
//  ssn
//
//  Created by lingminjun on 14/12/7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDataStore.h"
#import "NSString+SSN.h"
#import "NSFileManager+SSN.h"
#import <pthread.h>

NSString *const SSNDataStoreDir = @"ssndatastore";
#define SSNDataStoreCASFactorLength 2

@interface SSNDataStore () {
    pthread_rwlock_t _rwlock;
    NSCache *_cache;//数据做缓存
    NSString *_path;
}

- (void)saveToFileWithData:(NSData *)data forKey:(NSString *)key;
- (NSData *)dataFromFileForKey:(NSString *)key;
- (void)removeFileForKey:(NSString *)key;

@end

@implementation SSNDataStore

@synthesize scope = _scope;

- (instancetype)initWithScope:(NSString *)scope isCacheDir:(BOOL)cacheDir {
    NSAssert([scope length], @"请输入正确的scope目录");
    self = [super init];
    if (self) {
        _scope = [scope copy];
        _cache = [[NSCache alloc] init];
        pthread_rwlock_init(&_rwlock, NULL);
        _isCacheDir = cacheDir;
        
        NSString *comps = [SSNDataStoreDir stringByAppendingPathComponent:scope];
        NSFileManager *manager = [NSFileManager ssn_fileManager];
        if (cacheDir) {
            _path = [manager pathCachesDirectoryWithPathComponents:comps];
        }
        else {
            _path = [manager pathDocumentDirectoryWithPathComponents:comps];
        }
    }
    return self;
}

- (void)dealloc {
    pthread_rwlock_destroy(&_rwlock);
}


/**
 @brief key对应的存储的文件内容
 @param key 需要寻找的key
 @return 返回找到的数据，可能返回nil
 */
- (NSData *)dataForKey:(NSString *)key {
    NSData *data = [_cache objectForKey:key];
    if (data) {
        return data;
    }
    
    pthread_rwlock_rdlock(&_rwlock);
    data = [self dataFromFileForKey:key];
    pthread_rwlock_unlock(&_rwlock);
    
    if (data) {
        [_cache setObject:data forKey:key cost:[data length]];
    }
    
    return data;
}

/**
 @brief 将数据存放到对应的key下面
 @param key 对应的key
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key {
    [_cache setObject:data forKey:key cost:[data length]];
    
    pthread_rwlock_wrlock(&_rwlock);
    [self saveToFileWithData:data forKey:key];
    pthread_rwlock_unlock(&_rwlock);
}

/**
 @brief 删除对应的数据
 @param key 对应的key
 */
- (void)removeDataForKey:(NSString *)key {
    [_cache removeObjectForKey:key];
    
    pthread_rwlock_wrlock(&_rwlock);
    [self removeFileForKey:key];
    pthread_rwlock_unlock(&_rwlock);
}


/**
 @brief 返回数据存放位置
 @param key 需要寻找的key
 @return 返回路径（绝对路径），可能返回nil
 */
- (NSString *)dataPathForKey:(NSString *)key {
    NSString *md5 = [key ssn_md5];
    NSString *header = [md5 substringToIndex:SSNDataStoreCASFactorLength];
    NSString *file = [NSString stringWithFormat:@"%@/%@.dt",header,md5];
    return [_path stringByAppendingPathComponent:file];
}

/**
 @brief 释放内存换曾
 */
- (void)clearMemory {
    [_cache removeAllObjects];
}


/**
 @brief 清理磁盘【不可逆】
 */
- (void)clearDisk {
    [self clearMemory];
    
    //目录删除
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    NSError *error = nil;
    pthread_rwlock_wrlock(&_rwlock);
    if ([manager fileExistsAtPath:_path]) {
        [manager removeItemAtPath:_path error:&error];
    }
    [manager createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:&error];
    pthread_rwlock_unlock(&_rwlock);
}


#pragma mark 文件存储实现
- (void)saveToFileWithData:(NSData *)data forKey:(NSString *)key {
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    NSString *filepath = [self dataPathForKey:key];
    NSString *dirpath = [filepath stringByDeletingLastPathComponent];
    
    NSError *error = nil;
    if (![manager fileExistsAtPath:dirpath]) {
        [manager createDirectoryAtPath:dirpath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    [data writeToFile:filepath atomically:YES];
}

- (NSData *)dataFromFileForKey:(NSString *)key {
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    NSString *filepath = [self dataPathForKey:key];
    return [manager contentsAtPath:filepath];
}

- (void)removeFileForKey:(NSString *)key {
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    NSString *filepath = [self dataPathForKey:key];
    
    NSError *error = nil;
    if ([manager fileExistsAtPath:filepath]) {
        [manager removeItemAtPath:filepath error:&error];
    }
}

@end

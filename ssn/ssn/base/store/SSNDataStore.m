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

@interface SSNDataStoreCacheBox : NSObject
@property (nonatomic,strong) NSData *data;
@property (nonatomic) int64_t visitAt;//访问时间点
@property (nonatomic) uint64_t expire;//过期时长
@end

@implementation SSNDataStoreCacheBox
+ (instancetype)boxWithData:(NSData *)data {
    SSNDataStoreCacheBox *box = [[[self class] alloc] init];
    box.data = data;
    return box;
}
@end

@interface SSNDataStore () {
    pthread_rwlock_t _rwlock;
    NSCache *_cache;//数据做缓存
    NSCache *_expireCache;//超时时间缓存
    NSString *_path;
}
@end

@implementation SSNDataStore

@synthesize scope = _scope;

- (instancetype)initWithScope:(NSString *)scope directoryType:(SSNDataStoreDirectoryType)directoryType {
    NSAssert([scope length], @"请输入正确的scope目录");
    self = [super init];
    if (self) {
        _scope = [scope copy];
        _cache = [[NSCache alloc] init];
        _directoryType = directoryType;
        pthread_rwlock_init(&_rwlock, NULL);
        
        NSString *comps = [SSNDataStoreDir stringByAppendingPathComponent:scope];
        NSFileManager *manager = [NSFileManager ssn_fileManager];
        
        switch (directoryType) {
            case SSNDataStoreDocumentDirectory:
                _path = [manager pathDocumentDirectoryWithPathComponents:comps];
                break;
            case SSNDataStoreCachesDirectory:
                _path = [manager pathCachesDirectoryWithPathComponents:comps];
                break;
            case SSNDataStoreTemporaryDirectory:
                _path = [manager pathTemporaryDirectoryWithPathComponents:comps];
                break;
            default:
                _path = [manager pathDocumentDirectoryWithPathComponents:comps];
                break;
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
    SSNDataStoreCacheBox *box = [_cache objectForKey:key];
    
    if (box && box.expire == 0) {//直接返回，不需要检查
        return box.data;
    }
    
    int64_t now = [self getNowTime];
    
    //有效
    if (box.expire > 0) {
        box.visitAt = now;
        
        BOOL expired = box.expire + box.visitAt > now;
        pthread_rwlock_wrlock(&_rwlock);
        if (expired) {//过期删除
            [_cache removeObjectForKey:key];
            [self removeFileForKey:key];
            box.data = nil;
        }
        else {//未过期更新时间
            NSString *filepath = [self dataPathForKey:key];
            [self updateTailExpire:box.expire visitAt:now atFilePath:filepath];//传入零删除日志文件
        }
        pthread_rwlock_unlock(&_rwlock);
        
        return box.data;
    }
    
    uint64_t expire = 0;
    BOOL isExpired = NO;
    
    //需要从文件中获取
    pthread_rwlock_wrlock(&_rwlock);
    NSData *data = [self dataFromFileForKey:key expire:&expire saveAt:NULL visitAt:now isExpired:&isExpired readonly:NO];
    pthread_rwlock_unlock(&_rwlock);
    
    if (data && !isExpired) {
        SSNDataStoreCacheBox *box = [SSNDataStoreCacheBox boxWithData:data];
        box.expire = expire;
        box.visitAt = now;
        [_cache setObject:box forKey:key cost:[data length]];
    }
    else {//过期的不返回
        data = nil;
    }
    
    return data;
}

/**
 @brief key对应的存储的文件内容，文件过期返回nil，不更新文件访问实效性
 @param key 需要寻找的key
 @return 返回找到的数据，可能返回nil
 */
- (NSData *)accessDataForKey:(NSString *)key {
    SSNDataStoreCacheBox *box = [_cache objectForKey:key];
    
    if (box && box.expire == 0) {//直接返回，不需要检查
        return box.data;
    }
    
    int64_t now = [self getNowTime];
    
    //有效
    if (box.expire > 0) {
        box.visitAt = now;
        
        BOOL expired = box.expire + box.visitAt > now;
        pthread_rwlock_wrlock(&_rwlock);
        if (expired) {//过期删除
            [_cache removeObjectForKey:key];
            [self removeFileForKey:key];
            box.data = nil;
        }
        pthread_rwlock_unlock(&_rwlock);
        
        return box.data;
    }
    
    uint64_t expire = 0;
    int64_t saveAt = 0;
    BOOL isExpired = NO;
    
    //需要从文件中获取
    pthread_rwlock_wrlock(&_rwlock);
    NSData *data = [self dataFromFileForKey:key expire:&expire saveAt:&saveAt visitAt:now isExpired:&isExpired readonly:YES];
    pthread_rwlock_unlock(&_rwlock);
    
    if (data && !isExpired) {
        SSNDataStoreCacheBox *box = [SSNDataStoreCacheBox boxWithData:data];
        box.expire = expire;
        box.visitAt = saveAt;
        [_cache setObject:box forKey:key cost:[data length]];
    }
    else {
        data = nil;
    }
    
    return data;
}

/**
 @brief key对应的存储的文件内容，文件过期仍然返回，将在isExpired中标识，更新文件访问实效性
 @param key 需要寻找的key
 @param isExpired 数据是否过期
 @return 返回找到的数据，可能返回nil
 */
- (NSData *)dataForKey:(NSString *)key isExpired:(BOOL *)isExpired {
    SSNDataStoreCacheBox *box = [_cache objectForKey:key];
    
    if (box && box.expire == 0) {//直接返回，不需要检查
        if (isExpired) {
            *isExpired = NO;
        }
        return box.data;
    }
    
    int64_t now = [self getNowTime];
    
    //有效
    if (box.expire > 0) {
        box.visitAt = now;
        
        BOOL expired = box.expire + box.visitAt > now;
        
        if (isExpired) {
            *isExpired = expired;
        }
        
        pthread_rwlock_wrlock(&_rwlock);
        if (expired) {//过期删除
            [_cache removeObjectForKey:key];
            [self removeFileForKey:key];
        }
        else {//未过期更新时间
            NSString *filepath = [self dataPathForKey:key];
            [self updateTailExpire:box.expire visitAt:now atFilePath:filepath];//传入零删除日志文件
        }
        pthread_rwlock_unlock(&_rwlock);
        
        return box.data;
    }
    
    uint64_t expire = 0;
    BOOL tmpIsExpired = NO;
    
    //需要从文件中获取
    pthread_rwlock_wrlock(&_rwlock);
    NSData *data = [self dataFromFileForKey:key expire:&expire saveAt:NULL visitAt:now isExpired:&tmpIsExpired readonly:NO];
    pthread_rwlock_unlock(&_rwlock);
    
    if (isExpired) {//标记已经过期
        *isExpired = tmpIsExpired;
    }
    
    if (data && !isExpired) {
        SSNDataStoreCacheBox *box = [SSNDataStoreCacheBox boxWithData:data];
        box.expire = expire;
        box.visitAt = now;
        [_cache setObject:box forKey:key cost:[data length]];
    }
    
    return data;
}

/**
 @brief key对应的存储的文件内容，文件过期仍然返回，将在isExpired中标识，更新文件访问实效性
 @param key 需要寻找的key
 @param isExpired 数据是否过期
 @return 返回找到的数据，可能返回nil
 */
- (NSData *)accessDataForKey:(NSString *)key isExpired:(BOOL *)isExpired {
    SSNDataStoreCacheBox *box = [_cache objectForKey:key];
    
    if (box && box.expire == 0) {//直接返回，不需要检查
        if (isExpired) {
            *isExpired = NO;
        }
        return box.data;
    }
    
    int64_t now = [self getNowTime];
    
    //有效
    if (box.expire > 0) {
        box.visitAt = now;
        
        BOOL expired = box.expire + box.visitAt > now;
        
        if (isExpired) {
            *isExpired = expired;
        }
        
        pthread_rwlock_wrlock(&_rwlock);
        if (expired) {//过期删除
            [_cache removeObjectForKey:key];
            [self removeFileForKey:key];
        }
        pthread_rwlock_unlock(&_rwlock);
        
        return box.data;
    }
    
    uint64_t expire = 0;
    int64_t saveAt = 0;
    BOOL tmpIsExpired = NO;
    
    //需要从文件中获取
    pthread_rwlock_wrlock(&_rwlock);
    NSData *data = [self dataFromFileForKey:key expire:&expire saveAt:&saveAt visitAt:now isExpired:&tmpIsExpired readonly:YES];
    pthread_rwlock_unlock(&_rwlock);
    
    if (isExpired) {
        *isExpired = tmpIsExpired;
    }
    
    if (data && !isExpired) {
        SSNDataStoreCacheBox *box = [SSNDataStoreCacheBox boxWithData:data];
        box.expire = expire;
        box.visitAt = saveAt;
        [_cache setObject:box forKey:key cost:[data length]];
    }
    
    return data;
}

/**
 @brief 将数据存放到对应的key下面
 @param key 对应的key
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key {
    [self storeData:data forKey:key expire:0];
}

/**
 @brief 将数据存放到对应的key下面
 @param key 对应的key
 @param expire 过期时间(秒)，传入零表示永远不过期
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key expire:(uint64_t)expire {
    int64_t now = [self getNowTime];
    
    SSNDataStoreCacheBox *box = [SSNDataStoreCacheBox boxWithData:data];
    box.expire = expire;
    box.visitAt = now;
    
    [_cache setObject:box forKey:key cost:[data length]];
    
    pthread_rwlock_wrlock(&_rwlock);
    [self saveToFileWithData:data forKey:key expire:expire visitAt:now];
    pthread_rwlock_unlock(&_rwlock);
}

/**
 @brief 删除对应的数据
 @param key 对应的key
 */
- (void)removeDataForKey:(NSString *)key {
    [_cache removeObjectForKey:key];
    [_expireCache removeObjectForKey:key];
    
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

- (NSString *)dataTailForDataPath:(NSString *)dataPath {
    return [dataPath stringByAppendingString:@".tail"];
}

/**
 @brief 释放内存换曾
 */
- (void)clearMemory {
    [_cache removeAllObjects];
}


/**
 @brief 整理磁盘，主要清除过期文件
 */
- (void)tidyDisk {
    [self clearMemory];
    
    //扫描目录
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    
    NSArray *subPaths = [manager subpathsOfDirectoryAtPath:_path error:NULL];
    
    int64_t now = [self getNowTime];
    
    [subPaths enumerateObjectsUsingBlock:^(NSString *subPath, NSUInteger idx, BOOL *stop) {
        if ([subPath hasSuffix:@".tail"]) {//找到对应的时间文件
            pthread_rwlock_wrlock(&_rwlock);
            
            NSString *tailpath = [_path stringByAppendingPathComponent:subPath];
            BOOL isExpired = [self checkExpired:NULL saveAt:NULL visitAt:now atTailPath:tailpath];
            if (isExpired) {
                NSUInteger index = [tailpath length] - [@".tail" length];
                NSString *filepath = [tailpath substringToIndex:index];
                [manager removeItemAtPath:filepath error:NULL];
            }
            
            pthread_rwlock_unlock(&_rwlock);
        }
    }];
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
- (int64_t)getNowTime {
    time_t rawtime;
    time(&rawtime);
    return rawtime;
}

- (void)updateTailExpire:(uint64_t)expire visitAt:(int64_t)visitAt atFilePath:(NSString *)filepath {
    NSString *tailpath = [self dataTailForDataPath:filepath];
    if (expire > 0) {
        FILE *fp = fopen([tailpath UTF8String], "wt");//只写
        fprintf(fp, "%lld,%llu",visitAt, expire);
        fflush(fp);//效率稍微稍微收到影响
        fclose(fp);
    }
    else {
        unlink([tailpath UTF8String]);
    }
}

- (BOOL)updateCheckExpired:(uint64_t *)expire saveAt:(int64_t *)saveAt visitAt:(int64_t)visitAt atTailPath:(NSString *)tailpath {
    
    FILE *fp = fopen([tailpath UTF8String], "rt+");//读写不创建
    if (fp == NULL ) {//文件不存在，永不过期
        if (expire) {
            *expire = 0;
        }
        return NO;
    }
    
    char tailInfo[32] = {'\0'};
    fgets(tailInfo, 32, fp);
    
    char *p = strchr(tailInfo, ',');
    if (p) {
        *p = '\0';
        p++;
    }
    
    int64_t o_visitAt = atoll(tailInfo);
    uint64_t o_expire = atoll(p);
    
    if (saveAt) {
        *saveAt = o_visitAt;
    }
    
    if (expire) {
        *expire = o_expire;
    }
    
    BOOL isExpired = (o_expire + o_visitAt <= visitAt);
    
    if (isExpired) {//过期删除
        fclose(fp);
        unlink([tailpath UTF8String]);
    }
    else {
        fprintf(fp, "%lld,%llu",visitAt, o_expire);
        fflush(fp);//效率稍微稍微收到影响
        fclose(fp);
    }
    
    return isExpired;
}

- (BOOL)checkExpired:(uint64_t *)expire saveAt:(int64_t *)saveAt visitAt:(int64_t)visitAt atTailPath:(NSString *)tailpath {
    FILE *fp = fopen([tailpath UTF8String], "rt");//只读
    if (fp == NULL ) {//文件不存在，永不过期
        if (expire) {
            *expire = 0;
        }
        return NO;
    }
    
    char tailInfo[32] = {'\0'};
    fgets(tailInfo, 32, fp);
    
    char *p = strchr(tailInfo, ',');
    if (p) {
        *p = '\0';
        p++;
    }
    
    int64_t o_visitAt = atoll(tailInfo);
    uint64_t o_expire = atoll(p);
    
    if (saveAt) {
        *saveAt = o_visitAt;
    }
    
    if (expire) {
        *expire = o_expire;
    }
    
    fclose(fp);
    
    BOOL isExpired = (o_expire + o_visitAt <= visitAt);
    
    if (isExpired) {//过期删除
        unlink([tailpath UTF8String]);
    }
    
    return isExpired;
}


- (void)saveToFileWithData:(NSData *)data forKey:(NSString *)key expire:(uint64_t)expire visitAt:(int64_t)visitAt {
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    NSString *filepath = [self dataPathForKey:key];
    NSString *dirpath = [filepath stringByDeletingLastPathComponent];
    
    NSError *error = nil;
    if (![manager fileExistsAtPath:dirpath]) {
        [manager createDirectoryAtPath:dirpath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    [self updateTailExpire:expire visitAt:visitAt atFilePath:filepath];//更新时间
    [data writeToFile:filepath atomically:YES];
}

- (NSData *)dataFromFileForKey:(NSString *)key expire:(uint64_t *)expire saveAt:(int64_t *)saveAt visitAt:(int64_t)visitAt isExpired:(BOOL *)isExpired readonly:(BOOL)readonly {
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    NSString *filepath = [self dataPathForKey:key];
    NSData *data = [manager contentsAtPath:filepath];
    
    BOOL expired = NO;
    NSString *tailpath = [self dataTailForDataPath:filepath];
    if (readonly) {
        expired = [self checkExpired:expire saveAt:saveAt visitAt:visitAt atTailPath:tailpath];
    }
    else {
        expired = [self updateCheckExpired:expire saveAt:saveAt visitAt:visitAt atTailPath:tailpath];
    }
    
    NSError *error = nil;
    if (isExpired) {//过期删除文件
        *isExpired = expired;
        [manager removeItemAtPath:filepath error:&error];
    }
    
    return data;
}

- (void)removeFileForKey:(NSString *)key {
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    NSString *filepath = [self dataPathForKey:key];
    
    NSError *error = nil;
    if ([manager fileExistsAtPath:filepath]) {
        [manager removeItemAtPath:filepath error:&error];
        [self updateTailExpire:0 visitAt:0 atFilePath:filepath];//传入零删除日志文件
    }
}

@end

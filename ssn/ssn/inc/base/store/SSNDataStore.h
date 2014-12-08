//
//  SSNDataStore.h
//  ssn
//
//  Created by lingminjun on 14/12/7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 方便的存储文件，CAS（Content-Addressable Storage），内容寻址存储，系一种数据存储机构。
 */
@interface SSNDataStore : NSObject

@property (nonatomic,copy,readonly) NSString *scope;//所在区域（决定路径）
@property (nonatomic,readonly) BOOL isCacheDir;//是否为cache目录
@property (nonatomic) BOOL memoryCache;//内存缓存，是否存在内存缓存

/**
 @brief key对应的存储的文件内容
 @param key 需要寻找的key
 @return 返回找到的数据，可能返回nil
 */
- (NSData *)dataForKey:(NSString *)key;//key不能为空

/**
 @brief 将数据存放到对应的key下面
 @param key 对应的key
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key;

/**
 @brief 删除对应的数据
 @param key 对应的key
 */
- (void)removeDataForKey:(NSString *)key;


/**
 @brief 返回数据存放位置
 @param key 需要寻找的key
 @return 返回路径（绝对路径），可能返回nil
 */
- (NSString *)dataPathForKey:(NSString *)key;//key不能为空

/**
 @brief 释放内存换曾
 */
- (void)clearMemory;//


/**
 @brief 清理磁盘【不可逆】
 */
- (void)clearDisk;//

/**
 @brief Documents/ssnstore/[scope]目录下缓存
 */
+ (instancetype)dataStoreWithScope:(NSString *)scope;


/**
 @brief Library/Caches/ssnstore/[scope]目录下缓存
 */
+ (instancetype)cacheStoreWithScope:(NSString *)scope;

@end

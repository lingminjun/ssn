//
//  SSNDataStore.h
//  ssn
//
//  Created by lingminjun on 14/12/7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  目录类型
 */
typedef NS_ENUM(NSUInteger, SSNDataStoreDirectoryType){
    /**
     *  Document目录下
     */
    SSNDataStoreDocumentDirectory,
    /**
     *  Library/Caches目录下
     */
    SSNDataStoreCachesDirectory,
    /**
     *  tmp目录下
     */
    SSNDataStoreTemporaryDirectory,
};

/**
 @brief 方便的存储文件，灵活运用CAS（Content-Addressable Storage：内容寻址存储，是一种数据存储机构）。
        存储内容具备时效性，请使用者注意使用合适的接口获取数据
 */
@interface SSNDataStore : NSObject

@property (nonatomic,copy,readonly) NSString *scope;//所在区域（决定路径）
@property (nonatomic,readonly) SSNDataStoreDirectoryType directoryType;//是否为cache目录
@property (nonatomic) BOOL memoryCache;//内存缓存，是否存在内存缓存

/**
 @brief 唯一初始化方法
 @param scope 定义的域
 @param cacheDir 是否为cache目录
 @return 返回找到的数据，可能返回nil
 */
- (instancetype)initWithScope:(NSString *)scope directoryType:(SSNDataStoreDirectoryType)directoryType;

/**
 @brief key对应的存储的文件内容，数据过期返回nil，更新数据访问实效性
 @param key 需要寻找的key
 @return 返回找到的数据，可能返回nil，过期返回nil
 */
- (NSData *)dataForKey:(NSString *)key;//key不能为空

/**
 @brief key对应的存储的文件内容，数据过期返回nil，不更新数据访问实效性
 @param key 需要寻找的key
 @return 返回找到的数据，可能返回nil，过期返回nil
 */
- (NSData *)accessDataForKey:(NSString *)key;//key不能为空

/**
 @brief key对应的存储的文件内容，数据过期仍然返回，将在isExpired中标识过期，更新数据访问实效性
 @param key 需要寻找的key
 @param isExpired 数据是否过期
 @return 返回找到的数据，可能返回nil，找到过期仍然返回
 */
- (NSData *)dataForKey:(NSString *)key isExpired:(BOOL *)isExpired;//key不能为空

/**
 @brief key对应的存储的文件内容，数据过期仍然返回，将在isExpired中标识过期，不更新数据访问实效性
 @param key 需要寻找的key
 @param isExpired 数据是否过期
 @return 返回找到的数据，可能返回nil，找到过期仍然返回
 */
- (NSData *)accessDataForKey:(NSString *)key isExpired:(BOOL *)isExpired;//key不能为空

/**
 @brief 将数据存放到对应的key下面，数据永远不过期
 @param key 对应的key
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key;

/**
 @brief 将数据存放到对应的key下面
 @param key 对应的key
 @param expire 过期时间(秒)，传入0表示永远不过期
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key expire:(uint64_t)expire;

/**
 @brief 删除对应的数据
 @param key 对应的key
 */
- (void)removeDataForKey:(NSString *)key;

/**
 @brief 返回数据存放位置，不检查过期性
 @param key 需要寻找的key
 @return 返回路径（绝对路径），可能返回nil
 */
- (NSString *)dataPathForKey:(NSString *)key;//key不能为空

/**
 @brief 释放内存换曾，
 */
- (void)clearMemory;//

/**
 @brief 整理磁盘，主要清除过期文件，内存同时释放，耗时，操作
 */
- (void)tidyDisk;//

/**
 @brief 清理磁盘【不可逆】
 */
- (void)clearDisk;//

@end

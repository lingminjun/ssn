//
//  SSNBlackBox.h
//  ssn
//
//  Created by lingminjun on 14/12/11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    @brief 黑匣子工具
 */
@interface SSNBlackBox : NSObject

+ (instancetype)sharedInstance;

/**
 @brief 对应的密文文件
 @param path 黑匣子对应存储文件路径
 */
- (void)setBBoxPath:(NSString *)path;

/**
 @brief 根据key获取密文信息
 @param key 密文对应的key
 */
- (NSString *)securityValueForKey:(NSString *)key;


/**
 @brief 在对应的key上设置密文文件
 @param value 存储密文
 @param key 密文对应的key
 */
- (void)saveSecurityValue:(NSString *)value forKey:(NSString *)key;

/**
 @brief 根据key删除密文信息
 @param key 密文对应的key
 */
- (void)removeSecurityValueForKey:(NSString *)key;

@end

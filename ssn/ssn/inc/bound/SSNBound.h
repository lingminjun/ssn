//
//  SSNBound.h
//  ssn
//
//  Created by lingminjun on 14/12/13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSNSafeDictionary;

@protocol SSNBound <NSObject>
@required
/**
 @brief 返回另一端对象
 */
- (id)ssn_tailObject;

/**
 @brief 返回另一端绑定的key
 */
- (NSString *)ssn_tailKey;
@end


/**
 @brief 绑定器weak引用
 */
@interface SSNWeakBound : NSObject

- (id)object;

+ (instancetype)bound:(id<SSNBound>)obj;
+ (instancetype)bound:(id<SSNBound>)obj free:(void(^)(id obj))free;

@end

/**
 @brief 绑定器联合点，绑定器一定涉及两端端：绑定者和被绑定者
 */
@interface NSObject (SSNBound)

/**
 @brief 作用端绑定
 @param bound  绑定器
 @param key    绑定作用的属性
 */
- (void)ssn_tieBound:(id <SSNBound>)bound forKey:(NSString *)key;

/**
 @brief 响应端绑定
 @param box    绑定器weak装箱
 @param key    绑定作用的属性
 */
- (void)ssn_tieTailBound:(SSNWeakBound *)box forKey:(NSString *)key;

/**
 @brief 移除属性的绑定
 @param tieField    绑定作用的属性
 */
- (void)ssn_clearTieFieldBound:(NSString *)tieField;

@end
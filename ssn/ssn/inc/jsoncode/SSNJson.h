//
//  SSNJson.h
//  ssn
//
//  Created by lingminjun on 14-11-10.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  json coder对象负责encode和decode序列过程
 *  SSNJsonCoder非线程安全，你永远也不需要单独创建他的实例
 */
@interface SSNJsonCoder : NSObject
@end

/**
 *  json coding 协议，自定义对象需要重载此协议来实现自定义的code
 */
@protocol SSNJsonCoding <NSObject>

@required
- (void)encodeWithJsonCoder:(SSNJsonCoder *)aCoder;//写入
- (void)decodeWithJsonCoder:(SSNJsonCoder *)aDecoder;//写出

@end

/**
 *  默认实现支持，NSObject 默认实现了一套encodeWithJsonCoder和decodeWithJsonCoder，并提供通用方法来获取最终值
 *  NSObject的默认实现是code所有属性，key为属性名
 *  注意，若属性中存在NSNumber其中NSNumber为类对象('#')、方法(':')、指针('^')以及结构枚举共用体的复杂值类型将被当做bit encode
 */
@interface NSObject (SSNJson) <SSNJsonCoding>

- (NSData *)ssn_toJson;//转换成json序列
- (NSString *)ssn_toJsonString;//UTF8code

//- (NSData *)ssn_toCleanJson;//转换成json序列，不会将类名code到json
//- (NSString *)ssn_toCleanJsonString;//UTF8code，不会将类名code到json

+ (instancetype)ssn_objectFromJsonData:(NSData *)jsonData;//从json序列取出json描述的类实例
+ (instancetype)ssn_objectFromJsonString:(NSString *)jsonString;//从json序列取出json描述的类实例

+ (instancetype)ssn_objectFromJsonData:(NSData *)jsonData targetClass:(Class)targetClass;//从json序列取出targetClass类实例
+ (instancetype)ssn_objectFromJsonString:(NSString *)jsonString targetClass:(Class)targetClass;//从json序列取出targetClass类实例

@end

/**
 *  coder支持的类型
 *  注意key不能为空，传入的值必须有意义，解码遇到类型不对可能出现异常
 */
@interface SSNJsonCoder (SSNExtendedJsonCoder)

#pragma mark encode extend
/**
 *  encode对象类型
 *  @param objv 被encode的对象，如果你能明确encode的值或者对象类型，请务必调用对应类型的encode接口，否则无法正确decode出数据
 *          注意：objv尽量不要传入NSData，NSDate，String以及NSNumber或者NSValue对象基本类型，基本类型请使用下面的接口
 *  @param key encode 值对应的key
 */
- (void)encodeObject:(id)objv forKey:(NSString *)key;

- (void)encodeData:(NSData *)data forKey:(NSString *)key;//base64[]转string存储
- (void)encodeDate:(NSDate *)date forKey:(NSString *)key;//采用utc code
- (void)encodeString:(NSString *)string forKey:(NSString *)key;

/**
 *  encode NSValue以及NSNumber复杂值类型
 *  @param value 本转入的NSValue或者NSNumber类型
 *  @param key encode 值对应的key
 */
- (void)encodeValue:(NSValue *)value forKey:(NSString *)key;

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key;
- (void)encodeInt:(int)intv forKey:(NSString *)key;
- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key;
- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key;
- (void)encodeFloat:(float)realv forKey:(NSString *)key;
- (void)encodeDouble:(double)realv forKey:(NSString *)key;

#pragma mark decode extend
/**
 *  找到对应key的decode对象
 *  @param key encode 值对应的key
 *  @return 返回对应encodeObject:forKey:进入的对象，
 *   注意，encode时传入基本类型将造成无法正常解析出对象
 */
- (id)decodeObjectForKey:(NSString *)key;

- (NSData *)decodeDataForKey:(NSString *)key;
- (NSDate *)decodeDateForKey:(NSString *)key;
- (NSString *)decodeStringForKey:(NSString *)key;

/**
 *  找到对应key的值类型返回
 *  @param key encode 值对应的key
 *  @return 被encodeValue:forKey:进入的值类型
 */
- (NSValue *)decodeValueForKey:(NSString *)key;

- (BOOL)decodeBoolForKey:(NSString *)key;
- (int)decodeIntForKey:(NSString *)key;
- (int32_t)decodeInt32ForKey:(NSString *)key;
- (int64_t)decodeInt64ForKey:(NSString *)key;
- (float)decodeFloatForKey:(NSString *)key;
- (double)decodeDoubleForKey:(NSString *)key;


- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key;
- (NSInteger)decodeIntegerForKey:(NSString *)key;

//json array单独支持，一个对象选择array存储后，再调用上面对象存储方式，将会抛出异常，同样，一段选用上面对象存储方式后，就不能再选用数组存储了
- (void)encodeArray:(NSArray *)array;
- (void)addEncodeObjectInArray:(id)objv;
- (NSArray *)decodeArray;

@end

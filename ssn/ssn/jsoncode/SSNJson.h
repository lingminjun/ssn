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
- (id)initWithJsonCoder:(SSNJsonCoder *)aDecoder;//解析

@end

/**
 *  默认实现支持SSNJsonCoding，
 *  NSObject默认实现了一套encodeWithJsonCoder和decodeWithJsonCoder，并提供通用方法来获取最终值
 *  NSObject的默认实现是code所有属性，key为属性名
 *  注意：若对象属性类型被KVC转换成NSNumber，其中NSNumber为类对象('#')、方法(':')、指针('^')以及结构枚举共用体的复杂值类型将被当做bit encode
 *       对象的属性读写都是采用KVC方式，若你的属性中定义了指针（'*'）、自定义结构（'{'）请务必重载-valueForUndefinedKey:方法
 */
@interface NSObject (SSNJson) <SSNJsonCoding>

- (NSData *)ssn_toJson;//转换成json序列
- (NSString *)ssn_toJsonString;//UTF8code

//- (NSData *)ssn_toCleanJson;//转换成json序列，不会将类名code到json
//- (NSString *)ssn_toCleanJsonString;//UTF8code，不会将类名code到json

+ (instancetype)ssn_objectFromJsonData:(NSData *)jsonData;//从json序列取出当前类实例
+ (instancetype)ssn_objectFromJsonString:(NSString *)jsonString;//从json序列取出当前类实例

+ (instancetype)ssn_objectFromJsonData:(NSData *)jsonData targetClass:(Class)targetClass;//从json序列取出targetClass类实例
+ (instancetype)ssn_objectFromJsonString:(NSString *)jsonString targetClass:(Class)targetClass;//从json序列取出targetClass类实例

@end


#pragma mark 属性修饰符
/**
 * 用于忽略属性定义，若某对象不想被json序列，可以适用此修饰符修饰属性
 *
 *  例如：
 *  @property (strong, nonatomic) NSString <ssnjson_ignore> *propertyName;
 */
#define ssnjson_ignore __ssn_json_coder_ignore

/**
 *  jsonModel定义，若采用此宏定义后，此对象即可嵌套或者放入容器中（NSArray或者NSDictionary）
 *
 *  @ssnjson_interface(JsonModel) {
 *      NSString *_name;
 *  }
 *  @end
 */
#define ssnjson_interface(model) _ssnjson_interface_(model)
    #define _ssnjson_interface_(m) protocol __ssn_json_coder_corvert_to_##m <NSObject> \
            @end \
            @interface NSObject( _ssn_json_coder_compatibility_##m )< __ssn_json_coder_corvert_to_##m > \
            @end\
            @interface m

/**
 *  配合ssnjson_interface使用，model必须已经使用ssnjson_interface定义，则可嵌入使用
 *
 *  例如：
 *  @property (copy, nonatomic) NSArray <ssnjson_convert(JsonModel)> *propertyName;
 */
#define ssnjson_convert(model)  __ssn_json_coder_corvert_to_##model

/**
 *  coder支持的类型
 *  注意key不能为空，传入的值必须有意义，解码遇到类型不对可能出现异常
 */
@interface SSNJsonCoder (SSNExtendedJsonCoder)

#pragma mark encode extend
/**
 *  encode对象类型
 *  @param objv 被encode的对象，如果你能明确encode的值或者对象类型，请务必调用对应类型的encode接口，否则无法正确decode出数据
 *          注意：objv不要传入NSData，NSDate，String以及NSNumber或者NSValue对象基本类型，基本类型请使用下面对应的接口，如果随意使用，将无法正确解析
 *  @param key encode 值对应的key
 */
- (void)encodeObject:(id)objv forKey:(NSString *)key;

- (void)encodeData:(NSData *)data forKey:(NSString *)key;//base64[]转string存储
- (void)encodeDate:(NSDate *)date forKey:(NSString *)key;//采用utc code
- (void)encodeString:(NSString *)string forKey:(NSString *)key;

/**
 *  encode NSValue以及NSNumber复杂值类型
 *          若要encode自定义struct，可以采用NSValue包装，如[NSValue valueWithBytes:&struct objCType:"struct_name=ifB"]
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
 *  找到对应key的decode出class实例对象
 *  @param clazz 要解析出来的实例对象，因为json解析对象后一般不保留原对象类型，所以需要给定目标对象，可以传入nil
 *  @param key encode 值对应的key
 *  @return 返回对应encodeObject:forKey:进入的对象，
 *   注意，encode时传入基本类型将造成无法正常解析出对象
 */
- (id)decodeObjectClass:(Class)clazz forKey:(NSString *)key;
- (id)decodeObjectForKey:(NSString *)key;//尽量使用-decodeObjectClass:forKey:代替，明确返回类型

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
- (NSArray *)decodeArrayObjectClass:(Class)clazz;

- (void)encodeSet:(NSSet *)set;
- (NSSet *)decodeSetObjectClass:(Class)clazz;

- (void)encodeDictionary:(NSDictionary *)dic;
- (void)addEncodeValueInDictionary:(id)objv forKey:(NSString *)key;
- (NSDictionary *)decodeDictionaryValueClass:(Class)clazz;

- (void)encodeIndexSet:(NSIndexSet *)set;
- (NSIndexSet *)decodeIndexSet;

//转么解析容器元素
- (id)decodeObjectClass:(Class)clazz element:(Class)element forKey:(NSString *)key;

@end

//属性忽略coding
@protocol __ssn_json_coder_ignore<NSObject>
@end
@interface NSObject (_ssn_json_coder_compatibility_ignore)
@end

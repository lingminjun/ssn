//
//  FJSON.h
//  ssn
//
//  Created by lingminjun on 16/7/3.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FJSONConfig;


/**
 *  动态配置项
 *
 *  @param entityClass 实体类型
 *
 *  @return 返回需要过滤的属性。若针对某个类返回nil或者空NSArray，则认为没有配置此类的过滤数据
 */
typedef NSArray<NSString *> *(^FJSONFilter)(Class entityClass);


/**
 *  动态配置mapping
 *
 *  @param entityClass 实体类
 *
 *  @return 返回需要配置的mapping。若针对某个类返回nil或者空NSDictionary，则认为没有配置此类的mapping数据
 */
typedef NSDictionary<NSString *,NSString *> *(^FJSONMapping)(Class entityClass);

/**
 *  动态配置泛型类型支持
 *
 *  @param entityClass  实体类
 *  @param undefinedKey 其实体类未定义泛型类型的属性
 *
 *  @return 返回其泛型属性元素类型组。若针对某个类返回nil，则认为没有配置此类数据；若返回NSObject，说明配置成忽略此属性
 */
typedef Class (^FJSONGeneric)(Class entityClass, NSString *undefinedKey);

/**
 *  建议的JSON转换
 */
@interface FJSON : NSObject

/**
 *  将数据实体转换为json data，数据实体存在循环引用时将被忽略
 *
 *  @param entity 需要被序列换的实例
 *
 *  @return 返回json data (UTF8code)
 */
+ (NSData *)toJSONData:(NSObject *)entity;//

/**
 *  从json data中解析entity实例，若json为数组，则entity为元素类型
 *  注意：
 *  a、对于NSString与基本类型【int,long,short,float,double,boolean,char】之间将会自动转换
 *  b、对于其属性为容器类型时【NSArray|NSDictionary|NSSet】请使用Entity同名协议限定，但是切记不能与Lightweight Generics一起使用，否则无法被正确decode
 *  c、对于其属性为容器类型时【NSArray|NSDictionary|NSSet】若无法被识别类型，则会调用fjson_genericTypeForUndefinedKey询问
 *
 *  @param entityClass 需要生产的最终数据类型
 *  @param jsonData  json data (UTF8code)
 *
 *  @return 返回实例对象
 */
+ (id)entity:(Class)entityClass fromJSONData:(NSData *)jsonData;//从json序列取出当前类实例

/**
 *  从json data中解析entity实例
 *
 *  @param entity 需要被序列换的实例
 *  @param config 序列化配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置（小技巧，若想忽略原类协议FJSONEntity配置，可以设置非空项）
 *
 *  @return 返回json data (UTF8code)
 */
+ (NSData *)toJSONData:(NSObject *)entity config:(FJSONConfig *)config;

/**
 *  从json data中解析entity实例
 *
 *  @param entity  需要被序列换的实例
 *  @param filter  过滤器配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置（小技巧，若想忽略原类协议FJSONEntity配置，可以返回非空项）
 *  @param mapping 对应项配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置（小技巧，若想忽略原类协议FJSONEntity配置，可以返回非空项）
 *
 *  @return 返回json data (UTF8code)
 */
+ (NSData *)toJSONData:(NSObject *)entity filter:(FJSONFilter)filter mapping:(FJSONMapping)mapping;

/**
 *  从json data中解析entity实例，若json为数组，则entity为元素类型
 *
 *  @param entityClass 需要生产的最终数据类型
 *  @param jsonData  json data (UTF8code)
 *  @param config      序列化配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置（小技巧，若想忽略原类协议FJSONEntity配置，可以设置非空项）
 *
 *  @return 返回实例对象
 */
+ (id)entity:(Class)entityClass fromJSONData:(NSData *)jsonData config:(FJSONConfig *)config;

/**
 *  从json data中解析entity实例，若json为数组，则entity为元素类型
 *
 *  @param entityClass 需要生产的最终数据类型
 *  @param jsonData  son string (UTF8code)
 *  @param filter      过滤器配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置（小技巧，若想忽略原类协议FJSONEntity配置，可以返回非空项）
 *  @param mapping     对应项配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置（小技巧，若想忽略原类协议FJSONEntity配置，可以返回非空项）
 *  @param generic     泛型配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置
 *
 *  @return 返回实例对象
 */
+ (id)entity:(Class)entityClass fromJSONData:(NSData *)jsonData filter:(FJSONFilter)filter mapping:(FJSONMapping)mapping generic:(FJSONGeneric)generic;

/**
 *  对已有对象填充，不支持从JSONArray中填充数据
 */
+ (void)fillEntity:(id)entity fromJSONData:(NSData *)jsonData;
+ (void)fillEntity:(id)entity fromJSONData:(NSData *)jsonData config:(FJSONConfig *)config;
+ (void)fillEntity:(id)entity fromJSONData:(NSData *)jsonData filter:(FJSONFilter)filter mapping:(FJSONMapping)mapping generic:(FJSONGeneric)generic;
@end

/**
 *  配置器，主要是针对Entity类型配置Filter 和 Mapping
 */
@interface FJSONConfig : NSObject

+ (instancetype)config;//工厂方法

/**
 *  过滤器，主要针对entity对象的属性名字来过滤
 */
- (NSSet<NSString *> *)filterForEntityClass:(Class)entityClass;//获取过滤项
- (void)removeFilterForEntityClass:(Class)entityClass;//移除过滤项
- (void)addFilter:(NSArray<NSString *> *)filters forEntityClass:(Class)entityClass;//添加过滤项

/**
 *  mapping key是entity的property name，value则是可以被解析的json key，可以支持一对多，也可以多对一
 *  例：key:@"uid"  value:@"uid,userId"             //一对多，当decode时若多key存在，仅仅对json中存在的key处理
 *     key:@"account,mobile,mail" value:@"account" //多对一，当encode时多个key存在，请尽量使其值都一样，否则错乱
 *
 */
- (NSDictionary<NSString *,NSSet<NSString *> *> *)mappingForEntityClass:(Class)entityClass;//获取属性对应
- (void)removeMappingForEntityClass:(Class)entityClass;//移除属性对应
- (void)addMapping:(NSDictionary<NSString *,NSString *> *)mapping forEntityClass:(Class)entityClass;//添加属性对应

/**
 *  主要用于decode过程，定义泛型元素类型，若某个类其属性为泛型容器[NSArray,NSSet,NSDictionary]，则需要采用配置方式识别元素类型
 *  对于NSArray,NSSet，其类型将为元素类型，若元素类型不一致，将不能正确解析
 *  对于NSDictionary，其类型为值元素类型，键类型仅仅支持String
 */
- (NSDictionary<NSString *,Class> *)genericForEntityClass:(Class)entityClass;//获取泛型元素类型
- (void)removeGenericForEntityClass:(Class)entityClass;//移除泛型元素类型定义
- (void)addGeneric:(NSDictionary<NSString *,Class> *)generic forEntityClass:(Class)entityClass;//添加泛型元素类型定义

/**
 *  脚本方式支持
 *  实例：
 *  config[[Entity class]] = @[@"des",@"logDes"];//设置filter
 *  config[[Entity class]] = @{@"uid":@"uid,userId"};//设置mapping
 *  config[[Entity class]] = @{@"mobiles":[Entity class]};//设置generic
 *
 *  @param obj 根据类型去判断，是设置filter,mapping,generic
 *  @param entityClass entity类型
 */
- (void)setObject:(id)obj forKeyedSubscript:(Class)entityClass;

@end


/**
 *  实体协议，可配置Filter、Mapping
 */
@protocol FJSONEntity <NSObject>

@optional
/**
 *  返回当前类的过滤项
 *
 *  @return 当前类的过滤项。若返回nil或者空NSArray，则认为没有配置此类的过滤数据
 */
- (NSArray<NSString *> *)fjson_filter;

/**
 *  返回当前类的属性对应关系
 *  注意，对应为
 *
 *  @return 返回对应关系。若返回nil或者空NSDictionary，则认为没有配置此类的mapping数据
 */
- (NSDictionary<NSString *,NSString *> *)fjson_mapping;

/**
 *  未指定元素泛型类型时回调，返回值说明：
 *  对于NSArray 返回元素 如[Entity class]
 *  对于NSDictionary 返回值元素，如[Entity class]，对于字典类型，json仅仅支持NSString，故你可以仅仅返回value的类型
 *  对于自定义泛型，则根据定义泛型类型个数而定（暂时未支持）
 *
 *  @param key 属性名称
 *
 *  @return 返回泛型元素类型，这里指的泛型暂时限定为苹果提供的现有集中【NSArray,NSDictionary,NSSet】
 *          若针返回nil，则认为没有配置此类数据；若返回NSObject，说明配置成忽略此属性
 */
- (Class)fjson_genericTypeForUndefinedKey:(NSString *)key;

/**
 *  json kvc 实现，可以实现他此去支持的更多类型，如结构体,数字,指针,Data,等一些类型，将其转换成可以支持的类型[String,int,long,short,float,double,boolean,char]
 *
 *  @param key 属性名
 *
 *  @return 返回nil表示不作转化
 */
- (id)fjson_valueForKey:(NSString *)key;

/**
 *  json kvc 实现，可以实现他此去支持的更多类型，如结构体,数字,指针,Data,等一些类型，将其转换成可以支持的类型[String,int,long,short,float,double,boolean,char]
 *
 *  @param value 从json中取出的数据
 *  @param key   属性名
 *
 *  @return 返回YES表示已经处理，返回NO，表示没有处理
 */
- (BOOL)fjson_setValue:(id)value forKey:(NSString *)key;

@end





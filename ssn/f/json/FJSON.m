//
//  FJSON.m
//  ssn
//
//  Created by lingminjun on 16/7/3.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import "FJSON.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

NSString *const FJSON_NULL                    = @"NULL";

//需要忽略的属性
const char * FJSON_IGNORE_description_KEY      = "description";
const char * FJSON_IGNORE_debugDescription_KEY = "debugDescription";
const char * FJSON_IGNORE_hash_KEY             = "hash";
const char * FJSON_IGNORE_superclass_KEY       = "superclass";

/**
 *  存储属性
 */
@interface FJSONClassProperty : NSObject
@property (nonatomic,copy) NSString *name;  //类型名字
@property (nonatomic,copy) NSString *key;   //对应的值名称
@property (nonatomic) char typePrefix;      //类型编码
@property (nonatomic) BOOL readonly;        //只读（解析时并不忽略，只是标记，只读类型先处理）
@property (nonatomic) BOOL ignore;          //忽略
@property (nonatomic) BOOL isContainer;     //是容器
@property (nonatomic,strong) Class clazz;   //属性类型（若值类型）
@property (nonatomic,strong) Class subclazz;//容器类型中的元素类型
@property (nonatomic,strong) NSMutableArray<Class> *gencclzs;//泛型类型
@end

@implementation FJSONClassProperty

- (NSUInteger)hash {
    return [self.name hash];
}

- (BOOL)isEqual:(FJSONClassProperty *)other {
    if ([other isKindOfClass:[NSNull class]]) {
        return NO;
    }
    return [self.name isEqualToString:other.name];
}

@end

//是否为当前类
BOOL fjson_is_kind_of(Class acls, Class other)
{
    Class cls = acls;
    while (cls != Nil)
    {
        if (cls == other)
        {
            return YES;
        }
        cls = class_getSuperclass(cls);
    }
    return NO;
}

//是否为当前类
BOOL fjson_respond_mutable_copy(Class acls)
{
    if (acls == [NSArray class]
        || acls == [NSDictionary class]
        || acls == [NSSet class]
        || acls == [NSIndexSet class]
//        || acls == [NSString class]//没有必要
        ) {
        return YES;
    }
    return NO;
}


FJSONClassProperty *fjson_create_property(const char *property_name, const char *property_attrs) {
    
    Class ns_array_clazz = [NSArray class];
    Class ns_dictionary_clazz = [NSDictionary class];
    Class ns_set_clazz = [NSSet class];
    Class ns_index_set_clazz = [NSIndexSet class];
    
    FJSONClassProperty *classProperty = [[FJSONClassProperty alloc] init];
    classProperty.name = [NSString stringWithUTF8String:property_name];
    NSString* propertyAttributes =  [NSString stringWithUTF8String:property_attrs];
    
    //是否忽略字段
    //                    if ([propertyAttributes rangeOfString:FJSON_CODER_IGNORE_PROTOCOL].length > 0) {
    //                        continue ;
    //                    }
    
    NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];
    
    //取key
    NSString *value = [attributeItems lastObject];
    if (value && [value hasPrefix:@"V"]) {
        classProperty.key = [value substringFromIndex:1];
    }
    else {
        classProperty.key = classProperty.name;
    }
    
    if ([attributeItems containsObject:@"R"]) {//read-only properties
        //                        continue; //to next property
        classProperty.readonly = YES;
    }
    
    classProperty.typePrefix = property_attrs[1];
    
    if (property_attrs[1] == '@') {//若是对象类型，需要获取类型
        //T@,&,VidRetain
        //T@"NSObject",R,&,N,Vobj01
        //T@"NSString<SDXIgnore>",&,N,V_name
        //T@"NSMutableArray<SDXConvert>",C,N,V_list
        //T@"SDObject<SDXIgnore>",&,N,V_obj
        //T@"SDObject<SDXIgnore><SDXConvert>",&,N,V_obj
        NSString *typeAttribute = attributeItems[0];
        NSUInteger typeLength = [typeAttribute length];
        
        if (typeLength > 4) {//说明有类型
            
            typeAttribute = [typeAttribute substringWithRange:NSMakeRange(3, typeLength - 4)];
            NSArray *comps = [typeAttribute componentsSeparatedByString:@"<"];
            classProperty.clazz = NSClassFromString(comps[0]);
            if (fjson_is_kind_of(classProperty.clazz, ns_array_clazz)
                || fjson_is_kind_of(classProperty.clazz, ns_dictionary_clazz)
                || fjson_is_kind_of(classProperty.clazz, ns_set_clazz)) {
                classProperty.isContainer = YES;
                
                //取容器属性
                NSInteger count = [comps count];
                for (NSInteger idx = 1; idx < count; idx++) {
                    NSString *protocol = comps[idx];
                    protocol = [protocol substringToIndex:[protocol length] - 1];
                    
                    Class clz = NSClassFromString(protocol);
                    if (clz == nil) {
                        continue;
                    }
                    
                    if (classProperty.subclazz == nil) {
                        classProperty.subclazz = clz;
                    }
                    
                    if (classProperty.gencclzs == nil) {
                        classProperty.gencclzs = [NSMutableArray array];
                    }
                    [classProperty.gencclzs addObject:clz];
                }
            }
            else if (fjson_is_kind_of(classProperty.clazz, ns_index_set_clazz)) {
                classProperty.isContainer = YES;
            }
        }
    }
    
    return classProperty;
}

//是否为需要忽略的属性名
BOOL fjson_is_ignore_property(const char *c_property_name)
{
    if (strcmp(FJSON_IGNORE_description_KEY, c_property_name) == 0) {
        return YES;
    }
    
    if (strcmp(FJSON_IGNORE_debugDescription_KEY, c_property_name) == 0) {
        return YES;
    }
    
    if (strcmp(FJSON_IGNORE_hash_KEY, c_property_name) == 0) {
        return YES;
    }
    
    if (strcmp(FJSON_IGNORE_superclass_KEY, c_property_name) == 0) {
        return YES;
    }
    
    return NO;
}

//是否为需要忽略的属性类型
BOOL fjson_is_ignore_property_type(const char type)
{
//    switch (type) {
//        case '^'://对象或者函数指针暂时不做支持
//            return YES;
//        case '{'://struct 暂时不做支持
//            return YES;
//        case '('://Union 暂时不做支持
//            return YES;
//        default:
//            break;
//    }
    return NO;
}


//缓存每一个class的属性列表
NSCache<NSString *, NSDictionary<NSString *, FJSONClassProperty *> *> *fjson_class_property_cache() {
    static NSCache *_share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share = [[NSCache alloc] init];
    });
    return _share;
}

//是否已经到了基类
BOOL fjson_is_base_class(Class clazz) {
    if (clazz == [NSObject class] || clazz == [NSProxy class]) {
        return YES;
    }
    
    return NO;
}

//递归的方法查找
NSDictionary<NSString *, FJSONClassProperty *> *fjson_collect_class_properties(Class clazz) { @autoreleasepool {
    
    //已经是基类了，不需要关心了
    if (fjson_is_base_class(clazz)) {
        return [NSDictionary dictionary];
    }
    
    //缓存类属性列表，防止每次都需要遍历类
    NSCache<NSString *, NSDictionary<NSString *, FJSONClassProperty *> *> *cache = fjson_class_property_cache();
    
    //找到，则继续
    NSDictionary<NSString *, FJSONClassProperty *> *properties = [cache objectForKey:NSStringFromClass(clazz)];
    if (properties != nil) {
        return properties;
    }
    
    //未找到，则向上寻找基类
    NSDictionary<NSString *, FJSONClassProperty *> *super_ppt = fjson_collect_class_properties(class_getSuperclass(clazz));
    
    //构建结果集
    NSMutableDictionary<NSString *, FJSONClassProperty *> *result = [NSMutableDictionary dictionaryWithDictionary:super_ppt];
    
    //获取当前类属性
    unsigned int outCount;
    objc_property_t *c_properties = class_copyPropertyList(clazz, &outCount);
    
    //遍历当前类属性
    for (unsigned int i = 0; i < outCount; i++) { @autoreleasepool {
        objc_property_t property = c_properties[i];
        
        const char *c_property_name = property_getName(property);
        if (c_property_name && strlen(c_property_name) == 0) {
            continue ;
        }
        
        //需要忽略的属性
        if (fjson_is_ignore_property(c_property_name)) {
            continue ;
        }
        
        //get property attributes
        /* 请参考官网地址
         https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
         */
        const char *attrs = property_getAttributes(property);
        //                    printf("\nobj_Attributes:%s",attrs);
        const long length = strlen(attrs);
        if (length <= 1) {
            continue ;
        }
        
        //查看不支持的类型
        if (fjson_is_ignore_property_type(attrs[1])) {
            continue;
        }
        
        //构建property
        FJSONClassProperty *classProperty = fjson_create_property(c_property_name,attrs);
        
        //记录下来，若基类存在，也直接替换，说明同名属性被派生类覆盖
        if (classProperty.name) {
            [result setObject:classProperty forKey:classProperty.name];//加入到结果集
        }
    }}
    
    if (c_properties) {
        free(c_properties);
    }

    //将数据备份起来，防止下次还需要重新遍历
    [cache setObject:result forKey:NSStringFromClass(clazz)];
    
    return result;
}}

NSDictionary<NSString *, FJSONClassProperty *> *fjson_get_class_property_name(Class clazz) {
    
    //类型校验
    NSString *className = NSStringFromClass(clazz);
    if ([className length] <= 0) {
        return [NSDictionary dictionary];
    }
    
    //查找遍历所有类的属性，若派生类覆盖基类属性，则采用基类属性
    return fjson_collect_class_properties(clazz);
}

//具体序列化方法
@interface FJsonCoder : NSObject
{
    id _jsonObj;
    BOOL _isArray;
    //BOOL _beginEncoding;//准备encoding，一旦准备coding，json是array容器或者自定容器确定后不能再改变
}

@property (nonatomic,strong) Class targetClass;
@property (nonatomic,strong) NSDictionary *ppts;

@property (nonatomic,strong) FJSONConfig *config;//配置项
@property (nonatomic,strong) NSIndexSet *uniq;//encode时去重

- (BOOL)isArray;

- (id)rootJsonObj;//获取根对象

- (NSMutableArray *)rootArray;
- (NSMutableDictionary *)rootDictionary;

- (NSData *)encodeData;//当前被encode的数据
- (void)setEncodeData:(NSData *)jsonData;//重置解析数据

//- (NSString *)encodeString;
//- (void)setEncodeString:(NSString *)string;

+ (FJsonCoder *)coderWithTargetClass:(Class)clazz;
+ (FJsonCoder *)coderWithRootObject:(id)objv;

- (BOOL)encodeObject:(NSObject *)object;//encode入口
- (id)decodeObject:(Class)element;//decode入口

/**
 *  encode对象类型
 *  @param objv 被encode的对象，如果你能明确encode的值或者对象类型，请务必调用对应类型的encode接口，否则无法正确decode出数据
 *          注意：objv不要传入NSData，NSDate，String以及NSNumber或者NSValue对象基本类型，基本类型请使用下面对应的接口，如果随意使用，将无法正确解析
 *  @param key encode 值对应的key
 */
- (void)encodeObject:(id)objv forKeys:(NSSet<NSString *> *)keys;

- (void)encodeData:(NSData *)data forKeys:(NSSet<NSString *> *)keys;//base64[]转string存储
- (void)encodeDate:(NSDate *)date forKeys:(NSSet<NSString *> *)keys;//采用utc code
- (void)encodeString:(NSString *)string forKeys:(NSSet<NSString *> *)keys;

/**
 *  encode NSValue以及NSNumber复杂值类型
 *          若要encode自定义struct，可以采用NSValue包装，如[NSValue valueWithBytes:&struct objCType:"struct_name=ifB"]
 *  @param value 本转入的NSValue或者NSNumber类型
 *  @param key encode 值对应的key
 */
- (void)encodeValue:(NSValue *)value forKeys:(NSSet<NSString *> *)keys;

- (void)encodeBool:(BOOL)boolv forKeys:(NSSet<NSString *> *)keys;
- (void)encodeInt:(int)intv forKeys:(NSSet<NSString *> *)keys;
- (void)encodeInt32:(int32_t)intv forKeys:(NSSet<NSString *> *)keys;
- (void)encodeInt64:(int64_t)intv forKeys:(NSSet<NSString *> *)keys;
- (void)encodeFloat:(float)realv forKeys:(NSSet<NSString *> *)keys;
- (void)encodeDouble:(double)realv forKeys:(NSSet<NSString *> *)keys;


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

//专门解析容器元素
- (id)decodeObjectClass:(Class)clazz element:(Class)element forKey:(NSString *)key;
@end

//配置解析行为类
@interface FJSONConfig ()
@property (nonatomic,strong) NSMutableDictionary<NSString *,NSSet<NSString *> *> *filter;
@property (nonatomic,strong) NSMutableDictionary<NSString *,NSDictionary<NSString *,NSSet<NSString *> *> *> *mapping;
@property (nonatomic,strong) NSMutableDictionary<NSString *,NSDictionary<NSString *,Class> *> *generic;

@property (nonatomic,copy) FJSONFilter bfilter;
@property (nonatomic,copy) FJSONMapping bmapping;
@property (nonatomic,copy) FJSONGeneric bgeneric;

+ (BOOL)isValidProperty:(FJSONClassProperty *)key targetObject:(NSObject *)obj atConfig:(FJSONConfig *)config;//是否为有效的属性
+ (NSSet<NSString *> *)jsonKeysFromProperty:(FJSONClassProperty *)key targetObject:(NSObject *)obj atConfig:(FJSONConfig *)config;//获取json key
+ (Class)genericClassForProperty:(FJSONClassProperty *)key targetObject:(NSObject *)obj atConfig:(FJSONConfig *)config;//获取泛型属性类型

@end

//对外提供接口实现类
@implementation FJSON

/**
 *  将数据实体转换为json data
 *
 *  @param entity 需要被序列换的实例
 *
 *  @return 返回json data (UTF8code)
 */
+ (NSData *)toJSONData:(NSObject *)entity {
    FJsonCoder *coder = [FJsonCoder coderWithTargetClass:[entity class]];
    [coder encodeObject:entity];
    return [coder encodeData];
}


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
+ (id)entity:(Class)entityClass fromJSONData:(NSData *)jsonData {
    FJsonCoder *coder = [FJsonCoder coderWithTargetClass:entityClass];
    [coder setEncodeData:jsonData];
    
    if (coder.isArray) {
        return [coder decodeArrayObjectClass:entityClass];
    } else {
        return [coder decodeObject:nil];
    }
}

/**
 *  从json data中解析entity实例
 *
 *  @param entity 需要被序列换的实例
 *  @param config 序列化配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置
 *
 *  @return 返回json data (UTF8code)
 */
+ (NSData *)toJSONData:(NSObject *)entity config:(FJSONConfig *)config {
    FJsonCoder *coder = [FJsonCoder coderWithTargetClass:[entity class]];
    if (config != nil) {
        coder.config = config;
    }
    [coder encodeObject:entity];
    return [coder encodeData];
}

/**
 *  从json data中解析entity实例
 *
 *  @param entity  需要被序列换的实例
 *  @param filter  过滤器配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置
 *  @param mapping 对应项配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置
 *
 *  @return 返回json data (UTF8code)
 */
+ (NSData *)toJSONData:(NSObject *)entity filter:(FJSONFilter)filter mapping:(FJSONMapping)mapping {
    FJsonCoder *coder = [FJsonCoder coderWithTargetClass:[entity class]];
    if (filter != nil || mapping != nil) {
        coder.config.bfilter = filter;
        coder.config.bmapping = mapping;
    }
    [coder encodeObject:entity];
    return [coder encodeData];
}

/**
 *  从json data中解析entity实例，若json为数组，则entity为元素类型
 *
 *  @param entityClass 需要生产的最终数据类型
 *  @param jsonData  json data (UTF8code)
 *  @param config      序列化配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置
 *
 *  @return 返回实例对象
 */
+ (id)entity:(Class)entityClass fromJSONData:(NSData *)jsonData config:(FJSONConfig *)config {
    FJsonCoder *coder = [FJsonCoder coderWithTargetClass:entityClass];
    
    if (config != nil) {
        coder.config = config;
    }
    
    [coder setEncodeData:jsonData];
    
    if (coder.isArray) {
        return [coder decodeArrayObjectClass:entityClass];
    } else {
        return [coder decodeObject:nil];
    }
}

/**
 *  从json data中解析entity实例，若json为数组，则entity为元素类型
 *
 *  @param entityClass 需要生产的最终数据类型
 *  @param jsonData  son string (UTF8code)
 *  @param filter      过滤器配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置
 *  @param mapping     对应项配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置
 *  @param generic     泛型配置，若其中配置了某个entity其满足FJSONEntity相关特性，优先采用参数中配置
 *
 *  @return 返回实例对象
 */
+ (id)entity:(Class)entityClass fromJSONData:(NSData *)jsonData filter:(FJSONFilter)filter mapping:(FJSONMapping)mapping generic:(FJSONGeneric)generic {
    FJsonCoder *coder = [FJsonCoder coderWithTargetClass:entityClass];
    
    if (filter != nil || mapping != nil || generic != nil) {
        coder.config.bfilter = filter;
        coder.config.bmapping = mapping;
        coder.config.bgeneric = generic;
    }
    
    [coder setEncodeData:jsonData];
    
    if (coder.isArray) {
        return [coder decodeArrayObjectClass:entityClass];
    } else {
        return [coder decodeObject:nil];
    }
}

@end

@implementation FJsonCoder
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isArray = NO;
    }
    return self;
}

- (BOOL)isArray {
    return _isArray;
}

- (id)rootJsonObj
{
    return _jsonObj;
}

- (NSMutableArray *)rootArray {
    if (_jsonObj) {
        if (!_isArray) {
            @throw [NSException exceptionWithName:@"SSNJson" reason:@"json coder 不支持 同时code两种容器" userInfo:nil];
        }
        return (NSMutableArray *)_jsonObj;
    }
    else {
        //if (_beginEncoding) {
        _isArray = YES;
        _jsonObj = [[NSMutableArray alloc] init];
        //}
        return (NSMutableArray *)_jsonObj;
    }
}
- (NSMutableDictionary *)rootDictionary {
    if (_jsonObj) {
        if (_isArray) {
            @throw [NSException exceptionWithName:@"SSNJson" reason:@"json coder 不支持 同时code两种容器" userInfo:nil];
        }
        return (NSMutableDictionary *)_jsonObj;
    }
    else {
        //if (_beginEncoding && !_isArray) {
        _jsonObj = [[NSMutableDictionary alloc] init];
        //}
        return (NSMutableDictionary *)_jsonObj;
    }
}

- (NSData *)encodeData {
    if (!_jsonObj) {
        return nil;
    }
    
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:_jsonObj options:NSJSONWritingPrettyPrinted error:&error];
}

//- (NSString *)encodeString {
//    NSData *data = [self encodeData];
//    if ([data length] <= 0) {
//        return nil;
//    }
//    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//}

- (void)setEncodeData:(NSData *)jsonData {
    if ([jsonData length] <= 0) {
        return ;
    }
    
    NSError *error = nil;
    _jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if ([_jsonObj isKindOfClass:[NSArray class]]) {
        _isArray = YES;
    }
}

//- (void)setEncodeString:(NSString *)string {
//    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//    [self setEncodeData:data];
//}

- (Class)targetClass {
    if (_targetClass) {
        return _targetClass;
    }
    
    if (_isArray) {
        _targetClass = [NSMutableArray class];
        return _targetClass;
    }
    
    _targetClass = [NSMutableDictionary class];
    return _targetClass;
}

- (NSDictionary *)ppts
{
    if (_ppts) {
        return _ppts;
    }
    
    Class clazz = [self targetClass];
    if (!clazz) {
        return nil;
    }
    
    _ppts = fjson_get_class_property_name(clazz);
    return _ppts;
}

- (FJSONConfig *)config {
    if (_config == nil) {
        _config = [[FJSONConfig alloc] init];
    }
    return _config;
}

- (NSIndexSet *)uniq
{
    if (_uniq == nil) {
        _uniq = [[NSIndexSet alloc] init];
    }
    
    return _uniq;
}

+ (FJsonCoder *)coderWithTargetClass:(Class)clazz
{
    FJsonCoder *coder = [[[self class] alloc] init];
    coder.targetClass = clazz;
    return coder;
}

+ (FJsonCoder *)coderWithRootObject:(id)objv
{
    //是字典类型，需要对值对象化
    if ([objv isKindOfClass:[NSDictionary class]])//是对象
    {
        FJsonCoder *coder = [FJsonCoder coderWithTargetClass:nil];
        [[coder rootDictionary] setDictionary:objv];
        return coder;
    }
    
    //是数组类型，需要对值对象化
    if ([objv isKindOfClass:[NSArray class]])
    {
        FJsonCoder *coder = [FJsonCoder coderWithTargetClass:nil];
        [[coder rootArray] setArray:(NSArray *)objv];
        return coder;
    }
    
    return nil;
}

- (FJsonCoder *)subCoderWithObject:(id)objv targetClass:(Class)clazz {
    FJsonCoder *coder = nil;
    if (clazz != nil) {
        coder = [FJsonCoder coderWithTargetClass:clazz];
    } else if (objv != nil) {
        coder = [FJsonCoder coderWithRootObject:objv];
    }
    
    //将一些检查项保留下来
    if (coder != nil) {
        coder.uniq = self.uniq;
        coder.config = self.config;
    }
    
    return coder;
}

#define fjson_safe_kvc_get(obj,value,key) \
@try {value = [(obj) valueForKey:(key)];} @catch (NSException *exception) {NSLog(@"%@",exception);} @finally {}
#define fjson_safe_kvc_set(obj,value,key) \
@try {[(obj) setValue:(value) forKey:(key)];} @catch (NSException *exception) {NSLog(@"%@",exception);} @finally {}

//encode 入口
#define fjson_not_support_encode_class(obj,clazz) if ([(obj) isKindOfClass:[clazz class]]) {return NO;}
#define fjson_not_support_decode_class(obj,clazz) if ([(obj) isKindOfClass:[clazz class]]) {return (obj);}
- (BOOL)encodeObject:(NSObject *)object {
    if ([object class] == [NSObject class]) {
        return NO;
    }
    fjson_not_support_encode_class(object,FJsonCoder)
    fjson_not_support_encode_class(object,NSString)
    fjson_not_support_encode_class(object,NSData)
    fjson_not_support_encode_class(object,NSValue)
    fjson_not_support_encode_class(object,NSCharacterSet)
    fjson_not_support_encode_class(object,NSDate)//时间支持也没有意义
    
    if ([object isKindOfClass:[NSArray class]]) {
        [self encodeArray:(NSArray *)object];
    }
    else if ([object isKindOfClass:[NSDictionary class]]) {
        [self encodeDictionary:(NSDictionary *)object];
    }
    else if ([object isKindOfClass:[NSSet class]]) {
        [self encodeSet:(NSSet *)object];
    }
    else if ([object isKindOfClass:[NSIndexSet class]]) {
        [self encodeIndexSet:(NSIndexSet *)object];
    }
    else //对于其他对象，我们只code其属性
    {
        NSArray *allKeys = [self.ppts allKeys];
        for (NSString *key in allKeys) {
            FJSONClassProperty *ppt = [self.ppts objectForKey:key];
            
            //过滤不需要的key
            if (![FJSONConfig isValidProperty:ppt targetObject:object atConfig:self.config]) {
                continue;
            }
            
            id value = nil;
            if ([object respondsToSelector:@selector(fjson_valueForKey:)]) {
                value = [(id<FJSONEntity>)object fjson_valueForKey:key];
            }
            if (value == nil) {//表示需要取
                fjson_safe_kvc_get(object,value,key);
//                value = [object valueForKey:key];
            }
            
            //防止死循环，查看是否已经循环，暂时还没找到好的做法来判断，树状结构不能被过滤
//            if ([self.uniq containsIndex:(NSUInteger)((__bridge void *)value)]) {
//                continue;
//            }
            
            //使用mapping
            if (value) {
                NSSet<NSString *> *keys = [FJSONConfig jsonKeysFromProperty:ppt targetObject:object atConfig:self.config];
                [self encodeObject:value forKeys:keys];
            }
        }
    }
    return YES;
}

//decode出口
- (id)decodeObject:(Class)element {

    Class clazz = [self targetClass];
    if (clazz == nil) {
        return nil;
    }
    
    id object = [[clazz alloc] init];//生产实例
    
    if (object) {
        if ([object class] == [NSObject class]) {
            return object;
        }
        fjson_not_support_decode_class(object,FJsonCoder)
        fjson_not_support_decode_class(object,NSString)
        fjson_not_support_decode_class(object,NSData)
        fjson_not_support_decode_class(object,NSValue)
        fjson_not_support_decode_class(object,NSCharacterSet)
        fjson_not_support_decode_class(object,NSDate)//时间支持也没有意义
        
        if ([object isKindOfClass:[NSArray class]]) {//不可变没有意义
            NSArray *ary = [self decodeArrayObjectClass:element];
            if ([object isKindOfClass:[NSMutableArray class]]) {
                if (ary) {
                    [(NSMutableArray *)object setArray:ary];
                }
            }
            else {
                return ary;
            }
        }
        else if ([object isKindOfClass:[NSDictionary class]]) {//不可变没有意义
            NSDictionary *dic = [self decodeDictionaryValueClass:element];
            if ([object isKindOfClass:[NSMutableDictionary class]]) {
                //此处用到code内部方法
                
                if (dic) {
                    [(NSMutableDictionary *)object setDictionary:dic];
                }
            }
            else {
                return dic;
            }
        }
        else if ([object isKindOfClass:[NSSet class]]) {
            NSSet *set = [self decodeSetObjectClass:element];
            if ([object isKindOfClass:[NSMutableSet class]]) {
                if (set) {
                    [(NSMutableSet *)object setSet:set];
                }
            }
            else {
                return set;
            }
        }
        else if ([object isKindOfClass:[NSIndexSet class]]) {
            NSIndexSet *set = [self decodeIndexSet];
            if ([object isKindOfClass:[NSMutableIndexSet class]]) {
                if (set) {
                    [(NSMutableIndexSet *)object addIndexes:set];
                }
            }
            else {
                return set;
            }
        }
        else //对于其他对象，我们只code其属性
        {
            BOOL resp_json_kvc = [object respondsToSelector:@selector(fjson_setValue:forKey:)];
            
            NSArray *allKeys = [self.ppts allKeys];
            for (NSString *org_key in allKeys) {
                //熟悉取出来
                FJSONClassProperty *classProperty = [self.ppts objectForKey:org_key];
                
                //过滤不需要的key
                if (![FJSONConfig isValidProperty:classProperty targetObject:object atConfig:self.config]) {
                    continue;
                }
                
                //找到映射的key
                NSSet<NSString *> *keys = [FJSONConfig jsonKeysFromProperty:classProperty targetObject:object atConfig:self.config];
                for (NSString *key in keys) {
                    if (![[self rootDictionary] objectForKey:key]) {
                        continue;
                    }
                    
                    //具体解析
                    switch (classProperty.typePrefix)
                    {
                        case 'c'://	A char
                        case 'i'://	An int
                        case 's'://	A short
                        case 'l'://	A longl is treated as a 32-bit quantity on 64-bit programs.
                        case 'q'://	A long long
                        case 'C'://	An unsigned char
                        case 'I'://	An unsigned int
                        case 'S'://	An unsigned short
                        case 'L'://	An unsigned long
                        case 'Q'://	An unsigned long long
                        {// 以上数据类型直接将值encode
                            id value = [self decodeObjectClass:nil forKey:key];
                            BOOL set = NO;
                            if (resp_json_kvc && value != nil) {
                                set = [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                            }
                            if (!set) {
                                if ([value respondsToSelector:@selector(longLongValue)]) {
                                    fjson_safe_kvc_set(object,@([(NSNumber *)value longLongValue]),classProperty.key);
                                }
                            }
                        } break;
                        case 'B'://	A C++ bool or a C99 _Bool
                        {// 以上数据类型直接将值encode
                            id value = [self decodeObjectClass:nil forKey:key];
                            BOOL set = NO;
                            if (resp_json_kvc && value != nil) {
                                set = [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                            }
                            if (!set) {
                                if ([value respondsToSelector:@selector(boolValue)]) {
                                    fjson_safe_kvc_set(object,@([(NSNumber *)value boolValue]),classProperty.key);
                                }
                            }
                        } break;
                        case 'f'://	A float
                        case 'd'://	A double
                        {
                            id value = [self decodeObjectClass:nil forKey:key];
                            BOOL set = NO;
                            if (resp_json_kvc && value != nil) {
                                set = [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                            }
                            if (!set) {
                                if ([value respondsToSelector:@selector(doubleValue)]) {
                                    fjson_safe_kvc_set(object,@([(NSNumber *)value doubleValue]),classProperty.key);
                                } else if ([value respondsToSelector:@selector(longLongValue)]) {
                                    fjson_safe_kvc_set(object,@([(NSNumber *)value longLongValue]),classProperty.key);
                                }
                            }
                        } break;
                        case 'v'://	A void
                        {// 默认的不支持
                            id value = [self decodeObjectClass:nil forKey:key];
                            if (resp_json_kvc && value != nil) {
                                [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                            }
                        } break;
                        case '*'://	A character string (char *)
                        {// 转换成NSString encode
                            id value = [self decodeObjectClass:nil forKey:key];
                            BOOL set = NO;
                            if (resp_json_kvc && value != nil) {
                                set = [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                            }
                            
                            //默认的支持方式
                            if (!set) {
                                if ([value isKindOfClass:[NSString class]]) {
                                    NSString *string = [(NSString *)value uppercaseString];
                                    if (![[string uppercaseString] isEqualToString:FJSON_NULL]) {
                                        fjson_safe_kvc_set(object,value,classProperty.key);
                                        //                                    [object setValue:value forKey:classProperty.key];
                                    }
                                } else {
                                    if (value) {
                                        NSString *string = [NSString stringWithFormat:@"%@",value];
                                        fjson_safe_kvc_set(object,string,classProperty.key);
                                        //                                    [object setValue:string forKey:classProperty.key];
                                    }
                                }
                            }
                        } break;
                        case '@'://	An object (whether statically typed or typed id)
                        {// 将对象还原出来 再 encode
                            
                            if (fjson_is_kind_of(classProperty.clazz, [NSArray class])
                                || fjson_is_kind_of(classProperty.clazz, [NSSet class])
                                || fjson_is_kind_of(classProperty.clazz, [NSDictionary class])) {//1、对象容器支持
                                
                                //容器需要询问元素类型
                                Class generic = [FJSONConfig genericClassForProperty:classProperty targetObject:object atConfig:self.config];
                                if (generic != nil) {
                                    id value = [self decodeObjectClass:classProperty.clazz element:generic forKey:key];
                                    BOOL set = NO;
                                    if (resp_json_kvc && value != nil) {
                                        set = [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                                    }
                                    if (!set) {
                                        fjson_safe_kvc_set(object,value,classProperty.key);
//                                        [object setValue:value forKey:classProperty.key];
                                    }
                                }
                            } else if (fjson_is_kind_of(classProperty.clazz, [NSIndexSet class])){//2、值容器支持
                                id value = [self decodeObjectClass:classProperty.clazz forKey:key];
                                BOOL set = NO;
                                if (resp_json_kvc && value != nil) {
                                    set = [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                                }
                                if (!set) {
                                    fjson_safe_kvc_set(object,value,classProperty.key);
//                                    [object setValue:value forKey:classProperty.key];
                                }
                            } else if (fjson_is_kind_of(classProperty.clazz, [NSString class])) {//字符容器支持
                                id value = [self decodeObjectClass:classProperty.clazz forKey:key];
                                BOOL set = NO;
                                if (resp_json_kvc && value != nil) {
                                    set = [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                                }
                                if (!set) {
                                    if ([value isKindOfClass:[NSString class]]) {
                                        if (![[(NSString *)value uppercaseString] isEqualToString:FJSON_NULL]) {
                                            fjson_safe_kvc_set(object,value,classProperty.key);
                                            //                                        [object setValue:value forKey:classProperty.key];
                                        }
                                    } else {
                                        if (value) {
                                            NSString *string = [NSString stringWithFormat:@"%@",value];
                                            fjson_safe_kvc_set(object,string,classProperty.key);
                                            //                                        [object setValue:string forKey:classProperty.key];
                                        }
                                    }
                                }
                            } else {//普通对象
                                id value = [self decodeObjectClass:classProperty.clazz forKey:key];
                                BOOL set = NO;
                                if (resp_json_kvc && value != nil) {
                                    set = [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                                }
                                if (!set) {
                                    fjson_safe_kvc_set(object,value,classProperty.key);
//                                    [object setValue:value forKey:classProperty.key];
                                }
                            }
                        } break;
                        case '#'://	A class object (Class)
                        case ':'://	A method selector (SEL) ,@encode(SEL) ':v@:@'
                        case '[': //[array type]	An array
                        case '{': //{name=type...}	A structure
                        case '(': //(name=type...)	A union
                        case 'b': //'bnum'	A bit field of num bits
                        case '^': //^type	A pointer to type
                        case '?': //	An unknown type (among other things, this code is used for function pointers)
                        default:
                        {// 以上数据取出
                            id value = [self decodeValueForKey:key];
                            BOOL set = NO;
                            if (resp_json_kvc && value != nil) {
                                set = [(id<FJSONEntity>)object fjson_setValue:value forKey:key];
                            }
                            if (!set) {
                                fjson_safe_kvc_set(object,value,classProperty.key);
//                                [object setValue:value forKey:classProperty.key];
                            }
                        } break;
                    }
                }
            }
        }
    }
    
    return object;
}



////////////////////////////////////////////////////////////////////////////////////////
//  具体序列化过程
////////////////////////////////////////////////////////////////////////////////////////
//object-c class类型
- (void)encodeObject:(id)objv forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0 && objv, @"FJsonCoder：请传入正确参数");
    if ([objv isKindOfClass:[NSData class]])
    {
        [self encodeData:(NSData *)objv forKeys:keys];
    }
    if ([objv isKindOfClass:[NSString class]])
    {
        [self encodeString:(NSString *)objv forKeys:keys];
    }
    if ([objv isKindOfClass:[NSDate class]])
    {
        [self encodeDate:(NSDate *)objv forKeys:keys];
    }
    else if ([objv isKindOfClass:[NSValue class]]) //对于数据类型，需要根据type分别处理
    {
        [self encodeValue:(NSValue *)objv forKeys:keys];
    }
    //    else if ([objv isKindOfClass:[NSArray class]]) {
    //        [self encodeArray:(NSArray *)objv];
    //    }
    //    else if ([objv isKindOfClass:[NSDictionary class]]) {
    //        [self encodeDictionary:(NSDictionary *)objv];
    //    }
    //    else if ([objv isKindOfClass:[NSSet class]]) {
    //        [self encodeSet:(NSSet *)objv];
    //    }
    //    else if ([objv isKindOfClass:[NSCharacterSet class]]) {
    //        [self encodeCharacterSet:(NSCharacterSet *)objv];
    //    }
    //    else if ([objv isKindOfClass:[NSIndexSet class]]) {
    //        [self encodeIndexSet:(NSIndexSet *)objv];
    //    }
    else //是普通对象则需要将对象递归encode
    {
        FJsonCoder *coder = [self subCoderWithObject:nil targetClass:[objv class]];
        [coder encodeObject:objv];
        id jsonObj = [coder rootJsonObj];
        if (jsonObj) {
            for (NSString *key in keys) {
                [[self rootDictionary] setValue:jsonObj forKey:key];
            }
        }
    }
}

- (void)encodeData:(NSData *)data forKeys:(NSSet<NSString *> *)keys {
    NSLog(@"FJSON暂时未对NSData类型做支持，没有支持的类型");
//    NSAssert([keys count] > 0 && [data length] > 0, @"FJsonCoder：请传入正确参数");
//    NSString *base64 = [data ssn_base64];
//    [[self rootDictionary] setValue:base64 forKey:key];
}

- (void)encodeDate:(NSDate *)date forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0 && date, @"FJsonCoder：请传入正确参数");
    long long utc = [date timeIntervalSince1970];
    [self encodeInt64:utc forKeys:keys];
}

- (void)encodeString:(NSString *)string forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0 && string != nil, @"FJsonCoder：请传入正确参数");
    for (NSString *key in keys) {
        [[self rootDictionary] setValue:string forKey:key];
    }
}

- (void)encodeValue:(NSValue *)value forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0 && value, @"FJsonCoder：请传入正确参数");
    const char *type = [value objCType];
    if (strlen(type) <= 0) {
        return ;
    }
    char typePrefix = type[0];
    switch (typePrefix)
    {
        case 'c'://	A char
        case 'i'://	An int
        case 's'://	A short
        case 'l'://	A longl is treated as a 32-bit quantity on 64-bit programs.
        case 'q'://	A long long
        case 'C'://	An unsigned char
        case 'I'://	An unsigned int
        case 'S'://	An unsigned short
        case 'L'://	An unsigned long
        case 'Q'://	An unsigned long long
        case 'f'://	A float
        case 'd'://	A double
        case 'B'://	A C++ bool or a C99 _Bool
        {// 以上数据类型直接将值encode
            for (NSString *key in keys) {
                [[self rootDictionary] setValue:value forKey:key];
            }
        } break;
        case 'v'://	A void
        {// void丢弃
        } break;
        case '*'://	A character string (char *)
        {// 转换成NSString encode
            NSString *stringValue = [(NSNumber *)value stringValue];
            [self encodeString:stringValue forKeys:keys];
        } break;
        case '@'://	An object (whether statically typed or typed id)
        {// 将对象还原出来 再 encode
            id nonretainedObjectValue = [value nonretainedObjectValue];
            //防止死循环，查看是否已经循环，暂时还没找到好的做法来判断，树状结构不能被过滤
            if (nonretainedObjectValue/* && ![self.uniq containsIndex:(NSUInteger)((__bridge void *)nonretainedObjectValue)]*/) {
                [self encodeObject:nonretainedObjectValue forKeys:keys];
            }
        } break;
        case '#'://	A class object (Class)
        case ':'://	A method selector (SEL) ,@encode(SEL) ':v@:@'
        case '[': //[array type]	An array
        case '{': //{name=type...}	A structure
        case '(': //(name=type...)	A union
        case 'b': //'bnum'	A bit field of num bits
        case '^': //^type	A pointer to type
        case '?': //	An unknown type (among other things, this code is used for function pointers)
        default:
        {// 以上数据取出，暂时可以不做支持
            NSUInteger size = 0;
            NSGetSizeAndAlignment(value.objCType, &size, 0);
            if (size) {
                
                int type_length = (int)strlen(value.objCType);
                unsigned char *bytes = (unsigned char *)malloc((size + type_length + 1) * sizeof(unsigned char));
                unsigned char *pbytes = bytes;
                pbytes[0] = (unsigned char)strlen(value.objCType);//将类型长度存入第一位，以为足够存储类型长度
                pbytes += 1;
                strncpy((char *)pbytes, value.objCType, type_length);
                pbytes += type_length;
                
                [value getValue:pbytes];
                NSData *data = [NSData dataWithBytesNoCopy:bytes length:(size + type_length + 1)];//no copy
                [self encodeData:data forKeys:keys];
            }
        } break;
    }
}

- (void)encodeBool:(BOOL)boolv forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0 , @"FJsonCoder：请传入正确参数");
    for (NSString *key in keys) {
        [[self rootDictionary] setValue:@(boolv) forKey:key];
    }
}

- (void)encodeInt:(int)intv forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0, @"FJsonCoder：请传入正确参数");
    for (NSString *key in keys) {
        [[self rootDictionary] setValue:@(intv) forKey:key];
    }
}

- (void)encodeInt32:(int32_t)intv forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0 , @"FJsonCoder：请传入正确参数");
    for (NSString *key in keys) {
        [[self rootDictionary] setValue:@(intv) forKey:key];
    }
}

- (void)encodeInt64:(int64_t)intv forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0 , @"FJsonCoder：请传入正确参数");
    for (NSString *key in keys) {
        [[self rootDictionary] setValue:@(intv) forKey:key];
    }
}

- (void)encodeFloat:(float)realv forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0 , @"FJsonCoder：请传入正确参数");
    for (NSString *key in keys) {
        [[self rootDictionary] setValue:@(realv) forKey:key];
    }
}

- (void)encodeDouble:(double)realv forKeys:(NSSet<NSString *> *)keys {
    NSAssert([keys count] > 0 , @"FJsonCoder：请传入正确参数");
    for (NSString *key in keys) {
        [[self rootDictionary] setValue:@(realv) forKey:key];
    }
}

- (id)decodeObjectClass:(Class)clazz forKey:(NSString *)key {
    NSAssert([key length] > 0, @"FJsonCoder：请传入正确参数");
    
    return [self decodeObjectClass:clazz element:nil forKey:key];
}

//专门解析容器元素
- (id)decodeObjectClass:(Class)clazz element:(Class)element forKey:(NSString *)key {
    NSAssert([key length] > 0, @"FJsonCoder：请传入正确参数");
    
    //step 1 从code中取出数据，检查是否为容器类型（字典或者数组，需要进一步处理）
    id objv = [[self rootDictionary] valueForKey:key];
    
    //是字典类型 或者 数组类型，需要对值对象化
    if ([objv isKindOfClass:[NSDictionary class]] || [objv isKindOfClass:[NSArray class]]) {
        FJsonCoder *coder = [self subCoderWithObject:objv targetClass:nil];
        coder.targetClass = clazz;
        id obj = [coder decodeObject:element];
        if (obj) {
            return obj;
        }
        
        //将其转换成可变返回，能适应跟多场景
        return [objv mutableCopy];
    }
    
    return objv;
}

- (id)decodeObjectForKey:(NSString *)key {
    NSAssert([key length] > 0, @"FJsonCoder：请传入正确参数");
    return [self decodeObjectClass:nil forKey:key];
}

- (NSData *)decodeDataForKey:(NSString *)key {
    NSLog(@"FJSON暂时未对NSData类型做支持，没有支持的类型");
//    NSString *base64 = [[self rootDictionary] valueForKey:key];
//    if (base64) {
//        return [NSData ssn_base64EncodedString:base64];
//    }
    return nil;
}

- (NSDate *)decodeDateForKey:(NSString *)key {
    long long utc = [[[self rootDictionary] valueForKey:key] longLongValue];
    return [NSDate dateWithTimeIntervalSince1970:utc];
}

- (NSString *)decodeStringForKey:(NSString *)key {
    return [[self rootDictionary] valueForKey:key];
}

- (NSValue *)decodeValueForKey:(NSString *)key {
    id obj = [[self rootDictionary] valueForKey:key];
    if (!obj) {
        return nil;
    }
    
    if ([obj isKindOfClass:[NSValue class]])
    {   //通过encode 进入的数据，值转换会数据
        /*
         case 'c'://	A char
         case 'i'://	An int
         case 's'://	A short
         case 'l'://	A longl is treated as a 32-bit quantity on 64-bit programs.
         case 'q'://	A long long
         case 'C'://	An unsigned char
         case 'I'://	An unsigned int
         case 'S'://	An unsigned short
         case 'L'://	An unsigned long
         case 'Q'://	An unsigned long long
         case 'f'://	A float
         case 'd'://	A double
         case 'B'://	A C++ bool or a C99 _Bool
         */
        return (NSValue *)obj;
    }
    
    if ([obj isKindOfClass:[NSString class]])
    {
        if ([[(NSString *)obj uppercaseString] isEqualToString:FJSON_NULL]) {
            return nil;
        }
        //step 1、 通过 c string 转入的value
        /*
         case '*'://	A character string (char *)
         */
        
        //step 2、因为data 最终也是被base64成string存储，故先检查是否可以反base64
        /*
         case '#'://	A class object (Class)
         case ':'://	A method selector (SEL) ,@encode(SEL) ':v@:@'
         case '[': //[array type]	An array
         case '{': //{name=type...}	A structure
         case '(': //(name=type...)	A union
         case 'b': //'bnum'	A bit field of num bits
         case '^': //^type	A pointer to type
         case '?': //	An unknown type (among other things, this code is used for function pointers)
         default:
         */
        NSData *data = [self decodeDataForKey:key];
        if ([data length] > 0)
        {
            const unsigned char * bytes = [data bytes];
            int type_length = bytes[0];
            if (type_length + 1 < [data length]) {
                char type[255] = {'\0'};
                memcpy(type, (bytes + 1), type_length);
                if (strlen(type) > 0) {
                    return [NSValue value:(bytes + 1 + type_length) withObjCType:type];
                }
            }
        }
        
        NSString *string = [self decodeStringForKey:key];
        return [NSValue valueWithPointer:[string UTF8String]];
    }
    
    //最后只剩下对象类型
    /*
     case '@'://	An object (whether statically typed or typed id)
     */
    return [NSValue valueWithNonretainedObject:obj];
}

- (BOOL)decodeBoolForKey:(NSString *)key {
    return [[[self rootDictionary] valueForKey:key] boolValue];
}

- (int)decodeIntForKey:(NSString *)key {
    return [[[self rootDictionary] valueForKey:key] intValue];
}

- (int32_t)decodeInt32ForKey:(NSString *)key {
    return [[[self rootDictionary] valueForKey:key] intValue];
}

- (int64_t)decodeInt64ForKey:(NSString *)key {
    return [[[self rootDictionary] valueForKey:key] longLongValue];
}

- (float)decodeFloatForKey:(NSString *)key {
    return [[[self rootDictionary] valueForKey:key] floatValue];
}

- (double)decodeDoubleForKey:(NSString *)key {
    return [[[self rootDictionary] valueForKey:key] doubleValue];
}

- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key {
    NSAssert([key length] > 0, @"FJsonCoder：请传入正确参数");
    [[self rootDictionary] setValue:@(intv) forKey:key];
}

- (NSInteger)decodeIntegerForKey:(NSString *)key {
    return [[[self rootDictionary] valueForKey:key] integerValue];
}

- (void)encodeArray:(NSArray *)array {
    NSAssert(array, @"FJsonCoder：请传入正确参数");
    for (id obj in array) {
        [self addEncodeObjectInArray:obj];
    }
}

- (void)addEncodeObjectInArray:(id)objv {
    NSAssert(objv, @"FJsonCoder：请传入正确参数");
    
    FJsonCoder *coder = [self subCoderWithObject:nil targetClass:[objv class]];
    [coder encodeObject:objv];
    if (coder.rootJsonObj) {
        [[self rootArray] addObject:coder.rootJsonObj];
    }
    else {
        [[self rootArray] addObject:objv];
    }
}

- (NSArray *)decodeArrayObjectClass:(Class)clazz {
    NSMutableArray *array = [NSMutableArray array];
    for (id aobj in [self rootArray]) {
        
        id target_obj = nil;
        FJsonCoder *coder = [self subCoderWithObject:aobj targetClass:nil];
        coder.targetClass = clazz;
        id obj = [coder decodeObject:clazz];
        if (obj) {
            target_obj = obj;
        }
        else {
            if (fjson_respond_mutable_copy([aobj class])) {
                target_obj = [aobj mutableCopy];
            } else {
                target_obj = aobj;
            }
        }
        
        if (target_obj) {
            [array addObject:target_obj];
        }
    }
    return array;
}

- (NSArray *)decodeArray {
    return [self decodeArrayObjectClass:nil];
}

- (void)encodeSet:(NSSet *)set {
    NSAssert(set, @"FJsonCoder：请传入正确参数");
    [self encodeArray:[set allObjects]];
}
- (NSSet *)decodeSetObjectClass:(Class)clazz {
    NSArray *ary = [self decodeArrayObjectClass:clazz];
    return [NSSet setWithArray:ary];
}

- (void)encodeDictionary:(NSDictionary *)dic {
    NSAssert(dic, @"FJsonCoder：请传入正确参数");
    
    for (id key in [dic allKeys]) {
        NSString *keyStr = nil;
        if ([key isKindOfClass:[NSString class]]) {
            keyStr = key;
        }
        else
        {
            keyStr = [NSString stringWithFormat:@"%@",key];
        }
        id obj = [dic objectForKey:key];
        [self addEncodeValueInDictionary:obj forKey:keyStr];
    }
}

- (void)addEncodeValueInDictionary:(id)objv forKey:(NSString *)key {
    NSAssert(objv && key, @"FJsonCoder：请传入正确参数");
    FJsonCoder *coder = [self subCoderWithObject:nil targetClass:[objv class]];
    if ([coder encodeObject:objv] && coder.rootJsonObj) {
        [[self rootDictionary] setObject:coder.rootJsonObj forKey:key];
    } else {
        if ([objv isKindOfClass:[NSString class]]) {
            [[self rootDictionary] setObject:objv forKey:key];
        } else if ([objv isKindOfClass:[NSValue class]]) {
            NSValue *value = (NSValue *)objv;
            switch (*(value.objCType)) {
                case 'c'://	A char
                case 'i'://	An int
                case 's'://	A short
                case 'l'://	A longl is treated as a 32-bit quantity on 64-bit programs.
                case 'q'://	A long long
                case 'C'://	An unsigned char
                case 'I'://	An unsigned int
                case 'S'://	An unsigned short
                case 'L'://	An unsigned long
                case 'Q'://	An unsigned long long
                case 'f'://	A float
                case 'd'://	A double
                case 'B'://	A C++ bool or a C99 _Bool
                    [[self rootDictionary] setObject:objv forKey:key];//部分类型不支持
                    break;
                default:
                    break;
            }
        }
    }
}
- (NSDictionary *)decodeDictionaryValueClass:(Class)clazz {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSDictionary *root = [self rootDictionary];
    for (NSString *key in [root allKeys]) {
        id aobj = [root objectForKey:key];
        
        id target_obj = nil;
        FJsonCoder *coder = [self subCoderWithObject:aobj targetClass:nil];
        coder.targetClass = clazz;
        id obj = [coder decodeObject:clazz];
        if (obj) {
            target_obj = obj;
        }
        else {
            if (fjson_respond_mutable_copy([aobj class])) {
                target_obj = [aobj mutableCopy];
            } else {
                target_obj = aobj;
            }
        }
        
        if (target_obj) {
            [dic setObject:target_obj forKey:key];
        }
    }
    return dic;
}

- (void)encodeIndexSet:(NSIndexSet *)set {
    NSAssert(set, @"FJsonCoder：请传入正确参数");
    NSMutableArray *ary = [NSMutableArray array];
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [ary addObject:@(idx)];
    }];
    [self encodeArray:ary];
}

- (NSIndexSet *)decodeIndexSet {
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (id aobj in [self rootArray]) {
        if (![aobj respondsToSelector:@selector(longLongValue)]) {
            continue ;
        }
        int64_t i = [(NSNumber *)aobj longLongValue];
        [set addIndex:i];
    }
    return set;
}

@end


/**
 *  配置器，主要是针对Entity类型配置Filter 和 Mapping
 */
@implementation FJSONConfig

+ (instancetype)config {
    return [[[self class] alloc] init];
}

- (NSMutableDictionary<NSString *,NSSet<NSString *> *> *)filter {
    if (_filter == nil) {
        _filter = [[NSMutableDictionary alloc] init];
    }
    return _filter;
}
- (NSMutableDictionary<NSString *,NSDictionary<NSString *,NSSet<NSString *> *> *> *)mapping {
    if (_mapping == nil) {
        _mapping = [[NSMutableDictionary alloc] init];
    }
    return _mapping;
}
- (NSMutableDictionary<NSString *,NSDictionary<NSString *,Class> *> *)generic {
    if (_generic == nil) {
        _generic = [[NSMutableDictionary alloc] init];
    }
    return _generic;
}

+ (NSString *)keyForEntityClass:(Class)entityClass {
    return NSStringFromClass(entityClass);
}

//配置实现
+ (BOOL)isValidProperty:(FJSONClassProperty *)key targetObject:(NSObject *)obj atConfig:(FJSONConfig *)config {
    NSSet<NSString *> *flts = nil;
    if (config->_filter != nil) {//防止创建_filter
        flts = [config filterForEntityClass:[obj class]];
    }
    
    //说明_filter没有配置此类的信息，继续看bfilter
    if (flts == nil && config.bfilter != nil) {
        NSArray<NSString *> *list = config.bfilter([obj class]);
        if (list != nil) {
            [config addFilter:list forEntityClass:[obj class]];
        }
        flts = [config filterForEntityClass:[obj class]];
    }
    
    //说明bfilter没有配置此类的信息，继续看协议是否支持
    if (flts == nil && [obj respondsToSelector:@selector(fjson_filter)]) {
        NSArray<NSString *> *list = [(id<FJSONEntity>)obj fjson_filter];
        if (list != nil) {
            [config addFilter:list forEntityClass:[obj class]];
        }
        flts = [config filterForEntityClass:[obj class]];
    }
    
    return ![flts containsObject:key.name];
}

+ (NSSet<NSString *> *)jsonKeysFromProperty:(FJSONClassProperty *)key targetObject:(NSObject *)obj atConfig:(FJSONConfig *)config {
    NSDictionary<NSString *,NSSet<NSString *> *> *mapping = nil;
    if (config->_mapping != nil) {//防止创建_filter
        mapping = [config mappingForEntityClass:[obj class]];
    }
    
    //说明_mapping没有配置此类的信息，继续看bmapping
    if (mapping == nil && config.bmapping != nil) {
        NSDictionary<NSString *,NSString *> * org_mapping = config.bmapping([obj class]);
        if (org_mapping != nil) {
            [config addMapping:org_mapping forEntityClass:[obj class]];
        }
        mapping = [config mappingForEntityClass:[obj class]];
    }
    
    //说明bmapping没有配置此类的信息，继续看协议是否支持
    if ([obj respondsToSelector:@selector(fjson_mapping)]) {
        NSDictionary<NSString *,NSString *> * org_mapping = [(id<FJSONEntity>)obj fjson_mapping];
        if (org_mapping != nil) {
            [config addMapping:org_mapping forEntityClass:[obj class]];
        }
        mapping = [config mappingForEntityClass:[obj class]];
    }
    
    NSSet<NSString *> *set = [mapping objectForKey:key.name];
    if ([set count] > 0) {
        return set;
    } else {
        return [NSSet setWithObject:key.name];
    }
}
+ (Class)genericClassForProperty:(FJSONClassProperty *)key targetObject:(NSObject *)obj atConfig:(FJSONConfig *)config {
    Class clazz = nil;
    if (config->_generic != nil) {//防止创建_filter
        clazz = [[config genericForEntityClass:[obj class]] objectForKey:key.name];
    }
    
    if (clazz == nil && config.bgeneric != nil) {
        clazz = config.bgeneric([obj class],key.name);
        if (clazz != nil) {
            [config addGeneric:@{key.name:clazz} forEntityClass:[obj class]];
        }
    }
    
    if (clazz == nil && [obj respondsToSelector:@selector(fjson_genericTypeForUndefinedKey:)]) {
        clazz = [(id<FJSONEntity>)obj fjson_genericTypeForUndefinedKey:key.name];
        if (clazz != nil) {
            [config addGeneric:@{key.name:clazz} forEntityClass:[obj class]];
        }
    }
    
    if (clazz != nil) {
        return clazz;
    }
    
    return key.subclazz;
}

/**
 *  过滤器，主要针对entity对象的属性名字来过滤
 */
- (NSSet<NSString *> *)filterForEntityClass:(Class)entityClass {
    if (entityClass == nil) {
        return nil;
    }
    return [_filter objectForKey:[FJSONConfig keyForEntityClass:entityClass]];
}
- (void)removeFilterForEntityClass:(Class)entityClass {
    if (entityClass == nil) {
        return ;
    }
    [_filter removeObjectForKey:[FJSONConfig keyForEntityClass:entityClass]];
}
- (void)addFilter:(NSArray<NSString *> *)filters forEntityClass:(Class)entityClass {
    if (entityClass == nil) {
        return ;
    }
    if ([filters count] == 0) {
        [_filter removeObjectForKey:[FJSONConfig keyForEntityClass:entityClass]];
    } else {
        [self.filter setObject:[NSSet setWithArray:filters] forKey:[FJSONConfig keyForEntityClass:entityClass]];
    }
}

/**
 *  mapping key是entity的property name，value则是可以被解析的json key，可以支持一对多，也可以多对一
 *  例：key:@"uid"  value:@"uid,userId"             //一对多，当decode时若多key存在，仅仅对json中存在的key处理
 *     key:@"account,mobile,mail" value:@"account" //多对一，当encode时多个key存在，请尽量使其值都一样，否则错乱
 *
 */
- (NSDictionary<NSString *,NSSet<NSString *> *> *)mappingForEntityClass:(Class)entityClass {
    if (entityClass == nil) {
        return nil;
    }
    return [_mapping objectForKey:[FJSONConfig keyForEntityClass:entityClass]];
}
- (void)removeMappingForEntityClass:(Class)entityClass {
    if (entityClass == nil) {
        return ;
    }
    [_mapping removeObjectForKey:[FJSONConfig keyForEntityClass:entityClass]];
}
- (void)addMapping:(NSDictionary<NSString *,NSString *> *)mapping forEntityClass:(Class)entityClass {
    if (entityClass == nil) {
        return ;
    }
    if ([mapping count] == 0) {
        [_mapping removeObjectForKey:[FJSONConfig keyForEntityClass:entityClass]];
    } else {//为了效率考虑，将maping拆分
        NSMutableDictionary<NSString *,NSSet<NSString *> *> *clz_mapping = [NSMutableDictionary dictionary];
        [mapping enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            NSArray<NSString *> *keys = [key componentsSeparatedByString:@","];
            NSSet<NSString *> *values = [NSSet setWithArray:[obj componentsSeparatedByString:@","]];
            if ([values count] > 0) {
                for (NSString *k in keys) {
                    [clz_mapping setObject:values forKey:k];
                }
            }
        }];
        if ([clz_mapping count] > 0) {
            [self.mapping setObject:clz_mapping forKey:[FJSONConfig keyForEntityClass:entityClass]];
        }
    }
}

/**
 *  主要用于decode过程，定义泛型元素类型，若某个类其属性为泛型，则需要采用配置方式识别元素类型
 *
 */
- (NSDictionary<NSString *,Class> *)genericForEntityClass:(Class)entityClass {
    if (entityClass == nil) {
        return nil;
    }
    return [_generic objectForKey:[FJSONConfig keyForEntityClass:entityClass]];
}
- (void)removeGenericForEntityClass:(Class)entityClass {
    if (entityClass == nil) {
        return ;
    }
    [_generic removeObjectForKey:[FJSONConfig keyForEntityClass:entityClass]];
}
- (void)addGeneric:(NSDictionary<NSString *,Class> *)generic forEntityClass:(Class)entityClass {
    if (entityClass == nil) {
        return ;
    }
    if ([generic count] == 0) {
        [_generic removeObjectForKey:[FJSONConfig keyForEntityClass:entityClass]];
    } else {
        [self.generic setObject:generic forKey:[FJSONConfig keyForEntityClass:entityClass]];
    }
}

/**
 *  脚本方式支持
 *
 *  @param obj 根据类型去判断，是设置filter还是mapping
 *  @param entityClass entity类型
 */
- (void)setObject:(id)obj forKeyedSubscript:(Class)entityClass {
    if (entityClass == nil) {
        return ;
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        [self addFilter:(NSArray<NSString *> *)obj forEntityClass:entityClass];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)obj;
        id v = [[dic allValues] firstObject];
        if ([v isKindOfClass:[NSString class]]) {
            [self addMapping:(NSDictionary<NSString *,NSString *> *)obj forEntityClass:entityClass];
        } else if (v == [v class]) {
            [self addGeneric:(NSDictionary<NSString *,Class> *)obj forEntityClass:entityClass];
        }
    }
}


@end

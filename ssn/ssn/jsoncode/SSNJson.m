//
//  SSNJson.m
//  ssn
//
//  Created by lingminjun on 14-11-10.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNJson.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif
#import "NSData+SSNBase64.h"
#import "SSNSafeDictionary.h"

const char * SSN_JSON_IGNORE_description_KEY      = "description";
const char * SSN_JSON_IGNORE_debugDescription_KEY = "debugDescription";
const char * SSN_JSON_IGNORE_hash_KEY             = "hash";
const char * SSN_JSON_IGNORE_superclass_KEY       = "superclass";

NSString *const SSN_JSON_CODER_IGNORE_PROTOCOL  = @"__ssn_json_coder_ignore";
NSString *const SSN_JSON_CODER_CORVERT_PROTOCOL  = @"__ssn_json_coder_corvert_to_";

BOOL ssn_is_kind_of(Class acls, Class other)
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

@interface SSNClassProperty : NSObject
@property (nonatomic,copy) NSString *name;  //类型名字
@property (nonatomic) char typePrefix;      //类型编码
@property (nonatomic) BOOL readonly;        //只读（解析时并不忽略，只是标记，只读类型先处理）
@property (nonatomic) BOOL ignore;          //忽略
@property (nonatomic) BOOL isContainer;     //是容器
@property (nonatomic,strong) Class clazz;   //属性类型（若值类型）
@property (nonatomic,strong) Class subclazz;//容器类型中的元素类型
@end

@implementation SSNClassProperty

- (NSUInteger)hash {
    return [self.name hash];
}

- (BOOL)isEqual:(SSNClassProperty *)other {
    if ([other isKindOfClass:[NSNull class]]) {
        return NO;
    }
    return [self.name isEqualToString:other.name];
}

@end

NSMutableDictionary *ssn_get_class_property_name(Class clazz) {
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    
    @autoreleasepool {
        //递归寻找
        Class p_cls = clazz;
        Class ns_object_calzz = [NSObject class];
        Class ns_proxy_clazz = [NSProxy class];
        Class ns_array_clazz = [NSArray class];
        Class ns_dictionary_clazz = [NSDictionary class];
        Class ns_set_clazz = [NSSet class];
        Class ns_index_set_clazz = [NSIndexSet class];
        
        while (p_cls != nil && (p_cls != ns_object_calzz && p_cls != ns_proxy_clazz)) {
            unsigned int outCount;
            objc_property_t *c_properties = class_copyPropertyList(p_cls, &outCount);
            
            for (unsigned int i = 0; i < outCount; i++)
            {
                @autoreleasepool {
                    objc_property_t property = c_properties[i];
                    
                    const char *c_property_name = property_getName(property);
                    if (c_property_name && strlen(c_property_name) == 0) {
                        continue ;
                    }
                    
                    if (strcmp(SSN_JSON_IGNORE_description_KEY, c_property_name) == 0) {
                        continue ;
                    }
                    
                    if (strcmp(SSN_JSON_IGNORE_debugDescription_KEY, c_property_name) == 0) {
                        continue ;
                    }
                    
                    if (strcmp(SSN_JSON_IGNORE_hash_KEY, c_property_name) == 0) {
                        continue ;
                    }
                    
                    if (strcmp(SSN_JSON_IGNORE_superclass_KEY, c_property_name) == 0) {
                        continue ;
                    }
                    
                    //get property attributes
                    /* 请参考官网地址
                     https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
                     */
                    const char *attrs = property_getAttributes(property);
                    printf("\nobj_Attributes:%s",attrs);
                    const long length = strlen(attrs);
                    if (length <= 1) {
                        continue ;
                    }
                    
                    switch (attrs[1]) {
                        case '^'://对象或者函数指针暂时不做支持
                            continue ;
                            break;
                        case '{'://struct 暂时不做支持
                            continue ;
                            break;
                        case '('://Union 暂时不做支持
                            continue ;
                            break;
                        default:
                            break;
                    }
                    
                    SSNClassProperty *classProperty = [[SSNClassProperty alloc] init];
                    
                    classProperty.name = [NSString stringWithUTF8String:c_property_name];
                    NSString* propertyAttributes =  [NSString stringWithUTF8String:attrs];
                    
                    //是否忽略字段
                    if ([propertyAttributes rangeOfString:SSN_JSON_CODER_IGNORE_PROTOCOL].length > 0) {
                        continue ;
                    }
                    
                    NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];
                    if ([attributeItems containsObject:@"R"]) {//read-only properties
//                        continue; //to next property
                        classProperty.readonly = YES;
                    }
                    
                    classProperty.typePrefix = attrs[1];
                    
                    if (attrs[1] == '@') {//若是对象类型，需要获取类型
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
                            if (ssn_is_kind_of(classProperty.clazz, ns_array_clazz)
                                || ssn_is_kind_of(classProperty.clazz, ns_dictionary_clazz)
                                || ssn_is_kind_of(classProperty.clazz, ns_set_clazz)) {
                                classProperty.isContainer = YES;
                                
                                //取容器属性
                                NSInteger count = [comps count];
                                for (NSInteger idx = 1; idx < count; idx++) {
                                    NSString *protocol = comps[idx];
                                    if ([protocol hasPrefix:SSN_JSON_CODER_CORVERT_PROTOCOL]) {
                                        
                                        NSString *subclass = [protocol substringFromIndex:[SSN_JSON_CODER_CORVERT_PROTOCOL length]];
                                        subclass = [subclass substringToIndex:[subclass length] - 1];
                                        classProperty.subclazz = NSClassFromString(subclass);
                                        
                                        break ;
                                    }
                                }
                            }
                            else if (ssn_is_kind_of(classProperty.clazz, ns_index_set_clazz)) {
                                classProperty.isContainer = YES;
                            }
                        }
                    }
                    
                    //记录下来
                    if (classProperty.name) {
                        [properties setObject:classProperty forKey:classProperty.name];
                    }
                }
            }
            
            if (c_properties) {
                free(c_properties);
            }
            
            p_cls = class_getSuperclass(p_cls);
        }
    }
    
    return properties;
}


/**
 *  json coder对象负责encode和decode序列过程
 */
@interface SSNJsonCoder ()
{
    id _jsonObj;
    BOOL _isArray;
    //BOOL _beginEncoding;//准备encoding，一旦准备coding，json是array容器或者自定容器确定后不能再改变
    Class _targetClass;
    NSDictionary *_ppts;//目标对象的字段列表
}

@property (nonatomic) Class targetClass;
@property (nonatomic,strong) NSDictionary *ppts;

- (BOOL)isArray;

- (id)rootJsonObj;//获取根对象

- (NSMutableArray *)rootArray;
- (NSMutableDictionary *)rootDictionary;

- (NSData *)encodeData;//当前被encode的数据
- (void)setEncodeData:(NSData *)jsonData;//重置解析数据

- (NSString *)encodeString;
- (void)setEncodeString:(NSString *)string;

@end


@implementation SSNJsonCoder

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

- (NSString *)encodeString {
    NSData *data = [self encodeData];
    if ([data length] <= 0) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)setEncodeData:(NSData *)jsonData {
    if ([jsonData length] <= 0) {
        return ;
    }
    
    NSError *error = nil;
    _jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingMutableContainers
                                                 error:&error];
    
    if ([_jsonObj isKindOfClass:[NSArray class]]) {
        _isArray = YES;
    }
}

- (void)setEncodeString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self setEncodeData:data];
}

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

+ (NSDictionary *)sharedPPTsWithClass:(Class)clazz {
    static SSNSafeDictionary *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[SSNSafeDictionary alloc] initWithCapacity:1];
    });
    NSNumber *key = @((long)(clazz));
    NSDictionary *ppts = [shared objectForKey:key];
    if (ppts) {
        return ppts;
    }
    ppts = ssn_get_class_property_name(clazz);
    if (ppts) {
        [shared setObject:ppts forKey:key];
    }
    return ppts;
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
    
    _ppts = [SSNJsonCoder sharedPPTsWithClass:clazz];
    return _ppts;
}

+ (SSNJsonCoder *)coderWithTargetClass:(Class)clazz
{
    SSNJsonCoder *coder = [[[self class] alloc] init];
    coder.targetClass = clazz;
    return coder;
}

+ (SSNJsonCoder *)coderWithRootObject:(id)objv
{
    //是字典类型，需要对值对象化
    if ([objv isKindOfClass:[NSDictionary class]])//是对象
    {
        SSNJsonCoder *coder = [SSNJsonCoder coderWithTargetClass:nil];
        [[coder rootDictionary] setDictionary:objv];
        return coder;
    }
    
    //是数组类型，需要对值对象化
    if ([objv isKindOfClass:[NSArray class]])
    {
        SSNJsonCoder *coder = [SSNJsonCoder coderWithTargetClass:nil];
        [[coder rootArray] setArray:(NSArray *)objv];
        return coder;
    }
    
    return nil;
}

@end


/**
 *  默认实现支持，NSObject 默认实现了一套encodeWithJsonCoder和decodeWithJsonCoder，并提供通用方法来获取最终值
 *  NSObject的默认实现是code所有属性，key为属性名
 */
@implementation NSObject (SSNJson)

#pragma mark SSNJsonCoding
#define ssn_not_support_encode_class(clazz) if ([self isKindOfClass:[clazz class]]) {return ;}
#define ssn_not_support_decode_class(clazz) if ([self isKindOfClass:[clazz class]]) {return self;}
- (void)encodeWithJsonCoder:(SSNJsonCoder *)aCoder {
    if ([self class] == [NSObject class]) {
        return ;
    }
    ssn_not_support_encode_class(SSNJsonCoder)
    ssn_not_support_encode_class(NSString)
    ssn_not_support_encode_class(NSData)
    ssn_not_support_encode_class(NSValue)
    ssn_not_support_encode_class(NSCharacterSet)
    ssn_not_support_encode_class(NSDate)//时间支持也没有意义
    
    if ([self isKindOfClass:[NSArray class]]) {
        [aCoder encodeArray:(NSArray *)self];
    }
    else if ([self isKindOfClass:[NSDictionary class]]) {
        [aCoder encodeDictionary:(NSDictionary *)self];
    }
    else if ([self isKindOfClass:[NSSet class]]) {
        [aCoder encodeSet:(NSSet *)self];
    }
    else if ([self isKindOfClass:[NSIndexSet class]]) {
        [aCoder encodeIndexSet:(NSIndexSet *)self];
    }
    else //对于其他对象，我们只code其属性
    {
        NSArray *allKeys = [aCoder.ppts allKeys];
        for (NSString *key in allKeys) {
            id value = [self valueForKey:key];
            if (value) {
                [aCoder encodeObject:value forKey:key];
            }
        }
    }
}

- (id)initWithJsonCoder:(SSNJsonCoder *)aDecoder {
    return [self initWithJsonCoder:aDecoder element:nil];
}

- (id)initWithJsonCoder:(SSNJsonCoder *)aDecoder element:(Class)element {
    self = [self init];
    if (self) {
        if ([self class] == [NSObject class]) {
            return self;
        }
        ssn_not_support_decode_class(SSNJsonCoder)
        ssn_not_support_decode_class(NSString)
        ssn_not_support_decode_class(NSData)
        ssn_not_support_decode_class(NSValue)
        ssn_not_support_decode_class(NSCharacterSet)
        ssn_not_support_decode_class(NSDate)//时间支持也没有意义
        
        if ([self isKindOfClass:[NSArray class]]) {//不可变没有意义
            NSArray *ary = [aDecoder decodeArrayObjectClass:element];
            if ([self isKindOfClass:[NSMutableArray class]]) {
                if (ary) {
                    [(NSMutableArray *)self setArray:ary];
                }
            }
            else {
                return ary;
            }
        }
        else if ([self isKindOfClass:[NSDictionary class]]) {//不可变没有意义
            NSDictionary *dic = [aDecoder decodeDictionaryValueClass:element];
            if ([self isKindOfClass:[NSMutableDictionary class]]) {
                //此处用到code内部方法
                
                if (dic) {
                    [(NSMutableDictionary *)self setDictionary:dic];
                }
            }
            else {
                return dic;
            }
        }
        else if ([self isKindOfClass:[NSSet class]]) {
            NSSet *set = [aDecoder decodeSetObjectClass:element];
            if ([self isKindOfClass:[NSMutableSet class]]) {
                if (set) {
                    [(NSMutableSet *)self setSet:set];
                }
            }
            else {
                return set;
            }
        }
        else if ([self isKindOfClass:[NSIndexSet class]]) {
            NSIndexSet *set = [aDecoder decodeIndexSet];
            if ([self isKindOfClass:[NSMutableIndexSet class]]) {
                if (set) {
                    [(NSMutableIndexSet *)self addIndexes:set];
                }
            }
            else {
                return set;
            }
        }
        else //对于其他对象，我们只code其属性
        {
            NSArray *allKeys = [aDecoder.ppts allKeys];
            for (NSString *key in allKeys) {
                //熟悉取出来
                SSNClassProperty *classProperty = [aDecoder.ppts objectForKey:key];
                
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
                    case 'f'://	A float
                    case 'd'://	A double
                    case 'B'://	A C++ bool or a C99 _Bool
                    {// 以上数据类型直接将值encode
                        id value = [aDecoder decodeValueForKey:key];
                        if (value) {
                            [self setValue:value forKey:key];
                        }
                    } break;
                    case 'v'://	A void
                    {// void丢弃
                    } break;
                    case '*'://	A character string (char *)
                    {// 转换成NSString encode
                        id value = [aDecoder decodeValueForKey:key];
                        if (value) {
                            [self setValue:value forKey:key];
                        }
                    } break;
                    case '@'://	An object (whether statically typed or typed id)
                    {// 将对象还原出来 再 encode
                        
                        if (ssn_is_kind_of(classProperty.clazz, [NSArray class])
                            || ssn_is_kind_of(classProperty.clazz, [NSDictionary class])
                            || ssn_is_kind_of(classProperty.clazz, [NSSet class]))
                        {//1、对象容器支持
                            id value = [aDecoder decodeObjectClass:classProperty.clazz element:classProperty.subclazz forKey:key];
                            if (value) {
                                [self setValue:value forKey:key];
                            }
                        }
                        else if (ssn_is_kind_of(classProperty.clazz, [NSIndexSet class])){//2、值容器支持
                            id value = [aDecoder decodeObjectClass:classProperty.clazz forKey:key];
                            if (value) {
                                [self setValue:value forKey:key];
                            }
                        }
                        else {
                            id value = [aDecoder decodeObjectClass:classProperty.clazz forKey:key];
                            if (value) {
                                [self setValue:value forKey:key];
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
                        id value = [aDecoder decodeValueForKey:key];
                        if (value) {
                            [self setValue:value forKey:key];
                        }
                    } break;
                }
            }
        }
    }
    
    return self;
}

- (SSNJsonCoder *)ssn_toJsonCoder {
    SSNJsonCoder *coder = [SSNJsonCoder coderWithTargetClass:[self class]];
    [self encodeWithJsonCoder:coder];
    return coder;
}

- (NSData *)ssn_toJson {
    return [[self ssn_toJsonCoder] encodeData];
}

- (NSString *)ssn_toJsonString {
    NSData *data = [self ssn_toJson];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


+ (instancetype)ssn_objectFromJsonData:(NSData *)jsonData {
    return [self ssn_objectFromJsonData:jsonData targetClass:[self class]];
}


+ (instancetype)ssn_objectFromJsonString:(NSString *)jsonString {
    return [self ssn_objectFromJsonString:jsonString targetClass:[self class]];
}

+ (instancetype)ssn_objectFromJsonData:(NSData *)jsonData targetClass:(Class)targetClass {
    SSNJsonCoder *coder = [SSNJsonCoder coderWithTargetClass:targetClass];
    [coder setEncodeData:jsonData];
    return [self ssn_objectFromJsonCoder:coder];
}

+ (instancetype)ssn_objectFromJsonCoder:(SSNJsonCoder *)coder {
    if (!coder) {
        return nil;
    }
    
    Class clazz = [coder targetClass];
    if (clazz == nil) {
        return nil;
    }
    id obj = [[clazz alloc] initWithJsonCoder:coder];//生产实例
    return obj;
}

+ (instancetype)ssn_objectFromJsonCoder:(SSNJsonCoder *)coder element:(Class)element {
    if (!coder) {
        return nil;
    }
    
    Class clazz = [coder targetClass];
    if (clazz == nil) {
        return nil;
    }
    id obj = [[clazz alloc] initWithJsonCoder:coder element:element];//生产实例
    return obj;
}

+ (instancetype)ssn_objectFromJsonString:(NSString *)jsonString targetClass:(Class)targetClass {
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [self ssn_objectFromJsonData:data targetClass:targetClass];
}

@end

/**
 *  coder支持的类型
 *  注意key不能为空，传入的值必须有意义，解码遇到类型不对可能出现异常
 */
@implementation SSNJsonCoder (SSNExtendedJsonCoder)

//object-c class类型
- (void)encodeObject:(id)objv forKey:(NSString *)key {
    NSAssert([key length] > 0 && objv, @"SSNJsonCoder：传入正确参数");
    if ([objv isKindOfClass:[NSData class]])
    {
        [self encodeData:(NSData *)objv forKey:key];
    }
    if ([objv isKindOfClass:[NSString class]])
    {
        [self encodeString:(NSString *)objv forKey:key];
    }
    if ([objv isKindOfClass:[NSDate class]])
    {
        [self encodeDate:(NSDate *)objv forKey:key];
    }
    else if ([objv isKindOfClass:[NSValue class]]) //对于数据类型，需要根据type分别处理
    {
        [self encodeValue:(NSValue *)objv forKey:key];
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
        SSNJsonCoder *coder = [objv ssn_toJsonCoder];
        id jsonObj = [coder rootJsonObj];
        if (jsonObj) {
            [[self rootDictionary] setValue:jsonObj forKey:key];
        }
    }
}

- (void)encodeData:(NSData *)data forKey:(NSString *)key {
    NSAssert([key length] > 0 && [data length] > 0, @"SSNJsonCoder：传入正确参数");
    NSString *base64 = [data ssn_base64];
    [[self rootDictionary] setValue:base64 forKey:key];
}

- (void)encodeDate:(NSDate *)date forKey:(NSString *)key {
    NSAssert([key length] > 0 && date, @"SSNJsonCoder：传入正确参数");
    long long utc = [date timeIntervalSince1970];
    [self encodeInt64:utc forKey:key];
}

- (void)encodeString:(NSString *)string forKey:(NSString *)key {
    NSAssert([key length] > 0 && [string length] > 0, @"SSNJsonCoder：传入正确参数");
    [[self rootDictionary] setValue:string forKey:key];
}

- (void)encodeValue:(NSValue *)value forKey:(NSString *)key {
    NSAssert([key length] > 0 && value, @"SSNJsonCoder：传入正确参数");
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
            [[self rootDictionary] setValue:value forKey:key];
        } break;
        case 'v'://	A void
        {// void丢弃
        } break;
        case '*'://	A character string (char *)
        {// 转换成NSString encode
            NSString *stringValue = [(NSNumber *)value stringValue];
            [self encodeString:stringValue forKey:key];
        } break;
        case '@'://	An object (whether statically typed or typed id)
        {// 将对象还原出来 再 encode
            id nonretainedObjectValue = [value nonretainedObjectValue];
            if (nonretainedObjectValue) {
                [self encodeObject:nonretainedObjectValue forKey:key];
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
                [self encodeData:data forKey:key];
            }
        } break;
    }
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key {
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    [[self rootDictionary] setValue:@(boolv) forKey:key];
}

- (void)encodeInt:(int)intv forKey:(NSString *)key {
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    [[self rootDictionary] setValue:@(intv) forKey:key];
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key {
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    [[self rootDictionary] setValue:@(intv) forKey:key];
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key {
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    [[self rootDictionary] setValue:@(intv) forKey:key];
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key {
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    [[self rootDictionary] setValue:@(realv) forKey:key];
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key {
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    [[self rootDictionary] setValue:@(realv) forKey:key];
}

- (id)decodeObjectClass:(Class)clazz forKey:(NSString *)key {
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    
    return [self decodeObjectClass:clazz element:nil forKey:key];
}

//转么解析容器元素
- (id)decodeObjectClass:(Class)clazz element:(Class)element forKey:(NSString *)key {
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    
    //step 1 从code中取出数据，检查是否为容器类型（字典或者数组，需要进一步处理）
    id objv = [[self rootDictionary] valueForKey:key];
    
    //是字典类型 或者 数组类型，需要对值对象化
    if ([objv isKindOfClass:[NSDictionary class]]
        || [objv isKindOfClass:[NSArray class]])//是对象
    {
        SSNJsonCoder *coder = [SSNJsonCoder coderWithRootObject:objv];
        coder.targetClass = clazz;
        id obj = [NSObject ssn_objectFromJsonCoder:coder element:element];
        if (obj) {
            return obj;
        }
        
        //将其转换成可变返回，能适应跟多场景
        return [objv mutableCopy];
    }
    
    return objv;
}

- (id)decodeObjectForKey:(NSString *)key {
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    return [self decodeObjectClass:nil forKey:key];
}

- (NSData *)decodeDataForKey:(NSString *)key {
    NSString *base64 = [[self rootDictionary] valueForKey:key];
    if (base64) {
        return [NSData ssn_base64EncodedString:base64];
    }
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
    {   //step 1、 通过 c string 转入的value
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
    NSAssert([key length] > 0, @"SSNJsonCoder：传入正确参数");
    [[self rootDictionary] setValue:@(intv) forKey:key];
}

- (NSInteger)decodeIntegerForKey:(NSString *)key {
    return [[[self rootDictionary] valueForKey:key] integerValue];
}

- (void)encodeArray:(NSArray *)array {
    NSAssert(array, @"SSNJsonCoder：传入正确参数");
    for (id obj in array) {
         [self addEncodeObjectInArray:obj];
    }
}

- (void)addEncodeObjectInArray:(id)objv {
    NSAssert(objv, @"SSNJsonCoder：传入正确参数");
    
    SSNJsonCoder *coder = [SSNJsonCoder coderWithTargetClass:[objv class]];
    [objv encodeWithJsonCoder:coder];
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
        SSNJsonCoder *coder = [SSNJsonCoder coderWithRootObject:aobj];
        coder.targetClass = clazz;
        id obj = [NSObject ssn_objectFromJsonCoder:coder];
        if (obj) {
            target_obj = obj;
        }
        else {
            if ([aobj respondsToSelector:@selector(mutableCopy)]) {
                target_obj = [aobj mutableCopy];
            }
            else {
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
    NSAssert(set, @"SSNJsonCoder：传入正确参数");
    [self encodeArray:[set allObjects]];
}
- (NSSet *)decodeSetObjectClass:(Class)clazz {
    NSArray *ary = [self decodeArrayObjectClass:clazz];
    return [NSSet setWithArray:ary];
}

- (void)encodeDictionary:(NSDictionary *)dic {
    NSAssert(dic, @"SSNJsonCoder：传入正确参数");
    
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
    NSAssert(objv && key, @"SSNJsonCoder：传入正确参数");
    SSNJsonCoder *coder = [SSNJsonCoder coderWithTargetClass:[objv class]];
    [objv encodeWithJsonCoder:coder];
    if (coder.rootJsonObj) {
        [[self rootDictionary] setObject:coder.rootJsonObj forKey:key];
    }
}
- (NSDictionary *)decodeDictionaryValueClass:(Class)clazz {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSDictionary *root = [self rootDictionary];
    for (NSString *key in [root allKeys]) {
        id aobj = [root objectForKey:key];
        
        id target_obj = nil;
        SSNJsonCoder *coder = [SSNJsonCoder coderWithRootObject:aobj];
        coder.targetClass = clazz;
        id obj = [NSObject ssn_objectFromJsonCoder:coder];
        if (obj) {
            target_obj = obj;
        }
        else {
            if ([aobj respondsToSelector:@selector(mutableCopy)]) {
                target_obj = [aobj mutableCopy];
            }
            else {
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
    NSAssert(set, @"SSNJsonCoder：传入正确参数");
    NSMutableArray *ary = [NSMutableArray array];
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [ary addObject:@(idx)];
    }];
    [self encodeArray:ary];
}

- (NSIndexSet *)decodeIndexSet {
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (id aobj in [self rootArray]) {
        if (![aobj isKindOfClass:[NSNumber class]]) {
            continue ;
        }
        int64_t i = [(NSNumber *)aobj longLongValue];
        [set addIndex:i];
    }
    return set;
}

@end


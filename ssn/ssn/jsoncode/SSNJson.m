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

NSString *const SSN_JSON_CODER_CLASS_TYPE_KEY   = @":class@";//避免与常见属性重复，冒号不可能作为语言标示符，故以冒号开头


@interface SSNClassProperty : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic) char typePrefix;
@property (nonatomic) BOOL readonly;
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
                    
                    char *typeEncoding = property_copyAttributeValue(property, "T");
                    if (typeEncoding == NULL || strlen(typeEncoding) == 0) {
                        if (typeEncoding) {
                            free(typeEncoding);
                        }
                        continue ;
                    }
                    
                    SSNClassProperty *classProperty = [[SSNClassProperty alloc] init];
                    classProperty.name = [NSString stringWithFormat:@"%s",c_property_name];
                    classProperty.typePrefix = typeEncoding[0];
                    
                    const char *propAttr = property_getAttributes(property);
                    NSString *propString = [NSString stringWithUTF8String:propAttr];
                    NSArray *attrArray = [propString componentsSeparatedByString:@","];
                    classProperty.readonly = [attrArray containsObject:@"R"];
                    
                    if (![properties objectForKey:classProperty.name]) {
                        [properties setObject:classProperty forKey:classProperty.name];
                    }
                    
                    if (typeEncoding) {
                        free(typeEncoding);
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

//@synthesize beginEncoding = _beginEncoding;

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
    
    NSDictionary *dic = [self rootDictionary];
    NSString *class = [dic objectForKey:SSN_JSON_CODER_CLASS_TYPE_KEY];
    if (class) {
        _targetClass = NSClassFromString(class);
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
    
    _ppts = ssn_get_class_property_name(clazz);
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
#define ssn_not_support_code_class(clazz) if ([self isKindOfClass:[clazz class]]) {return ;}
- (void)encodeWithJsonCoder:(SSNJsonCoder *)aCoder {
    if ([self class] == [NSObject class]) {
        return ;
    }
    ssn_not_support_code_class(SSNJsonCoder)
    ssn_not_support_code_class(NSString)
    ssn_not_support_code_class(NSData)
    ssn_not_support_code_class(NSValue)
    ssn_not_support_code_class(NSDate)//时间支持也没有意义
    
    if ([self isKindOfClass:[NSArray class]]) {
        [aCoder encodeArray:(NSArray *)self];
    }
    else if ([self isKindOfClass:[NSDictionary class]]) {
        for (id key in [(NSDictionary *)self allKeys]) {
            NSString *keyStr = nil;
            if ([key isKindOfClass:[NSString class]]) {
                keyStr = key;
            }
            else
            {
                keyStr = [NSString stringWithFormat:@"%@",key];
            }
            
            id value = [(NSDictionary *)self objectForKey:key];
            if (value) {
                [aCoder encodeObject:value forKey:keyStr];
            }
        }
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
        
        //将类名code到json串中
        [aCoder encodeString:NSStringFromClass([self class]) forKey:SSN_JSON_CODER_CLASS_TYPE_KEY];
    }
}

- (void)decodeWithJsonCoder:(SSNJsonCoder *)aDecoder {
    if ([self class] == [NSObject class]) {
        return ;
    }
    ssn_not_support_code_class(SSNJsonCoder)
    ssn_not_support_code_class(NSString)
    ssn_not_support_code_class(NSData)
    ssn_not_support_code_class(NSValue)
    ssn_not_support_code_class(NSDate)//时间支持也没有意义
    
    if ([self isKindOfClass:[NSArray class]]) {
        if ([self isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)self setArray:[aDecoder decodeArray]];
        }
    }
    else if ([self isKindOfClass:[NSDictionary class]]) {
        if ([self isKindOfClass:[NSMutableDictionary class]]) {
            //此处用到code内部方法
            NSDictionary *codeDic = [aDecoder rootDictionary];
            for (NSString *key in [codeDic allKeys]) {
                id obj = [aDecoder decodeObjectForKey:key];
                if (obj) {
                    [(NSMutableDictionary *)self setValue:obj forKey:key];
                }
            }
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
                    id value = [aDecoder decodeObjectForKey:key];
                    if (value) {
                        [self setValue:value forKey:key];
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
    return [self ssn_objectFromJsonData:jsonData targetClass:nil];
}


+ (instancetype)ssn_objectFromJsonString:(NSString *)jsonString {
    return [self ssn_objectFromJsonString:jsonString targetClass:nil];
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
    id obj = [[clazz alloc] init];//生产实例
    [obj decodeWithJsonCoder:coder];
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
    
    //step 1 从code中取出数据，检查是否为容器类型（字典或者数组，需要进一步处理）
    id objv = [[self rootDictionary] valueForKey:key];
    
    //是字典类型 或者 数组类型，需要对值对象化
    if ([objv isKindOfClass:[NSDictionary class]] || [objv isKindOfClass:[NSArray class]])//是对象
    {
        SSNJsonCoder *coder = [SSNJsonCoder coderWithRootObject:objv];
        coder.targetClass = clazz;
        id obj = [NSObject ssn_objectFromJsonCoder:coder];
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
}

- (NSArray *)decodeArrayObjectClass:(Class)clazz {
    NSMutableArray *array = [NSMutableArray array];
    for (id obj in [self rootArray]) {

        id target_obj = nil;
        SSNJsonCoder *coder = [SSNJsonCoder coderWithRootObject:obj];
        coder.targetClass = clazz;
        id obj = [NSObject ssn_objectFromJsonCoder:coder];
        if (obj) {
            target_obj = obj;
        }
        else {
            if ([obj respondsToSelector:@selector(mutableCopy)]) {
                target_obj = [obj mutableCopy];
            }
            else {
                target_obj = obj;
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

@end


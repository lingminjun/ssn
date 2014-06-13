//
//  SSNModel.m
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNModel.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif
#import "SSNMeta.h"
#import "ssnbase.h"
#import "SSNModelPrivate.h"
#import "SSNModelManagerProtocol.h"

static const char *ssn_method_header            = "ssn_model_set_";
//属性类型 位于方法 15位
static const size_t ssn_method_type_location    = 14;
static const char ssn_method_int_flag           = 'i';//int , bool
static const char ssn_method_float_flag         = 'f';//float , double
static const char ssn_method_obj_flag           = 'o';//string , data


//键值类型位 位于方法 16位
static const size_t ssn_method_key_location    = 15;
static const char ssn_method_pri_key           = 'p';
static const char ssn_method_nor_key           = 'n';

//方法总长度
static const size_t ssn_method_header_length    = 17;//ssn_model_set_ip_


NSString *const SSNModelException = @"SSNModelException";


@interface SSNModelKeys : NSObject
{
    NSArray *_primaryKeys;
    NSArray *_valuesKeys;
    NSArray *_valuesTypes;
#ifndef SSN_USER_DETACHED_MODEL_MANAGER
    __weak id<SSNModelManagerProtocol> _manager;
#endif
}

@property (nonatomic,strong) NSArray *primaryKeys;
@property (nonatomic,strong) NSArray *valuesKeys;
@property (nonatomic,strong) NSArray *valuesTypes;
#ifndef SSN_USER_DETACHED_MODEL_MANAGER
@property (nonatomic,weak) id<SSNModelManagerProtocol> manager;
#endif

@end



@implementation SSNModel

@synthesize meta = _meta;
@synthesize vls = _vls;
@synthesize keyPredicate = _keyPredicate;
@synthesize opt = _opt;
@synthesize hasChanged = _hasChanged;


- (BOOL)isTemporary {
    if (self.meta) {
        return NO;
    }
    return YES;
}

- (BOOL)isFault {
    if (!self.meta) {
        return NO;
    }
    return [self.meta isFault];
}

- (BOOL)needUpdate {
    if ([self isTemporary]) {
        return NO;
    }
    
    if ([self isFault]) {
        return NO;
    }
    
    if (self.opt < self.meta.opt) {//操作数小于元数据，表明可以更新
        return YES;
    }
    
    return NO;
}

- (BOOL)isDeleted {
    if ([self isTemporary]) {
        return NO;
    }
    
    return self.meta.isDeleted;
}

- (NSString *)keyPredicate {
    if (_keyPredicate) {//已经有了就直接返回
        return _keyPredicate;
    }
    
    if (self.meta) {
        @autoreleasepool {
            _keyPredicate = self.meta.mkey;
            return _keyPredicate;
        }
    }
    
    //需要检查主键是否有值
    @autoreleasepool {
        NSArray *pKeys = [self primaryKeys];
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:1];
        BOOL notValue = NO;
        for (NSString *key in pKeys) {
            id v = [self.vls objectForKey:key];
            if (v == nil) {
                notValue = YES;
                break ;
            }
            [values addObject:v];
        }
        
        //还有一部分主键没有赋值，
        if (notValue) {
            return _keyPredicate;
        }
        
        _keyPredicate = [NSString predicateValues:values keys:pKeys];
    }
    
    return _keyPredicate;
}

#pragma mark 防止深入继承
- (id)init {
    //只有一层继承关系，
    if ([self superclass] != [SSNModel class]) {
        [NSException raise: SSNModelException
                    format: @"SSNModel对象只能产生其直接派生类型。"];
        return nil;
    }
    
    self = [super init];
    if (self) {
        _vls = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

#pragma mark 与永久库操作
//db 操作
- (BOOL)insertToStore {
    NSAssert([self manager], @"请设置%@对象管理器，设置方法调用+setManager:方法",[self class]);
    
    NSString *predicate = [self keyPredicate];
    if ([predicate length] == 0) {
        return NO;
    }
    
    BOOL result = [[self manager] model:self insertDatas:self.vls forPredicate:predicate];
    if (!result) {
        return NO;
    }
    
    //插入成功，必须保存meta
    if (self.meta) {//存在meta，需要，更新信息
        [SSNMeta loadMeta:self.meta datas:self.vls];
        self.opt = self.meta.opt;
    }
    else {//不存在
        self.meta = SSNMetaFactory([self class], predicate);
        [SSNMeta loadMeta:self.meta datas:self.vls];
        self.opt = self.meta.opt;
    }
    
    return result;
}

- (BOOL)updateToStore {
    NSAssert([self manager], @"请设置%@对象管理器，设置方法调用+setManager:方法",[self class]);
    
    if ([self isTemporary]) {
        return NO;
    }
    
    if (![self hasChanged]) {
        return NO;
    }
    
    NSString *predicate = [self keyPredicate];
    if ([predicate length] == 0) {
        return NO;
    }
    
    NSArray *pKeys = [self primaryKeys];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.vls];
    [dic removeObjectsForKeys:pKeys];
    
    BOOL result = [[self manager] model:self updateDatas:dic forPredicate:predicate];
    if (!result) {
        return NO;
    }
    
    //插入成功，必须保存meta
    if (self.meta) {//存在meta，需要，更新信息
        [SSNMeta loadMeta:self.meta datas:self.vls];
        self.opt = self.meta.opt;
    }
    else {//不存在
        self.meta = SSNMetaFactory([self class], predicate);
        [SSNMeta loadMeta:self.meta datas:self.vls];
        self.opt = self.meta.opt;
    }
    self.hasChanged = NO;
    
    return result;
}

- (BOOL)deleteFromStore {
    NSAssert([self manager], @"请设置%@对象管理器，设置方法调用+setManager:方法",[self class]);
    
    if ([self isTemporary]) {
        return NO;
    }
    
    NSString *predicate = [self keyPredicate];
    if ([predicate length] == 0) {
        return NO;
    }
    
    BOOL result = [[self manager] model:self deleteForPredicate:predicate];
    if (!result) {
        return NO;
    }
    
    //插入成功，必须保存meta
    if (self.meta) {//存在meta，需要，更新信息
        [SSNMeta deleteMeta:self.meta];
        self.opt = self.meta.opt;
    }
    else {//不存在
        self.meta = SSNMetaFactory([self class], predicate);
        [SSNMeta deleteMeta:self.meta];
        self.opt = self.meta.opt;
    }
    
    return YES;
}

#pragma mark SSNModel协议实现 (派生类 get set方法实现)
//取值方法，int,bool,float等基本类型采用NSNumber方式使用
- (id)getObjectValueForKey:(NSString *)key {//核心方法
    NSAssert([key length], @"不能传入没有意义key");
    
    id v = [self.vls valueForKey:key];
    
    //取到数据直接返回
    if (v) {
        return v;
    }
    
    //临时数据
    if (!self.meta) {
        return v;
    }
    
    //非临时数据，看元数据是否加载
    if (![self.meta isFault]) {//已经加载
        [self.vls setDictionary:self.meta.vls];
        return [self.vls valueForKey:key];
    }
    
    //还未加载,则加载数据
    id <SSNModelManagerProtocol> theManager = [self manager];
    if (theManager) {
        NSDictionary *datas = [theManager model:self loadDatasWithPredicate:[self keyPredicate]];
        if (datas) {
            [SSNMeta loadMeta:self.meta datas:datas];
            [self.vls setDictionary:datas];
            v = [self.vls valueForKey:key];
        }
    }
    
    return v;
}

- (void)setObjectValue:(id)value forKey:(NSString *)key {//核心方法
    
    NSAssert([key length], @"不能传入没有意义key");
    
    //临时数据，直接设置
    if (!self.meta) {
        [self.vls setValue:value forKey:key];
        self.hasChanged = YES;
        return ;
    }
    
    //非临时数据，先加载值
    id v = [self getObjectValueForKey:key];
    if (!v || [v isKindOfClass:[NSNull class]]) {//数据库中还没有对应字段
        [self.vls setValue:value forKey:key];
        self.hasChanged = YES;
        return ;
    }
    
    //判断是否相等，如果相等，就不要再设置了
    BOOL isEqual = [value isEqual:v];
    if (isEqual) {
        return ;
    }
    
    //是否为主键，如果是主键，直接抛出异常
    if ([[self class] modelContainedThePrimaryKey:key]) {
        [NSException raise: SSNModelException
                    format: @"%@对象主键%@是不可更改的",self,key];
        return ;
    }
    
    //不是主键，且不相等，覆盖
    [self.vls setValue:value forKey:key];
    self.hasChanged = YES;
}

//- (id)objectForKeyedSubscript:(id)key {
//    return [self getObjectValueForKey:key];
//}
//- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
//    [self setObjectValue:obj forKey:key];
//}

+ (NSMutableDictionary *)modelsValuesKeys {
    static NSMutableDictionary *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[NSMutableDictionary alloc] init];
    });
    return share;
}

#ifndef SSN_USER_DETACHED_MODEL_MANAGER
+ (void)setManager:(id<SSNModelManagerProtocol>)manager {
    NSDictionary *dic = [self modelsValuesKeys];
    NSString *cls = [NSString stringWithUTF8Format:"%p",self];
    SSNModelKeys *keysObj = [dic objectForKey:cls];
    keysObj.manager = manager;
}

+ (id <SSNModelManagerProtocol>)manager {
    NSDictionary *dic = [self modelsValuesKeys];
    NSString *cls = [NSString stringWithUTF8Format:"%p",self];
    SSNModelKeys *keysObj = [dic objectForKey:cls];
    return keysObj.manager;
}
#endif

- (id <SSNModelManagerProtocol>)manager {
#ifndef SSN_USER_DETACHED_MODEL_MANAGER
    return [[self class] manager];
#else
    return _manager;
#endif
}


+ (NSArray *)primaryKeys {
    
    NSAssert([self class] != [SSNModel class], @"必须实现派生Model后此方法才有意义");
    
    NSDictionary *dic = [self modelsValuesKeys];
    NSString *cls = [NSString stringWithUTF8Format:"%p",self];
    SSNModelKeys *keysObj = [dic objectForKey:cls];
    return keysObj.primaryKeys;
}

+ (NSArray *)valuesKeys {
    
    NSAssert([self class] != [SSNModel class], @"必须实现派生Model后此方法才有意义");
    
    NSDictionary *dic = [self modelsValuesKeys];
    NSString *cls = [NSString stringWithUTF8Format:"%p",self];
    SSNModelKeys *keysObj = [dic objectForKey:cls];
    return keysObj.valuesKeys;
}

- (NSArray *)primaryKeys {
    return [[self class] primaryKeys];
}

- (NSArray *)valuesKeys {
    return [[self class] valuesKeys];
}

+ (NSString *)valueTypeForKey:(NSString *)valueKey {
    if ([valueKey length] == 0) {
        return @"v";
    }
    
    NSAssert([self class] != [SSNModel class], @"必须实现派生Model后此方法才有意义");
    
    NSDictionary *dic = [self modelsValuesKeys];
    NSString *cls = [NSString stringWithUTF8Format:"%p",self];
    SSNModelKeys *keysObj = [dic objectForKey:cls];
    
    NSInteger index = [keysObj.valuesKeys indexOfObject:valueKey];
    
    if (index < [keysObj.valuesTypes count]) {
        return [keysObj.valuesTypes objectAtIndex:index];
    }
    
    return @"v";
}

- (NSString *)valueTypeForKey:(NSString *)valueKey {
    return [[self class] valueTypeForKey:valueKey];
}

//设置表字段，或者说是实体属性字段
+ (void)setKeys:(NSArray *)keys primaryKeys:(NSArray *)pkeys {
    NSMutableDictionary *dic = [self modelsValuesKeys];
    NSString *cls = [NSString stringWithUTF8Format:"%p",self];
    
    SSNModelKeys *keysObj = [dic objectForKey:cls];
    
    if (!keysObj) {//实例还不存在，创建一个，并保存起来
        keysObj = [[SSNModelKeys alloc] init];
        [dic setObject:keysObj forKey:cls];
    }
    
    //产生副本，防止外界改动
    keysObj.valuesKeys = [keys copy];
    keysObj.primaryKeys = [pkeys copy];
}

//当前model是否包此主key
+ (BOOL)modelContainedThePrimaryKey:(NSString *)key {
    NSMutableDictionary *dic = [self modelsValuesKeys];
    NSString *cls = [NSString stringWithUTF8Format:"%p",self];
    SSNModelKeys *keys = [dic objectForKey:cls];
    return [keys.primaryKeys containsObject:key];
}

//当前model是否包此key
+ (BOOL)modelContainedTheKey:(NSString *)key {
    NSMutableDictionary *dic = [self modelsValuesKeys];
    NSString *cls = [NSString stringWithUTF8Format:"%p",self];
    SSNModelKeys *keys = [dic objectForKey:cls];
    return [keys.valuesKeys containsObject:key];
}

+ (void)initialize {
    
    //其他类型不关心
    if ([self superclass] != [SSNModel class]) {
        return ;
    }
    
    Class selfClass = [self class];
    
    //开始加载get和set方法
    u_int count = 0;
    Method *methods= class_copyMethodList(selfClass, &count);
    
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *pkeys = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (int i = 0; i < count ; i++)
    {
        SEL name = method_getName(methods[i]);
        
        const char *method_name = sel_getName(name);
        size_t method_length = strlen(method_name);
        
        //长度不符合的直接排除
        if (method_length <= ssn_method_header_length) {
            continue ;
        }
        
        //并不是设置属性方法的排除
        if (strncmp(method_name, ssn_method_header, ssn_method_header_length - 3) != 0) {
            continue ;
        }
        
        @autoreleasepool {
            
            char valueType = method_name[ssn_method_type_location];
            char keyType = method_name[ssn_method_key_location];
            
            NSString *strName = [NSString  stringWithCString:method_name encoding:NSUTF8StringEncoding];
            
            //取到的名字均为 ssn_model_set_obj_n_Test: 只需要 “Test” 段就可以
            NSRange range = NSMakeRange(ssn_method_header_length, method_length - ssn_method_header_length);
            NSString *new_method_name = [strName substringWithRange:range];
            
            //将首字母
            new_method_name = [new_method_name capitalizedString];
            new_method_name = [NSString stringWithFormat:@"set%@",new_method_name];
            SEL new_method = sel_registerName([new_method_name UTF8String]);
            
            //方法实现
            IMP method_imp = class_getMethodImplementation(selfClass, name);
            
            //取方法类型描述
            const char *method_types = "v@:@";
            if (valueType == ssn_method_int_flag) {
                method_types = "v@:i";
            }
            else if (valueType == ssn_method_float_flag) {
                method_types = "v@:f";
            }
            else if (valueType == ssn_method_obj_flag) {
                method_types = "v@:@";
            }
            
            //替换方法
            class_replaceMethod(selfClass, new_method, method_imp, method_types);
            
            range.length = range.length - 1;//后面有个“:”
            NSString *keyName = [strName substringWithRange:range];
            if (keyType == ssn_method_pri_key) {
                [pkeys addObject:keyName];
            }
            else if (keyType == ssn_method_nor_key) {
            }
            
            [keys addObject:keyName];
            
            printf("%s\t%s\n",[new_method_name UTF8String],[keyName UTF8String]);
        }
    }
    
    //将键值初始化号
    [self setKeys:keys primaryKeys:pkeys];
    
    if (methods) {
        free(methods);
    }
}


#pragma mark 重载掉KVC方法
//重载KVC方法
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([self class] != [SSNModel class] && [[self class] modelContainedTheKey:key]) {
        [(id<SSNModel>)self setObjectValue:value forKey:key];
    }
    else {
        [super setValue:value forKeyPath:key];
    }
}

- (id)valueForKey:(NSString *)key {
    if ([self class] != [SSNModel class] && [[self class] modelContainedTheKey:key]) {
        return [(id<SSNModel>)self getObjectValueForKey:key];
    }
    else {
        return [super valueForKey:key];
    }
}

#pragma mark 校验方法重载
- (BOOL)isEqual:(SSNModel *)other {
    
    if ([other isKindOfClass:[SSNModel class]]) {
        return NO;
    }
    
    if (self.meta && self.meta == other.meta) {
        return YES;
    }
    
    return [self.keyPredicate isEqualToString:other.keyPredicate];
}

- (NSUInteger)hash {
    return [self.keyPredicate hash];
}

#pragma mark 支持拷贝
- (SSNModel *)copyWithZone:(NSZone *)zone {
    SSNModel *cp = [[[self class] alloc] init];
    cp.meta = self.meta;
    [cp.vls setDictionary:self.vls];
    cp.keyPredicate = self.keyPredicate;
    cp.opt = self.opt;
    return cp;
}

#pragma mark API实现
- (void)refreshModel {
    if ([self needUpdate]) {
        [self.vls removeAllObjects];
        self.opt = self.meta.opt;
    }
}

#pragma - mark 工程方法实现
#ifndef SSN_USER_DETACHED_MODEL_MANAGER
+ (instancetype)modelWithKeyPredicate:(NSString *)keyPredicate {
    NSAssert([self manager], @"请设置%@对象管理器，设置方法调用+setManager:方法",[self class]);
    
    //简单校验keyPredicate
    BOOL notKey = NO;
    for (NSString *key in [self primaryKeys]) {
        if ([keyPredicate rangeOfString:key].length == 0) {
            notKey = YES;
            break ;
        }
    }
    
    if (notKey) {
        return nil;
    }
    
    SSNModel *m = [[[self class] alloc] init];
    m.keyPredicate = keyPredicate;
    m.meta = SSNMetaFactory([self class], keyPredicate);
    
    return m;
}

+ (instancetype)modelWithValues:(NSArray *)values keys:(NSArray *)keys {
    NSAssert([self manager], @"请设置%@对象管理器，设置方法调用+setManager:方法",[self class]);
    
    //简单校验keyPredicate
    NSSet *kset = [NSSet setWithArray:keys];
    NSSet *pset = [NSSet setWithArray:[self primaryKeys]];
    
    if (![pset isSubsetOfSet:kset]) {
        return nil;
    }

    NSString *keyPredicate = [NSString predicateValues:values keys:keys];
    
    SSNModel *m = [[[self class] alloc] init];
    m.keyPredicate = keyPredicate;
    m.meta = SSNMetaFactory([self class], keyPredicate);
    
    return m;
}

+ (instancetype)modelWithKeyAndValues:(NSDictionary *)keyValues {
    NSAssert([self manager], @"请设置%@对象管理器，设置方法调用+setManager:方法",[self class]);
    
    //简单校验keyPredicate
    NSSet *kset = [NSSet setWithArray:[keyValues allKeys]];
    NSSet *pset = [NSSet setWithArray:[self primaryKeys]];
    
    if (![pset isSubsetOfSet:kset]) {
        return nil;
    }
    
    NSString *keyPredicate = [NSString predicateKeyAndValues:keyValues];
    
    SSNModel *m = [[[self class] alloc] init];
    m.keyPredicate = keyPredicate;
    m.meta = SSNMetaFactory([self class], keyPredicate);
    
    return m;
}
#else
+ (instancetype)modelWithKeyPredicate:(NSString *)keyPredicate manager:(id <SSNModelManagerProtocol>)manager {
    NSAssert(manager, @"请设置%@对象管理器",[self class]);
    
    //简单校验keyPredicate
    BOOL notKey = NO;
    for (NSString *key in [self primaryKeys]) {
        if ([keyPredicate rangeOfString:key].length == 0) {
            notKey = YES;
            break ;
        }
    }
    
    if (notKey) {
        return nil;
    }
    
    SSNModel *m = [[[self class] alloc] init];
    m.manager = manager;
    m.keyPredicate = keyPredicate;
    m.meta = SSNMetaFactory([self class], keyPredicate);
    
    return m;
}
+ (instancetype)modelWithValues:(NSArray *)values keys:(NSArray *)keys manager:(id <SSNModelManagerProtocol>)manager {
    NSAssert(manager, @"请设置%@对象管理器",[self class]);
    
    //简单校验keyPredicate
    NSSet *kset = [NSSet setWithArray:keys];
    NSSet *pset = [NSSet setWithArray:[self primaryKeys]];
    
    if (![pset isSubsetOfSet:kset]) {
        return nil;
    }
    
    NSString *keyPredicate = [NSString predicateValues:values keys:keys];
    
    SSNModel *m = [[[self class] alloc] init];
    m.manager = manager;
    m.keyPredicate = keyPredicate;
    m.meta = SSNMetaFactory([self class], keyPredicate);
    
    return m;

}
+ (instancetype)modelWithKeyAndValues:(NSDictionary *)keyValues manager:(id <SSNModelManagerProtocol>)manager {
    NSAssert(manager, @"请设置%@对象管理器",[self class]);
    
    //简单校验keyPredicate
    NSSet *kset = [NSSet setWithArray:[keyValues allKeys]];
    NSSet *pset = [NSSet setWithArray:[self primaryKeys]];
    
    if (![pset isSubsetOfSet:kset]) {
        return nil;
    }
    
    NSString *keyPredicate = [NSString predicateKeyAndValues:keyValues];
    
    SSNModel *m = [[[self class] alloc] init];
    m.manager = manager;
    m.keyPredicate = keyPredicate;
    m.meta = SSNMetaFactory([self class], keyPredicate);
    
    return m;
}
#endif

#pragma mark debug description;
- (NSString *)description {
    NSMutableString *str = [NSMutableString stringWithFormat:@"<%@:%p ",NSStringFromClass([self class]),self];
    
    [str appendFormat:@"keyPredicate = \"%@\", ",[self keyPredicate]];
    
    [str appendFormat:@"isTemporary = %d, ",[self isTemporary]];
    
    [str appendFormat:@"isFault = %d, ",[self isFault]];
    
    [str appendFormat:@"hasChanged = %d, \n",[self hasChanged]];
    
    for (NSString *key in [self valuesKeys]) {
        id value = [self.vls objectForKey:key];
        if (value) {
            [str appendFormat:@"\t%@ = %@,\n",key,value];
        }
        else {
            [str appendFormat:@"\t%@ = nil,\n",key];
        }
    }
    
    [str appendString:@">"];
    
    return str;
}

@end



@implementation SSNModelKeys

@synthesize primaryKeys = _primaryKeys;
@synthesize valuesKeys = _valuesKeys;
@synthesize valuesTypes = _valuesTypes;

#ifndef SSN_USER_DETACHED_MODEL_MANAGER
@synthesize manager = _manager;
#endif

@end



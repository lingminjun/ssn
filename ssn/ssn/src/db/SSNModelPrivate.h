//
//  SSNModelPrivate.h
//  ssn
//
//  Created by lingminjun on 14-5-31.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

@class SSNMeta;

#pragma mark 私有方法属性声明
@interface SSNModel () <SSNModel>
{
    SSNMeta * _meta;            //源数据
    NSMutableDictionary * _vls; //数据存储,对应数据表（关系存储keyPredicate字段）
    NSString *_keyPredicate;    //对象主键
    
#ifdef SSN_USER_DETACHED_MODEL_MANAGER
    __weak id<SSNModelManagerProtocol> _manager;
#endif
    
    //操作数
    NSUInteger _opt;            //操作数
    
    //状态变量
    BOOL _hasChanged;
}

@property (nonatomic,strong) SSNMeta * meta;
@property (nonatomic,strong) NSMutableDictionary *vls;
@property (nonatomic,strong) NSMutableDictionary *rvls;
@property (nonatomic,strong) NSString *keyPredicate;

#ifdef SSN_USER_DETACHED_MODEL_MANAGER
@property (nonatomic,weak) id<SSNModelManagerProtocol> manager;
#endif

@property (nonatomic) NSUInteger opt;

@property (nonatomic) BOOL hasChanged;      //数据本身有提交与永久存储数据不同的值，临时数据永远返回NO

#ifndef SSN_USER_DETACHED_MODEL_MANAGER
+ (id <SSNModelManagerProtocol>)manager;
#endif

+ (void)setKeys:(NSArray *)keys primaryKeys:(NSArray *)pkeys;

//当前model是否包此主key
+ (BOOL)modelContainedThePrimaryKey:(NSString *)key;

//当前model是否包此key
+ (BOOL)modelContainedTheKey:(NSString *)key;

@end

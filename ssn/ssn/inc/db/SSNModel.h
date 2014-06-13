//
//  SSNModel.h
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ssnmodelimp.h"


@protocol SSNModelManagerProtocol;  //数据加载协议

/*
 实体中能承载的属性类型主要是sqlite能装载的数据，如int(bool),float,data,string，其他对象请不要设置为表字段
 
 请参考sqlite中的定义
 #define SQLITE_INTEGER  1
 #define SQLITE_FLOAT    2
 #define SQLITE_BLOB     4
 #define SQLITE_NULL     5
 #ifdef SQLITE_TEXT
 */

@interface SSNModel : NSObject <NSCopying>

//设置表字段，或者说是实体属性字段，key要求字母开头，可以包含字母，下划线，和数字
+ (NSArray *)primaryKeys;               //数据主键
+ (NSArray *)valuesKeys;                //对应永久存储的所有字段，包含primaryKeys
- (NSArray *)primaryKeys;               //数据主键
- (NSArray *)valuesKeys;                //对应永久存储的所有字段，包含primaryKeys

+ (NSString *)valueTypeForKey:(NSString *)valueKey;//返回{"@","i","f","v"},分别表示，oc对象，int，和float，void(未知)
- (NSString *)valueTypeForKey:(NSString *)valueKey;//返回{"@","i","f","v"},分别表示，oc对象，int，和float，void(未知)

- (NSString *)keyPredicate;             //数据存储主键组合，如：@"gid = '101' AND uid = '231890'"


- (BOOL)isTemporary;     //返回YES，表明数据没有关联到永久存储上，反之已然。

- (BOOL)isFault;         //返回YES，表明数据还未加载，只有主键数据，反之。临时数据返回值没有意义，请不要关注。

@property (nonatomic,readonly) BOOL hasChanged;      //数据本身有提交与永久存储数据不同的值，临时数据永远返回NO

- (BOOL)needUpdate;      //返回YES，数据已经加载，但是对应的永久存储数据已经发生改变，反之。

- (BOOL)isDeleted;      //被删除了

- (void)refreshModel;//needUpdate为yes时，此方法才能刷新对象数据，否则忽略

- (id <SSNModelManagerProtocol>)manager;//对象管理器

#ifndef SSN_USER_DETACHED_MODEL_MANAGER //自行管理
//给当前实例设置加载源，根据不同model类型进行区分
+ (void)setManager:(id <SSNModelManagerProtocol>)manager;

/*工程方法*/
//只有注册maneger 后，下面方法才有效
+ (instancetype)modelWithKeyPredicate:(NSString *)keyPredicate;//内部会校验其 keyPredicate的合法性
+ (instancetype)modelWithValues:(NSArray *)values keys:(NSArray *)keys;
+ (instancetype)modelWithKeyAndValues:(NSDictionary *)keyValues;

/*io方法*/
//db 操作
- (BOOL)insertToStore;//delete的数据将调用model:updateDatas:forPredicate:方法执行
- (BOOL)updateToStore;//非临时数据且非删除数据，并且有更改将会调用model:insertDatas:forPredicate:方法执行
- (BOOL)deleteFromStore;//非临时数据，或者非已经删除数据，都会调用model:deleteForPredicate:方法执行

#else

/*工程方法, manager不能为空*/
+ (instancetype)modelWithKeyPredicate:(NSString *)keyPredicate manager:(id <SSNModelManagerProtocol>)manager;//内部会校验其 keyPredicate的合法性
+ (instancetype)modelWithValues:(NSArray *)values keys:(NSArray *)keys manager:(id <SSNModelManagerProtocol>)manager;
+ (instancetype)modelWithKeyAndValues:(NSDictionary *)keyValues manager:(id <SSNModelManagerProtocol>)manager;

#endif

@end




@protocol SSNModel <NSObject>

//取值方法，int,bool,float等基本类型采用NSNumber方式使用
- (id)getObjectValueForKey:(NSString *)key;
- (void)setObjectValue:(id)value forKey:(NSString *)key;

////采用快速取值
//- (id)objectForKeyedSubscript:(NSString *)key;
//- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;

@end






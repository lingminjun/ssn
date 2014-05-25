//
//  SSNDataBase.h
//  ssn
//
//  Created by lingminjun on 13-12-14.
//  Copyright (c) 2013年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@protocol SSNModelTableProtocol;

/*
 SSNDataBase 仅仅提供 两种DDL方法（-createTable:withDelegate:；-dropTable:），以满足绝大部分业务需要，
 其他sql的方法（-queryObjects:executeSql:；-executeTransaction:）仅仅支持DML操作。
 */
@interface SSNDataBase : NSObject

@property(nonatomic,copy) NSString *pathToDataBase;
@property(nonatomic,readonly) NSUInteger currentVersion;//数据库版本，没有初始化前currentVersion

//如果传入的version小于当前的数据库版本，传入值将被忽略
- (id)initWithPath:(NSString *)filePath version:(NSUInteger)version;

//创建表，内部做单步数据表迁移（如果发现历史版本）
- (void)createTable:(NSString *)tableName withDelegate:(id <SSNModelTableProtocol>)delegate;
- (void)dropTable:(NSString *)tableName;//如果需要删除表，请调用此方法删除
- (void)executeDDLSql:(NSString *)sql;//此方法主要执行一些框架无法满足的DDL操作，如实现联合索引和唯一索引等

- (BOOL)isOpen;
- (void)open;
- (void)close;


#pragma sql method
//aclass传入NULL时默认用NSDictionary代替，当执行单纯的sql时，忽略aclass，返回值将为nil,为了防止sql注入，请输入参数
- (NSArray *)queryObjects:(Class)aclass sql:(NSString *)sql, ...;//参数必须传入object对象,无法执行DDL操作，仅仅支持DML操作,请以nil结尾
- (void)queryObjects:(Class)aclass completion:(void (^)(NSArray *results))completion sql:(NSString *)sql, ...;
- (NSArray *)queryObjects:(Class)aclass sql:(NSString *)sql arguments:(NSArray *)arguments;//参数必须传入object对象,无法执行DDL操作，仅仅支持DML操作,请以nil结尾
- (void)queryObjects:(Class)aclass completion:(void (^)(NSArray *results))completion sql:(NSString *)sql arguments:(NSArray *)arguments;

#pragma Transaction method
//执行事务，在arc中请注意传入strong参数，确保操作完成，防止循环引用
- (void)executeSync:(BOOL)sync inTransaction:(void (^)(SSNDataBase *dataBase, BOOL *rollback))block;

#pragma Other API
- (NSArray *)columnsForTableName:(NSString *)tableName;
- (NSArray *)tableNames;

@end


#ifndef _SSNModelPropertDescription_
#define _SSNModelPropertDescription_

typedef enum {//属性描述
    SSNModelPropertNormalKey     = 0,         //一般属性(可为空)
    SSNModelPropertNotNullKey    = 1,         //一般属性(不允许为空)
    SSNModelPropertPrimaryKey    = 2,         //主键（不允许为空）,多个时默认形成联合组件
} SSNModelPropertKeyType;

typedef enum {
    SSNModelPropertNotIndex      = 0,        //不需要索引
    SSNModelPropertNormalIndex   = 1,        //索引（不允许为空）
    SSNModelPropertUniqueIndex   = 2,        //唯一索引（不允许为空）
} SSNModelPropertIndexType;

typedef enum {//属性类型
    SSNModelPropertInteger   =   SQLITE_INTEGER,
    SSNModelPropertFloat     =   SQLITE_FLOAT,
    SSNModelPropertBool      =   SQLITE_INTEGER,
    SSNModelPropertBlob      =   SQLITE_BLOB,
    SSNModelPropertText      =   SQLITE_TEXT,
    SSNModelPropertNull      =   SQLITE_NULL,
} SSNModelPropertType;


#endif

@class SSNTableColumnInfo;

@protocol SSNModelTableProtocol <NSObject>

@optional//模板表名字，默认就是数据表名字，dataBase:columnsForTemplateName:
- (NSString *)dataBase:(SSNDataBase *)database tableTemplateName:(NSString *)tableName;

@required//历史版本的version最好是不要删除，因为database自身一但没有找到历史版本记录，就会询问代码实现,返回SSNTableColumnInfo数据，某个版本返回nil，表示没有更新
- (NSArray *)dataBase:(SSNDataBase *)database columnsForTemplateName:(NSString *)templateName databaseVersion:(NSUInteger)version;

@end

//表数据
@interface SSNTableColumnInfo : NSObject

@property (nonatomic,copy,readonly) NSString *column;
@property (nonatomic,copy,readonly) NSString *defaultValue;
@property (nonatomic,copy,readonly) NSString *mappingFormatter;//数据迁移时用，如(prevTableColumnName + 1)
@property (nonatomic,readonly) SSNModelPropertType type;
@property (nonatomic,readonly) SSNModelPropertKeyType keyType;
@property (nonatomic,readonly) SSNModelPropertIndexType indexType;

+ (instancetype)columnWithName:(NSString *)column
                          type:(SSNModelPropertType)type
                       keyType:(SSNModelPropertKeyType)keyType
                     indexType:(SSNModelPropertIndexType)indexType
                       default:(NSString *)defaultValue
                       mapping:(NSString *)mappingFormatter;

@end


//
//  SSNDBTable.h
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const SSNDBTableWillMigrateNotification; //数据准备迁移 mainThread
FOUNDATION_EXTERN NSString *const SSNDBTableDidMigrateNotification;  //数据迁移结束 mainThread
FOUNDATION_EXTERN NSString *const SSNDBTableDidDropNotification;     //数据表删除 mainThread
FOUNDATION_EXTERN NSString *const SSNDBTableUpdatedNotification;     //数据表更新 mainThread
FOUNDATION_EXTERN NSString *const SSNDBTableNameUserInfoKey;         //数据迁移表格

#ifndef _SSNDBTable_
#define _SSNDBTable_

typedef enum : NSUInteger
{
    SSNDBTableNone,   //表示数据表还不存在
    SSNDBTableUpdate, //表示数据表待更新
    SSNDBTableOK,     //数据表 已经 可以操作
} SSNDBTableStatus;

#endif

@class SSNDB, SSNDBColumn;

@interface SSNDBTable : NSObject

@property (nonatomic, strong, readonly) SSNDBTable *meta; //模板
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) SSNDB *db; //依赖的数据库
@property (nonatomic, readonly) NSUInteger currentVersion;

/*
 JSON方式 实现table 版本管理
 json文件定义:与数据SSNDBColumn对应
 {
 "tb":"Person",
 "its":[{
            "vs":1,
            "cl":[  {"name":"uid",  "type":1,   "level":2,  "fill":"",  "index":1,  "mapping":""},
                    {"name":"name", "type":3,   "level":0,  "fill":"",  "index":0,  "mapping":""},
                    {"name":"age",  "type":1,   "level":0,  "fill":"",  "index":0,  "mapping":""}
                ]
        },
        {
            "vs":2,
            "cl":[  {"name":"uid",  "type":1,   "level":2,  "fill":"",  "index":1,  "mapping":""},
                    {"name":"name", "type":3,   "level":0,  "fill":"",  "index":0,  "mapping":""},
                    {"name":"age",  "type":1,   "level":0,  "fill":"",  "index":0,  "mapping":""},
                    {"name":"sex",  "type":1,   "level":0,  "fill":"",  "index":0,  "mapping":""}
                ]
        }]
 }
 */
- (instancetype)initWithDB:(SSNDB *)db tableJSONDescriptionFilePath:(NSString *)path;
+ (instancetype)tableWithDB:(SSNDB *)db tableJSONDescriptionFilePath:(NSString *)path;

//创建模板表
- (instancetype)initWithTemplateTableJSONDescriptionFilePath:(NSString *)path;
+ (instancetype)tableWithTemplateTableJSONDescriptionFilePath:(NSString *)path;

- (instancetype)initWithName:(NSString *)name meta:(SSNDBTable *)meta db:(SSNDB *)db; //分表名不能与主表名重复
+ (instancetype)tableWithName:(NSString *)name meta:(SSNDBTable *)meta db:(SSNDB *)db; //分表名不能与主表名重复

- (SSNDBTableStatus)status; //表状态，非常重要的接口

// table的状体
- (void)update; //创建数据表并升级到最新，使用者需要操作某个数据表时，一定要保证此方法已经被执行，此方法不放在初始化中调用主要用于多表集中迁移思路

- (void)drop; //删除数据表

//最终表的主键和所有列
- (NSArray *)columnNames;
- (NSArray *)primaryColumnNames;

//接管db操作
- (void)insertObject:(id)object;
- (void)insertObjects:(NSArray *)objects;
- (void)insertObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction;//是否在事务中，方便多个DDL方法组装

- (void)updateObject:(id)object;
- (void)updateObjects:(NSArray *)objects;
- (void)updateObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction;//是否在事务中，方便多个DDL方法组装

- (void)deleteObject:(id)object;
- (void)deleteObjects:(NSArray *)objects;
- (void)deleteObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction;//是否在事务中，方便多个DDL方法组装

- (void)upinsertObject:(id)object;          // update or insert
- (void)upinsertObjects:(NSArray *)objects; // update or insert
- (void)upinsertObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction;//是否在事务中，方便多个DDL方法组装

- (void)upinsertObject:(id)object fields:(NSArray *)fields;          // update(指定字段) or insert，如果fields传入nil将等价与upinsertObject:
- (void)upinsertObjects:(NSArray *)objects fields:(NSArray *)fields; // update(指定字段) or insert，如果fields传入nil将等价与upinsertObjects:
- (void)upinsertObjects:(NSArray *)objects fields:(NSArray *)fields inTransaction:(BOOL)inTransaction;//是否在事务中，方便多个DDL方法组装

- (void)inreplaceObject:(id)object;          // insert or replace
- (void)inreplaceObjects:(NSArray *)objects; // insert or replace
- (void)inreplaceObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction;//是否在事务中，方便多个DDL方法组装

- (NSArray *)objectsWithClass:(Class)clazz forPredicate:(NSPredicate *)predicate;//查询支持
- (NSArray *)objectsWithClass:(Class)clazz forConditions:(NSDictionary *)conditions;//查询支持

- (void)truncate;//清空表，请务必调用此方法，否则hook失效，并非sql语句“truncate table xxx”，实际执行delete语句，所以可以与其他方法一起在事务中使用

@end

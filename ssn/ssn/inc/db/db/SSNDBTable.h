//
//  SSNDBTable.h
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *SSNDBTableWillMigrateNotification; //数据准备迁移 mainThread
FOUNDATION_EXTERN NSString *SSNDBTableDidMigrateNotification;  //数据迁移结束 mainThread
FOUNDATION_EXTERN NSString *SSNDBTableDidDropNotification;     //数据表删除 mainThread
FOUNDATION_EXTERN NSString *SSNDBTableNameKey;                 //数据迁移表格

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
- (void)update; //创建数据表并升级到最新，使用者需要操作某个数据表时，一定要保证此方法已经被执行

- (void)drop; //删除数据表

//最终表的主键和所有列
- (NSArray *)currentColums;
- (NSArray *)currentPrimaryColums;

//接管db操作
- (void)insertObject:(id)object;
- (void)insertObjects:(NSArray *)objects;

- (void)updateObject:(id)object;
- (void)updateObjects:(NSArray *)objects;

- (void)deleteObject:(id)object;
- (void)deleteObjects:(NSArray *)objects;

- (void)upinsertObject:(id)object;          // update or insert
- (void)upinsertObjects:(NSArray *)objects; // update or insert

@end

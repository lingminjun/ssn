//
//  SSNDBColumn.h
//  ssn
//
//  Created by lingminjun on 14-8-13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#ifndef _SSNDBColumn_
#define _SSNDBColumn_

typedef enum : NSUInteger
{
    SSNDBColumnInt = SQLITE_INTEGER,
    SSNDBColumnFloat = SQLITE_FLOAT,
    SSNDBColumnBool = SQLITE_INTEGER,
    SSNDBColumnBlob = SQLITE_BLOB,
    SSNDBColumnText = SQLITE_TEXT,
    SSNDBColumnNull = SQLITE_NULL,
} SSNDBColumnType;

typedef enum : NSUInteger
{                           //属性描述
    SSNDBColumnNormal = 0,  //一般属性(可为空)
    SSNDBColumnNotNull = 1, //一般属性(不允许为空)
    SSNDBColumnPrimary = 2, //主键（不允许为空）,多个时默认形成联合组件
} SSNDBColumnLevel;

typedef enum
{
    SSNDBColumnNotIndex = 0,    //不需要索引
    SSNDBColumnNormalIndex = 1, //索引（不允许为空）
    SSNDBColumnUniqueIndex = 2, //唯一索引（不允许为空）
} SSNDBColumnIndex;

#endif

@interface SSNDBColumn : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *fill;    //默认填充值，default value
@property (nonatomic, strong, readonly) NSString *mapping; //数据迁移时用，如(prevTableColumnName + 1)
@property (nonatomic, readonly) SSNDBColumnType type;
@property (nonatomic, readonly) SSNDBColumnLevel level;
@property (nonatomic, readonly) SSNDBColumnIndex index;

- (instancetype)initWithName:(NSString *)name
                        type:(SSNDBColumnType)type
                       level:(SSNDBColumnLevel)level
                       index:(SSNDBColumnIndex)index
                        fill:(NSString *)fill
                     mapping:(NSString *)mapping;

+ (instancetype)columnWithName:(NSString *)name
                          type:(SSNDBColumnType)type
                         level:(SSNDBColumnLevel)level
                         index:(SSNDBColumnIndex)index
                          fill:(NSString *)fill
                       mapping:(NSString *)mapping;

// sql 支持
- (NSString *)createTableSQLFragmentStringMutablePrimaryKeys:(BOOL)amutable; //单纯数据创建
- (NSString *)createIndexSQLStringWithTableName:(NSString *)tableName;

- (NSString *)mappingTableSQLFragmentStringOldExist:(BOOL)exist; //数据表迁移sql语句

+ (int)columnTypeToInt:(NSString *)columnType;
+ (NSString *)columnTypeToString:(NSInteger)columnType;
+ (NSString *)mutablePrimaryKeysWithColumns:(NSArray *)columns;

//创建数据库语句
+ (NSArray *)createSqlsForColumns:(NSArray *)columns forTable:(NSString *)tableName;

//需要升级，数据表字段有变化都需要升级，升级
+ (NSArray *)table:(NSString *)tableName mappingSqlsFromColumns:(NSArray *)fromCols toColumns:(NSArray *)toCols;

@end

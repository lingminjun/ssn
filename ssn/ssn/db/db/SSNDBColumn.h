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

/*
 #define SQLITE_INTEGER  1
 #define SQLITE_FLOAT    2
 #define SQLITE_BLOB     4
 #define SQLITE_NULL     5
 #ifdef SQLITE_TEXT
 # undef SQLITE_TEXT
 #else
 # define SQLITE_TEXT     3
 #endif
 #define SQLITE3_TEXT     3
 */
typedef NS_ENUM(NSUInteger, SSNDBColumnType) {
    SSNDBColumnInt = SQLITE_INTEGER,    //"Int"
    SSNDBColumnFloat = SQLITE_FLOAT,    //"Float"
    SSNDBColumnBool = SQLITE_INTEGER,   //"Bool"
    SSNDBColumnBlob = SQLITE_BLOB,      //"Blob"
    SSNDBColumnText = SQLITE_TEXT,      //"Text"
    SSNDBColumnNull = SQLITE_NULL,      //"Null"
};

typedef NS_ENUM(NSUInteger, SSNDBColumnLevel) {                           //属性描述
    SSNDBColumnNormal = 0,  //"" 一般属性(可为空)
    SSNDBColumnNotNull = 1, //"NotNull" 一般属性(不允许为空)
    SSNDBColumnPrimary = 2, //"Primary" 主键（不允许为空）,多个时默认形成联合组件
};

typedef NS_ENUM(NSUInteger, SSNDBColumnIndex) {
    SSNDBColumnNotIndex = 0,    //"" 不需要索引
    SSNDBColumnNormalIndex = 1, //"Index" 索引（不允许为空）
    SSNDBColumnUniqueIndex = 2, //"Unique" 唯一索引（不允许为空）
};
/*
{
    "tb":"Person",
    "its":[{
        "vs":1,
        "cl":[  {"name":"uid",    "type":"Int",   "level":"Primary",  "fill":"",  "index":"Index",   "mapping":""},
              {"name":"name",   "type":"Text",  "level":"NotNull",  "fill":"",  "index":"Unique",  "mapping":""},
              {"name":"sex",    "type":"Bool",  "level":"",         "fill":"",  "index":"",        "mapping":""},
              {"name":"height", "type":"Float", "level":"",         "fill":"",  "index":"",        "mapping":""},
              {"name":"avatar", "type":"Blob",  "level":"",         "fill":"",  "index":"",        "mapping":""},
              {"name":"other",  "type":"Null",  "level":"",         "fill":"",  "index":"",        "mapping":""}
              ]
    },
           {
               "vs":2,
               "cl":[  {"name":"uid",    "type":"Int",   "level":"Primary",  "fill":"",  "index":"Index",   "mapping":""},
                     {"name":"name",   "type":"Text",  "level":"NotNull",  "fill":"",  "index":"Unique",  "mapping":""},
                     {"name":"sex",    "type":"Bool",  "level":"",         "fill":"",  "index":"",        "mapping":""},
                     {"name":"height", "type":"Float", "level":"",         "fill":"",  "index":"",        "mapping":""},
                     {"name":"avatar", "type":"Blob",  "level":"",         "fill":"",  "index":"",        "mapping":""},
                     {"name":"mobile", "type":"Text",  "level":"",         "fill":"",  "index":"Index",   "mapping":""},
                     {"name":"other",  "type":"Null",  "level":"",         "fill":"",  "index":"",        "mapping":""}
                     ]
           }]
}
 */


#endif

@interface SSNDBColumn : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *fill;    //默认填充值，default value
@property (nonatomic, strong, readonly) NSString *mapping; //数据迁移时用，如(prevTable.ColumnName + 1)
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
+ (NSArray *)createTableSqlsWithColumns:(NSArray *)columns forTable:(NSString *)tableName;

//创建索引语句
+ (NSArray *)createIndexSqlsWithColumns:(NSArray *)columns forTable:(NSString *)tableName;

//需要升级，数据表字段有变化都需要升级，升级
+ (NSArray *)mappingTable:(NSString *)tableName fromColumns:(NSArray *)fcls toColumns:(NSArray *)tcls last:(BOOL)last;

@end

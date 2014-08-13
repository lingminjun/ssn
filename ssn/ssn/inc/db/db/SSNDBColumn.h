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
    SSNColumnInt = SQLITE_INTEGER,
    SSNColumnFloat = SQLITE_FLOAT,
    SSNColumnBool = SQLITE_INTEGER,
    SSNColumnBlob = SQLITE_BLOB,
    SSNColumnText = SQLITE_TEXT,
    SSNColumnNull = SQLITE_NULL,
} SSNColumnType;

typedef enum : NSUInteger
{                         //属性描述
    SSNColumnNormal = 0,  //一般属性(可为空)
    SSNColumnNotNull = 1, //一般属性(不允许为空)
    SSNColumnPrimary = 2, //主键（不允许为空）,多个时默认形成联合组件
} SSNColumnStyle;

typedef enum
{
    SSNColumnNotIndex = 0,    //不需要索引
    SSNColumnNormalIndex = 1, //索引（不允许为空）
    SSNColumnUniqueIndex = 2, //唯一索引（不允许为空）
} SSNColumnIndexStyle;

#endif

@interface SSNDBColumn : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *fill;    //默认填充值，default value
@property (nonatomic, strong, readonly) NSString *mapping; //数据迁移时用，如(prevTableColumnName + 1)
@property (nonatomic, readonly) SSNColumnType type;
@property (nonatomic, readonly) SSNColumnStyle style;
@property (nonatomic, readonly) SSNColumnIndexStyle index;

@end

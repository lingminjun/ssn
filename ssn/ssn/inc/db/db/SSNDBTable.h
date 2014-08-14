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
    SSNDBTableOK,
} SSNDBTableStatus;

#endif

@class SSNDB, SSNDBColumn;

@interface SSNDBTable : NSObject

@property (nonatomic, strong, readonly) SSNDBTable *meta; //模板
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) SSNDB *db; //依赖的数据库
@property (nonatomic, readonly) NSUInteger currentVersion;

- (NSArray *)columnsForVersion:(NSUInteger)version; //返回某个版本的数据

- (instancetype)initWithDB:(SSNDB *)db tableJSONDescription:(NSData *)tableJSONDescription;
+ (instancetype)tableWithDB:(SSNDB *)db tableJSONDescription:(NSData *)tableJSONDescription;

- (SSNDBTableStatus)status; //根据

// table的状体
- (void)update; //创建数据表并升级到最新，使用者需要操作某个数据表时，一定要保证此方法已经被执行

- (void)drop; //删除数据表

@end

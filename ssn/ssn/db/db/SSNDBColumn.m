//
//  SSNDBColumn.m
//  ssn
//
//  Created by lingminjun on 14-8-13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBColumn.h"
#import "NSString+SSN.h"

@interface SSNDBColumn ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fill;    //默认填充值，default value
@property (nonatomic, strong) NSString *mapping; //数据迁移时用，如(prevTableColumnName + 1)
@property (nonatomic) SSNDBColumnType type;
@property (nonatomic) SSNDBColumnLevel level;
@property (nonatomic) SSNDBColumnIndex index;

@end

@implementation SSNDBColumn

- (instancetype)initWithName:(NSString *)name
                        type:(SSNDBColumnType)type
                       level:(SSNDBColumnLevel)level
                       index:(SSNDBColumnIndex)index
                        fill:(NSString *)fill
                     mapping:(NSString *)mapping
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _type = type;
        _level = level;
        _index = index;
        _fill = [fill copy];
        _mapping = [mapping copy];
    }
    return self;
}

+ (instancetype)columnWithName:(NSString *)name
                          type:(SSNDBColumnType)type
                         level:(SSNDBColumnLevel)level
                         index:(SSNDBColumnIndex)index
                          fill:(NSString *)fill
                       mapping:(NSString *)mapping
{
    return [[[self class] alloc] initWithName:name type:type level:level index:index fill:fill mapping:mapping];
}

#pragma mark sql 语句 拼装
- (NSString *)fillString
{
    NSString *string = nil;
    switch (_type)
    {
    case SQLITE_TEXT:
        if (_fill)
        {
            string = [NSString stringWithUTF8Format:"'%s'", [_fill UTF8String]];
        }
        else
        {
            string = @"NULL";
        }
        break;
    case SQLITE_INTEGER:
    case SQLITE_FLOAT:
    case SQLITE_BLOB:
    case SQLITE_NULL:
    default:
        if ([_fill length] > 0)
        {
            string = _fill;
        }
        else
        {
            string = @"0";
        }
        break;
    }
    return string;
}

- (NSString *)createTableSQLFragmentStringMutablePrimaryKeys:(BOOL)amutable
{
    NSString *sql = [NSString
        stringWithUTF8Format:"%s %s %s DEFAULT %s", [_name UTF8String],
                             [[SSNDBColumn columnTypeToString:_type] UTF8String],
                             [[SSNDBColumn columnlevelToString:_level supportPrimaryKey:!amutable] UTF8String],
                             [[self fillString] UTF8String]];
    return sql;
}

- (NSString *)createIndexSQLStringWithTableName:(NSString *)tableName
{
    if (_index == SSNDBColumnNotIndex)
    {
        return @"";
    }

    NSString *sql =
        [NSString stringWithUTF8Format:"CREATE %s INDEX IF NOT EXISTS idx_%s_%s ON %s(%s)",
                                       ((_index == SSNDBColumnUniqueIndex) ? "UNIQUE" : ""), [tableName UTF8String],
                                       [_name UTF8String], [tableName UTF8String], [_name UTF8String]];
    return sql;
}

- (NSString *)mappingTableSQLFragmentStringOldExist:(BOOL)exist
{
    if ([_mapping length])
    { //需要迁移,直接as就好了
        return [NSString stringWithUTF8Format:"(%s) AS %s", [_mapping UTF8String], [_name UTF8String]];
    }
    else
    {
        if (exist)
        {
            return _name;
        }
        else
        {
            return [NSString stringWithUTF8Format:"%s AS %s", [[self fillString] UTF8String], [_name UTF8String]];
        }
    }
}

+ (int)columnTypeToInt:(NSString *)columnType
{
    if ([columnType isEqualToString:@"INTEGER"])
    {
        return SQLITE_INTEGER;
    }
    else if ([columnType isEqualToString:@"REAL"])
    {
        return SQLITE_FLOAT;
    }
    else if ([columnType isEqualToString:@"TEXT"])
    {
        return SQLITE_TEXT;
    }
    else if ([columnType isEqualToString:@"BLOB"])
    {
        return SQLITE_BLOB;
    }
    else if ([columnType isEqualToString:@"NULL"])
    {
        return SQLITE_NULL;
    }
    return SQLITE_TEXT;
}

+ (NSString *)columnTypeToString:(NSInteger)columnType
{
    NSString *string = nil;
    switch (columnType)
    {
    case SQLITE_INTEGER:
        string = @"INTEGER";
        break;
    case SQLITE_FLOAT:
        string = @"REAL";
        break;
    case SQLITE_TEXT:
        string = @"TEXT";
        break;
    case SQLITE_BLOB:
        string = @"BLOB";
        break;
    case SQLITE_NULL:
        string = @"NULL";
        break;
    default:
        string = @"TEXT";
        break;
    }
    return string;
}

+ (NSString *)columnlevelToString:(SSNDBColumnLevel)level supportPrimaryKey:(BOOL)support
{
    NSString *string = nil;
    switch (level)
    {
    case SSNDBColumnNormal:
        string = @"";
        break;
    case SSNDBColumnNotNull:
        string = @"NOT NULL";
        break;
    case SSNDBColumnPrimary:
        if (support)
        {
            string = @"NOT NULL PRIMARY KEY";
        }
        else
        {
            string = @"NOT NULL";
        }
        break;
    default:
        string = @"";
        break;
    }
    return string;
}

+ (NSString *)mutablePrimaryKeysWithColumns:(NSArray *)columns
{
    NSMutableString *keys = [NSMutableString stringWithCapacity:1];
    NSUInteger keyCount = 0;
    for (SSNDBColumn *column in columns)
    {
        if (column.level == SSNDBColumnPrimary)
        {
            if (keyCount > 0)
            {
                [keys appendString:@","];
            }

            [keys appendString:column.name];

            keyCount++;
        }
    }

    NSString *string = nil;
    if (keyCount > 1)
    {
        string = [NSString stringWithUTF8Format:"PRIMARY KEY(%s)", [keys UTF8String]];
    }
    else
    {
        string = @"";
    }
    return string;
}

#pragma -
#pragma mark 数据库升级 流程控制
- (BOOL)isEqualToColumnInfo:(SSNDBColumn *)col ignoreMapping:(BOOL)ignoreMapping
{
    if ([_name isEqualToString:col.name] &&
        (([_fill length] == 0 && [col.fill length] == 0) || [_fill isEqualToString:col.fill]) && _type == col.type &&
        _level == col.level && _index == col.index)
    {
        if (ignoreMapping)
        {
            return YES;
        }
        else
        {
            if (([_mapping length] == 0 && [col.mapping length] == 0) || [_mapping isEqualToString:col.mapping])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }
    return NO;
}

+ (NSArray *)createTableSqlsWithColumns:(NSArray *)columns forTable:(NSString *)tableName
{
    //直接创建数据表
    NSMutableString *sql = [[NSMutableString alloc] initWithCapacity:1];
    NSMutableArray *sqls = [NSMutableArray arrayWithObject:sql];

    [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ (", tableName];
    NSString *primaryKeys = [SSNDBColumn mutablePrimaryKeysWithColumns:columns];
    BOOL isMutable = NO;
    if ([primaryKeys length])
    {
        isMutable = YES;
    }

    BOOL isFirst = YES;
    for (SSNDBColumn *column in columns)
    {
        if (!isFirst)
        {
            [sql appendString:@","];
        }
        else
        {
            isFirst = NO;
        }
        [sql appendString:[column createTableSQLFragmentStringMutablePrimaryKeys:isMutable]];
    }

    //加上联合主键
    if (isMutable)
    {
        [sql appendFormat:@",%@", primaryKeys];
    }

    [sql appendString:@")"];

    return sqls;
}

+ (NSArray *)createIndexSqlsWithColumns:(NSArray *)columns forTable:(NSString *)tableName
{
    NSMutableArray *sqls = [NSMutableArray arrayWithCapacity:1];
    for (SSNDBColumn *column in columns)
    {
        //索引sql
        NSString *indexSql = [column createIndexSQLStringWithTableName:tableName];
        if ([indexSql length])
        {
            [sqls addObject:indexSql];
        }
    }
    return sqls;
}

//数据库升级控制
+ (NSArray *)mappingTable:(NSString *)tableName
              fromColumns:(NSArray *)fromCols
                toColumns:(NSArray *)toCols
                     last:(BOOL)last
{

    NSMutableDictionary *toDic = [NSMutableDictionary dictionaryWithCapacity:0]; //用于无序分析表样式，前后两张表如果
    NSMutableDictionary *mapDic = [NSMutableDictionary dictionaryWithCapacity:0]; //记录迁移值
    NSMutableArray *toColNames = [NSMutableArray arrayWithCapacity:0];            //记录所有建表字段

    NSMutableDictionary *fromDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableSet *fromSet = [NSMutableSet setWithCapacity:0];
    for (SSNDBColumn *col in toCols)
    {
        [toColNames addObject:col.name];

        [toDic setValue:col forKey:col.name];

        if ([col.mapping length])
        {
            [mapDic setValue:col forKey:col.mapping];
        }
    }

    for (SSNDBColumn *col in fromCols)
    {
        [fromSet addObject:col.name];
        [fromDic setValue:col forKey:col.name];
    }

    if ([fromCols count] == [toCols count])
    {

        BOOL colNotChange = YES;
        for (SSNDBColumn *col in fromCols)
        {
            SSNDBColumn *tcol = [toDic objectForKey:col.name];
            if ([tcol isEqualToColumnInfo:col ignoreMapping:YES])
            {
                colNotChange = NO;
                break;
            }
        }

        if (colNotChange)
        { //属性没有发生任何变化，此时只需要关注值的变化
            if ([mapDic count] == 0)
            { //说明连数据迁移项也没有，数据表不需要任何改变
                return [NSArray array];
            }
        }
    }

    NSMutableArray *sqls = [NSMutableArray arrayWithCapacity:4];

    // 1 改变原来表名字
    [sqls addObject:[NSString stringWithUTF8Format:"ALTER TABLE %s RENAME TO __temp__%s", [tableName UTF8String],
                                                   [tableName UTF8String]]];

    // 2 创建新的表
    NSArray *createSqls = [self createTableSqlsWithColumns:toCols forTable:tableName];
    [sqls addObjectsFromArray:createSqls];

    // 3 导入数据（create table as 虽然速度快，但是表字段定义类型模糊【无类型】，主键索引都无法描述）
    NSMutableString *insertInto = [NSMutableString stringWithCapacity:10];
    [sqls addObject:insertInto];
    [insertInto appendFormat:@"INSERT INTO %@ SELECT ", tableName];
    BOOL isFirst = YES;
    for (SSNDBColumn *col in toCols)
    {
        if (isFirst)
        {
            isFirst = NO;
        }
        else
        {
            [insertInto appendString:@", "];
        }
        BOOL exist = [fromSet containsObject:col.name];
        [insertInto appendString:[col mappingTableSQLFragmentStringOldExist:exist]];
    }
    [insertInto appendFormat:@" FROM __temp__%@", tableName];

    // 4 删除临时表
    [sqls addObject:[NSString stringWithUTF8Format:"DROP TABLE __temp__%s", [tableName UTF8String]]];

    // 5 重新创建索引(最后一次创建索引，索引创建消耗比较大)
    if (last)
    {
        NSArray *indexSqls = [self createIndexSqlsWithColumns:toCols forTable:tableName];
        [sqls addObjectsFromArray:indexSqls];
    }

    /*
     另外，如果遇到复杂的修改操作，比如在修改的同时，需要进行数据的转移，那么可以采取在一个事务中执行如下语句来实现修改表的需求。
     　　1. 将表名改为临时表
     ALTER TABLE Subscription RENAME TO __temp__Subscription;
     　　2. 创建新表
     CREATE TABLE Subscription (OrderId VARCHAR(32) PRIMARY KEY ,UserName VARCHAR(32) NOT NULL ,ProductId VARCHAR(16)
     NOT NULL);

     //CREATE TABLE lw_ext_friend AS SELECT userId,name,(iSSNTar+1)*3 AS starOne FROM lw_friend

     //CREATE TABLE lw_friend_ext AS SELECT userId,name,'' as dddd,0 as  tttt FROM lw_friend

     3. 导入数据
     INSERT INTO Subscription SELECT OrderId, “”, ProductId FROM __temp__Subscription;
     　　或者
     INSERT INTO Subscription() SELECT OrderId, “”, ProductId FROM __temp__Subscription;
     　　* 注意 双引号”” 是用来补充原来不存在的数据的

     4. 删除临时表
     DROP TABLE __temp__Subscription;

     　　通过以上四个步骤，就可以完成旧数据库结构向新数据库结构的迁移，并且其中还可以保证数据不会应为升级而流失。
     　　当然，如果遇到减少字段的情况，也可以通过创建临时表的方式来实现。
     */

    return sqls;
}

@end

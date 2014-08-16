//
//  SSNDBTable.m
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBTable.h"
#import "SSNDBColumn.h"
#import "SSNDB.h"
#import "ssnbase.h"

NSString *SSNDBTableWillMigrateNotification = @"SSNDBTableWillMigrateNotification"; //数据准备迁移 mainThread
NSString *SSNDBTableDidMigrateNotification = @"SSNDBTableDidMigrateNotification";   //数据迁移结束 mainThread
NSString *SSNDBTableDidDropNotification = @"SSNDBTableDidDropNotification";
NSString *SSNDBTableNameKey = @"SSNDBTableNameKey";

@interface SSNDBTable ()

@property (nonatomic, strong) SSNDBTable *meta; //模板
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) SSNDB *db; //依赖的数据库
@property (nonatomic, strong) NSString *path;
@property (nonatomic) NSUInteger currentVersion;
@property (nonatomic) NSUInteger lastVersion; //最后的版本

@property (nonatomic, strong) NSDictionary *its;

@property (nonatomic) SSNDBTableStatus status;

- (NSArray *)columnsForVersion:(NSUInteger)version;

//日志表操作方法
- (void)checkCreateTableLog; //日志表检查与创建
- (NSUInteger)versionForTableName:(NSString *)tableName;
- (void)updateVersion:(NSUInteger)version forTableName:(NSString *)tableName;
- (void)removeVersionForTableName:(NSString *)tableName;

//解析表
- (NSDictionary *)parseJSONForFilePath:(NSString *)path;

//检查表状态
- (void)checkTableStatus;

@end

@implementation SSNDBTable

- (NSArray *)columnsForVersion:(NSUInteger)version
{
    return [self.its objectForKey:@(version)];
}

- (instancetype)initWithDB:(SSNDB *)db tableJSONDescriptionFilePath:(NSString *)path
{
    NSAssert(db && path, @"创建数据表实例参数非法");
    self = [super init];
    if (self)
    {
        self.db = db;
        self.path = [path copy];

        // 1、检查并创建表日志表
        [self checkCreateTableLog];

        // 2、解析数据表描述
        self.its = [self parseJSONForFilePath:path];
        NSAssert([_its count], @"表解析不合法! 请修改表描述文件");

        // 3、检查表状态
        [self checkTableStatus];
    }
    return self;
}

+ (instancetype)tableWithDB:(SSNDB *)db tableJSONDescriptionFilePath:(NSString *)path
{
    return [[[self class] alloc] initWithDB:db tableJSONDescriptionFilePath:path];
}

- (instancetype)initWithName:(NSString *)name meta:(SSNDBTable *)meta
{
    NSAssert([name length] && meta && ![name isEqualToString:meta.name], @"创建数据表子表实例参数非法");
    self = [super init];
    if (self)
    {
        self.name = [name copy];
        self.meta = meta;
        self.lastVersion = meta.lastVersion; //需要集成的关系
        self.db = meta.db;
        self.path = meta.path;
        self.its = meta.its;

        // 1、检查并创建表日志表
        [self checkCreateTableLog];

        // 2、检查表状态
        [self checkTableStatus];
    }
    return self;
}

+ (instancetype)tableWithName:(NSString *)name meta:(SSNDBTable *)meta
{
    return [[[self class] alloc] initWithName:name meta:meta];
}

// table的状体
- (void)update
{
    if (_status == SSNDBTableOK)
    {
        return;
    }

    //继续判断是否表数据是否在内存
    if (!_its)
    {
        if (!_meta)
        {
            self.its = _meta.its;
        }
        else
        {
            self.its = [self parseJSONForFilePath:_path];
        }
    }

    void (^block)(SSNDB * db, BOOL * rollback) = ^(SSNDB *db, BOOL *rollback) {
        @autoreleasepool
        {

            //需要更新标信息存储
            [self updateVersion:_lastVersion forTableName:_name];
            NSInteger start_vs = _currentVersion;
            _currentVersion = _lastVersion;

            NSArray * (^t_block)(NSUInteger version, NSArray * lastAry) = ^(NSUInteger version, NSArray *lastAry) {

                NSArray *ary = [self columnsForVersion:version];

                if (lastAry)
                {
                    [self mapingTable:_name fromColumns:lastAry toColumns:ary];
                }
                else
                {
                    [self createTable:_name columns:ary];
                }

                return ary;
            };

            //通知界面，正在迁移
            NSDictionary *notifyInfo = @{SSNDBTableNameKey : _name};
            [self postMainThreadNotification:SSNDBTableWillMigrateNotification info:notifyInfo];

            if (_status == SSNDBTableNone)
            { //表示没有创建过表，直接从当前版本开始创建表
                t_block(_lastVersion, nil);
            }
            else
            {
                NSArray *lastCols = nil;

                for (NSUInteger vs = start_vs; vs <= _lastVersion; vs++)
                {
                    @autoreleasepool
                    {
                        lastCols = t_block(vs, lastCols);
                    }
                }
            }

            [self postMainThreadNotification:SSNDBTableDidMigrateNotification info:notifyInfo];

            self.its = nil; //可以释放内存，减少没必要开销
        }
    };

    [_db executeTransaction:block sync:YES];
}

- (void)drop
{
    if (_status == SSNDBTableNone)
    {
        return;
    }

    NSString *dropsql = [NSString stringWithUTF8Format:"DROP TABLE %s", [_name UTF8String]];
    void (^block)(SSNDB * db, BOOL * rollback) = ^(SSNDB *db, BOOL *rollback) {
        [db executeSql:dropsql, nil];
        [self removeVersionForTableName:_name];

        NSDictionary *notifyInfo = @{SSNDBTableNameKey : _name};
        [self postMainThreadNotification:SSNDBTableDidDropNotification info:notifyInfo];
    };
    [_db executeTransaction:block sync:YES];
    _status = SSNDBTableNone;
    _currentVersion = 0;
}

#pragma mark 日志表操作
- (void)checkCreateTableLog
{
    [_db executeSql:@"CREATE TABLE IF NOT EXISTS ssn_db_tb_log (name TEXT, value INTEGER,PRIMARY KEY(name))", nil];
}

- (NSUInteger)versionForTableName:(NSString *)tableName
{
    NSString *sql = @"SELECT value FROM ssn_db_tb_log WHERE name = ?";
    NSArray *ary = [_db objects:nil sql:sql, tableName, nil];
    return [[[ary lastObject] objectForKey:@"value"] integerValue];
}

- (void)updateVersion:(NSUInteger)version forTableName:(NSString *)tableName
{
    if (version)
    {
        //采用sql0将造成rowid更新，实际操作是delete and insert
        NSString *sql1 = @"UPDATE ssn_db_tb_log SET value = ? WHERE name = ?";
        NSString *sql2 = @"INSERT INTO ssn_db_tb_log (name,value) VALUES(?,?)";
        [_db executeTransaction:^(SSNDB *dataBase, BOOL *rollback) {
            [_db executeSql:sql1, @(version), tableName, nil];
            [_db executeSql:sql2, tableName, @(version), nil];
        } sync:YES];
    }
    else
    {
        [self removeVersionForTableName:tableName];
    }
}

- (void)removeVersionForTableName:(NSString *)tableName
{
    NSString *sql = @"DELETE FROM ssn_db_tb_log WHERE name = ?";
    [_db executeSql:sql, tableName, nil];
}

#pragma mark 表描述文件解析
- (NSDictionary *)parseJSONForFilePath:(NSString *)path
{
    NSMutableDictionary *rslt = [NSMutableDictionary dictionaryWithCapacity:1];

    @autoreleasepool
    {
        NSData *data = [NSData dataWithContentsOfFile:path];
        if ([data length] == 0)
        {
            return nil;
        }

        // IOS5自带解析类NSJSONSerialization从data中解析出数据放到字典中
        NSDictionary *temDic =
            [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];

        self.name = [temDic objectForKey:@"tb"];
        NSAssert([_name length], @"解析 table description file 出错，请按要求描述table");

        NSArray *its = [temDic objectForKey:@"its"];

        for (NSDictionary *item in its)
        {
            NSNumber *vs = [item objectForKey:@"vs"];
            NSArray *cls = [item objectForKey:@"cl"];

            NSUInteger i_vs = [vs integerValue];
            if (_lastVersion < i_vs) //取最大的版本
            {
                _lastVersion = i_vs;
            }

            NSMutableArray *tcls = [NSMutableArray arrayWithCapacity:[cls count]];

            for (NSDictionary *cl in cls)
            {
                SSNDBColumn *clmn = [SSNDBColumn columnWithName:[cl objectForKey:@"name"]
                                                           type:[[cl objectForKey:@"type"] integerValue]
                                                          level:[[cl objectForKey:@"level"] integerValue]
                                                          index:[[cl objectForKey:@"index"] integerValue]
                                                           fill:[cl objectForKey:@"fill"]
                                                        mapping:[cl objectForKey:@"mapping"]];

                [tcls addObject:clmn];
            }

            if ([tcls count])
            {
                [rslt setObject:tcls forKey:vs];
            }
        }
    }

    if ([rslt count] == 0)
    {
        return nil;
    }

    return rslt;
}

#pragma mark 检查表状态
- (void)checkTableStatus
{
    _currentVersion = [self versionForTableName:_name];
    if (_currentVersion == 0)
    { //还没有建标
        _status = SSNDBTableNone;
    }
    else if (_currentVersion < _lastVersion)
    { //待更新
        _status = SSNDBTableUpdate;
    }
    else
    {
        _status = SSNDBTableOK;
    }
}

#pragma mark 表 创建于更新实现
- (void)mapingTable:(NSString *)tableName fromColumns:(NSArray *)fcolumns toColumns:(NSArray *)tcolumns
{
    @autoreleasepool
    {
        NSArray *sqls = [SSNDBColumn table:tableName mappingSqlsFromColumns:fcolumns toColumns:tcolumns];

        for (NSString *sql in sqls)
        {
            [_db executeSql:sql, nil];
        }
    }
}

- (void)createTable:(NSString *)tableName columns:(NSArray *)columns
{
    @autoreleasepool
    {
        NSArray *sqls = [SSNDBColumn createSqlsForColumns:columns forTable:tableName];

        for (NSString *sql in sqls)
        {
            [_db executeSql:sql, nil];
        }
    }
}

#pragma mark 通知抛出
#pragma - mark 通知
- (void)postMainThreadNotification:(NSString *)key info:(NSDictionary *)info
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{ [[NSNotificationCenter defaultCenter] postNotificationName:key object:self userInfo:info]; });
}

@end

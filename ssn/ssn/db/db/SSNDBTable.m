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
#import "NSString+SSN.h"

NSString *const SSNDBTableWillMigrateNotification = @"SSNDBTableWillMigrateNotification"; //数据准备迁移 mainThread
NSString *const SSNDBTableDidMigrateNotification = @"SSNDBTableDidMigrateNotification"; //数据迁移结束 mainThread
NSString *const SSNDBTableDidDropNotification = @"SSNDBTableDidDropNotification";
NSString *const SSNDBTableUpdatedNotification = @"SSNDBTableUpdatedNotification";

@interface SSNDBTable ()

@property (nonatomic, strong) SSNDBTable *meta; //模板
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) SSNDB *db; //依赖的数据库
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, strong) NSArray *primaries;
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

//存储columns
- (void)peelcolumns;

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

        // 3、缓存列名
        [self peelcolumns];

        // 4、检查表状态
        [self checkTableStatus];
        
        // 5、监听变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbupdatedNotification:) name:SSNDBUpdatedNotification object:db];
    }
    return self;
}

//创建模板表
- (instancetype)initWithTemplateTableJSONDescriptionFilePath:(NSString *)path
{
    NSAssert(path, @"创建模板数据表实例参数非法");
    self = [super init];
    if (self)
    {
        self.path = [path copy];

        // 1、解析数据表描述
        self.its = [self parseJSONForFilePath:path];
        NSAssert([_its count], @"模板表解析不合法! 请修改表描述文件");

        // 3、缓存列名
        [self peelcolumns];
    }
    return self;
}

+ (instancetype)tableWithTemplateTableJSONDescriptionFilePath:(NSString *)path
{
    return [[[self class] alloc] initWithTemplateTableJSONDescriptionFilePath:path];
}

+ (instancetype)tableWithDB:(SSNDB *)db tableJSONDescriptionFilePath:(NSString *)path
{
    return [[[self class] alloc] initWithDB:db tableJSONDescriptionFilePath:path];
}

- (instancetype)initWithName:(NSString *)name meta:(SSNDBTable *)meta db:(SSNDB *)db
{
    NSAssert(db && [name length] && meta && ![name isEqualToString:meta.name], @"创建数据表子表实例参数非法");
    self = [super init];
    if (self)
    {
        self.name = [name copy];
        self.meta = meta;
        self.lastVersion = meta.lastVersion; //需要集成的关系
        self.db = db;
        self.path = meta.path;
        self.its = meta.its;
        self.columns = meta.columns;
        self.primaries = meta.primaries;

        // 1、检查并创建表日志表
        [self checkCreateTableLog];

        // 2、检查表状态
        [self checkTableStatus];
        
        // 3、监听变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbupdatedNotification:) name:SSNDBUpdatedNotification object:db];
    }
    return self;
}

+ (instancetype)tableWithName:(NSString *)name meta:(SSNDBTable *)meta db:(SSNDB *)db
{
    return [[[self class] alloc] initWithName:name meta:meta db:db];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// table的状体
- (void)update
{
    NSAssert(_db, @"模板表不能执行update方法");

    if (_status == SSNDBTableOK)
    {
        return;
    }

    //继续判断表数据是否在内存
    if (!_its)
    {
        if (!_meta)
        {
            _its = _meta.its;
        }
        else
        {
            _its = [self parseJSONForFilePath:_path];
        }
    }

    void (^block)(SSNDB * db) = ^(SSNDB *db) {
        @autoreleasepool
        {
            //需要防止多个表对象同时操作，重新检查表状态
            [self checkTableStatus];
            if (SSNDBTableOK == _status) {
                return ;
            }

            //需要更新标信息存储
            [self updateVersion:_lastVersion forTableName:_name];
            NSInteger start_vs = _currentVersion;
            _currentVersion = _lastVersion;

            NSArray * (^t_block)(NSUInteger version, NSArray * precls, BOOL last) =
                ^(NSUInteger version, NSArray *precls, BOOL last) {

                NSArray *ary = [self columnsForVersion:version];

                if (precls)
                {
                    [self mapingTable:_name fromColumns:precls toColumns:ary last:last];
                }
                else
                {
                    [self createTable:_name columns:ary];
                }

                return ary;
            };

            //通知界面，正在迁移
            NSDictionary *notifyInfo = @{SSNDBTableNameUserInfoKey : _name};
            [self postMainThreadNotification:SSNDBTableWillMigrateNotification info:notifyInfo];

            if (_status == SSNDBTableNone)
            { //表示没有创建过表，直接从当前版本开始创建表
                t_block(_lastVersion, nil, YES);
            }
            else
            {
                NSArray *preCols = [self columnsForVersion:start_vs];

                for (NSUInteger vs = start_vs + 1; vs <= _lastVersion; vs++)
                {
                    @autoreleasepool
                    {
                        preCols = t_block(vs, preCols, vs == _lastVersion);
                    }
                }
            }

            [self postMainThreadNotification:SSNDBTableDidMigrateNotification info:notifyInfo];

            //self.its = nil; //可以释放内存，减少没必要开销
        }
    };

    [_db executeBlock:block sync:YES];//DDL操作每一句话都将是事务级别，所以放事务block反而增加开销
    _status = SSNDBTableOK;
}

- (void)drop
{
    NSAssert(_db, @"模板表不能drop");

    if (_status == SSNDBTableNone)
    {
        return;
    }

    NSString *dropsql = [NSString stringWithUTF8Format:"DROP TABLE %s", [_name UTF8String]];
    void (^block)(SSNDB * db) = ^(SSNDB *db) {
        [db prepareSql:dropsql arguments:nil];
        [self removeVersionForTableName:_name];

        NSDictionary *notifyInfo = @{SSNDBTableNameUserInfoKey : _name};
        [self postMainThreadNotification:SSNDBTableDidDropNotification info:notifyInfo];
    };
    [_db executeBlock:block sync:YES];
    _status = SSNDBTableNone;
    _currentVersion = 0;
}

#pragma mark 通知监听
- (void)dbupdatedNotification:(NSNotification *)notice {
    //只关心数据的增删改
    NSDictionary *userInfo = notice.userInfo;
    NSString *tableName = [userInfo objectForKey:SSNDBTableNameUserInfoKey];
    if (![_name isEqualToString:tableName]) {
        return ;
    }
    
    [self postMainThreadNotification:SSNDBTableUpdatedNotification info:userInfo];
}

#pragma mark 日志表操作
- (void)checkCreateTableLog
{
    [_db prepareSql:@"CREATE TABLE IF NOT EXISTS ssn_db_tb_log (name TEXT, value INTEGER,PRIMARY KEY(name))" arguments:nil];
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
        [_db executeTransaction:^(SSNDB *db, BOOL *rollback) {
            [db prepareSql:sql1 arguments:@[ @(version), tableName ]];
            [db prepareSql:sql2 arguments:@[ tableName, @(version)]];
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
    [_db prepareSql:sql arguments:@[ tableName ]];
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

#pragma mark 剥离存储columns
- (void)peelcolumns
{
    if (!_its)
    {
        return;
    }

    @autoreleasepool
    {
        NSArray *cls = [self columnsForVersion:_lastVersion];

        NSMutableArray *clnames = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *primaries = [NSMutableArray arrayWithCapacity:1];

        for (SSNDBColumn *cl in cls)
        {
            if (cl.level == SSNDBColumnPrimary)
            {
                [primaries addObject:cl.name];
            }
            [clnames addObject:cl.name];
        }

        _columns = [clnames copy];
        _primaries = [primaries copy];
    }
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
- (void)mapingTable:(NSString *)tableName fromColumns:(NSArray *)fcolumns toColumns:(NSArray *)tcolumns last:(BOOL)last
{
    @autoreleasepool
    {
        NSArray *sqls = [SSNDBColumn mappingTable:tableName fromColumns:fcolumns toColumns:tcolumns last:last];

        NSMutableString *sql_assembly = [NSMutableString stringWithCapacity:1];
        for (NSString *sql in sqls)
        {
            [sql_assembly appendFormat:@"%@;", sql];
        }
        [_db executeSql:sql_assembly];
    }
}

- (void)createTable:(NSString *)tableName columns:(NSArray *)columns
{
    @autoreleasepool
    {
        NSMutableArray *sqls = [NSMutableArray arrayWithCapacity:1];
        NSArray *createSqls = [SSNDBColumn createTableSqlsWithColumns:columns forTable:tableName];
        [sqls addObjectsFromArray:createSqls];

        NSArray *indexSqls = [SSNDBColumn createIndexSqlsWithColumns:columns forTable:tableName];
        [sqls addObjectsFromArray:indexSqls];

        NSMutableString *sql_assembly = [NSMutableString stringWithCapacity:1];

        for (NSString *sql in sqls)
        {
            [sql_assembly appendFormat:@"%@;", sql];
        }

        [_db executeSql:sql_assembly];
    }
}

#pragma mark 通知抛出
#pragma - mark 通知
- (void)postMainThreadNotification:(NSString *)key info:(NSDictionary *)info
{
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(main_queue, ^{ [[NSNotificationCenter defaultCenter] postNotificationName:key object:self userInfo:info]; });
}

#pragma mark 数据管理
//最终表的主键和所有列
- (NSArray *)columnNames
{
    return [_columns copy];
}

- (NSArray *)primaryColumnNames
{
    return [_primaries copy];
}

- (NSArray *)valuesFormKeys:(NSArray *)keys object:(id)object
{
    NSMutableArray *vs = [NSMutableArray arrayWithCapacity:1];
    for (NSString *key in keys)
    {
        id value = [object valueForKey:key];
        if (value != nil)
        {
            [vs addObject:value];
        }
        else
        {
            [vs addObject:[NSNull null]];
        }
    }
    return vs;
}

//接管db操作
- (void)insertObjects:(NSArray *)objects {
    [self insertObjects:objects inTransaction:YES];
}

- (void)insertObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction
{
    NSAssert(_db, @"模板表不能操作数据");
    
    if ([objects count] == 0) {
        return ;
    }
    @autoreleasepool {
        NSString *clnames = [_columns componentsJoinedByString:@","];
        NSString *format = [NSString stringWithUTF8String:"?" repeat:[_columns count] joinedUTF8String:","];
        NSString *sql = [NSString stringWithUTF8Format:"INSERT INTO %s(%s) VALUES(%s)", [_name UTF8String], [clnames UTF8String], [format UTF8String]];
        
        void (^inline_block)(SSNDB *db) = ^(SSNDB *db) {
            for (id obj in objects){ @autoreleasepool {
                [db prepareSql:sql arguments:[self valuesFormKeys:_columns object:obj]];
            }}
        };
        
        if (inTransaction) {
            [_db executeTransaction:^(SSNDB *db, BOOL *rollback) { inline_block(db); } sync:YES];
        }
        else {
            [_db executeBlock:^(SSNDB *db) { inline_block(db); } sync:YES];
        }
    }
}

- (void)updateObjects:(NSArray *)objects {
    [self updateObjects:objects inTransaction:YES];
}

- (void)updateObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction
{
    NSAssert(_db, @"模板表不能操作数据");
    
    if ([objects count] == 0) {
        return ;
    }
    
    if ([_primaries count] == 0)
    {
        return;
    }
    
    @autoreleasepool {
        NSMutableArray *cls = [NSMutableArray arrayWithArray:_columns];
        NSString *values = [NSString componentsStringWithArray:cls appendingString:@" = ?" joinedString:@","];
        NSString *wheres = [NSString componentsStringWithArray:_primaries appendingString:@" = ?" joinedString:@" AND "];
        NSString *sql = [NSString stringWithUTF8Format:"UPDATE %s SET %s WHERE (%s)", [_name UTF8String], [values UTF8String], [wheres UTF8String]];
        
        [cls addObjectsFromArray:_primaries]; //从新把主键加上
        
        void (^inline_block)(SSNDB *db) = ^(SSNDB *db) {
            for (id obj in objects){ @autoreleasepool {
                [db prepareSql:sql arguments:[self valuesFormKeys:cls object:obj]];
            }}
        };
        
        if (inTransaction) {
            [_db executeTransaction:^(SSNDB *db, BOOL *rollback) { inline_block(db); } sync:YES];
        }
        else {
            [_db executeBlock:^(SSNDB *db) { inline_block(db); } sync:YES];
        }
    }
}
- (void)deleteObjects:(NSArray *)objects {
    [self deleteObjects:objects inTransaction:YES];
}

- (void)deleteObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction
{
    NSAssert(_db, @"模板表不能操作数据");
    
    if ([objects count] == 0) {
        return ;
    }
    
    if ([_primaries count] == 0)
    {
        return;
    }
    
    @autoreleasepool {
        
        NSString *wheres = [NSString componentsStringWithArray:_primaries appendingString:@" = ?" joinedString:@" AND "];
        NSString *sql = [NSString stringWithUTF8Format:"DELETE FROM %s WHERE (%s)", [_name UTF8String], [wheres UTF8String]];
        
        void (^inline_block)(SSNDB *db) = ^(SSNDB *db) {
            for (id obj in objects){ @autoreleasepool {
                [db prepareSql:sql arguments:[self valuesFormKeys:_primaries object:obj]];
            }}
        };
        
        if (inTransaction) {
            [_db executeTransaction:^(SSNDB *db, BOOL *rollback) { inline_block(db); } sync:YES];
        }
        else {
            [_db executeBlock:^(SSNDB *db) { inline_block(db); } sync:YES];
        }
    }
}

- (void)upinsertObjects:(NSArray *)objects {
    [self upinsertObjects:objects inTransaction:YES];
}

- (void)upinsertObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction
{
    NSAssert(_db, @"模板表不能操作数据");
    
    if ([objects count] == 0) {
        return ;
    }
    
    if ([_primaries count] == 0)
    {
        return;
    }
    
    @autoreleasepool {
        NSMutableArray *cls = [NSMutableArray arrayWithArray:_columns];
        NSString *values = [NSString componentsStringWithArray:cls appendingString:@" = ?" joinedString:@","];
        NSString *wheres = [NSString componentsStringWithArray:_primaries appendingString:@" = ?" joinedString:@" AND "];
        NSString *upsql = [NSString stringWithUTF8Format:"UPDATE %s SET %s WHERE (%s)", [_name UTF8String], [values UTF8String], [wheres UTF8String]];
        
        [cls addObjectsFromArray:_primaries]; //从新把主键加上
        
        NSString *clnames = [_columns componentsJoinedByString:@","];
        NSString *format = [NSString stringWithUTF8String:"?" repeat:[_columns count] joinedUTF8String:","];
        NSString *insql = [NSString stringWithUTF8Format:"INSERT INTO %s(%s) VALUES(%s)", [_name UTF8String], [clnames UTF8String], [format UTF8String]];
        
        void (^inline_block)(SSNDB *db) = ^(SSNDB *db) {
            for (id obj in objects){ @autoreleasepool {
                [db prepareSql:upsql arguments:[self valuesFormKeys:cls object:obj]];
                [db prepareSql:insql arguments:[self valuesFormKeys:_columns object:obj]];
            }}
        };
        
        if (inTransaction) {
            [_db executeTransaction:^(SSNDB *db, BOOL *rollback) { inline_block(db); } sync:YES];
        }
        else {
            [_db executeBlock:^(SSNDB *db) { inline_block(db); } sync:YES];
        }
    }
}

- (void)upinsertObjects:(NSArray *)objects fields:(NSArray *)fields {
    [self upinsertObjects:objects fields:fields inTransaction:YES];
}

- (void)upinsertObjects:(NSArray *)objects fields:(NSArray *)fields inTransaction:(BOOL)inTransaction {
    NSAssert(_db, @"模板表不能操作数据");
    
    if ([objects count] == 0) {
        return ;
    }
    
    if ([_primaries count] == 0)
    {
        return;
    }
    
    if ([fields count] == 0) {
        [self updateObjects:objects inTransaction:inTransaction];
        return ;
    }
    
    @autoreleasepool {
        
        NSMutableArray *cls = [NSMutableArray arrayWithArray:fields];
        NSString *values = [NSString componentsStringWithArray:cls appendingString:@" = ?" joinedString:@","];
        NSString *wheres = [NSString componentsStringWithArray:_primaries appendingString:@" = ?" joinedString:@" AND "];
        NSString *upsql = [NSString stringWithUTF8Format:"UPDATE %s SET %s WHERE (%s)", [_name UTF8String], [values UTF8String], [wheres UTF8String]];
        
        [cls addObjectsFromArray:_primaries]; //从新把主键加上
        
        NSString *clnames = [_columns componentsJoinedByString:@","];
        NSString *format = [NSString stringWithUTF8String:"?" repeat:[_columns count] joinedUTF8String:","];
        NSString *insql = [NSString stringWithUTF8Format:"INSERT INTO %s(%s) VALUES(%s)", [_name UTF8String], [clnames UTF8String], [format UTF8String]];
    
        void (^inline_block)(SSNDB *db) = ^(SSNDB *db) {
            for (id obj in objects){ @autoreleasepool {
                [db prepareSql:upsql arguments:[self valuesFormKeys:cls object:obj]];
                [db prepareSql:insql arguments:[self valuesFormKeys:_columns object:obj]];
            }}
        };
        
        if (inTransaction) {
            [_db executeTransaction:^(SSNDB *db, BOOL *rollback) { inline_block(db); } sync:YES];
        }
        else {
            [_db executeBlock:^(SSNDB *db) { inline_block(db); } sync:YES];
        }
    }
}

- (void)inreplaceObjects:(NSArray *)objects {
    [self inreplaceObjects:objects inTransaction:YES];
}

- (void)inreplaceObjects:(NSArray *)objects inTransaction:(BOOL)inTransaction {
    NSAssert(_db, @"模板表不能操作数据");
    
    if ([objects count] == 0) {
        return ;
    }
    
    if ([_primaries count] == 0)
    {
        return;
    }
    
    @autoreleasepool {
        NSString *clnames = [_columns componentsJoinedByString:@","];
        NSString *format = [NSString stringWithUTF8String:"?" repeat:[_columns count] joinedUTF8String:","];
        NSString *sql = [NSString stringWithUTF8Format:"INSERT OR REPLACE INTO %s(%s) VALUES(%s)", [_name UTF8String], [clnames UTF8String], [format UTF8String]];
    
        void (^inline_block)(SSNDB *db) = ^(SSNDB *db) {
            for (id obj in objects){ @autoreleasepool {
                [db prepareSql:sql arguments:[self valuesFormKeys:_columns object:obj]];
            }}
        };
        
        if (inTransaction) {
            [_db executeTransaction:^(SSNDB *db, BOOL *rollback) { inline_block(db); } sync:YES];
        }
        else {
            [_db executeBlock:^(SSNDB *db) { inline_block(db); } sync:YES];
        }
    }
}

- (void)insertObject:(id)object
{
    if (object) {
        [self insertObjects:@[ object ]];
    }
}

- (void)updateObject:(id)object
{
    if (object) {
        [self updateObjects:@[ object ]];
    }
}

- (void)deleteObject:(id)object
{
    if (object) {
        [self deleteObjects:@[ object ]];
    }
}

- (void)upinsertObject:(id)object
{
    if (object) {
        [self upinsertObjects:@[ object ]];
    }
}

- (void)upinsertObject:(id)object fields:(NSArray *)fields {
    if (object) {
        [self upinsertObjects:@[ object ] fields:fields];
    }
}

- (void)inreplaceObject:(id)object {
    if (object) {
        [self inreplaceObjects:@[ object ]];
    }
}

- (NSArray *)objectsWithClass:(Class)clazz forPredicate:(NSPredicate *)predicate {
    NSAssert(_db, @"模板表不能查询数据");
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",_name];
    if (predicate) {
        [sql appendFormat:@"WHERE %@",[predicate predicateFormat]];
    }
    
    return [_db objects:clazz sql:sql arguments:nil];
}

- (NSArray *)objectsWithClass:(Class)clazz forConditions:(NSDictionary *)conditions {
    NSAssert(_db, @"模板表不能查询数据");
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",_name];

    NSArray *values = nil;
    if ([conditions count]) {
        NSArray *allKeys = [conditions allKeys];
        values = [conditions objectsForKeys:allKeys notFoundMarker:[NSNull null]];
        NSString *wheres = [NSString componentsStringWithArray:allKeys appendingString:@" = ?" joinedString:@" AND "];
        [sql appendFormat:@"WHERE %@",wheres];
    }
    
    return [_db objects:clazz sql:sql arguments:values];
}

- (void)truncate {
    NSString *sql = [NSString stringWithUTF8Format:"DELETE FROM %s WHERE rowid > 0",[_name UTF8String]];
    [_db prepareSql:sql arguments:nil];
}


@end

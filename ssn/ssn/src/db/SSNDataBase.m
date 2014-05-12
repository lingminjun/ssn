//
//  SSNDataBase.m
//  ssn
//
//  Created by lingminjun on 13-12-14.
//  Copyright (c) 2013年 lingminjun. All rights reserved.
//

#import "SSNDataBase.h"
#import "ssnbase.h"

//表模板定义（表模板名_版本，列名，列类型，是否主键，是否有索引，默认值，数据迁移描述）
NSString *const kSSNDBTableTemplateHistory   = @"db_tb_tp_lg";
NSString *const kSSNDBTableTemplateName      = @"vtbNm";//version-TableName
NSString *const kSSNDBTableColumnName        = @"clNm";
NSString *const kSSNDBTableColumnType        = @"tp";
NSString *const kSSNDBTableKeyType           = @"ky";
NSString *const kSSNDBTableIndexType         = @"idx";
NSString *const kSSNDBTableDefaultValue      = @"df";
NSString *const kSSNDBTableMaping            = @"mp";

//表版本日志（表名，版本）
NSString *const kSSNDBTableVersionLog        = @"db_tb_vs_lg";
NSString *const kSSNDBTableName              = @"tbNm";  //表名字
NSString *const kSSNDBTableVersion           = @"vs";    //版本（不可大于数据库版本）

#pragma -
#pragma mark 数据表列字段定义
@interface SSNTableColumnInfo () {
    NSString *_column;
    NSString *_defaultValue;
    NSString *_mappingFormatter;
    SSNModelPropertType _type;
    SSNModelPropertKeyType _keyType;
    SSNModelPropertIndexType _indexType;
}
@property (nonatomic,copy) NSString *column;
@property (nonatomic,copy) NSString *defaultValue;
@property (nonatomic,copy) NSString *mappingFormatter;
@property (nonatomic) SSNModelPropertType type;
@property (nonatomic) SSNModelPropertKeyType keyType;
@property (nonatomic) SSNModelPropertIndexType indexType;

- (NSString *)createTableSQLFragmentStringMutablePrimaryKeys:(BOOL)mutable;//单纯数据创建
- (NSString *)createIndexSQLStringWithTableName:(NSString *)tableName;

- (NSString *)mappingTableSQLFragmentStringOldExist:(BOOL)exist;//数据表迁移sql语句

+ (int)columnTypeToInt:(NSString *)columnType;
+ (NSString *)columnTypeToString:(NSInteger)columnType;
+ (NSString *)mutablePrimaryKeysWithColumns:(NSArray *)columns;

//创建数据库语句
+ (NSArray *)table:(NSString *)tableName createSqlsForColumns:(NSArray *)columns;

//需要升级，数据表字段有变化都需要升级，升级
+ (NSArray *)table:(NSString *)tableName mappingSqlsFromColumns:(NSArray *)fromCols toColumns:(NSArray *)toCols;

@end

#pragma -
#pragma mark 数据库管理类
@interface SSNDataBase () {
    NSString *_pathToDataBase;
    sqlite3 *_database;
    BOOL _isOpen;
    BOOL _transAction;
    NSUInteger _currentVersion;
}

- (void)raiseSqliteException:(NSString *)errorMessage;
- (NSArray *)columnNamesForStatement:(sqlite3_stmt *)statement;
- (NSArray *)columnTypesForStatement:(sqlite3_stmt *)statement;

- (int)typeForStatement:(sqlite3_stmt *)statement column:(int)column;

- (void)copyValuesFromStatement:(sqlite3_stmt *)statement
                          toRow:(NSMutableDictionary *)row
                    columnTypes:(NSArray *)columnTypes
                    columnNames:(NSArray *)columnNames;

- (BOOL)bindArguments:(NSArray *)arguments toStatement:(sqlite3_stmt *)statement;

//目录控制
+ (void)insureThePath:(NSString *)thePath;

+ (BOOL)isDDLSQL:(NSString *)sql;//

//表创建
- (void)createTable:(NSString *)tableName columns:(NSArray *)columns;

//创建数据库升级记录表
- (void)createTableVersionLogTable;
- (void)saveVersion:(NSInteger)version forTableName:(NSString *)tableName;//保存表版本
- (NSInteger)versionForTableName:(NSString *)tableName;//当前数据表的版本
- (void)removeVersionForTableName:(NSString *)tableName;//删除表版本记录


- (void)createTableTemplateInfoTable;
- (void)saveTableColumns:(NSArray *)cols forTemplateName:(NSString *)tableName dataBaseVersion:(NSInteger)version;
- (NSArray *)tableColumnsWithTemplateName:(NSString *)tableName dataBaseVersion:(NSInteger)version;//取出某个版本的数据数据库模型
 

//私有执行sql的方法
- (NSArray *)executeSql:(NSString *)sql;
- (NSArray *)queryObjects:(Class)aclass executeSql:(NSString *)sql arguments:(NSArray *)arguments;

@end


@implementation SSNDataBase

@synthesize pathToDataBase = _pathToDataBase;
@synthesize currentVersion = _currentVersion;

- (id)initWithPath:(NSString *)filePath version:(NSUInteger)version
{
    if (self = [super init]) {
        self.pathToDataBase = filePath;
        _currentVersion = version;
    }
    return self;
}

#pragma -
#pragma mark 路径处理
+ (void)insureThePath:(NSString *)thePath {
    static NSString *application_Home = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            application_Home = [[NSString alloc] initWithString:[documentsDirectory stringByDeletingLastPathComponent]];
        }
    });
    
    if (![thePath hasPrefix:application_Home]) {//路径是合理的
        return ;
    }
    
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *dirPath = [thePath stringByDeletingLastPathComponent];
        if (![fileManager fileExistsAtPath:dirPath]) {
            [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

#pragma -
#pragma mark 表创建与迁移操作
- (void)createTableVersionLogTable {
    NSArray *cols = [NSArray arrayWithObjects:
                     [SSNTableColumnInfo columnWithName:kSSNDBTableName
                                                  type:SSNModelPropertText
                                               keyType:SSNModelPropertPrimaryKey
                                             indexType:SSNModelPropertNormalIndex
                                               default:@""
                                               mapping:nil],
                     [SSNTableColumnInfo columnWithName:kSSNDBTableVersion
                                                  type:SSNModelPropertInteger
                                               keyType:SSNModelPropertNotNullKey
                                             indexType:SSNModelPropertNotIndex
                                               default:@"0"
                                               mapping:nil],
                     nil];
    [self createTable:kSSNDBTableVersionLog columns:cols];
}


- (void)createTableTemplateInfoTable {
    NSArray *cols = [NSArray arrayWithObjects:
                     [SSNTableColumnInfo columnWithName:kSSNDBTableTemplateName //version-TableName
                                                  type:SSNModelPropertText
                                               keyType:SSNModelPropertPrimaryKey
                                             indexType:SSNModelPropertNormalIndex
                                               default:@""
                                               mapping:nil],
                     [SSNTableColumnInfo columnWithName:kSSNDBTableColumnName  //行名
                                                  type:SSNModelPropertText
                                               keyType:SSNModelPropertPrimaryKey
                                             indexType:SSNModelPropertNormalIndex
                                               default:@""
                                               mapping:nil],
                     [SSNTableColumnInfo columnWithName:kSSNDBTableColumnType    //类型
                                                  type:SSNModelPropertInteger
                                               keyType:SSNModelPropertNotNullKey
                                             indexType:SSNModelPropertNotIndex
                                               default:@""
                                               mapping:nil],
                     [SSNTableColumnInfo columnWithName:kSSNDBTableKeyType    //key类型
                                                  type:SSNModelPropertInteger
                                               keyType:SSNModelPropertNotNullKey
                                             indexType:SSNModelPropertNotIndex
                                               default:@""
                                               mapping:nil],
                     [SSNTableColumnInfo columnWithName:kSSNDBTableIndexType    //index类型
                                                  type:SSNModelPropertInteger
                                               keyType:SSNModelPropertNotNullKey
                                             indexType:SSNModelPropertNotIndex
                                               default:@""
                                               mapping:nil],
                     [SSNTableColumnInfo columnWithName:kSSNDBTableDefaultValue    //default类型
                                                  type:SSNModelPropertText
                                               keyType:SSNModelPropertNotNullKey
                                             indexType:SSNModelPropertNotIndex
                                               default:@""
                                               mapping:nil],
                     [SSNTableColumnInfo columnWithName:kSSNDBTableMaping    //数据迁移描述
                                                  type:SSNModelPropertText
                                               keyType:SSNModelPropertNotNullKey
                                             indexType:SSNModelPropertNotIndex
                                               default:@""
                                               mapping:nil],
                     nil];
    [self createTable:kSSNDBTableTemplateHistory columns:cols];
}
 

- (void)saveVersion:(NSInteger)version forTableName:(NSString *)tableName {
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@,%@) VALUES(?,?)",
                     kSSNDBTableVersionLog,kSSNDBTableName,kSSNDBTableVersion];
    [self queryObjects:NULL executeSql:sql arguments:[NSArray arrayWithObjects:tableName,[NSNumber numberWithInteger:version], nil]];
}

- (NSInteger)versionForTableName:(NSString *)tableName {
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = ?",
                     kSSNDBTableVersion,kSSNDBTableVersionLog,kSSNDBTableName];
    NSArray *v = [self queryObjects:NULL executeSql:sql arguments:[NSArray arrayWithObject:tableName]];
    if ([v count]) {
        return [[[v objectAtIndex:0] objectForKey:kSSNDBTableVersion] integerValue];
    }
    else {
        return 0;
    }
}

- (void)removeVersionForTableName:(NSString *)tableName {
    NSString *sql = [NSString stringWithUTF8Format:"DELETE FROM %s WHERE %s = '%s'",[kSSNDBTableVersionLog UTF8String],[kSSNDBTableName UTF8String],[tableName UTF8String]];
    [self executeSql:sql];
}


- (void)saveTableColumns:(NSArray *)cols forTemplateName:(NSString *)tableName dataBaseVersion:(NSInteger)version {
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@,%@,%@,%@,%@,%@,%@) VALUES(?,?,?,?,?,?,?)",
                     kSSNDBTableTemplateHistory,
                     //begin values
                     kSSNDBTableTemplateName,
                     kSSNDBTableColumnName,
                     kSSNDBTableColumnType,
                     kSSNDBTableKeyType,
                     kSSNDBTableIndexType,
                     kSSNDBTableDefaultValue,
                     kSSNDBTableMaping
                     //end
                     ];
    NSString *v_tbaleName = [NSString stringWithFormat:@"%ld-%@",version,tableName];
    
    [self executeTransaction:^(SSNDataBase *dataBase) {
        for (SSNTableColumnInfo *col in cols) {
            [self queryObjects:NULL executeSql:sql arguments:[NSArray arrayWithObjects:v_tbaleName,
                                                              col.column,
                                                              [NSNumber numberWithInt:col.type],
                                                              [NSNumber numberWithInt:col.keyType],
                                                              [NSNumber numberWithInt:col.indexType],
                                                              (col.defaultValue?col.defaultValue:[NSNull null]),
                                                              (col.mappingFormatter?col.mappingFormatter:[NSNull null]),nil]];
        }
    }];
}

- (NSArray *)tableColumnsWithTemplateName:(NSString *)tableName dataBaseVersion:(NSInteger)version {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?",kSSNDBTableTemplateHistory,kSSNDBTableTemplateName];
    NSString *clNm = [NSString stringWithFormat:@"%ld-%@",version,tableName];
    NSArray *cols = [self queryObjects:NULL executeSql:sql arguments:[NSArray arrayWithObject:clNm]];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[cols count]];
    for (NSDictionary *row in cols) {
        NSString *colName = [row objectForKey:kSSNDBTableColumnName];
        SSNModelPropertType type = (SSNModelPropertType)[[row objectForKey:kSSNDBTableColumnType] integerValue];
        SSNModelPropertKeyType keyType = (SSNModelPropertKeyType)[[row objectForKey:kSSNDBTableKeyType] integerValue];
        SSNModelPropertIndexType indexType = (SSNModelPropertIndexType)[[row objectForKey:kSSNDBTableIndexType] integerValue];
        NSString *defaultValue = [row objectForKey:kSSNDBTableDefaultValue];
        NSString *mappingFormatter = [row objectForKey:kSSNDBTableMaping];
        SSNTableColumnInfo *colItem = [SSNTableColumnInfo columnWithName:colName
                                                                  type:type
                                                               keyType:keyType
                                                             indexType:indexType
                                                               default:defaultValue
                                                               mapping:mappingFormatter];
        [result addObject:colItem];
    }
    return result;
}
 

- (void)mapingTable:(NSString *)tableName fromColumns:(NSArray *)fcolumns toColumns:(NSArray *)tcolumns {
    @autoreleasepool {
        
        NSArray *sqls = [SSNTableColumnInfo table:tableName mappingSqlsFromColumns:fcolumns toColumns:tcolumns];
        
        for (NSString *tem_sql in sqls) {
            [self executeSql:tem_sql];
        }
    }
}

//表创建
- (void)createTable:(NSString *)tableName columns:(NSArray *)columns {
    @autoreleasepool {
        
    NSArray *sqls = [SSNTableColumnInfo table:tableName createSqlsForColumns:columns];
    
    for (NSString *tem_sql in sqls) {
        [self executeSql:tem_sql];
    }
    
    }
}

- (void)createTable:(NSString *)tableName withDelegate:(id <SSNModelTableProtocol>)delegate {
    NSString *templateName = nil;
    if ([delegate respondsToSelector:@selector(dataBase:tableTemplateName:)]) {
        templateName = [delegate dataBase:self tableTemplateName:tableName];
    }
    
    if ([templateName length] == 0) {
        templateName = tableName;
    }
    
    @synchronized(self) {
    
        //获取当前表格版本
        NSUInteger dbVersion = [self versionForTableName:tableName];
        if (dbVersion >= self.currentVersion) {//不需要更新
            dbVersion = self.currentVersion;//取目标版本
            return ;
        }
        
        //需要更新
        [self saveVersion:self.currentVersion forTableName:tableName];
        
        BOOL respond = NO;
        if ([delegate respondsToSelector:@selector(dataBase:columnsForTemplateName:databaseVersion:)]) {
            respond = YES;
        }
        
        if (dbVersion == 0) {//表示没有创建过表
            NSArray *ary = [self tableColumnsWithTemplateName:templateName dataBaseVersion:self.currentVersion];
            if ([ary count] == 0 && respond) {
                ary = [delegate dataBase:self columnsForTemplateName:templateName databaseVersion:self.currentVersion];
            }
            
            NSAssert([ary count], @"创建数据表 %@ 没找到表信息",tableName);
            
            [self createTable:tableName columns:ary];
            
            [self saveTableColumns:ary forTemplateName:tableName dataBaseVersion:self.currentVersion];
        }
        else {
            NSArray *lastCols = nil;
            
            for (NSUInteger versionIndex = dbVersion; versionIndex <= self.currentVersion; versionIndex++) {
                
                @autoreleasepool {
                    NSArray *ary = [self tableColumnsWithTemplateName:templateName dataBaseVersion:versionIndex];
                    if ([ary count] == 0 && respond) {
                        ary = [delegate dataBase:self columnsForTemplateName:templateName databaseVersion:versionIndex];
                    }
                    
                    if ([ary count]) {//如果count == 0 表示没有更新，
                        if (lastCols) {
                            [self mapingTable:tableName fromColumns:lastCols toColumns:ary];
                        }
                        else {
                            [self createTable:tableName columns:ary];
                        }
                        
                        lastCols = ary;
                    }
                }
                
            }
            
            //存入新的版本值，即使没有变化
            [self saveTableColumns:lastCols forTemplateName:tableName dataBaseVersion:self.currentVersion];
        }
    
    }
}

- (void)dropTable:(NSString *)tableName {
    NSString *sql = [NSString stringWithUTF8Format:"DROP TABLE %s",[tableName UTF8String]];
    
    @synchronized(self) {
        [self queryObjects:NULL executeSql:sql arguments:nil];
        [self removeVersionForTableName:tableName];
    }
}

#pragma -
#pragma mark 数据库操作

//+ (void)createTableWithDB:(MojoDatabase *)db
//{
//
//  NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (userId TEXT, mineId TEXT, name TEXT, pinyin TEXT COLLATE NOCASE, pyIndex INTEGER, alias TEXT, aliasPinyin TEXT, avatar TEXT, iSSNTar INTEGER, lastModify TEXT, primary key(userId, mineId))", [[self class] tableName]];
//
//    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (userId TEXT, mineId TEXT, name TEXT, pinyin TEXT COLLATE NOCASE, pyIndex INTEGER, alias TEXT, aliasPinyin TEXT, avatar TEXT, iSSNTar INTEGER, lastModify TEXT, primary key(userId, mineId))", [[self class] tableName]];
//    [db executeSql:sql];
//    
//    sql = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS idx_pinyin ON %@(pinyin)", [[self class] tableName]];
//    [db executeSql:sql];
//
//    sql = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS idx_pyIndex ON %@(pyIndex)", [[self class] tableName]];
//    [db executeSql:sql];
//[NSString stringWithFormat:@"CREATE UNIQUE INDEX IF NOT EXISTS idx_messages_MidUid ON %@(messageId, userId)", [[self class] tableName]];
//
//}

- (void)raiseSqliteException:(NSString *)errorMessage
{
    [NSException raise:@"SSNDatabaseSQLiteException" format:errorMessage, sqlite3_errmsg16(_database)];
}

- (NSArray *)columnNamesForStatement:(sqlite3_stmt *)statement
{
    int columnCount = sqlite3_column_count(statement);
    NSMutableArray *columnNames = [NSMutableArray array];
    for (int i = 0; i < columnCount; i++) {
        [columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]];
    }
    return columnNames;
}

- (NSArray *)columnTypesForStatement:(sqlite3_stmt *)statement
{
    int columnCount = sqlite3_column_count(statement);
    NSMutableArray *columnTypes = [NSMutableArray array];
    for (int i = 0; i < columnCount; i++) {
        [columnTypes addObject:[NSNumber numberWithInt:[self typeForStatement:statement column:i]]];
    }
    return columnTypes;
}

- (int)typeForStatement:(sqlite3_stmt *)statement column:(int)column
{
    const char *columnType = sqlite3_column_decltype(statement, column);
    
    if (columnType != NULL) {
        return [SSNTableColumnInfo columnTypeToInt:[[NSString stringWithUTF8String:columnType] uppercaseString]];
    }
    
    return sqlite3_column_type(statement, column);
}

- (void)copyValuesFromStatement:(sqlite3_stmt *)statement
                          toRow:(NSMutableDictionary *)row
                    columnTypes:(NSArray *)columnTypes
                    columnNames:(NSArray *)columnNames
{
    @synchronized(row) {//需要保证单个数据完整性
        
        int columnCount = sqlite3_column_count(statement);
        
        for (int i = 0; i < columnCount; i++) {
            id value = [self valueFromStatement:statement column:i columnTypes:columnTypes];
            
            if (value != nil) {
                [row setValue:value forKey:[columnNames objectAtIndex:i]];
            }
        }
        
    }
}

- (id)valueFromStatement:(sqlite3_stmt *)statement
                  column:(int)column
             columnTypes:(NSArray *)columnTypes
{
    int columnType = [[columnTypes objectAtIndex:column] intValue];
    
    /*
     * force conversion to the declared type using sql conversions; this saves
     * some problems with NSNull being assigned to non-object values
     */
    if (columnType == SQLITE_INTEGER) {
        return [NSNumber numberWithInt:sqlite3_column_int(statement, column)];
    } else if (columnType == SQLITE_FLOAT) {
        return [NSNumber numberWithDouble:sqlite3_column_double(statement, column)];
    } else if (columnType == SQLITE_TEXT) {
        const char *text = (const char *) sqlite3_column_text(statement, column);
        if (text != nil) {
            return [NSString stringWithUTF8String:text];
        } else {
            return nil;
        }
    } else if (columnType == SQLITE_BLOB) {
        // create an NSData object with the same size as the blob
        return [NSData dataWithBytes:sqlite3_column_blob(statement, column) length:sqlite3_column_bytes(statement, column)];
    } else if (columnType == SQLITE_NULL) {
        return nil;
    }
    
    return nil;
}

- (BOOL)isOpen {
    return _isOpen;
}

- (void)open {
    
    //确认下路径
    [SSNDataBase insureThePath:self.pathToDataBase];
    
    @synchronized (self) {
        // config sqlite to work with the same connection on multiple threads
        if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK) {
            //NSLog(@"Can now use sqlite on multiple threads, using the same connection");
        } else {
            //NSLog(@"UNABLE to use sqlite on multiple threads, using the same connection");
        }
        
        // opens database, creating the file if it does not already exist
        if (sqlite3_open([self.pathToDataBase UTF8String], &_database) != SQLITE_OK) {
            sqlite3_close(_database);
            _isOpen = NO;
            [self raiseSqliteException:@"Failed to open database with message '%S'."];
        }
        else {
            _isOpen = YES;
        }
        
        if (_isOpen) {//创建好数据库升级表
            [self createTableVersionLogTable];
            [self createTableTemplateInfoTable];
        }
        
    }
}

- (void)close {
    
    @synchronized(self) {
        if (sqlite3_close(_database) != SQLITE_OK) {
            [self raiseSqliteException:@"Failed to close database with message '%S'."];
        }
        else {
            _isOpen = NO;
        }
    }
}

- (BOOL)bindArguments:(NSArray *)arguments toStatement:(sqlite3_stmt *)statement {
    
    if (arguments == nil) {//不需要绑定参数的，直接返回
        return YES;
    }
    
    int expectedArguments = sqlite3_bind_parameter_count(statement);
    if (expectedArguments != [arguments count]) {
        return NO;
    }
    
    for (int i = 1; i <= expectedArguments; i++) {
        id argument = [arguments objectAtIndex:i-1];
        if([argument isKindOfClass:[NSString class]])
            sqlite3_bind_text(statement, i, [argument UTF8String], -1, SQLITE_TRANSIENT);
        else if([argument isKindOfClass:[NSData class]])
            sqlite3_bind_blob(statement, i, [argument bytes], (int)[argument length], SQLITE_TRANSIENT);
        else if([argument isKindOfClass:[NSDate class]])
            sqlite3_bind_double(statement, i, [argument timeIntervalSince1970]);
        else if([argument isKindOfClass:[NSNumber class]])
            sqlite3_bind_double(statement, i, [argument doubleValue]);
        else if([argument isKindOfClass:[NSNull class]])
            sqlite3_bind_null(statement, i);
        else {
            sqlite3_finalize(statement);
            return NO;
        }
    }
    return YES;
}

- (NSArray *)queryObjects:(Class)aclass executeSql:(NSString *)sql arguments:(NSArray *)arguments {
    NSMutableArray *rows = [NSMutableArray array];
    
    sqlite3_stmt * statement = nil;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if ([self bindArguments:arguments toStatement:statement]) {
            BOOL needsToFetchColumnTypesAndNames = YES;
            NSArray *columnTypes = nil;
            NSArray *columnNames = nil;
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                if (needsToFetchColumnTypesAndNames) {
                    columnTypes = [self columnTypesForStatement:statement];
                    columnNames = [self columnNamesForStatement:statement];
                    needsToFetchColumnTypesAndNames = NO;
                }
                
                @autoreleasepool {
                    NSMutableDictionary *row = [NSMutableDictionary dictionaryWithCapacity:1];
                    [self copyValuesFromStatement:statement toRow:row columnTypes:columnTypes columnNames:columnNames];
                    [rows addObject:row];
                }
            }
            
            sqlite3_finalize(statement);
        }
        else {
            sqlite3_finalize(statement);
            
            [self raiseSqliteException:[[NSString stringWithFormat:@"Failed to bind arguments: '%@' with message: ", sql] stringByAppendingString:@"%S"]];
        }
    } else {
        [self raiseSqliteException:[[NSString stringWithFormat:@"Failed to execute statement: '%@' with message: ", sql] stringByAppendingString:@"%S"]];
    }
    
    return rows;
}

+ (BOOL)isDDLSQL:(NSString *)sql {//DDL—数据定义语言(CREATE，ALTER，DROP，DECLARE)
    NSString *temSql = [sql stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange range = [temSql rangeOfString:@"CREATE" options:NSCaseInsensitiveSearch];
    if (range.length > 0 && range.location < 3) {
        return YES;
    }
    
    range = [temSql rangeOfString:@"ALTER" options:NSCaseInsensitiveSearch];
    if (range.length > 0 && range.location < 3) {
        return YES;
    }
    
    range = [temSql rangeOfString:@"DROP" options:NSCaseInsensitiveSearch];
    if (range.length > 0 && range.location < 3) {
        return YES;
    }
    
    range = [temSql rangeOfString:@"DECLARE" options:NSCaseInsensitiveSearch];
    if (range.length > 0 && range.location < 3) {
        return YES;
    }
    
    return NO;
}

- (NSArray *)queryObjects:(Class)aclass executeSql:(NSString *)sql, ... {
    
    if ([SSNDataBase isDDLSQL:sql]) {
        return [NSArray array];
    }
    
    NSArray *result = nil;
    @autoreleasepool {
        
    NSMutableArray *arguments = [NSMutableArray array];
    
    va_list argumentList;
    va_start(argumentList, sql);
    id argument;
    while ((argument = va_arg(argumentList, id))) {
        [arguments addObject:argument];
    }
    va_end(argumentList);
    
    Class rowClass = aclass;
    if (!rowClass) {
        rowClass = [NSMutableDictionary class];
    }
    
    if ([arguments count]) {
        arguments = nil;
    }
    
    @synchronized(self) {
        NSArray *temResult = [self queryObjects:rowClass executeSql:sql arguments:arguments];
        if ([temResult count]) {
            result = [[NSMutableArray alloc] initWithArray:temResult];
        }
    }
    
    }
    
    return result;
}

- (NSArray *)executeSql:(NSString *)sql {
    return [self queryObjects:NULL executeSql:sql arguments:nil];
}

- (void)executeTransaction:(void(^)(SSNDataBase *dataBase))transaction {
    
    if (transaction) {
        @synchronized(self) {
            BOOL needCommit = NO;
            if (!_transAction) {
                needCommit = YES;
                _transAction = YES;
                [self executeSql:@"BEGIN IMMEDIATE TRANSACTION;"];
            }
            
            transaction(self);
            
            if (needCommit) {
                [self executeSql:@"COMMIT TRANSACTION;"];
                _transAction = NO;
            }
        }
    }
    
}

- (NSArray *)columnsForTableName:(NSString *)tableName
{
    NSArray *results = nil;
    @synchronized(self) {
        results = [self executeSql:[NSString stringWithFormat:@"pragma table_info(%@)", tableName]];
    }
    return [results valueForKey:@"name"];
}

- (NSArray *)tables
{
    return [self executeSql:@"SELECT * FROM sqlite_master WHERE type = 'table'"];
}

- (NSArray *)tableNames
{
    NSArray *tables = nil;
    @synchronized(self) {
        tables = [[self tables] valueForKey:@"name"];
    }
    if ([tables count]) {
        NSMutableArray *temAry = [NSMutableArray arrayWithArray:tables];
        [temAry removeObject:kSSNDBTableTemplateHistory];
        [temAry removeObject:kSSNDBTableVersionLog];
        return temAry;
    }
    else {
        return [NSArray array];
    }
}

@end

#pragma -
#pragma mark tablecolumn
@implementation SSNTableColumnInfo

@synthesize column = _column;
@synthesize defaultValue = _defaultValue;
@synthesize mappingFormatter = _mappingFormatter;
@synthesize type = _type;
@synthesize keyType = _keyType;
@synthesize indexType = _indexType;

- (void)dealloc {
    
}

- (NSString *)defaultValueString {
    NSString *string = nil;
    switch (self.type) {
        case SQLITE_TEXT:
            if (self.defaultValue) {
                string = [NSString stringWithUTF8Format:"'%s'",[self.defaultValue UTF8String]];
            }
            else {
                string = @"NULL";
            }
            break;
        case SQLITE_INTEGER:
        case SQLITE_FLOAT:
        case SQLITE_BLOB:
        case SQLITE_NULL:
        default:
            if ([self.defaultValue length] > 0) {
                string = self.defaultValue;
            }
            else {
                string = @"0";
            }
            break;
    }
    return string;
}

- (NSString *)createTableSQLFragmentStringMutablePrimaryKeys:(BOOL)mutable {
    NSString *sql = [NSString stringWithUTF8Format:"%s %s %s DEFAULT %s",
                     [self.column UTF8String],
                     [[SSNTableColumnInfo columnTypeToString:self.type] UTF8String],
                     [[SSNTableColumnInfo columnKeyTypeToString:self.keyType supportPrimaryKey:!mutable] UTF8String],
                     [[self defaultValueString] UTF8String]];
    return sql;
}

- (NSString *)createIndexSQLStringWithTableName:(NSString *)tableName {
    if (self.indexType == SSNModelPropertNotIndex) {
        return @"";
    }
    
    NSString *sql = [NSString stringWithUTF8Format:"CREATE %s INDEX IF NOT EXISTS idx_%s_%s ON %s(%s)",
                     ((self.indexType == SSNModelPropertUniqueIndex)?"UNIQUE":""),
                     [tableName UTF8String],
                     [self.column UTF8String],
                     [tableName UTF8String],
                     [self.column UTF8String]];
    return sql;
}

- (NSString *)mappingTableSQLFragmentStringOldExist:(BOOL)exist {
    if ([self.mappingFormatter length]) {//需要迁移,直接as就好了
        return [NSString stringWithUTF8Format:"(%s) AS %s",[self.mappingFormatter UTF8String],[self.column UTF8String]];
    }
    else {
        if (exist) {
            return self.column;
        }
        else {
            return [NSString stringWithUTF8Format:"%s AS %s",[[self defaultValueString] UTF8String],[self.column UTF8String]];
        }
    }
}

+ (instancetype)columnWithName:(NSString *)column
                          type:(SSNModelPropertType)type
                       keyType:(SSNModelPropertKeyType)keyType
                     indexType:(SSNModelPropertIndexType)indexType
                       default:(NSString *)defaultValue
                       mapping:(NSString *)mappingFormatter {
    SSNTableColumnInfo *info = [[SSNTableColumnInfo alloc] init];
    info.column = column;
    info.type = type;
    info.keyType = keyType;
    info.indexType = indexType;
    info.defaultValue = defaultValue;
    info.mappingFormatter = mappingFormatter;
    return info;
}

+ (int)columnTypeToInt:(NSString *)columnType {
    if ([columnType isEqualToString:@"INTEGER"]) {
        return SQLITE_INTEGER;
    } else if ([columnType isEqualToString:@"REAL"]) {
        return SQLITE_FLOAT;
    } else if ([columnType isEqualToString:@"TEXT"]) {
        return SQLITE_TEXT;
    } else if ([columnType isEqualToString:@"BLOB"]) {
        return SQLITE_BLOB;
    } else if ([columnType isEqualToString:@"NULL"]) {
        return SQLITE_NULL;
    }
    return SQLITE_TEXT;
}

+ (NSString *)columnTypeToString:(NSInteger)columnType {
    NSString *string = nil;
    switch (columnType) {
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

+ (NSString *)columnKeyTypeToString:(SSNModelPropertKeyType)columnKeyType supportPrimaryKey:(BOOL)support {
    NSString *string = nil;
    switch (columnKeyType) {
        case SSNModelPropertNormalKey:
            string = @"";
            break;
        case SSNModelPropertNotNullKey:
            string = @"NOT NULL";
            break;
        case SSNModelPropertPrimaryKey:
            if (support) {
                string = @"NOT NULL PRIMARY KEY";
            }
            else {
                string = @"NOT NULL";
            }
            break;
        default:
            string = @"";
            break;
    }
    return string;
}

+ (NSString *)mutablePrimaryKeysWithColumns:(NSArray *)columns {
    NSMutableString *keys = [NSMutableString stringWithCapacity:1];
    NSUInteger keyCount = 0;
    for (SSNTableColumnInfo *column in columns) {
        if (column.keyType == SSNModelPropertPrimaryKey) {
            if (keyCount > 0) {
                [keys appendString:@","];
            }
            
            [keys appendString:column.column];
            
            keyCount++;
        }
    }
    
    NSString *string = nil;
    if (keyCount > 1) {
        string = [NSString stringWithUTF8Format:"PRIMARY KEY(%s)",[keys UTF8String]];
    }
    else {
        string = @"";
    }
    return string;
}

#pragma -
#pragma mark 数据库升级 流程控制
- (BOOL)isEqualToColumnInfo:(SSNTableColumnInfo *)col ignoreMapping:(BOOL)ignoreMapping {
    if ([self.column isEqualToString:col.column]
        && (([self.defaultValue length] == 0 && [col.defaultValue length] == 0) || [self.defaultValue isEqualToString:col.defaultValue])
        && self.type == col.type
        && self.keyType == col.keyType
        && self.indexType == col.indexType) {
        if (ignoreMapping) {
            return YES;
        }
        else {
            if (([self.mappingFormatter length] == 0 && [col.mappingFormatter length] == 0) || [self.mappingFormatter isEqualToString:col.mappingFormatter]) {
                return YES;
            }
            else {
                return NO;
            }
        }
    }
    return NO;
}

+ (NSArray *)table:(NSString *)tableName createSqlsForColumns:(NSArray *)columns {
    //直接创建数据表
    NSMutableString * sql = [[NSMutableString alloc] initWithCapacity:1];
    NSMutableArray *sqls = [NSMutableArray arrayWithObject:sql];
    
    [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ (",tableName];
    NSString *primaryKeys = [SSNTableColumnInfo mutablePrimaryKeysWithColumns:columns];
    BOOL isMutable = NO;
    if ([primaryKeys length]) {
        isMutable = YES;
    }
    
    BOOL isFirst = YES;
    for (SSNTableColumnInfo *column in columns) {
        if (!isFirst) {
            [sql appendString:@","];
        }
        else {
            isFirst = NO;
        }
        [sql appendString:[column createTableSQLFragmentStringMutablePrimaryKeys:isMutable]];
        
        //索引sql
        NSString *indexSql = [column createIndexSQLStringWithTableName:tableName];
        if ([indexSql length]) {
            [sqls addObject:indexSql];
        }
    }
    
    //加上联合主键
    if (isMutable) {
        [sql appendFormat:@",%@",primaryKeys];
    }
    
    [sql appendString:@")"];
    
    return sqls;
}

//数据库升级控制
+ (NSArray *)table:(NSString *)tableName mappingSqlsFromColumns:(NSArray *)fromCols toColumns:(NSArray *)toCols {
    
    NSMutableDictionary *toDic = [NSMutableDictionary dictionaryWithCapacity:0];//用于无序分析表样式，前后两张表如果
    NSMutableDictionary *mapDic = [NSMutableDictionary dictionaryWithCapacity:0];//记录迁移值
    NSMutableArray *toColNames = [NSMutableArray arrayWithCapacity:0];//记录所有建表字段
    
    NSMutableDictionary *fromDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableSet *fromSet = [NSMutableSet setWithCapacity:0];
    for (SSNTableColumnInfo *col in toCols) {
        [toColNames addObject:col.column];
        
        [toDic setValue:col forKey:col.column];
        
        if ([col.mappingFormatter length]) {
            [mapDic setValue:col forKey:col.mappingFormatter];
        }
    }
    
    for (SSNTableColumnInfo *col in fromCols) {
        [fromSet addObject:col.column];
        [fromDic setValue:col forKey:col.column];
    }
    
    if ([fromCols count] == [toCols count]) {
       
        BOOL colNotChange = YES;
        for (SSNTableColumnInfo *col in fromCols) {
            SSNTableColumnInfo *tcol = [toDic objectForKey:col.column];
            if ([tcol isEqualToColumnInfo:col ignoreMapping:YES]) {
                colNotChange = NO;
                break ;
            }
        }
        
        if (colNotChange) {//属性没有发生任何变化，此时只需要关注值的变化
            if ([mapDic count] == 0) {//说明连数据迁移项也没有，数据表不需要任何改变
                return [NSArray array];
            }
        }
        
    }
    
    NSMutableArray *sqls = [NSMutableArray arrayWithCapacity:4];
    
    //1 改变原来表名字
    [sqls addObject:[NSString stringWithUTF8Format:"ALTER TABLE %s RENAME TO __temp__%s",[tableName UTF8String],[tableName UTF8String]]];
    
    //2 创建新的表
    NSArray *createSqls = [self table:tableName createSqlsForColumns:toCols];
    [sqls addObjectsFromArray:createSqls];
    
    //3 导入数据
    NSMutableString *insertInto = [NSMutableString stringWithCapacity:10];
    [sqls addObject:insertInto];
    [insertInto appendFormat:@"INSERT INTO %@ SELECT ",tableName];
    BOOL isFirst = YES;
    for (SSNTableColumnInfo *col in toCols) {
        if (isFirst) {
            isFirst = NO;
        }
        else {
            [insertInto appendString:@", "];
        }
        BOOL exist = [fromSet containsObject:col.column];
        [insertInto appendString:[col mappingTableSQLFragmentStringOldExist:exist]];
    }
    [insertInto appendFormat:@" FROM __temp__%@",tableName];
    
    //4 删除临时表
    [sqls addObject:[NSString stringWithUTF8Format:"DROP TABLE __temp__%s",[tableName UTF8String]]];
    
        
    /*
     另外，如果遇到复杂的修改操作，比如在修改的同时，需要进行数据的转移，那么可以采取在一个事务中执行如下语句来实现修改表的需求。
     　　1. 将表名改为临时表
     ALTER TABLE Subscription RENAME TO __temp__Subscription;
     　　2. 创建新表
     CREATE TABLE Subscription (OrderId VARCHAR(32) PRIMARY KEY ,UserName VARCHAR(32) NOT NULL ,ProductId VARCHAR(16) NOT NULL);
     
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


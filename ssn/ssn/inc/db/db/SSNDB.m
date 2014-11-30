//
//  SSNDB.m
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDB.h"
#import "ssnbase.h"
#import <sqlite3.h>
#import "SSNCuteSerialQueue.h"
#import "NSFileManager+SSN.h"

NSString *const SSNDBUpdatedNotification = @"SSNDBUpdatedNotification";   //数据准备迁移
NSString *const SSNDBRollbackNotification = @"SSNDBRollbackNotification"; //数据迁移结束

NSString *const SSNDBTableNameUserInfoKey = @"SSNDBTableNameUserInfoKey";  //table name(NSString)
NSString *const SSNDBOperationUserInfoKey = @"SSNDBOperationUserInfoKey";  //operation(NSNumber<int>) eg. SQLITE_INSERT
NSString *const SSNDBRowIdUserInfoKey     = @"SSNDBRowIdUserInfoKey";      //row_id(NSNumber<int64>)

#define SSNDBFileName @"db.sqlite"

@interface SSNDB ()
{
    sqlite3 *_database;
    NSString *_dbpath;
    SSNCuteSerialQueue *_ioQueue;
}

@end

@implementation SSNDB

+ (NSString *)pathForScope:(NSString *)scope
{
    static NSString *dbdir = @"db";
    NSString *dirPath = [dbdir stringByAppendingPathComponent:scope];
    dirPath = [[NSFileManager defaultManager] pathDocumentDirectoryWithPathComponents:dirPath];
    return [dirPath stringByAppendingPathComponent:SSNDBFileName];
}

- (instancetype)initWithScope:(NSString *)scope
{
    NSAssert(scope, @"scope 参数");
    self = [super init];
    if (self)
    {
        if (nil == scope)
        { //效率考虑，空字符串也是可以的
            return nil;
        }

        //全部转成小写
        NSString *lowerScope = [scope lowercaseString];
        _dbpath = [SSNDB pathForScope:lowerScope];

        NSAssert(self.dbpath, @"dbpath 无法建立");
        ssn_log("\ndbpath=%s\n",[_dbpath UTF8String]);
        
        _ioQueue = [[SSNCuteSerialQueue alloc] initWithName:scope];

        dispatch_block_t block = ^{
            // 因为数据库单线程操作，直接SINGLETHREAD即可，效率更高
            if (sqlite3_config(SQLITE_CONFIG_SINGLETHREAD) == SQLITE_OK)
            {
                ssn_log("sqlite3 config single thread!\n");
            }

            // opens database, creating the file if it does not already exist
            if (sqlite3_open([_dbpath UTF8String], &_database) != SQLITE_OK)
            {
                sqlite3_close(_database);
                [self sqliteException:@"Failed to open database with message '%S'."];
            }

            // add hook
            sqlite3_update_hook(_database, &ssn_sqlite_update, (__bridge void *)(self));
            sqlite3_rollback_hook(_database, &ssndb_sqlite_rollback, (__bridge void *)(self));
        };

        [_ioQueue sync:block];
    }
    return self;
}

- (void)dealloc
{
    dispatch_block_t block = ^{
        sqlite3_update_hook(_database, NULL, NULL);
        sqlite3_rollback_hook(_database, NULL, NULL);

        if (sqlite3_close(_database) != SQLITE_OK)
        {
            [self sqliteException:@"Failed to close database with message '%S'."];
        }
    };

    [_ioQueue sync:block];
}

#pragma mark - Hook

static void ssn_sqlite_update(void *user_data, int operation, char const *database_name, char const *table_name, sqlite_int64 row_id)
{
    //并非我们关心的回调
    if (user_data == NULL) {
        return ;
    }
    
    @autoreleasepool {
        ssn_log("\nssn_sqlite_update operation = %d, table_name = %s, row_id = %lld\n",operation ,table_name, row_id);
        
        SSNDB *db = (__bridge SSNDB *)(user_data);
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        if (table_name) {
            [userInfo setObject:[NSString stringWithUTF8String:table_name] forKey:SSNDBTableNameUserInfoKey];
        }
        
        if (operation > 0) {
            [userInfo setObject:@(operation) forKey:SSNDBOperationUserInfoKey];
        }
        
        if (row_id > 0) {
            [userInfo setObject:@(row_id) forKey:SSNDBRowIdUserInfoKey];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SSNDBUpdatedNotification
                                                            object:db
                                                          userInfo:userInfo];

    }
    
}

static void ssndb_sqlite_rollback(void *user_data)
{
    //并非我们关心的回调
    if (user_data == NULL) {
        return ;
    }
    
    @autoreleasepool {
        ssn_log("\nssndb_sqlite_rollback\n");
        
        SSNDB *db = (__bridge SSNDB *)(user_data);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SSNDBRollbackNotification object:db];
        
    }
}

#pragma mark error
- (void)sqliteException:(NSString *)error
{
    [NSException raise:@"SSNDatabaseSQLiteException" format:error, sqlite3_errmsg16(_database)];
}

#pragma sql method
- (NSArray *)columnNamesForStatement:(sqlite3_stmt *)statement
{
    int columnCount = sqlite3_column_count(statement);
    NSMutableArray *columnNames = [NSMutableArray array];
    for (int i = 0; i < columnCount; i++)
    {
        [columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]];
    }
    return columnNames;
}

- (NSArray *)columnTypesForStatement:(sqlite3_stmt *)statement
{
    int columnCount = sqlite3_column_count(statement);
    NSMutableArray *columnTypes = [NSMutableArray array];
    for (int i = 0; i < columnCount; i++)
    {
        [columnTypes addObject:[NSNumber numberWithInt:[self typeForStatement:statement column:i]]];
    }
    return columnTypes;
}

- (int)columnTypeToInt:(NSString *)columnType
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

- (int)typeForStatement:(sqlite3_stmt *)statement column:(int)column
{
    const char *columnType = sqlite3_column_decltype(statement, column);

    if (columnType != NULL)
    {
        return [self columnTypeToInt:[[NSString stringWithUTF8String:columnType] uppercaseString]];
    }

    return sqlite3_column_type(statement, column);
}

- (void)copyValuesFromStatement:(sqlite3_stmt *)statement toRow:(id)row columnTypes:(NSArray *)columnTypes columnNames:(NSArray *)columnNames
{
    int columnCount = sqlite3_column_count(statement);

    for (int i = 0; i < columnCount; i++)
    {
        id value = [self valueFromStatement:statement column:i columnTypes:columnTypes];

        if (value != nil)
        {
            [row setValue:value forKey:[columnNames objectAtIndex:i]];
        }
    }
}

- (id)valueFromStatement:(sqlite3_stmt *)statement column:(int)column columnTypes:(NSArray *)columnTypes
{
    int columnType = [[columnTypes objectAtIndex:column] intValue];

    /*
     * force conversion to the declared type using sql conversions; this saves
     * some problems with NSNull being assigned to non-object values
     */
    if (columnType == SQLITE_INTEGER)
    {
        return [NSNumber numberWithInt:sqlite3_column_int(statement, column)];
    }
    else if (columnType == SQLITE_FLOAT)
    {
        return [NSNumber numberWithDouble:sqlite3_column_double(statement, column)];
    }
    else if (columnType == SQLITE_TEXT)
    {
        const char *text = (const char *)sqlite3_column_text(statement, column);
        if (text != nil)
        {
            return [NSString stringWithUTF8String:text];
        }
        else
        {
            return nil;
        }
    }
    else if (columnType == SQLITE_BLOB)
    {
        // create an NSData object with the same size as the blob
        return [NSData dataWithBytes:sqlite3_column_blob(statement, column)
                              length:sqlite3_column_bytes(statement, column)];
    }
    else if (columnType == SQLITE_NULL)
    {
        return nil;
    }

    return nil;
}

- (void)bindObject:(id)obj toColumn:(int)idx statement:(sqlite3_stmt *)stmt
{

    if ((!obj) || ((NSNull *)obj == [NSNull null]))
    {
        sqlite3_bind_null(stmt, idx);
    }

    // FIXME - someday check the return codes on these binds.
    else if ([obj isKindOfClass:[NSData class]])
    {
        const void *bytes = [obj bytes];
        if (!bytes)
        {
            // it's an empty NSData object, aka [NSData data].
            // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
            bytes = "";
        }
        sqlite3_bind_blob(stmt, idx, bytes, (int)[obj length], SQLITE_STATIC);
    }
    else if ([obj isKindOfClass:[NSDate class]])
    {
        sqlite3_bind_double(stmt, idx, [obj timeIntervalSince1970]);
    }
    else if ([obj isKindOfClass:[NSNumber class]])
    {

        if (strcmp([obj objCType], @encode(char)) == 0)
        {
            sqlite3_bind_int(stmt, idx, [obj charValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned char)) == 0)
        {
            sqlite3_bind_int(stmt, idx, [obj unsignedCharValue]);
        }
        else if (strcmp([obj objCType], @encode(short)) == 0)
        {
            sqlite3_bind_int(stmt, idx, [obj shortValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned short)) == 0)
        {
            sqlite3_bind_int(stmt, idx, [obj unsignedShortValue]);
        }
        else if (strcmp([obj objCType], @encode(int)) == 0)
        {
            sqlite3_bind_int(stmt, idx, [obj intValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned int)) == 0)
        {
            sqlite3_bind_int64(stmt, idx, (long long)[obj unsignedIntValue]);
        }
        else if (strcmp([obj objCType], @encode(long)) == 0)
        {
            sqlite3_bind_int64(stmt, idx, [obj longValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long)) == 0)
        {
            sqlite3_bind_int64(stmt, idx, (long long)[obj unsignedLongValue]);
        }
        else if (strcmp([obj objCType], @encode(long long)) == 0)
        {
            sqlite3_bind_int64(stmt, idx, [obj longLongValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long long)) == 0)
        {
            sqlite3_bind_int64(stmt, idx, (long long)[obj unsignedLongLongValue]);
        }
        else if (strcmp([obj objCType], @encode(float)) == 0)
        {
            sqlite3_bind_double(stmt, idx, [obj floatValue]);
        }
        else if (strcmp([obj objCType], @encode(double)) == 0)
        {
            sqlite3_bind_double(stmt, idx, [obj doubleValue]);
        }
        else if (strcmp([obj objCType], @encode(BOOL)) == 0)
        {
            sqlite3_bind_int(stmt, idx, ([obj boolValue] ? 1 : 0));
        }
        else
        {
            sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    else
    {
        sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
}

- (BOOL)bindArguments:(NSArray *)arguments toStatement:(sqlite3_stmt *)statement
{
    if (arguments == nil)
    { //不需要绑定参数的，直接返回
        return YES;
    }

    int expectedArguments = sqlite3_bind_parameter_count(statement);
    if (expectedArguments != [arguments count])
    {
        return NO;
    }

    for (int i = 1; i <= expectedArguments; i++)
    {
        id argument = [arguments objectAtIndex:i - 1];
        [self bindObject:argument toColumn:i statement:statement];
    }

    return YES;
}

- (NSArray *)prepareSql:sql arguments:arguments rowClass:(Class)aclass
{
    NSMutableArray *rows = [NSMutableArray array];

    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if ([self bindArguments:arguments toStatement:statement])
        {
            BOOL needsToFetchColumnTypesAndNames = YES;
            NSArray *columnTypes = nil;
            NSArray *columnNames = nil;

            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                if (needsToFetchColumnTypesAndNames)
                {
                    columnTypes = [self columnTypesForStatement:statement];
                    columnNames = [self columnNamesForStatement:statement];
                    needsToFetchColumnTypesAndNames = NO;
                }

                @autoreleasepool
                {
                    id row = nil;
                    if (aclass) {
                        row = [[aclass alloc] init];
                    }
                    else {
                        row = [NSMutableDictionary dictionary];
                    }
                    
                    [self copyValuesFromStatement:statement toRow:row columnTypes:columnTypes columnNames:columnNames];
                    [rows addObject:row];
                }
            }

            sqlite3_finalize(statement);
        }
        else
        {
            sqlite3_finalize(statement);

            [self sqliteException:[[NSString stringWithFormat:@"Failed to bind arguments: '%@' with message: ", sql]
                                      stringByAppendingString:@"%S"]];
        }
    }
    else
    {
        [self sqliteException:[[NSString stringWithFormat:@"Failed to execute statement: '%@' with message: ", sql]
                                  stringByAppendingString:@"%S"]];
    }

    return rows;
}

- (void)executeSql:(NSString *)sql
{
    @autoreleasepool
    {
        dispatch_block_t block = ^{ sqlite3_exec(_database, [sql UTF8String], NULL, 0, NULL); };

        [_ioQueue sync:block];
    }
}

- (void)executeSql:(NSString *)sql error:(NSError **)error
{
    @autoreleasepool
    {
        dispatch_block_t block = ^{
            char *err = NULL;
            if (sqlite3_exec(_database, [sql UTF8String], NULL, 0, &err) != SQLITE_OK) {
                NSString *err_str = [NSString stringWithFormat:@"%s",err];
                sqlite3_free(err);
                
                if (error) {
                    *error = [NSError errorWithDomain:@"SSNDB" code:1 userInfo:@{NSLocalizedFailureReasonErrorKey:err_str}];
                }
            }
        };
        
        [_ioQueue sync:block];
    }
}

//执行一条sql命令
- (void)prepareSql:(NSString *)sql, ...
{
    @autoreleasepool
    {

        NSMutableArray *arguments = [NSMutableArray array];

        va_list argumentList;
        va_start(argumentList, sql);
        id argument;
        while ((argument = va_arg(argumentList, id)))
        {
            [arguments addObject:argument];
        }
        va_end(argumentList);

        if ([arguments count] == 0)
        {
            arguments = nil;
        }

        [self prepareSql:sql arguments:arguments];
    }
}

- (void)prepareSql:(NSString *)sql arguments:(NSArray *)arguments
{
    @autoreleasepool
    {
        dispatch_block_t block = ^{ [self prepareSql:sql arguments:arguments rowClass:NULL]; };

        [_ioQueue sync:block];
    }
}

// aclass传入NULL时默认用NSDictionary代替，当执行单纯的sql时，忽略aclass，返回值将为nil,为了防止sql注入，请输入参数
- (NSArray *)objects:(Class)aclass sql:(NSString *)sql, ...
{
    __block NSArray *result = nil;
    @autoreleasepool
    {

        NSMutableArray *arguments = [NSMutableArray array];

        va_list argumentList;
        va_start(argumentList, sql);
        id argument;
        while ((argument = va_arg(argumentList, id)))
        {
            [arguments addObject:argument];
        }
        va_end(argumentList);

        Class rowClass = aclass;
        if (!rowClass)
        {
            rowClass = [NSMutableDictionary class];
        }

        if ([arguments count] == 0)
        {
            arguments = nil;
        }

        dispatch_block_t block = ^{ result = [self prepareSql:sql arguments:arguments rowClass:aclass]; };

        [_ioQueue sync:block];
    }

    return result;
}
- (void)objects:(Class)aclass completion:(void (^)(NSArray *results))completion sql:(NSString *)sql, ...
{
    @autoreleasepool
    {

        NSMutableArray *arguments = [NSMutableArray array];

        va_list argumentList;
        va_start(argumentList, sql);
        id argument;
        while ((argument = va_arg(argumentList, id)))
        {
            [arguments addObject:argument];
        }
        va_end(argumentList);

        Class rowClass = aclass;
        if (!rowClass)
        {
            rowClass = [NSMutableDictionary class];
        }

        if ([arguments count] == 0)
        {
            arguments = nil;
        }

        dispatch_block_t block = ^{
            NSArray *result = [self prepareSql:sql arguments:arguments rowClass:aclass];

            if (completion)
            {
                completion(result);
            }
        };

        [_ioQueue async:block];
    }
}

- (NSArray *)objects:(Class)aclass sql:(NSString *)sql arguments:(NSArray *)arguments
{
    __block NSArray *result = nil;
    @autoreleasepool
    {

        Class rowClass = aclass;
        if (!rowClass)
        {
            rowClass = [NSMutableDictionary class];
        }

        dispatch_block_t block = ^{ result = [self prepareSql:sql arguments:arguments rowClass:aclass]; };

        [_ioQueue sync:block];
    }

    return result;
}

- (void)objects:(Class)aclass sql:(NSString *)sql arguments:(NSArray *)arguments completion:(void (^)(NSArray *results))completion
{
    @autoreleasepool {
        
        Class rowClass = aclass;
        if (!rowClass)
        {
            rowClass = [NSMutableDictionary class];
        }

        dispatch_block_t block = ^{ @autoreleasepool {
            NSArray *result = [self prepareSql:sql arguments:arguments rowClass:aclass];

            if (completion)
            {
                completion(result);
            }
        }};

        [_ioQueue async:block];
    }
}

#pragma Transaction method
//执行事务，在arc中请注意传入strong参数，确保操作完成，防止循环引用
- (void)executeTransaction:(void (^)(SSNDB *database, BOOL *rollback))block sync:(BOOL)sync
{
    if (!block)
    {
        return;
    }
    
    dispatch_block_t in_block = ^{ @autoreleasepool {
        BOOL rollback = NO;
        [self executeSql:@"BEGIN IMMEDIATE TRANSACTION;"];

        block(self, &rollback);

        if (rollback)
        {
            [self executeSql:@"ROLLBACK TRANSACTION;"];
        }
        else
        {
            [self executeSql:@"COMMIT TRANSACTION;"];
        }
    }};

    if (sync)
    {
        [_ioQueue sync:in_block];
    }
    else
    {
        [_ioQueue async:in_block];
    }
}

//执行block，block在数据库执行线程中执行，在arc中请注意传入strong参数，确保操作完成，防止循环引用
- (void)executeBlock:(void (^)(SSNDB *database))block sync:(BOOL)sync {
    if (!block)
    {
        return;
    }
    
    dispatch_block_t in_block = ^{ @autoreleasepool { block(self); }};
    
    if (sync)
    {
        [_ioQueue sync:in_block];
    }
    else
    {
        [_ioQueue async:in_block];
    }
}

@end

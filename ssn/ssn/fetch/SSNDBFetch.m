//
//  SSNDBFetch.m
//  ssn
//
//  Created by lingminjun on 14/11/29.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBFetch.h"

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@interface NSObject (SSNDBFetch)
@end

@implementation NSObject (SSNDBFetch)

static char *ssn_dbfetch_rowid_key = NULL;
- (int64_t)ssn_dbfetch_rowid {
    NSNumber *v = objc_getAssociatedObject(self, &ssn_dbfetch_rowid_key);
    return [v longLongValue];
}

- (void)setSsn_dbfetch_rowid:(int64_t)ssn_dbfetch_rowid {
    objc_setAssociatedObject(self, &ssn_dbfetch_rowid_key, @(ssn_dbfetch_rowid), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - 查询结果级默认实现
@interface SSNDBFetch ()

@property (nonatomic, copy, readonly) NSString *dbTable;//数据来源的表，必填字段

@end

@implementation SSNDBFetch

- (instancetype)initWithEntity:(Class<SSNDBFetchObject>)clazz fromTable:(NSString *)dbTable {
    return [self initWithEntity:clazz sortDescriptors:nil predicate:nil offset:0 limit:0 fromTable:dbTable];
}

- (instancetype)initWithEntity:(Class<SSNDBFetchObject>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit fromTable:(NSString *)dbTable {
    NSAssert([dbTable length], @"必须输入数据来源主表名");
    self = [super init];
    if (self) {
        _entity = clazz;
        _sortDescriptors = [sortDescriptors copy];
        _predicate = [predicate copy];
        _offset = offset;
        _limit = limit;
        _dbTable = dbTable;
    }
    return self;
}

+ (instancetype)fetchWithEntity:(Class<SSNDBFetchObject>)clazz fromTable:(NSString *)dbTable {
    return [[[self class] alloc] initWithEntity:clazz fromTable:dbTable];
}

+ (instancetype)fetchWithEntity:(Class<SSNDBFetchObject>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit fromTable:(NSString *)dbTable {
    return [[[self class] alloc] initWithEntity:clazz sortDescriptors:sortDescriptors predicate:predicate offset:offset limit:limit fromTable:dbTable];
}

#pragma mark copying
- (instancetype)copyWithZone:(NSZone *)zone {
    SSNDBFetch *copy = [[[self class] alloc] initWithEntity:self.entity fromTable:self.dbTable];
    copy.sortDescriptors = self.sortDescriptors;
    copy.predicate = self.predicate;
    copy.offset = self.offset;
    copy.limit = self.limit;
    return copy;
}

#pragma mark sql statement
- (NSString *)sqlWhereStatement {
    //添加where子句
    if (_predicate) {
        return [NSString stringWithFormat:@" WHERE (%@)",[_predicate predicateFormat]];
    }
    return nil;
}

- (NSString *)sqlOrderByStatement {
    if ([_sortDescriptors count]) {
        NSMutableString *sqlstatement = [NSMutableString string];
        
        [sqlstatement appendString:@" ORDER BY "];
        
        BOOL isFirst = YES;
        for (NSSortDescriptor *sort in _sortDescriptors) {
            if (!isFirst) {
                [sqlstatement appendString:@", "];
            }
            isFirst = NO;
            
            [sqlstatement appendFormat:@"%@ %@", sort.key, sort.ascending? @"ASC": @"DESC"];
        }
        
        return sqlstatement;
    }
    return nil;
}

- (NSString *)sqlLimitStatement {
    if (_limit > 0) {
        return [NSString stringWithFormat:@" LIMIT %@, %@", @(_offset), @(_limit)];
    }
    return nil;
}

- (NSString *)sqlStatement {//where子句和order by子句以及limit子句
    
    @autoreleasepool {
        
        NSMutableString *sqlstatement = [NSMutableString string];
        
        //添加where子句
        NSString *where = [self sqlWhereStatement];
        if ([where length]) {
            [sqlstatement appendString:where];
        }
        
        //添加order by子句
        NSString *order = [self sqlOrderByStatement];
        if ([order length]) {
            [sqlstatement appendString:order];
        }
        
        //添加limit子句
        NSString *limit = [self sqlLimitStatement];
        if ([limit length]) {
            [sqlstatement appendString:limit];
        }
        
        return [sqlstatement copy];
    }
}

- (NSString *)fetchSql {
    return [NSString stringWithFormat:@"SELECT rowid AS ssn_dbfetch_rowid,* FROM %@ %@", _dbTable, [self sqlStatement]];
}

- (NSString *)fetchForRowidSql {
    return [NSString stringWithFormat:@"SELECT rowid AS ssn_dbfetch_rowid,* FROM %@ WHERE rowid = ? LIMIT 0,1", _dbTable];
}

@end


#pragma mark -级联表查询实现
@interface SSNDBCascadedItem : NSObject<SSNDBCascadedInfo>
@property (nonatomic,copy) NSString *cascadedTable;//被关联的表
@property (nonatomic,copy) NSString *joinedColumn;//被关联表的字段
@property (nonatomic,copy) NSString *column;//对应于来表字段
@end

@implementation SSNDBCascadedItem

- (instancetype)copyWithZone:(NSZone *)zone {
    SSNDBCascadedItem *copy = [[[self class] alloc] init];
    copy.cascadedTable = self.cascadedTable;
    copy.joinedColumn = self.joinedColumn;
    copy.column = self.column;
    return copy;
}

+ (instancetype)itemWithCascadedTable:(NSString *)cascadedTable joinedColumn:(NSString *)joinedColumn column:(NSString *)column {
    SSNDBCascadedItem *item = [[[self class] alloc] init];
    item.cascadedTable = cascadedTable;
    item.joinedColumn = joinedColumn;
    item.column = column;
    return item;
}

@end


@interface SSNDBCascadeFetch ()

@property (nonatomic,strong) NSMutableDictionary *cascadedMap;//table=>column=>SSNDBCascadedItem存放方式

@end

@implementation SSNDBCascadeFetch

- (NSMutableDictionary *)cascadedMap {
    if (_cascadedMap) {
        return _cascadedMap;
    }
    _cascadedMap = [[NSMutableDictionary alloc] initWithCapacity:1];
    return _cascadedMap;
}

- (void)addCascadedTable:(NSString *)cascadedTable joinedColumn:(NSString *)joinedColumn to:(NSString *)column {
    NSAssert([cascadedTable length] && [joinedColumn length] && [column length], @"请传人正确的参数");
    SSNDBCascadedItem *item = [SSNDBCascadedItem itemWithCascadedTable:cascadedTable joinedColumn:joinedColumn column:column];
    
    NSMutableDictionary *cascadedCls = [self.cascadedMap objectForKey:cascadedTable];
    if (!cascadedCls) {
        cascadedCls = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    [cascadedCls setObject:item forKey:column];
    [self.cascadedMap setObject:cascadedCls forKey:cascadedTable];
}


- (void)removeCascadedTable:(NSString *)cascadedTable to:(NSString *)column {
    NSAssert([cascadedTable length], @"请传人正确的参数");
    
    if (!column) {
        [self.cascadedMap removeObjectForKey:cascadedTable];
    }
    else {
        NSMutableDictionary *cascadedCls = [self.cascadedMap objectForKey:cascadedTable];
        [cascadedCls removeObjectForKey:column];
        if ([cascadedCls count] == 0) {
            [self.cascadedMap removeObjectForKey:cascadedTable];
        }
    }
}


- (NSArray *)cascadedInfos {
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *table in [self.cascadedMap allKeys]) {
        NSMutableDictionary *cascadedCls = [self.cascadedMap objectForKey:table];
        for (NSString *column in [cascadedCls allKeys]) {
            SSNDBCascadedItem *item = [cascadedCls objectForKey:column];
            [items addObject:item];
        }
    }
    return items;
}

- (NSSet *)cascadedTables {
    return [NSSet setWithArray:[self.cascadedMap allKeys]];
}

#pragma mark copying
- (instancetype)copyWithZone:(NSZone *)zone {
    
    SSNDBCascadeFetch *copy = [super copyWithZone:zone];
    copy.queryColumnDescriptors = self.queryColumnDescriptors;
    copy.cascadedMap = [self.cascadedMap mutableCopy];
    return copy;
}

#pragma mark sql statement
- (NSString *)sqlCascadingStatement {
    @autoreleasepool {
        NSMutableString *sql = [NSMutableString string];
        NSArray *items = [self cascadedInfos];
        [items enumerateObjectsUsingBlock:^(SSNDBCascadedItem *item, NSUInteger idx, BOOL *stop) {
            if (idx > 0) {
                [sql appendFormat:@" AND %@.%@ = %@.%@",item.cascadedTable,item.joinedColumn,self.dbTable,item.column];
            }
            else {
                [sql appendFormat:@" %@.%@ = %@.%@",item.cascadedTable,item.joinedColumn,self.dbTable,item.column];
            }
        }];
        
        return sql;
    }
    return nil;
}

- (NSString *)sqlWhereStatement {
    NSMutableString *sql = [NSMutableString string];
    
    NSString *cascade = [self sqlCascadingStatement];
    
    NSString *where = [super sqlWhereStatement];
    if (where) {
        [sql appendString:where];
        
        if (cascade) {
            [sql appendString:cascade];
        }
    }
    else {
        if (cascade) {
            [sql appendFormat:@" WHERE %@",cascade];
        }
    }

    return sql;
}

- (NSString *)perfectColumn:(NSString *)column {
    if ([column rangeOfString:@"."].length > 0) {
        return column;
    }
    return [NSString stringWithFormat:@"%@.%@ AS %@",self.dbTable, column, column];
}

- (NSString *)sqlQueryColumnStatement {
    if ([_queryColumnDescriptors count]) {
        NSMutableString *sql = [NSMutableString string];
        [_queryColumnDescriptors enumerateObjectsUsingBlock:^(NSString *column, NSUInteger idx, BOOL *stop) {
            if (idx > 0) {
                [sql appendFormat:@",%@",[self perfectColumn:column]];
            }
            else {
                [sql appendFormat:@"%@",[self perfectColumn:column]];
            }
        }];
        return sql;
    }
    return @"*";
}

- (NSString *)sqlFromTablesStatement {
    NSMutableString *sql = [NSMutableString stringWithString:self.dbTable];
    
    NSArray *tables = [self.cascadedMap allKeys];
    if ([tables count]) {
        [sql appendFormat:@",%@",[tables componentsJoinedByString:@","]];
    }
    return sql;
}

- (NSString *)fetchSql {
    return [NSString stringWithFormat:@"SELECT %@.rowid AS ssn_dbfetch_rowid,%@ FROM %@ %@", self.dbTable, [self sqlQueryColumnStatement],[self sqlFromTablesStatement], [self sqlStatement]];
}

- (NSString *)fetchForRowidSql {
    return [NSString stringWithFormat:@"SELECT %@.rowid AS ssn_dbfetch_rowid,%@ FROM %@ %@ AND %@.rowid = ? LIMIT 0,1", self.dbTable, [self sqlQueryColumnStatement], [self sqlFromTablesStatement], [self sqlWhereStatement], self.dbTable];
}

- (NSString *)fetchForCascadedTableChangedSql:(NSString *)table {
    return [NSString stringWithFormat:@"SELECT %@.rowid AS ssn_dbfetch_rowid FROM %@ %@ AND %@.rowid = ? LIMIT 0,1", self.dbTable, [self sqlFromTablesStatement], [self sqlWhereStatement],table];
}


@end


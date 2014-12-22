//
//  SSNDBBound.m
//  ssn
//
//  Created by lingminjun on 14/12/13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBBound.h"
#import "SSNBound.h"
#import "SSNDBTable.h"
#import "NSString+SSN.h"
#import "SSNDB.h"

@interface SSNDBBound : NSObject <SSNBound>

@property (nonatomic, strong) NSString *column;//绑定对象属性
@property (nonatomic, strong) NSString *tiekey;//被影响的属性
@property (nonatomic, strong) NSString *tailkey;//绑定对象记录绑定key，绑定到dbtable上
@property (nonatomic, copy) ssn_dbbound_mapping map1;
@property (nonatomic, copy) ssn_dbbound_batch_mapping map2;
@property (nonatomic, copy) ssn_dbbound_general_mapping map3;
@property (nonatomic, weak) id tobj;
@property (nonatomic, weak) SSNDBTable *table;

@property (nonatomic,strong) id<NSCopying> isEqualValue;
@property (nonatomic) int64_t rowid;

@property (nonatomic,strong) NSString *sql;

- (void)tableChangedNotify:(NSNotification *)notify;

- (NSArray *)fetchResults;

- (void)processChangedWithResults:(NSArray *)results;//处理监听的修改

- (void)processMainThreadChangedWithResults:(NSArray *)results;//处理监听的修改
@end

@implementation SSNDBBound

/**
 @brief 返回另一端对象
 */
- (id)ssn_tailObject {
    return _table;
}

/**
 @brief 返回另一端绑定的key
 */
- (NSString *)ssn_tailKey {
    return _tailkey;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)fetchResults {
    if (_rowid > 0) {//通过rowid的需要取到值
        return  [_table.db objects:nil sql:_sql arguments:@[@(_rowid)]];
    }
    else if (_isEqualValue)
    {
        return [_table.db objects:nil sql:_sql arguments:@[_isEqualValue]];
    }
    else //通用
    {
        return [_table.db objects:nil sql:_sql arguments:nil];
    }
    
    return nil;
}

- (void)tableChangedNotify:(NSNotification *)notify {
    //可以处理数据了
    NSArray *rts = [self fetchResults];
    [self processMainThreadChangedWithResults:rts];
}

- (void)processChangedWithResults:(NSArray *)results {
    
    id tobj = _tobj;
    id table = _table;
    
    if (nil == tobj || nil == table) {
        [tobj ssn_clearTieFieldBound:_tiekey];
        return ;
    }
    
    id value = nil;
    if (_rowid > 0) {//通过rowid的需要取到值
        id chaned_new_value = [[results firstObject] valueForKey:_column];
        
        id value = chaned_new_value;
        if (_map1) {
            value = _map1(table,  _column, chaned_new_value);
        }
    }
    else if (_isEqualValue)
    {
        NSArray *values = [results valueForKey:_column];
        if (_map2) {
            value = _map2(table,  _column, values);
        }
        else {
            value = [values firstObject];
        }
    }
    else //通用
    {
        if (_map3) {
            value = _map3(table, _sql, results);
        }
    }
    
    if (value) {
        [_tobj setValue:value forKey:_tiekey];
    }
    else {
        [_tobj setNilValueForKey:_tiekey];
    }
}

- (void)processMainThreadChangedWithResults:(NSArray *)results {
    __weak typeof(self) w_self = self;
    dispatch_block_t block = ^{
        __strong typeof(w_self) self = w_self;
        [self processChangedWithResults:results];
    };
    
    if ([NSThread isMainThread]) {//性能受损
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
@end


@implementation NSObject (SSNDBBound)

/**
 @brief 添加一个绑定到数据表单行数据的一个字段上
 @param table   绑定某个数据表，
 @param column  绑定数据表中在rowid上的数据列
 @param rowid   绑定数据表中rowid上的数据，
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 */
- (void)ssn_boundTable:(SSNDBTable *)table forColumn:(NSString *)column at:(int64_t)rowid tieField:(NSString *)tieField {
    [self ssn_boundTable:table forColumn:column at:rowid tieField:tieField map:nil];
}


/**
 @brief 添加一个绑定到数据表单行数据的一个字段上
 @param table   绑定某个数据表，
 @param column  绑定数据表中在rowid上的数据列
 @param rowid   绑定数据表中rowid上的数据，
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 @param map         映射，注意不要循环引用
 */
- (void)ssn_boundTable:(SSNDBTable *)table forColumn:(NSString *)column at:(int64_t)rowid tieField:(NSString *)tieField map:(ssn_dbbound_mapping)map {
    if (nil == table || nil == table.db || [column length] == 0 || [tieField length] == 0 || rowid <= 0) {
        return ;
    }
    
    SSNDBBound *bound = [[SSNDBBound alloc] init];
    bound.table = table;
    bound.tobj = self;
    bound.column = [column copy];
    bound.tiekey = [tieField copy];
    bound.tailkey = [NSString stringWithUTF8Format:"%p-%s",self,[column UTF8String]];
    bound.map1 = map;
    bound.rowid = rowid;
    
    //联系起来
    [self ssn_tieBound:bound forKey:tieField];
    [table ssn_tieTailBound:[SSNWeakBound bound:bound] forKey:bound.tailkey];
    
    //注册key-value change，将bound对象传入，不要引用bound，
    [[NSNotificationCenter defaultCenter] addObserver:bound selector:@selector(tableChangedNotify:) name:SSNDBTableUpdatedNotification object:table];

    //将数据加载下
    bound.sql = [NSString stringWithUTF8Format:"SELECT %s FROM %s WHERE rowid = ?", [column UTF8String], [table.name UTF8String]];
    
    NSArray *rts = [bound fetchResults];
    [bound processMainThreadChangedWithResults:rts];
}


/**
 @brief 添加一个绑定到数据表批量数据上
 @param table   绑定某个数据表，
 @param column  绑定数据表中列等于value的数据
 @param value   绑定数据表中column等于的value的数据
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 */
- (void)ssn_boundTable:(SSNDBTable *)table forColumn:(NSString *)column isEqual:(id)value tieField:(NSString *)tieField {
    [self ssn_boundTable:table forColumn:column isEqual:value tieField:tieField map:nil];
}


/**
 @brief 添加一个绑定到数据表批量数据上
 @param table   绑定某个数据表，
 @param column  绑定数据表中列等于value的数据
 @param value   绑定数据表中column等于的value的数据
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 @param map         映射，注意不要循环引用
 */
- (void)ssn_boundTable:(SSNDBTable *)table forColumn:(NSString *)column isEqual:(id)value tieField:(NSString *)tieField map:(ssn_dbbound_batch_mapping)map {
    if (nil == table || nil == table.db || [column length] == 0 || [tieField length] == 0 || value == nil) {
        return ;
    }
    
    SSNDBBound *bound = [[SSNDBBound alloc] init];
    bound.table = table;
    bound.tobj = self;
    bound.column = [column copy];
    bound.tiekey = [tieField copy];
    bound.tailkey = [NSString stringWithUTF8Format:"%p-%s",self,[column UTF8String]];
    bound.map2 = map;
    bound.isEqualValue = [value copy];
    
    //联系起来
    [self ssn_tieBound:bound forKey:tieField];
    [table ssn_tieTailBound:[SSNWeakBound bound:bound] forKey:bound.tailkey];
    
    //注册key-value change，将bound对象传入，不要引用bound，
    [[NSNotificationCenter defaultCenter] addObserver:bound selector:@selector(tableChangedNotify:) name:SSNDBTableUpdatedNotification object:table];
    
    //将数据加载下
    bound.sql = [NSString stringWithUTF8Format:"SELECT %s FROM %s WHERE %s = ?", [column UTF8String], [table.name UTF8String], [column UTF8String]];
    
    NSArray *rts = [bound fetchResults];
    [bound processMainThreadChangedWithResults:rts];
}


/**
 @brief 添加一个绑定到数据表批量数据上
 @param table   绑定某个数据表，
 @param sql     sql支持的sql语句
 @param tieField   绑定作用的属性，该属性必须支持setter方法
 @param map        映射，注意不要循环引用
 */
- (void)ssn_boundTable:(SSNDBTable *)table forSQL:(NSString *)sql tieField:(NSString *)tieField map:(ssn_dbbound_general_mapping)map {
    if (nil == table || nil == table.db || [sql length] == 0 || [tieField length] == 0 || nil == map) {
        return ;
    }
    
    SSNDBBound *bound = [[SSNDBBound alloc] init];
    bound.table = table;
    bound.tobj = self;
    bound.sql = [sql copy];
    bound.tiekey = [tieField copy];
    bound.tailkey = [NSString stringWithUTF8Format:"%p-%s",self,[sql UTF8String]];
    bound.map3 = map;
    
    //联系起来
    [self ssn_tieBound:bound forKey:tieField];
    [table ssn_tieTailBound:[SSNWeakBound bound:bound] forKey:bound.tailkey];
    
    //注册key-value change，将bound对象传入，不要引用bound，
    [[NSNotificationCenter defaultCenter] addObserver:bound selector:@selector(tableChangedNotify:) name:SSNDBTableUpdatedNotification object:table];
    
    //将数据加载下
    NSArray *rts = [bound fetchResults];
    [bound processMainThreadChangedWithResults:rts];
}

@end

//
//  SSNModelManager.m
//  ssn
//
//  Created by lingminjun on 14-5-30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNModelManager.h"
#import "SSNDataBase.h"
#import "ssnbase.h"
#import "SSNModel.h"
#import "SSNModelPrivate.h"
#import "SSNMeta.h"


@interface SSNModelManager () {
    SSNDataBase *_database;
}

@property (nonatomic,strong) SSNDataBase *database;

@end

@implementation SSNModelManager

@synthesize database = _database;

- (id)initWithDataBase:(SSNDataBase *)database {
    self = [super init];
    if (self) {
        self.database = database;
    }
    return self;
}

//加载某类型实例的数据，keyPredicate意味着是主键，所以只返回一个对象
- (NSDictionary *)model:(SSNModel *)model table:(NSString *)table loadDatasWithPredicate:(NSString *)keyPredicate {
    NSArray *ary = [self.database queryObjects:nil sql:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",table,keyPredicate],nil];
    return [ary lastObject];
}

//更新实例，不包含主键，存储成功请返回YES，否则返回失败
- (BOOL)model:(SSNModel *)model table:(NSString *)table updateDatas:(NSDictionary *)valueKeys forPredicate:(NSString *)keyPredicate {
    
    NSString *setValuesString = [NSString predicateStringKeyAndValues:valueKeys componentsJoinedByString:@","];
    
    [self.database queryObjects:nil sql:[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",table,setValuesString,keyPredicate],nil];
    
    return YES;
}

//插入实例，如果数据库中已经存在，可以使用replace，也可以返回NO，表示插入失败，根据使用者需要
- (BOOL)model:(SSNModel *)model table:(NSString *)table insertDatas:(NSDictionary *)valueKeys forPredicate:(NSString *)keyPredicate {
    
    NSString *keysString = [[valueKeys allKeys] componentsJoinedByString:@","];
    NSMutableArray *vs = [NSMutableArray array];
    for (NSInteger index = 0; index < [valueKeys count]; index ++) {
        [vs addObject:@"?"];
    }
    NSString *valueString = [vs componentsJoinedByString:@","];
    NSArray *values = [valueKeys objectsForKeys:[valueKeys allKeys] notFoundMarker:[NSNull null]];
    
    [self.database queryObjects:nil sql:[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",table,keysString,valueString] arguments:values];
    
    return YES;
}

//删除实例
- (BOOL)model:(SSNModel *)model table:(NSString *)table deleteForPredicate:(NSString *)keyPredicate {
    [self.database queryObjects:nil sql:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",table,keyPredicate]];
    return YES;
}

- (NSString *)sqlWithKeys:(NSArray *)keys table:(NSString *)table query:(NSString *)queryPredicate group:(NSString *)group sortDescriptors:(NSArray *)sortDescriptors offset:(NSUInteger)offset size:(NSUInteger)size {
    NSString *rsql = nil;
    @autoreleasepool {
        NSMutableString *sql = [NSMutableString stringWithString:@"SELECT "];
        BOOL isFirst = YES;
        for (NSString *str in keys) {
            
            if (isFirst) {
                isFirst = NO;
            }
            else {
                [sql appendString:@","];
            }
            
            if ([str length]) {
                [sql appendString:str];
            }
        }
        
        if ([group length]) {
            
            if (!isFirst) {
                [sql appendString:@","];
            }
            
            [sql appendString:group];
        }
        
        //from
        [sql appendFormat:@" FROM %@",table];
        
        
        //条件
        [sql appendFormat:@" WHERE %@ ",queryPredicate];
        
        //排序
        isFirst = YES;
        if ([sortDescriptors count]) {
            [sql appendString:@" ORDER BY "];
            for (NSSortDescriptor *sort in sortDescriptors) {
                if (isFirst) {
                    isFirst = NO;
                }
                else {
                    [sql appendString:@","];
                }
                
                if (sort.ascending) {
                    [sql appendFormat:@"%@ ASC",sort.key];
                }
                else {
                    [sql appendFormat:@"%@ DESC",sort.key];
                }
            }
        }
        
        if (size > 0) {
            if (offset) {
                [sql appendFormat:@"LIMIT %lu,%lu",(unsigned long)offset,(unsigned long)size];
            }
            else {
                [sql appendFormat:@"LIMIT %lu",(unsigned long)size];
            }
        }
        
        rsql = [NSString stringWithString:sql];
    }
    
    return rsql;
}

//批量数据支持，数据全部取出来
- (NSArray *)keys:(NSArray *)keys table:(NSString *)table query:(NSString *)queryPredicate group:(NSString *)group sortDescriptors:(NSArray *)sortDescriptors {
    
    NSMutableArray *gkeys = [NSMutableArray arrayWithCapacity:1];
    if (keys) {
        [gkeys setArray:keys];
    }
    
    if (group) {
        [gkeys addObject:group];
    }
    
    NSString *sql = [self sqlWithKeys:gkeys
                                table:table
                                query:queryPredicate
                                group:group
                      sortDescriptors:sortDescriptors
                               offset:0
                                 size:0];
    
    NSArray *ary = [self.database queryObjects:nil sql:sql arguments:nil];
    
    return ary;
}

//这是取单个分组中的数据，
- (NSArray *)keys:(NSArray *)keys table:(NSString *)table query:(NSString *)queryPredicate sortDescriptors:(NSArray *)sortDescriptors offset:(NSUInteger)offset size:(NSUInteger)size {
    
    NSString *sql = [self sqlWithKeys:keys
                                table:table
                                query:queryPredicate
                                group:nil
                      sortDescriptors:sortDescriptors
                               offset:offset
                                 size:size];
    
    NSArray *ary = [self.database queryObjects:nil sql:sql arguments:nil];
    
    return ary;
}

//- (NSArray *)sqlsWithInsert:(NSArray *)inserts update:(NSArray *)updates delete:(NSArray *)deletes table:(NSString *)table {
//    NSMutableArray *sqls = [NSMutableArray arrayWithCapacity:3];
//    
//    for (<#initialization#>; <#condition#>; <#increment#>) {
//        <#statements#>
//    }
//}

//批量存储接口
- (BOOL)storeInsert:(NSArray *)inserts update:(NSArray *)updates delete:(NSArray *)deletes table:(NSString *)table {
    //self.database
    return YES;
}


#ifdef SSN_USER_DETACHED_MODEL_MANAGER
//需要接管所有实例创建方法
- (SSNModel *)modelWithClass:(Class)aclass keyPredicate:(NSString *)keyPredicate {
    return [aclass modelWithKeyPredicate:keyPredicate manager:self];
}
- (SSNModel *)modelWithClass:(Class)aclass values:(NSArray *)values keys:(NSArray *)keys {
    return [aclass modelWithValues:values keys:keys manager:self];
}
- (SSNModel *)modelWithClass:(Class)aclass keyAndValues:(NSDictionary *)keyValues {
    return [aclass modelWithKeyAndValues:keyValues manager:self];
}

- (BOOL)insertModel:(SSNModel *)model {//delete的数据将调用model:updateDatas:forPredicate:方法执行
    if (model.manager == nil) {
        return NO;
    }
    NSAssert(model.manager != self, @"%@对象管理器与实际操作管理器不是同一实例",self);
    
    NSString *predicate = [model keyPredicate];
    if ([predicate length] == 0) {
        return NO;
    }
    
    BOOL result = [self model:model table:[model tableName] insertDatas:model.vls forPredicate:predicate];
    if (!result) {
        return NO;
    }
    
    //插入成功，必须保存meta
    if (model.meta) {//存在meta，需要，更新信息
        [SSNMeta loadMeta:model.meta datas:model.vls];
        model.opt = model.meta.opt;
    }
    else {//不存在
        model.meta = SSNMetaFactory([model class], predicate);
        [SSNMeta loadMeta:model.meta datas:model.vls];
        model.opt = model.meta.opt;
    }
    
    return result;
}
- (BOOL)updateModel:(SSNModel *)model {
    
    if (model.manager == nil) {
        return NO;
    }
    NSAssert(model.manager != self, @"%@对象管理器与实际操作管理器不是同一实例",self);
    
    if ([model isTemporary]) {
        return NO;
    }
    
    if (![model hasChanged]) {
        return NO;
    }
    
    NSString *predicate = [model keyPredicate];
    if ([predicate length] == 0) {
        return NO;
    }
    
    NSArray *pKeys = [model primaryKeys];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:model.vls];
    [dic removeObjectsForKeys:pKeys];
    
    BOOL result = [self model:model table:[model tableName] updateDatas:dic forPredicate:predicate];
    if (!result) {
        return NO;
    }
    
    //插入成功，必须保存meta
    if (model.meta) {//存在meta，需要，更新信息
        [SSNMeta loadMeta:model.meta datas:model.vls];
        model.opt = model.meta.opt;
    }
    else {//不存在
        model.meta = SSNMetaFactory([model class], predicate);
        [SSNMeta loadMeta:model.meta datas:model.vls];
        model.opt = model.meta.opt;
    }
    model.hasChanged = NO;
    
    return result;

}

- (BOOL)deleteModel:(SSNModel *)model {
    if (model.manager == nil) {
        return NO;
    }
    
    NSAssert(model.manager != self, @"%@对象管理器与实际操作管理器不是同一实例",self);
    
    if ([model isTemporary]) {
        return NO;
    }
    
    NSString *predicate = [model keyPredicate];
    if ([predicate length] == 0) {
        return NO;
    }
    
    BOOL result = [self model:model table:[model tableName] deleteForPredicate:predicate];
    if (!result) {
        return NO;
    }
    
    //插入成功，必须保存meta
    if (model.meta) {//存在meta，需要，更新信息
        [SSNMeta deleteMeta:model.meta];
        model.opt = model.meta.opt;
    }
    else {//不存在
        model.meta = SSNMetaFactory([model class], predicate);
        [SSNMeta deleteMeta:model.meta];
        model.opt = model.meta.opt;
    }
    
    return YES;
}

#endif

@end

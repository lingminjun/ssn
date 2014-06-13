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
- (NSDictionary *)model:(SSNModel *)model loadDatasWithPredicate:(NSString *)keyPredicate {
    NSArray *ary = [self.database queryObjects:nil sql:[NSString stringWithFormat:@"SELECT * FROM TestModel WHERE %@",keyPredicate],nil];
    return [ary lastObject];
}

//更新实例，不包含主键，存储成功请返回YES，否则返回失败
- (BOOL)model:(SSNModel *)model updateDatas:(NSDictionary *)valueKeys forPredicate:(NSString *)keyPredicate {
    
    NSString *setValuesString = [NSString predicateStringKeyAndValues:valueKeys componentsJoinedByString:@","];
    
    [self.database queryObjects:nil sql:[NSString stringWithFormat:@"UPDATE TestModel SET %@ WHERE %@",setValuesString,keyPredicate],nil];
    
    return YES;
}

//插入实例，如果数据库中已经存在，可以使用replace，也可以返回NO，表示插入失败，根据使用者需要
- (BOOL)model:(SSNModel *)model insertDatas:(NSDictionary *)valueKeys forPredicate:(NSString *)keyPredicate {
    
    NSString *keysString = [[valueKeys allKeys] componentsJoinedByString:@","];
    NSMutableArray *vs = [NSMutableArray array];
    for (NSInteger index = 0; index < [valueKeys count]; index ++) {
        [vs addObject:@"?"];
    }
    NSString *valueString = [vs componentsJoinedByString:@","];
    NSArray *values = [valueKeys objectsForKeys:[valueKeys allKeys] notFoundMarker:[NSNull null]];
    
    [self.database queryObjects:nil sql:[NSString stringWithFormat:@"INSERT INTO TestModel (%@) VALUES (%@)",keysString,valueString] arguments:values];
    
    return YES;
}

//删除实例
- (BOOL)model:(SSNModel *)model deleteForPredicate:(NSString *)keyPredicate {
    [self.database queryObjects:nil sql:[NSString stringWithFormat:@"DELETE FROM TestModel WHERE %@",keyPredicate]];
    return YES;
}

//批量数据支持，数据全部取出来
- (NSArray *)keys:(NSArray *)keys query:(NSString *)queryPredicate group:(NSString *)group sortDescriptors:(NSArray *)sortDescriptors {
    
//    NSString *sql = [NSString stringWithFormat:@"SELECT %@ "]
//    
//    [self.database queryObjects:nil sql:[NSString stringWithFormat:@"INSERT INTO TestModel (%@) VALUES (%@)",keysString,valueString] arguments:values];
    return nil;
}

//这是取单个分组中的数据，
- (NSArray *)keys:(NSArray *)keys query:(NSString *)queryPredicate sortDescriptors:(NSArray *)sortDescriptors offset:(NSUInteger)offset size:(NSUInteger)size {
    return nil;
}

//批量存储接口
- (BOOL)storeInsert:(NSArray *)inserts update:(NSArray *)updates delete:(NSArray *)deletes {
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
    
    BOOL result = [self model:model insertDatas:model.vls forPredicate:predicate];
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
    
    BOOL result = [self model:model updateDatas:dic forPredicate:predicate];
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
    
    BOOL result = [self model:model deleteForPredicate:predicate];
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

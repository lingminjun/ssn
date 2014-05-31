//
//  SSNModelManager.h
//  ssn
//
//  Created by lingminjun on 14-5-30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNModel.h"

@class SSNDataBase;

@interface SSNModelManager : NSObject <SSNModelManagerProtocol>

@property (nonatomic,strong,readonly) SSNDataBase *database;//默认不管理链接

- (id)initWithDataBase:(SSNDataBase *)database;


#ifdef SSN_USER_DETACHED_MODEL_MANAGER
//需要接管所有实例创建方法
- (SSNModel *)modelWithClass:(Class)aclass keyPredicate:(NSString *)keyPredicate;//内部会校验其 keyPredicate的合法性
- (SSNModel *)modelWithClass:(Class)aclass values:(NSArray *)values keys:(NSArray *)keys;
- (SSNModel *)modelWithClass:(Class)aclass keyAndValues:(NSDictionary *)keyValues;

//io操作执行
- (BOOL)insertModel:(SSNModel *)model;//delete的数据将调用model:updateDatas:forPredicate:方法执行
- (BOOL)updateModel:(SSNModel *)model;//非临时数据且非删除数据，并且有更改将会调用model:insertDatas:forPredicate:方法执行
- (BOOL)deleteModel:(SSNModel *)model;//非临时数据，或者非已经删除数据，都会调用model:deleteForPredicate:方法执行
#endif


@end

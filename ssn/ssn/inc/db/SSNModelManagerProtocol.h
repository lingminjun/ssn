//
//  SSNModelManagerProtocol.h
//  ssn
//
//  Created by lingminjun on 14-5-31.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSNModel;

@protocol SSNModelManagerProtocol <NSObject>

//加载某类型实例的数据，keyPredicate意味着是主键，所以只返回一个对象
- (NSDictionary *)model:(SSNModel *)model loadDatasWithPredicate:(NSString *)keyPredicate;

//更新实例，不包含主键，存储成功请返回YES，否则返回失败
- (BOOL)model:(SSNModel *)model updateDatas:(NSDictionary *)valueKeys forPredicate:(NSString *)keyPredicate;

//插入实例，如果数据库中已经存在，可以使用replace，也可以返回NO，表示插入失败，根据使用者需要
- (BOOL)model:(SSNModel *)model insertDatas:(NSDictionary *)valueKeys forPredicate:(NSString *)keyPredicate;

//删除实例
- (BOOL)model:(SSNModel *)model deleteForPredicate:(NSString *)keyPredicate;

//批量数据支持，数据全部取出来
- (NSArray *)keys:(NSArray *)keys query:(NSString *)queryPredicate group:(NSString *)group sortDescriptors:(NSArray *)sortDescriptors;

//这是取单个分组中的数据，
- (NSArray *)keys:(NSArray *)keys query:(NSString *)queryPredicate sortDescriptors:(NSArray *)sortDescriptors offset:(NSUInteger)offset size:(NSUInteger)size;

//批量存储接口
- (BOOL)storeInsert:(NSArray *)inserts update:(NSArray *)updates delete:(NSArray *)deletes;

@end

//
//  SSNDB.h
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const SSNDBUpdatedNotification;  //数据库更新 dbthread
FOUNDATION_EXTERN NSString *const SSNDBRollbackNotification; //数据库回滚 dbthread

FOUNDATION_EXTERN NSString *const SSNDBTableNameUserInfoKey;  //notification userinfo key : table name(NSString)
FOUNDATION_EXTERN NSString *const SSNDBOperationUserInfoKey;  //notification userinfo key : operation(NSNumber<int>) eg. SQLITE_INSERT
FOUNDATION_EXTERN NSString *const SSNDBRowIdUserInfoKey;      //notification userinfo key : row_id(NSNumber<int64>)

@interface SSNDB : NSObject

@property (nonatomic, strong, readonly) NSString *dbpath;

//数据库已经被open
- (instancetype)initWithScope:(NSString *)scope;

#pragma sql method
- (void)executeSql:(NSString *)sql;//错误直接忽略

- (void)executeSql:(NSString *)sql error:(NSError **)error;//错误返回

//执行一条sql命令
- (void)prepareSql:(NSString *)sql, ...;//参数必须传入object对象，以nil结尾，此方法不建议使用，效率比较低
- (void)prepareSql:(NSString *)sql arguments:(NSArray *)arguments;

// aclass传入NULL时默认用NSDictionary代替，当执行单纯的sql时，忽略aclass，返回值将为nil,为了防止sql注入，请输入参数
- (NSArray *)objects:(Class)aclass sql:(NSString *)sql, ...; //参数必须传入object对象，以nil结尾，此方法不建议使用，效率比较低
- (void)objects:(Class)aclass completion:(void (^)(NSArray *results))completion sql:(NSString *)sql, ...;//参数必须传入object对象，以nil结尾，此方法不建议使用，效率比较低
- (NSArray *)objects:(Class)aclass sql:(NSString *)sql arguments:(NSArray *)arguments; //参数必须传入object对象,
- (void)objects:(Class)aclass sql:(NSString *)sql arguments:(NSArray *)arguments completion:(void (^)(NSArray *results))completion;

#pragma Transaction method
//执行事务，在arc中请注意传入strong参数，确保操作完成，防止循环引用
- (void)executeTransaction:(void (^)(SSNDB *database, BOOL *rollback))block sync:(BOOL)sync;

//执行block，block在数据库执行线程中执行，在arc中请注意传入strong参数，确保操作完成，防止循环引用
- (void)executeBlock:(void (^)(SSNDB *database))block sync:(BOOL)sync;

@end

//
//  SSNDB.h
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const SSNDBUpdatedNotification;  //数据库更新 dbthread
//FOUNDATION_EXTERN NSString *const SSNDBCommitNotification; //数据库事务提交 dbthread
//FOUNDATION_EXTERN NSString *const SSNDBRollbackNotification; //数据库回滚 dbthread

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

#pragma attach other database completed arduous task
/**
 @brief 创建一个临时库来执行一项艰巨的任务，这里建议是一些非常耗时的任务，然后关联两个数据库，进行数据库关联操作，请不要随意使用，注意保持一个attachDatabase独立
 @param attachDatabase 临时库的名字，目录在主库目录下
 @param arduousBlock   艰巨任务执行block，临时库不建议应用出block，每次操作完他将关闭，不然后面的attach 可能失效，此block在非主库线程中
 @param attachBlock    最后关联动作执行，此block在主库线程中执行
 
 使用场景说明：比如有一项非常艰巨的任务，大批量的数据导入，如果直接在主库线程中执行，非常占用时间，导致其他模块阻塞，你可以采用临时库来完成
    sql:[db executeSql:@"INSERT OR IGNORE INTO table_name SELECT * FROM attach_db.table_name"];
 */
- (void)addAttachDatabase:(NSString *)attachDatabase arduousBlock:(void (^)(SSNDB *attachDB))arduousBlock attachBlock:(void (^)(SSNDB *db, NSString *attachDatabase))attachBlock;

/**
 @brief 移除临时表
 @param attachDatabase 临时库的名字，目录在主库目录下
 */
- (void)removeAttachDatabase:(NSString *)attachDatabase;//删除临时数据库

@end

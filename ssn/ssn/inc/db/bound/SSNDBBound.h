//
//  SSNDBBound.h
//  ssn
//
//  Created by lingminjun on 14/12/13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSNDBTable;//数据表绑定

/**
 @brief 映射，对目标改变值重新转换，最后转换成监听者可以赋值(KVC)的对象
 @param table     绑定的目标数据表
 @param column    绑定的目标数据表对应的列
 @param changed_new_value 绑定目标对象对应column列发生改变时新设置的值
 @return 返回合适的对象
 */
typedef id (^ssn_dbbound_mapping)(SSNDBTable *table, NSString *column, id changed_new_value);


/**
 @brief 映射，对目标改变值重新转换，最后转换成监听者可以赋值(KVC)的对象
 @param table     绑定的目标数据表
 @param column    绑定的目标数据表对应的列，这里不单单是某一列，凡是sqlite支持的函数都可以，如: sum(*) AS count
 @param changed_new_values 所有符合条件的数据column字段的值，
 @return 返回合适的对象
 */
typedef id (^ssn_dbbound_batch_mapping)(SSNDBTable *table, NSString *column, NSArray *changed_new_values);

/**
 @brief 映射，对目标改变值重新转换，最后转换成监听者可以赋值(KVC)的对象
 @param table  绑定的目标数据表
 @param sql    绑定的目标数据表对应的列，这里不单单是某一列，凡是sqlite支持的函数都可以，如: sum(*) AS count
 @param changed_new_values 所有符合条件的数据字典形式
 @return 返回合适的对象
 */
typedef id (^ssn_dbbound_general_mapping)(SSNDBTable *table, NSString *sql, NSArray *changed_new_values);

/**
 @brief 绑定器，数据库数据表绑定器，
 */
@interface NSObject (SSNDBBound)

/**
 @brief 添加一个绑定到数据表单行数据的一个字段上
 @param table   绑定某个数据表，
 @param column  绑定数据表中在rowid上的数据列
 @param rowid   绑定数据表中rowid上的数据，
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 */
- (void)ssn_boundTable:(SSNDBTable *)table forColumn:(NSString *)column at:(int64_t)rowid tieField:(NSString *)tieField;


/**
 @brief 添加一个绑定到数据表单行数据的一个字段上
 @param table   绑定某个数据表，
 @param column  绑定数据表中在rowid上的数据列
 @param rowid   绑定数据表中rowid上的数据，
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 @param map         映射，注意不要循环引用
 */
- (void)ssn_boundTable:(SSNDBTable *)table forColumn:(NSString *)column at:(int64_t)rowid tieField:(NSString *)tieField map:(ssn_dbbound_mapping)map;


/**
 @brief 添加一个绑定到数据表批量数据上
 @param table   绑定某个数据表，
 @param column  绑定数据表中列等于value的数据
 @param value   绑定数据表中column等于的value的数据
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 */
- (void)ssn_boundTable:(SSNDBTable *)table forColumn:(NSString *)column isEqual:(id<NSCopying>)value tieField:(NSString *)tieField;


/**
 @brief 添加一个绑定到数据表批量数据上
 @param table   绑定某个数据表，
 @param column  绑定数据表中列等于value的数据
 @param value   绑定数据表中column等于的value的数据
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 @param map         映射，注意不要循环引用
 */
- (void)ssn_boundTable:(SSNDBTable *)table forColumn:(NSString *)column isEqual:(id<NSCopying>)value tieField:(NSString *)tieField map:(ssn_dbbound_batch_mapping)map;


/**
 @brief 添加一个绑定到数据表批量数据上
 @param table   绑定某个数据表，
 @param sql     sql支持的sql语句
 @param tieField   绑定作用的属性，该属性必须支持setter方法
 @param map        映射，注意不要循环引用，必须存在
 */
- (void)ssn_boundTable:(SSNDBTable *)table forSQL:(NSString *)sql tieField:(NSString *)tieField map:(ssn_dbbound_general_mapping)map;

@end

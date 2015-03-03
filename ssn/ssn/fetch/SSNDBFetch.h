//
//  SSNDBFetch.h
//  ssn
//
//  Created by lingminjun on 14/11/29.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SSNDBFetchObject,SSNDBCascadedInfo;


/**
 *  查询数据集描述
 */
@protocol SSNDBFetchRequest <NSObject,NSCopying>

@required
- (NSString *)dbTable;//数据查询来源主表

- (Class<SSNDBFetchObject>)entity;//数据返回实例，如果你不传入对象，则返回数据项放入字典中

- (NSArray *)sortDescriptors;//<NSSortDescriptor *>

@property (nonatomic) NSUInteger offset;//起始点，按照sortDescriptors排序的起始值

@property (nonatomic) NSUInteger limit;//限制大小，传入0表示无限制

- (NSString *)fetchSql;//查询sql

- (NSString *)fetchForRowidSql;//查询sql单个数据

@optional

//查询字段描述，若没有实现，则采用当前表所有字段，可以填写"column AS alias_name"来实现表字段与实体字段部队一个问题
- (NSArray *)queryColumnDescriptors;

- (NSPredicate *)predicate; //eg. "userId = 8888"

- (NSSet *)cascadedTables;//被级联的表

- (NSString *)fetchForCascadedTableChangedSql:(NSString *)table;//查询sql 因为级联表发生改变影响到原来数据项的

@end



/**
 *  查询数据集描述默认实现
 */
@interface SSNDBFetch : NSObject<SSNDBFetchRequest>

@property (nonatomic, strong) Class<SSNDBFetchObject> entity; //数据返回实例，如果你不传入对象，则返回数据项放入字典中

@property (nonatomic, copy) NSArray *sortDescriptors; //<NSSortDescriptor *>

@property (nonatomic, copy) NSPredicate *predicate; //eg. "userId = 8888"

@property (nonatomic) NSUInteger offset;//起始点，按照sortDescriptors排序的起始值

@property (nonatomic) NSUInteger limit;//限制大小，传入0表示无限制

- (instancetype)initWithEntity:(Class<SSNDBFetchObject>)clazz fromTable:(NSString *)dbTable;
- (instancetype)initWithEntity:(Class<SSNDBFetchObject>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit fromTable:(NSString *)dbTable;

+ (instancetype)fetchWithEntity:(Class<SSNDBFetchObject>)clazz fromTable:(NSString *)dbTable;
+ (instancetype)fetchWithEntity:(Class<SSNDBFetchObject>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit fromTable:(NSString *)dbTable;

@end


/**
 *  查询数据集描述
 */
@interface SSNDBCascadeFetch : SSNDBFetch

/**
 *  需要查询的字段，级联操作必须填写表明.类型 cascaded_table_name.column AS alias_name
 */
@property(nonatomic,copy) NSArray *queryColumnDescriptors;

/**
 *  添加联合表项，被关联表可以有多个关联字段
 *
 *  @param cascadedTable  被级联的表，不能为空
 *  @param joinedColumn   被级联字段（被级联表中的字段），不能为空
 *  @param column         原表中字段，不能为空
 *
 */
- (void)addCascadedTable:(NSString *)cascadedTable joinedColumn:(NSString *)joinedColumn to:(NSString *)column;

/**
 *  删除级联项
 *
 *  @param cascadedTable  被级联的表，不能为空，
 *  @param column         关联原表中字段，如果为nil时，删除整改表的
 */
- (void)removeCascadedTable:(NSString *)cascadedTable to:(NSString *)column;

/**
 *  所有关联属性
 *
 *  @return 返回所有关联NSArray<SSNDBCascadedInfo>
 */
- (NSArray *)cascadedInfos;


/**
 *  所有被级联的表
 *
 *  @return 级联的表 NSSet<NSString>
 */
- (NSSet *)cascadedTables;//级联的表

/**
 *  级联表修改rowid影响到原来数据的数据
 *
 *  @param table 级联的表
 *
 *  @return sql语句
 */
- (NSString *)fetchForCascadedTableChangedSql:(NSString *)table;

@end


/**
 *  fetch使用满足fetch对象协议
 */
@protocol SSNDBFetchObject <NSObject,NSCopying>

@required//建议实现，可以减少增加fetch遍历效率
@property (nonatomic) int64_t ssn_dbfetch_rowid;//NSCopying实现是一定要将ssn_dbfetch_rowid赋值

@end

/**
 *  关联数据，仅仅支持字段相等关联
 */
@protocol SSNDBCascadedInfo <NSObject,NSCopying>

- (NSString *)cascadedTable;//被关联的表
- (NSString *)joinedColumn;//被关联表的字段
- (NSString *)column;//对应于来表字段

@end


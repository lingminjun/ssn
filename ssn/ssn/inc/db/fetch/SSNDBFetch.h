//
//  SSNDBFetch.h
//  ssn
//
//  Created by lingminjun on 14/11/29.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SSNDBFetchObject;

/**
 *  查询数据集描述
 */
@interface SSNDBFetch : NSObject<NSCopying>

@property (nonatomic, strong) Class<SSNDBFetchObject> entity; //数据返回实例，如果你不传入对象，则返回数据项放入字典中

@property (nonatomic, copy) NSArray *sortDescriptors; //<NSSortDescriptor *>

@property (nonatomic, copy) NSPredicate *predicate; //eg. "userId = 8888"

@property (nonatomic) NSUInteger offset;//起始点，按照sortDescriptors排序的起始值

@property (nonatomic) NSUInteger limit;//限制大小，传入0表示无限制

- (instancetype)initWithEntity:(Class<SSNDBFetchObject>)clazz;
- (instancetype)initWithEntity:(Class<SSNDBFetchObject>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit;

+ (instancetype)fetchWithEntity:(Class<SSNDBFetchObject>)clazz;
+ (instancetype)fetchWithEntity:(Class<SSNDBFetchObject>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit;

- (NSString *)sqlStatement;//where子句和order by子句以及limit子句

@end

//fetch使用满足fetch对象协议
@protocol SSNDBFetchObject <NSObject,NSCopying>

@required//建议实现，可以减少增加fetch遍历效率
@property (nonatomic) int64_t ssn_dbfetch_rowid;//

@end

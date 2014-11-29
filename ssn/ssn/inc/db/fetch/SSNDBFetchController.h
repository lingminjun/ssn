//
//  SSNDBFetchController.h
//  ssn
//
//  Created by lingminjun on 14/11/29.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSNDB,SSNDBTable,SSNDBFetch;
@protocol SSNDBFetchControllerDelegate;

/**
 *  查询结果集管理器
 */
@interface SSNDBFetchController : NSObject

@property (nonatomic, strong, readonly) SSNDB *db;//依赖的数据库
@property (nonatomic, strong, readonly) SSNDBTable *table;//查询数据表

@property (nonatomic, copy) SSNDBFetch *fetch;//查询描述，重置后将全部清空结果集

@property (nonatomic, strong) dispatch_queue_t delegateQueue;//委托执行队列，默认为主线程队列

@property (nonatomic, weak) id<SSNDBFetchControllerDelegate> delegate;

#pragma mark status
- (BOOL)isPerformed;//已经执行过了，

- (BOOL)performFetch;//执行查询，已经执行后忽略此方法，除非你更换了查询描述

#pragma mark init

- (instancetype)initWithDB:(SSNDB *)db table:(SSNDBTable *)table fetch:(SSNDBFetch *)fetch;
+ (instancetype)fetchControllerWithDB:(SSNDB *)db table:(SSNDBTable *)table fetch:(SSNDBFetch *)fetch;

#pragma mark object manager
- (NSUInteger)count;//数据集大小

- (NSArray *)objects;//返回所有当前数据的拷贝

- (id)objectAtIndex:(NSUInteger)index;//index必须大于等于fetch.offset，小于count，否则出现越界异常

- (NSUInteger)indexOfObject:(id)object;//如果结果集中没找到返回NSNotFound

@end

/**
 * 结果集改变委托
 */
@protocol SSNDBFetchControllerDelegate <NSObject>


typedef NS_ENUM(NSUInteger, SSNDBFetchedChangeType) {
    SSNDBFetchedChangeInsert = 1,
    SSNDBFetchedChangeDelete = 2,
    SSNDBFetchedChangeMove = 3,
    SSNDBFetchedChangeUpdate = 4
};


@optional
- (void)ssndb_controller:(SSNDBFetchController *)controller didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(SSNDBFetchedChangeType)type newIndex:(NSUInteger)newIndex;


@optional
- (void)ssndb_controllerWillChange:(SSNDBFetchController *)controller;


@optional
- (void)ssndb_controllerDidChange:(SSNDBFetchController *)controller;

@end
//
//  SSNFetchController.h
//  ssn
//
//  Created by lingminjun on 14-5-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSNModel;
@protocol SSNModelManagerProtocol,SSNDBSection,SSNFetchControllerDelegate;


@interface SSNFetchController : NSObject

//初始化函数
- (id)initWithManager:(id <SSNModelManagerProtocol>)manager //不能为空
                model:(NSString *)modelName
       sectionKeyPath:(NSString *)sectionKeyPath
            predicate:(NSPredicate *)predicate
      sortDescriptors:(NSArray *)sortDescriptors
               offset:(NSUInteger)offset
            batchSize:(NSUInteger)size;

+ (instancetype)fetchControllerWithManager:(id <SSNModelManagerProtocol>)manager //不能为空
                                     model:(NSString *)modelName
                            sectionKeyPath:(NSString *)sectionKeyPath//针对model的属性
                                 predicate:(NSPredicate *)predicate
                           sortDescriptors:(NSArray *)sortDescriptors
                                    offset:(NSUInteger)offset
                                 batchSize:(NSUInteger)size;
//
- (NSString *)modelName;//模块名字


- (id <SSNModelManagerProtocol>)manager;//对象管理器

- (NSString *)sectionKeyPath;//返回nil表示这是里仅仅提供一个默认的分组

//
- (NSPredicate *)predicate;

//
- (NSArray *)sortDescriptors;

//
- (NSUInteger)fetchOffset;

//
- (NSUInteger)fetchBatchSize;

//委托
@property (nonatomic,weak) id<SSNFetchControllerDelegate> delegate;

//配置section排序,默认随机
- (void)configSortedSectionUsingFunction:(NSInteger (*)(id, id))comparator;


//执行方法
- (BOOL)performFetch:(NSError **)error;


//取数据接口
- (NSUInteger)sectionCount;


//返回section
- (id <SSNDBSection>)sectionAtIndex:(NSUInteger)index;

@end



//sectionid
@protocol SSNDBSection <NSObject>

- (id)sectionValue;//model.sectionKeyPath取到的具体值，如果sectionKeyPath == nil,此时返回nil

- (NSUInteger)modelCount;//元素个数

- (SSNModel *)modelAtRow:(NSUInteger)row;//取值

@end


@protocol SSNFetchControllerDelegate <NSObject>

enum {
	NSFetchedChangeInsert = 1,
	NSFetchedChangeDelete = 2,
    NSFetchedChangeMove = 3,
	NSFetchedChangeUpdate = 4
};
typedef NSUInteger NSFetchedChangeType;

/* Notifies the delegate that a fetched object has been changed due to an add, remove, move, or update. Enables SSNFetchController change tracking.
 controller - controller instance that noticed the change on its fetched objects
 anObject - changed object
 indexPath - indexPath of changed object (nil for inserts)
 type - indicates if the change was an insert, delete, move, or update
 newIndexPath - the destination path for inserted or moved objects, nil otherwise
 
 Changes are reported with the following heuristics:
 
 On Adds and Removes, only the Added/Removed object is reported. It's assumed that all objects that come after the affected object are also moved, but these moves are not reported.
 The Move object is reported when the changed attribute on the object is one of the sort descriptors used in the fetch request.  An update of the object is assumed in this case, but no separate update message is sent to the delegate.
 The Update object is reported when an object's state changes, and the changed attributes aren't part of the sort keys.
 */
@optional
- (void)controller:(SSNFetchController *)controller didChangeModel:(SSNModel *)model atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;


/* Notifies the delegate that section and object changes are about to be processed and notifications will be sent.  Enables SSNFetchController change tracking.
 Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with -beginUpdates
 */
@optional
- (void)controllerWillChange:(SSNFetchController *)controller;

/* Notifies the delegate that all section and object changes have been sent. Enables SSNFetchController change tracking.
 Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */
@optional
- (void)controllerDidChange:(SSNFetchController *)controller;

@end






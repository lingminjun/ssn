//
//  SSNFetchController.h
//  ssn
//
//  Created by lingminjun on 14-5-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNFetchController : NSObject

//初始化函数
- (id)initWithModelName:(NSString *)modelName
         sectionKeyPath:(NSString *)sectionKeyPath
              predicate:(NSPredicate *)predicate
        sortDescriptors:(NSArray *)sortDescriptors
                 offset:(NSUInteger)offset
              batchSize:(NSUInteger)size
                  limit:(NSUInteger)limit;

+ (instancetype)fetchControllerWithModelName:(NSString *)modelName
                              sectionKeyPath:(NSString *)sectionKeyPath
                                   predicate:(NSPredicate *)predicate
                             sortDescriptors:(NSArray *)sortDescriptors
                                      offset:(NSUInteger)offset
                                   batchSize:(NSUInteger)size
                                       limit:(NSUInteger)limit;
//
- (NSString *)modelName;

- (NSString *)sectionKeyPath;

//
- (NSPredicate *)predicate;
//- (void)setPredicate:(NSPredicate *)predicate;
//
- (NSArray *)sortDescriptors;
//- (void)setSortDescriptors:(NSArray *)sortDescriptors;
//
- (NSUInteger)fetchLimit;
//- (void)setFetchLimit:(NSUInteger)limit;
//
- (NSUInteger)fetchOffset;
//- (void)setFetchOffset:(NSUInteger)offset;
//
- (NSUInteger)fetchBatchSize;
//- (void)setFetchBatchSize:(NSUInteger) bsize;


@end

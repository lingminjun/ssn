//
//  SSNFetchController.m
//  ssn
//
//  Created by lingminjun on 14-5-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNFetchController.h"

@interface SSNFetchController () {
}

//查询必须参数
@property(nonatomic,strong) NSString *modelName;
@property(nonatomic,strong) NSString *sectionKeyPath;
@property(nonatomic,strong) NSPredicate *predicate;
@property(nonatomic,strong) NSArray *sortDescriptors;
@property(nonatomic) NSUInteger fetchLimit;
@property(nonatomic) NSUInteger fetchOffset;
@property(nonatomic) NSUInteger fetchBatchSize;

//数据缓存和计算变更
@property(nonatomic,strong) NSCache *cache;//size一般为fetchBatchSize（3/2）
@property(nonatomic,strong) NSMutableArray *sections;

@end

@implementation SSNFetchController

- (id)initWithModelName:(NSString *)modelName
         sectionKeyPath:(NSString *)sectionKeyPath
              predicate:(NSPredicate *)predicate
        sortDescriptors:(NSArray *)sortDescriptors
                 offset:(NSUInteger)offset
              batchSize:(NSUInteger)size
                  limit:(NSUInteger)limit {
    
    self = [super init];
    if (self) {
        self.modelName = [modelName copy];
        self.sectionKeyPath = [sectionKeyPath copy];
        self.predicate = [predicate copy];
        self.sortDescriptors = [sortDescriptors copy];
        self.fetchOffset = offset;
        self.fetchBatchSize = size;
        self.fetchLimit = limit;
    }
    
    return self;
}

+ (instancetype)fetchControllerWithModelName:(NSString *)modelName
                              sectionKeyPath:(NSString *)sectionKeyPath
                                   predicate:(NSPredicate *)predicate
                             sortDescriptors:(NSArray *)sortDescriptors
                                      offset:(NSUInteger)offset
                                   batchSize:(NSUInteger)size
                                       limit:(NSUInteger)limit {
    return [[[self class] alloc] initWithModelName:modelName
                                    sectionKeyPath:sectionKeyPath
                                         predicate:predicate
                                   sortDescriptors:sortDescriptors
                                            offset:offset
                                         batchSize:size
                                             limit:limit];
}

@end

//
//  SSNFetchController.m
//  ssn
//
//  Created by lingminjun on 14-5-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNFetchController.h"

@interface SSNFetchController () {
    id <SSNModelManagerProtocol> _manager;
}

@property (nonatomic,strong) id <SSNModelManagerProtocol> manager;

//查询必须参数
@property(nonatomic,strong) NSString *modelName;
@property(nonatomic,strong) NSString *sectionKeyPath;
@property(nonatomic,strong) NSPredicate *predicate;
@property(nonatomic,strong) NSArray *sortDescriptors;
@property(nonatomic) NSUInteger fetchOffset;
@property(nonatomic) NSUInteger fetchBatchSize;

//数据缓存和计算变更
@property(nonatomic,strong) NSCache *cache;//size一般为fetchBatchSize（3/2）
@property(nonatomic,strong) NSMutableArray *sections;

@end

@implementation SSNFetchController

@synthesize manager = _manager;

- (id)initWithManager:(id <SSNModelManagerProtocol>)manager //不能为空
                model:(NSString *)modelName
       sectionKeyPath:(NSString *)sectionKeyPath
            predicate:(NSPredicate *)predicate
      sortDescriptors:(NSArray *)sortDescriptors
               offset:(NSUInteger)offset
            batchSize:(NSUInteger)size {
    
    self = [super init];
    if (self) {
        self.manager = manager;
        self.modelName = [modelName copy];
        self.sectionKeyPath = [sectionKeyPath copy];
        self.predicate = [predicate copy];
        self.sortDescriptors = [sortDescriptors copy];
        self.fetchOffset = offset;
        self.fetchBatchSize = size;
    }
    
    return self;
}

+ (instancetype)fetchControllerWithManager:(id <SSNModelManagerProtocol>)manager //不能为空
                                     model:(NSString *)modelName
                            sectionKeyPath:(NSString *)sectionKeyPath//针对model的属性
                                 predicate:(NSPredicate *)predicate
                           sortDescriptors:(NSArray *)sortDescriptors
                                    offset:(NSUInteger)offset
                                 batchSize:(NSUInteger)size {
    return [[[self class] alloc] initWithManager:manager
                                           model:modelName
                                  sectionKeyPath:sectionKeyPath
                                       predicate:predicate
                                 sortDescriptors:sortDescriptors
                                          offset:offset
                                       batchSize:size];
}

@end

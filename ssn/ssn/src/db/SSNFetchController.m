//
//  SSNFetchController.m
//  ssn
//
//  Created by lingminjun on 14-5-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNFetchController.h"
#import "SSNModelManagerProtocol.h"
#import "SSNModel.h"
#import "SSNDBSectionImp.h"

@interface SSNFetchController () {
    id <SSNModelManagerProtocol> _manager;
}

@property (nonatomic,strong) id <SSNModelManagerProtocol> manager;

//查询必须参数
@property(nonatomic,strong) NSString *modelName;
@property(nonatomic,strong) NSString *sectionKeyPath;
@property(nonatomic,strong) NSString *predicate;
@property(nonatomic,strong) NSArray *sortDescriptors;
@property(nonatomic) NSUInteger fetchOffset;
@property(nonatomic) NSUInteger fetchBatchSize;

//数据缓存和计算变更
@property(nonatomic,strong) NSCache *cache;//size一般为fetchBatchSize（3/2）
@property(nonatomic,strong) NSMutableArray *sections;

@property (nonatomic) NSInteger (*sectionComparator)(id, id);

@end

@implementation SSNFetchController

@synthesize manager = _manager;

- (id)initWithManager:(id <SSNModelManagerProtocol>)manager //不能为空
                model:(NSString *)modelName
       sectionKeyPath:(NSString *)sectionKeyPath
            predicate:(NSString *)predicate
      sortDescriptors:(NSArray *)sortDescriptors
               offset:(NSUInteger)offset
            batchSize:(NSUInteger)size {
    
    NSAssert(manager && [modelName length] && predicate, @"请填入合适的参数");
    
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
                                 predicate:(NSString *)predicate
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

//配置section排序,默认随机
- (void)configSortedSectionUsingFunction:(NSInteger (*)(id, id))comparator {
    self.sectionComparator = comparator;
}


- (NSArray *)groupForInList:(NSArray *)list withGroup:(NSString *)group {
    
    if ([group length] == 0) {
        
        SSNDBSectionImp *section = [[SSNDBSectionImp alloc] init];
        //[section set]
        
        
        return nil;
    }
    
//    for (NSDictionary *item in list) {
//        <#statements#>
//    }
    return nil;
}

//执行方法
- (BOOL)performFetch:(NSError **)error {
    
    @autoreleasepool {
        id model_class = NSClassFromString(self.modelName);
        NSArray *list = [self.manager keys:[model_class primaryKeys]
                                     table:[model_class tableName]
                                     query:self.predicate
                                     group:self.sectionKeyPath
                           sortDescriptors:self.sortDescriptors];
        

    }
    
    
    //[self.manager keys:]
    
    return YES;
}


//取数据接口
- (NSUInteger)sectionCount {
    return [self.sections count];
}


//返回section
- (id <SSNDBSection>)sectionAtIndex:(NSUInteger)index {
    if (index >= [self.sections count]) {
        return nil;
    }
    
    return [self.sections objectAtIndex:index];
}


@end

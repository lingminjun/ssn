//
//  SSNDBSectionImp.h
//  ssn
//
//  Created by lingminjun on 14-5-27.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNFetchController.h"

@interface SSNDBSectionImp : NSObject <SSNDBSection>

@property (nonatomic,strong) NSString *sectionKey;
@property (nonatomic,strong) id sectionValue;

@property (nonatomic,strong) NSMutableArray *objs;

@property (nonatomic) NSInteger offset;
@property (nonatomic) NSInteger maxSize;

//- (id)sectionValue;//model.sectionKeyPath取到的具体值，如果sectionKeyPath == nil,此时返回nil
//
//- (NSUInteger)modelCount;//元素个数
//
//- (SSNModel *)modelAtRow:(NSUInteger)row;//取值

@end

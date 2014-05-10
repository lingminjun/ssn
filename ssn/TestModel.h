//
//  TestModel.h
//  ssn
//
//  Created by lingminjun on 14-5-9.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNModel.h"

@interface TestModel : SSNModel

@property (nonatomic) NSInteger type;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic) NSInteger age;
@property (nonatomic) BOOL sex;
@property (nonatomic) float hight;

@end

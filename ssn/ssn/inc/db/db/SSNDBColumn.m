//
//  SSNDBColumn.m
//  ssn
//
//  Created by lingminjun on 14-8-13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBColumn.h"

@interface SSNDBColumn ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fill;    //默认填充值，default value
@property (nonatomic, strong) NSString *mapping; //数据迁移时用，如(prevTableColumnName + 1)
@property (nonatomic) SSNColumnType type;
@property (nonatomic) SSNColumnStyle style;
@property (nonatomic) SSNColumnIndexStyle index;

@end

@implementation SSNDBColumn

- (instancetype)initWithName:(NSString *)name
                        type:(SSNColumnType)type
                       style:(SSNColumnStyle)style
                       index:(SSNColumnIndexStyle)index
                        fill:(NSString *)fill
                     mapping:(NSString *)mapping
{
    self = [super init];
    if (self)
    {
        self.name = [name copy];
        self.type = type;
        self.style = style;
        self.index = index;
        self.fill = [fill copy];
        self.mapping = [mapping copy];
    }
    return self;
}

+ (instancetype)columnWithName:(NSString *)name
                          type:(SSNColumnType)type
                         style:(SSNColumnStyle)style
                         index:(SSNColumnIndexStyle)index
                          fill:(NSString *)fill
                       mapping:(NSString *)mapping
{
    return [[[self class] alloc] initWithName:name type:type style:style index:index fill:fill mapping:mapping];
}

@end

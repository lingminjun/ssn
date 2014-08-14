//
//  SSNDBTable.m
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBTable.h"
#import "SSNDBColumn.h"

NSString *SSNDBTableWillMigrateNotification = @"SSNDBTableWillMigrateNotification"; //数据准备迁移 mainThread
NSString *SSNDBTableDidMigrateNotification = @"SSNDBTableDidMigrateNotification";   //数据迁移结束 mainThread
NSString *SSNDBTableDidDropNotification = @"SSNDBTableDidDropNotification";
NSString *SSNDBTableNameKey = @"SSNDBTableNameKey";

@interface SSNDBTable ()

@property (nonatomic, strong) SSNDBTable *meta; //模板
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) SSNDB *db; //依赖的数据库
@property (nonatomic) NSUInteger currentVersion;
@property (nonatomic, strong) NSDictionary *its;

@property (nonatomic) SSNDBTableStatus status;

- (NSArray *)columnsForVersion:(NSUInteger)version;

@end

@implementation SSNDBTable

- (NSArray *)columnsForVersion:(NSUInteger)version
{
    return [self.its objectForKey:@(version)];
}

- (instancetype)initWithDB:(SSNDB *)db tableJSONDescription:(NSData *)tableJSONDescription
{
    NSAssert(db && tableJSONDescription, @"创建数据表实例参数非法");
    self = [super init];
    if (self)
    {
        self.db = db;
    }
    return self;
}
+ (instancetype)tableWithDB:(SSNDB *)db tableJSONDescription:(NSData *)tableJSONDescription
{
    return [[[self class] alloc] initWithDB:db tableJSONDescription:tableJSONDescription];
}

- (instancetype)initWithName:(NSString *)name meta:(SSNDBTable *)meta
{
    NSAssert(name && meta && ![name isEqualToString:meta.name], @"创建数据表子表实例参数非法");
    self = [super init];
    if (self)
    {
        self.name = [name copy];
        self.meta = meta;
    }
    return self;
}
+ (instancetype)tableWithName:(NSString *)name meta:(SSNDBTable *)meta
{
    return [[[self class] alloc] initWithName:name meta:meta];
}

// table的状体
- (void)update
{
}

- (void)drop
{
}

@end

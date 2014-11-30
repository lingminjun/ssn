//
//  SSNDBFetch.m
//  ssn
//
//  Created by lingminjun on 14/11/29.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBFetch.h"

@implementation SSNDBFetch

- (instancetype)initWithEntity:(Class<SSNDBFetchObject>)clazz {
    return [self initWithEntity:clazz sortDescriptors:nil predicate:nil offset:0 limit:0];
}

- (instancetype)initWithEntity:(Class<SSNDBFetchObject>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit {
    self = [super init];
    if (self) {
        _entity = clazz;
        _sortDescriptors = [sortDescriptors copy];
        _predicate = [predicate copy];
        _offset = offset;
        _limit = limit;
    }
    return self;
}

+ (instancetype)fetchWithEntity:(Class<SSNDBFetchObject>)clazz {
    return [[[self class] alloc] initWithEntity:clazz];
}

+ (instancetype)fetchWithEntity:(Class<SSNDBFetchObject>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit {
    return [[[self class] alloc] initWithEntity:clazz sortDescriptors:sortDescriptors predicate:predicate offset:offset limit:limit];
}

#pragma mark copying
- (instancetype)copyWithZone:(NSZone *)zone {
    SSNDBFetch *copy = [[[self class] alloc] initWithEntity:self.entity];
    copy.sortDescriptors = self.sortDescriptors;
    copy.predicate = self.predicate;
    copy.offset = self.offset;
    copy.limit = self.limit;
    return copy;
}

#pragma mark sql statement
- (NSString *)sqlStatement {//where子句和order by子句以及limit子句
    
    @autoreleasepool {
        
        NSMutableString *sqlstatement = [NSMutableString string];
        
        //添加where子句
        if (_predicate) {
            [sqlstatement appendFormat:@"WHERE %@",[_predicate predicateFormat]];
        }
        
        //添加order by子句
        if ([_sortDescriptors count]) {
            [sqlstatement appendString:@" ORDER BY "];
            
            BOOL isFirst = YES;
            for (NSSortDescriptor *sort in _sortDescriptors) {
                if (!isFirst) {
                    [sqlstatement appendString:@", "];
                }
                isFirst = NO;
                
                [sqlstatement appendFormat:@"%@ %@", sort.key, sort.ascending? @"ASC": @"DESC"];
            }
        }
        
        //添加limit子句
        if (_limit > 0) {
            [sqlstatement appendFormat:@" LIMIT %lu, %lu", _offset, _limit];
        }
        
        return [sqlstatement copy];
    }
}

@end

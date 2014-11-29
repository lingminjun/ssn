//
//  SSNDBFetch.m
//  ssn
//
//  Created by lingminjun on 14/11/29.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBFetch.h"

@implementation SSNDBFetch

- (instancetype)initWithEntity:(Class<NSCopying>)clazz {
    return [self initWithEntity:clazz sortDescriptors:nil predicate:nil offset:0 limit:0];
}

- (instancetype)initWithEntity:(Class<NSCopying>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit {
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

+ (instancetype)fetchWithEntity:(Class<NSCopying>)clazz {
    return [[[self class] alloc] initWithEntity:clazz];
}

+ (instancetype)fetchWithEntity:(Class<NSCopying>)clazz sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate offset:(NSUInteger)offset limit:(NSUInteger)limit {
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

@end

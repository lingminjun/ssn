//
//  DMPerson.m
//  ssn
//
//  Created by lingminjun on 14/11/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMPerson.h"

@implementation DMPerson

@synthesize rowid = _rowid;

- (NSUInteger)hash {
    return [self.uid hash];
}

- (BOOL)isEqual:(DMPerson *)object {
    if (![object isKindOfClass:[DMPerson class]]) {
        return NO;
    }
    return [self.uid isEqualToString:object.uid];
}


- (id)copyWithZone:(NSZone *)zone {
    DMPerson *copy = [[DMPerson alloc] init];
    copy.rowid = self.rowid;
    copy.uid = self.uid;
    copy.name = self.name;
    copy.avatar = self.avatar;
    copy.mobile = self.mobile;
    return copy;
}

@end

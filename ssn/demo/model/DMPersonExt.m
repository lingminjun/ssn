//
//  DMPersonExt.m
//  ssn
//
//  Created by lingminjun on 14/12/25.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMPersonExt.h"

@implementation DMPersonExt

- (NSUInteger)hash {
    return [self.uid hash];
}

- (BOOL)isEqual:(DMPersonExt *)object {
    if (![object isKindOfClass:[DMPersonExt class]]) {
        return NO;
    }
    return [self.uid isEqualToString:object.uid];
}


- (id)copyWithZone:(NSZone *)zone {
    DMPersonExt *copy = [[DMPersonExt alloc] init];
    copy.ssn_dbfetch_rowid = self.ssn_dbfetch_rowid;
    copy.uid = self.uid;
    copy.brief = self.brief;
    copy.address = self.address;
    return copy;
}
@end

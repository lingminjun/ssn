//
//  DMSession.m
//  ssn
//
//  Created by lingminjun on 14/11/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMSession.h"

@implementation DMSession

@synthesize ssn_dbfetch_rowid = _ssn_dbfetch_rowid;


- (NSUInteger)hash {
    return [self.sid hash];
}

- (BOOL)isEqual:(DMSession *)object {
    if (![object isKindOfClass:[DMSession class]]) {
        return NO;
    }
    return [self.sid isEqualToString:object.sid];
}


- (id)copyWithZone:(NSZone *)zone {
    DMSession *copy = [[DMSession alloc] init];
    copy.ssn_dbfetch_rowid = self.ssn_dbfetch_rowid;
    copy.sid = self.sid;
    copy.title = self.title;
    copy.icon = self.icon;
    copy.content = self.content;
    copy.modifiedAt = self.modifiedAt;
    copy.unreadCount = self.unreadCount;
    return copy;
}

+ (instancetype)sessionWithSelf:(DMPerson *)person toPerson:(DMPerson *)toPerson {
    NSComparisonResult rt = [person.uid compare:toPerson.uid];
    NSString *sid = nil;
    if (rt == NSOrderedAscending) {
        sid = [NSString stringWithFormat:@"%@:%@",person.uid,toPerson.uid];
    }
    else if (rt == NSOrderedDescending) {
        sid = [NSString stringWithFormat:@"%@:%@",toPerson.uid,person.uid];
    }
    
    if (nil == sid) {
        return nil;
    }
    
    DMSession *sn = [[DMSession alloc] init];
    sn.sid = sid;
    sn.title = [NSString stringWithFormat:@"与%@的私聊", toPerson.name];
    sn.icon = toPerson.avatar;
    sn.modifiedAt = [[NSDate date] timeIntervalSince1970] * 1000;
    return sn;
}

- (NSArray *)memberUids {
    return [self.sid componentsSeparatedByString:@":"];
}

@end

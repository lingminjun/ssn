//
//  DMSession.h
//  ssn
//
//  Created by lingminjun on 14/11/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSNDBFetch.h"

#import "DMPerson.h"

@interface DMSession : NSObject <SSNDBFetchObject>

@property (nonatomic,copy) NSString *sid;

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *icon;

@property (nonatomic,copy) NSString *content;

@property (nonatomic) int64_t modifiedAt;

@property (nonatomic) NSUInteger unreadCount;

//通过两个人创建一个会话
+ (instancetype)sessionWithSelf:(DMPerson *)person toPerson:(DMPerson *)toPerson;

- (NSArray *)memberUids;

@end

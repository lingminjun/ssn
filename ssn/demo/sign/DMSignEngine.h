//
//  DMSignEngine.h
//  ssn
//
//  Created by lingminjun on 14/11/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMPerson.h"

@interface DMSignEngine : NSObject


@property (nonatomic,copy) NSString *loginId;//当前登录的id

- (DMPerson *)selfProfile;

+ (instancetype)sharedInstance;

@end

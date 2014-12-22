//
//  DMSignEngine.m
//  ssn
//
//  Created by lingminjun on 14/11/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMSignEngine.h"

@implementation DMSignEngine

+ (instancetype)sharedInstance {
    static DMSignEngine *engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[DMSignEngine alloc] init];
    });
    return engine;
}

- (DMPerson *)selfProfile {
    DMPerson *pn = [[DMPerson alloc] init];
    pn.uid = self.loginId;
    pn.name = @"我";
    pn.mobile = self.loginId;
    return pn;
}

@end

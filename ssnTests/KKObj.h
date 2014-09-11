//
//  KKObj.h
//  ssn
//
//  Created by lingminjun on 14-9-10.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKObj : NSObject

@property (nonatomic, strong) NSString *str;

- (void)setTestStr:(NSString *)str;

@end

@interface KKDerive : KKObj

@property (nonatomic, strong) NSString *str;

- (void)setTest1Str:(NSString *)str;

- (NSString *)baseStr;

@end
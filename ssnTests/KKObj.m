//
//  KKObj.m
//  ssn
//
//  Created by lingminjun on 14-9-10.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "KKObj.h"

@interface KKObj ()
{
    NSString *_str;
}

@end

@implementation KKObj

@synthesize str = _str;

- (void)testBaseFunction
{
    NSLog(@"%@", self->_str);
}

- (NSString *)baseStr
{
    return self->_str;
}

- (void)setTestStr:(NSString *)str
{
    _str = str;
}

@end

@interface KKDerive ()
{
    NSString *_str;
    NSString *_uu;
}

@end

@implementation KKDerive

@synthesize str = _str;

- (void)setTest1Str:(NSString *)str
{
    _str = str;
}

- (void)testFunction
{
    [self testBaseFunction];
    NSLog(@"%@", self->_str);
}

- (NSString *)baseStr
{
    return [super baseStr];
}

@end
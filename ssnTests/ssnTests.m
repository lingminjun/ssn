//
//  ssnTests.m
//  ssnTests
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SSNRigidDictionary.h"

@interface ssnTests : XCTestCase

@end

@implementation ssnTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testRigidDictionary
{
    SSNRigidDictionary *set = [[SSNRigidDictionary alloc]
        initWithConstructor:^id(id key, NSDictionary *userInfo) { return [[NSObject alloc] init]; }];

    set.countLimit = 1;

    @autoreleasepool
    {
        id obj = [set objectForKey:@"1"];
        NSLog(@"%@", obj);
    }

    __weak id o = nil;
    @autoreleasepool
    {
        id obj = [set objectForKey:@"2"];
        NSLog(@"%@", obj);
        o = obj;
    }

    [set removeObjectForKey:@"2"];

    NSLog(@"%@", o);
}

@end

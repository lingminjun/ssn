//
//  ssnDTTest.m
//  ssn
//
//  Created by lingminjun on 14-10-12.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSObject+SSNTracking.h"

#define test_number 42//101010

@interface DTBaseObject : NSObject

- (void)oneObjParam:(id)one;

- (void)oneIntParam:(NSInteger)one;

- (void)oneLongParam:(long)one;

- (void)oneFloatParam:(float)one;

- (void)oneCharParam:(char)one;

- (void)twoObjParam:(id)one two:(id)two;

- (void)twoIntParam:(NSInteger)one two:(NSInteger)two;

- (void)twoCharParam:(char)one two:(char)two;

- (id)variableParam:(id)obj, ... NS_REQUIRES_NIL_TERMINATION;

@end


@implementation DTBaseObject

- (void)oneObjParam:(id)one
{
    NSLog(@"%@",one);
}

- (void)oneIntParam:(NSInteger)one
{
    NSLog(@"%ld",one);
}

- (void)oneLongParam:(long)one
{
    NSLog(@"%ld",one);
}

- (void)oneFloatParam:(float)one
{
    NSLog(@"%f",one);
}

- (void)oneCharParam:(char)one
{
    NSLog(@"%c",one);
}

- (void)twoObjParam:(id)one two:(id)two
{
    NSLog(@"%@===%@",one,two);
}

- (void)twoIntParam:(NSInteger)one two:(NSInteger)two
{
    NSLog(@"%ld===%ld",one,two);
}

- (void)twoCharParam:(char)one two:(char)two
{
    NSLog(@"%c===%c",one,two);
}

- (id)variableParam:(id)obj, ... NS_REQUIRES_NIL_TERMINATION
{
    NSLog(@"%@",obj);
    va_list vaList;
    va_start(vaList, obj);
    id o = nil;
    while((o = va_arg(vaList, id))){
        NSLog(@"%@",o);
    }
    va_end(vaList);
    return obj;
}

@end


@interface DTDeriveObject : DTBaseObject

@end


@implementation DTDeriveObject

- (void)twoCharParam:(char)one two:(char)two
{
    NSLog(@"Derive:%c===%c",one,two);
}

@end


@interface ssnDTTest : XCTestCase

@end

@implementation ssnDTTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/*
 - (void)oneObjParam:(id)one;
 
 - (void)oneIntParam:(NSInteger)one;
 
 - (void)oneLongParam:(long)one;
 
 - (void)oneFloatParam:(float)one;
 
 - (void)oneCharParam:(char)one;
 
 - (void)twoObjParam:(id)one two:(id)two;
 
 - (void)twoIntParam:(NSInteger)one two:(NSInteger)two;
 
 - (void)twoCharParam:(char)one two:(char)two;
 
 - (id)variableParam:(id)obj, ... NS_REQUIRES_NIL_TERMINATION;
 */

- (void)testExample {
   
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneObjParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneIntParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneLongParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneCharParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneFloatParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(twoObjParam:two:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(twoIntParam:two:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(twoCharParam:two:)];
    
    DTDeriveObject *obj = [[DTDeriveObject alloc] init];
    
    [obj oneObjParam:@"abcdefg"];
    [obj oneIntParam:test_number];
    [obj oneLongParam:test_number];
    [obj oneFloatParam:1.010100];
    [obj oneCharParam:(char)(test_number)];
    
    [obj twoIntParam:test_number two:test_number];
    [obj twoObjParam:@"12345" two:@"abcdefg"];
    [obj twoCharParam:(char)(test_number) two:(char)(test_number)];
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

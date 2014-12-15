//
//  QuantaTest.m
//  ssn
//
//  Created by lingminjun on 14-11-16.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "SSNQuantum.h"

@interface QuantaTest : XCTestCase

@end

@implementation QuantaTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)quantum:(SSNQuantum *)quantum objects:(NSArray *)objects {
    NSLog(@"\n===============\n%@\n===============",objects);
}

- (void)test_add_less_obj {
    SSNQuantum *quant = [[SSNQuantum alloc] initWithInterval:0.001 maxCount:5];
    quant.delegate = self;
    
    [quant pushObject:@"1"];
    [quant pushObject:@"2"];
    [quant pushObject:@"3"];
    
    sleep(1);
    
    [quant pushObject:@"4"];
    [quant pushObject:@"5"];
    [quant pushObject:@"6"];
    
    sleep(1);
}

- (void)test_retain_count {
    SSNQuantum *quant = [[SSNQuantum alloc] initWithInterval:0.001 maxCount:5];
    quant.delegate = self;
    
    [quant pushObject:@"1"];
    
    sleep(1);
}


- (void)test_add_over_obj {
    SSNQuantum *quant = [[SSNQuantum alloc] initWithInterval:0.5 maxCount:5];
    quant.delegate = self;
    
    [quant pushObject:@"1"];
    [quant pushObject:@"2"];
    [quant pushObject:@"3"];
    [quant pushObject:@"4"];
    [quant pushObject:@"5"];
    
    [quant pushObject:@"6"];
    
    
    sleep(10);
}


- (void)test_add_direct_obj {
    SSNQuantum *quant = [[SSNQuantum alloc] initWithInterval:0.01 maxCount:5];
    quant.delegate = self;
    
    [quant pushObject:@"1"];
    [quant pushObject:@"2"];
    [quant pushObject:@"3"];
    [quant pushObject:@"4"];
    
    [quant express];
    
    
    sleep(1);
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

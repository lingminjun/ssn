//
//  ssn_safe_set_test.m
//  ssn
//
//  Created by lingminjun on 14-11-9.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "SSNSafeSet.h"

@interface ssn_safe_set_test : XCTestCase

@end

@implementation ssn_safe_set_test

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
    NSSet *set = [NSSet setWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    
    for (NSString *obj in set) {
        NSLog(@"set = %@",obj);
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)test_fast_Enumeration {
    // This is an example of a functional test case.
    SSNSafeSet *set = [SSNSafeSet setWithSet:[NSSet setWithObjects:@"1",@"2",@"3",@"4",@"5", nil]];
    
    for (NSString *obj in set) {
        NSLog(@"set = %@",obj);
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)test_fast_Enumeration_v1 {
    // This is an example of a functional test case.
    SSNSafeSet *set = [SSNSafeSet set];
    
    for (int i = 0; i < 100; i++) {
        NSString *obj = [NSString stringWithFormat:@"%i",i];
        [set addObject:obj];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100; i=i+3) {
            NSString *obj = [NSString stringWithFormat:@"%i",i];
            [set removeObject:obj];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSString *obj in set) {
            NSLog(@"set = %@",obj);
        }
    });
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 5, false);
    
    XCTAssert(YES, @"Pass");
}

- (void)test_fast_Enumeration_v2 {
    // This is an example of a functional test case.
    SSNSafeSet *set = [SSNSafeSet set];
    
    for (int i = 0; i < 100; i++) {
        NSString *obj = [NSString stringWithFormat:@"%i",i];
        [set addObject:obj];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 100; i < 200; i++) {
            NSString *obj = [NSString stringWithFormat:@"%i",i];
            [set addObject:obj];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSString *obj in set) {
            NSLog(@"set = %@",obj);
        }
    });
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 5, false);
                   
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

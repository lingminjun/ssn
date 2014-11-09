//
//  ssn_safe_array_test.m
//  ssn
//
//  Created by lingminjun on 14-11-9.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SSNSafeArray.h"

@interface TSPerson : NSObject
@property (nonatomic,strong) NSString *name;
@end

@implementation TSPerson
@end

@interface ssn_safe_array_test : XCTestCase

@end

@implementation ssn_safe_array_test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)test_Fast_Enumeration {
    // This is an example of a functional test case.
    
    SSNSafeArray *ary = [[SSNSafeArray alloc] init];
    
    @autoreleasepool {
        for (int i = 0; i < 100; i++) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            [ary addObject:key];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        for (int i = 0; i < 100; i=i+2) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            [ary removeObject:key];
            NSLog(@"remove%@",key);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (id obj in ary) {
            NSLog(@"syncl%@",obj);
        }
    });
    
    for (id obj in ary) {
        NSLog(@"leave%@",obj);
    }

    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 5, false);
    XCTAssert(YES, @"Pass");
}

- (void)test_Enumeration {
    SSNSafeArray *ary = [[SSNSafeArray alloc] init];
    
    @autoreleasepool {
        for (int i = 0; i < 20; i++) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            [ary addObject:key];
        }
    }
    
    NSEnumerator *en = [ary objectEnumerator];
    NSEnumerator *rven = [ary reverseObjectEnumerator];
    
    id obj = nil;
    while ((obj = [en nextObject])) {
        NSLog(@"%@",obj);
    }
    NSLog(@"======");
    while ((obj = [rven nextObject])) {
        NSLog(@"%@",obj);
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)test_k_v_c_test {
    
    SSNSafeArray *ary = [[SSNSafeArray alloc] init];
    
    @autoreleasepool {
        for (int i = 0; i < 100; i++) {
            NSString *key = [NSString stringWithFormat:@"name%d", i];
            TSPerson *ps = [[TSPerson alloc] init];
            ps.name = key;
            [ary addObject:ps];
        }
    }
    
     //[ary setValue:@"ddddd" forKey:@"0.name"];
    
    NSArray *names = [ary valueForKey:@"name"];
    NSLog(@"names=%@",names);
    
    //CFRunLoopRunInMode(kCFRunLoopDefaultMode, 5, false);
    XCTAssert(YES, @"Pass");
}


- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

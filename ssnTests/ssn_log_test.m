//
//  ssn_log_test.m
//  ssn
//
//  Created by lingminjun on 14/12/1.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ssnlog.h"
#import "SSNLogger.h"

@interface ssn_log_test : XCTestCase

@end

@implementation ssn_log_test

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
    
    SSNLogVerbose(@"dsfsdj%sdddd","000000000000");
    SSNLogVerbose(@"dshjfsdhfdksjfj");
    SSNLogVerbose(@"================================");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        SSNLogVerbose(@"dsfsdj%sdddd","000000000000");
        SSNLogVerbose(@"dshjfsdhfdksjfj");
        SSNLogVerbose(@"================================");
        SSNLogVerbose(@"kkkkk的首付款防溺水的说法是放假的思考了 ");
        SSNLogVerbose(@"kkkkk的首付款的撒旦防溺水的说法是放假的思考了 ");
        SSNLogVerbose(@"k的撒旦顶顶顶顶顶顶顶顶顶顶顶顶顶考了 ");
    }];
}

@end

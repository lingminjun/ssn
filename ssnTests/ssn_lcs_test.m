//
//  ssn_lcs_test.m
//  ssn
//
//  Created by lingminjun on 14/12/16.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ssndiff.h"


@interface ssn_lcs_test : XCTestCase

@end

@implementation ssn_lcs_test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


int ssn_diff_element_is_equal_fun(void *from, void *to, const size_t f_idx, const size_t t_idx, void *context) {
    return *((char *)from + f_idx) == *((char *)to + t_idx);
}


void ssn_diff_results_iterator_fun(void *from, void *to, const size_t f_idx, const size_t t_idx, const ssn_diff_change_type type, void *context) {
    switch (type) {
        case ssn_diff_no_change:
            printf("%03lu    %c\n", f_idx,*((char *)from + f_idx));
            break;
        case ssn_diff_insert:
            printf("%03lu ++ %c\n", t_idx,*((char *)to + t_idx));
            break;
        case ssn_diff_delete:
            printf("%03lu -- %c\n", f_idx,*((char *)from + f_idx));
            break;
        default:
            break;
    }
}

/**
 @brief diff 比较
 @from 原始结果集
 @to 目标结果集
 @f_size 原始结果大小
 @t_size 目标结果大小
 @equal  元素相等回调
 @iterator 遍历结果回调
 */
//void ssn_diff(void *from, void *to, const size_t f_size, const size_t t_size, ssn_diff_element_is_equal equal, ssn_diff_results_iterator iterator);
- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
    
    char *s1 = "abcdef";//"MZJAWXU"
    char *s2 = "adcefb";
    
    ssn_diff(s1, s2, strlen(s1), strlen(s2), ssn_diff_element_is_equal_fun, ssn_diff_results_iterator_fun, NULL);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

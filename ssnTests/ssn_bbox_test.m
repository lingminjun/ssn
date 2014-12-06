//
//  ssn_bbox_test.m
//  ssn
//
//  Created by lingminjun on 14/12/6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ssnsimplemap.h"

@interface ssn_bbox_test : XCTestCase

@end

@implementation ssn_bbox_test

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
    
    
    ssn_simple_map_t *map = ssn_smap_create(4, 1);
    
    const char *a = "肖海长";
    //NSLog(@"111 = %s",a);
    ssn_smap_add_node(map, a, "111");
    ssn_smap_add_node(map, "杨世亮", "222");
    ssn_smap_add_node(map, "梁冰珏", "333");
    ssn_smap_add_node(map, "张居阔", "444");
    ssn_smap_add_node(map, "刘太举", "555");
    
    const char *s = ssn_smap_get_value(map, "111");
    NSLog(@"111 = %s",s);
    NSLog(@"222 = %s",ssn_smap_get_value(map, "222"));
    NSLog(@"333 = %s",ssn_smap_get_value(map, "333"));
    NSLog(@"444 = %s",ssn_smap_get_value(map, "444"));
    NSLog(@"555 = %s",ssn_smap_get_value(map, "555"));
    
    ssn_smap_remove_value(map, "555", 0);
    
    const char *p = ssn_smap_get_value(map, "555");
    if (p) {
        NSLog(@"555 exist");
    }
    
    ssn_smap_destroy(map, 0);
    
    XCTAssert(YES, @"Pass");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

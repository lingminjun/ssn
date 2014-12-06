//
//  ssn_bbox_test.m
//  ssn
//
//  Created by lingminjun on 14/12/6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ssnsmap.h"
#import "ssnbbox.h"

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

- (void)test_map {
    // This is an example of a functional test case.
    
    
    ssn_smap_t *map = ssn_smap_create(4, 1);
    
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

- (void)test_box {
    char *p = "/Users/lingminjun/Workdesk/work/ssn/ssnTests/bbox.txt";
    
    ssn_bbox_t *box = ssn_bbox_create(p, 4);
    ssn_bbox_set_value("肖海长", "111", box);
    ssn_bbox_set_value("杨世亮", "222", box);
    ssn_bbox_set_value("梁冰珏", "333", box);
    ssn_bbox_set_value("张居阔", "444", box);
    ssn_bbox_set_value("刘太举", "555", box);
    
    NSLog(@"222 = %s",ssn_bbox_get_value("222", box));
    NSLog(@"333 = %s",ssn_bbox_get_value("333", box));
    NSLog(@"444 = %s",ssn_bbox_get_value("444", box));
    NSLog(@"555 = %s",ssn_bbox_get_value("555", box));
    
    ssn_bbox_destroy(box);
    
    XCTAssert(YES, @"Pass");
    
}

- (void)test_box_read {
    char *p = "/Users/lingminjun/Workdesk/work/ssn/ssnTests/bbox.txt";
    
    ssn_bbox_t *box = ssn_bbox_create(p, 4);
//    ssn_bbox_set_value("肖海长", "111", box);
//    ssn_bbox_set_value("杨世亮", "222", box);
//    ssn_bbox_set_value("梁冰珏", "333", box);
//    ssn_bbox_set_value("张居阔", "444", box);
//    ssn_bbox_set_value("刘太举", "555", box);
    
    NSLog(@"222 = %@",[NSString stringWithUTF8String:ssn_bbox_get_value("222", box)]);
    NSLog(@"333 = %@",[NSString stringWithUTF8String:ssn_bbox_get_value("333", box)]);
    NSLog(@"444 = %@",[NSString stringWithUTF8String:ssn_bbox_get_value("444", box)]);
    NSLog(@"555 = %@",[NSString stringWithUTF8String:ssn_bbox_get_value("555", box)]);
    
    ssn_bbox_destroy(box);
    
    XCTAssert(YES, @"Pass");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

//
//  ssn_datastore_test.m
//  ssn
//
//  Created by lingminjun on 14/12/8.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SSNDataStore+Factory.h"

@interface ssn_datastore_test : XCTestCase

@end

@implementation ssn_datastore_test

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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)test_save_image {
    NSString *urlstr = @"http://mg.soupingguo.com/bizhi/big/10/284/696/10284696.jpg";
    NSURL *url = [NSURL URLWithString:urlstr];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    SSNDataStore *store = [SSNDataStore dataStoreWithScope:@"test"];
    [store storeData:data forKey:urlstr];
    
    NSString *path = [store dataPathForKey:urlstr];
    NSLog(@"path= %@",path);
    
    [store clearMemory];
    
    NSData *temData = [store dataForKey:urlstr];
    
    if ([temData length] == [data length]) {
        NSLog(@"djfskfdhk");
    }
}

@end

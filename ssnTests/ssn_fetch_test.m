//
//  ssn_fetch_test.m
//  ssn
//
//  Created by lingminjun on 14/11/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ssnbase.h"
#import "SSNDB.h"
#import "SSNDBPool.h"
#import "SSNDBTable.h"

#import "TSUser.h"
#import "TSPerson.h"

@interface ssn_fetch_test : XCTestCase

@end

@implementation ssn_fetch_test

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


- (void)test_fetch_rowid
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScope:@"test1"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestUser2.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];
    
    [table update];
    
    NSArray *objs = [db objects:nil sql:@"SELECT rowid,* FROM user", nil];
    
    NSLog(@"%@", objs);
    
    objs = [db objects:nil sql:@"SELECT * FROM user WHERE rowid = 3", nil];
    
    NSLog(@"%@", objs);
    
}

- (void)test_insert_objs {
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScope:@"test1"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestPerson.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];
    
    [table update];
    
    TSPerson *user = [[TSPerson alloc] init];
    user.uid = @"11";
    user.name = @"name:肖海长";
    user.age = 26;
    user.sex = 1;
    
    TSPerson *user1 = [[TSPerson alloc] init];
    user1.uid = @"12";
    user1.name = @"name:凌敏均";
    user1.age = 26;
    user1.sex = 0;
    
    [table upinsertObject:user];
    [table upinsertObject:user1];
}

- (void)test_fetch_rowid2
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScope:@"test1"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestPerson.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];
    
    [table update];
    
    NSArray *objs = [db objects:nil sql:@"SELECT rowid,* FROM person", nil];
    
    NSLog(@"%@", objs);
    
    objs = [db objects:nil sql:@"SELECT * FROM person WHERE rowid = 1", nil];
    
    NSLog(@"%@", objs);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

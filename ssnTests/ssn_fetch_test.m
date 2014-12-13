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
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    NSLog(@"%lld",(long long)[date timeIntervalSince1970]);
    
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    [fm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dt = [fm dateFromString:@"2014-01-01 00:00:00"];
    NSLog(@"%lld",(long long)[dt timeIntervalSince1970]);
    
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
}








- (void)test_db_attach1
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScope:@"attach1"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestPerson.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];
    [table update];
    
    SSNDB *db2 = [pool dbWithScope:@"attach2"];
    NSString *path2 = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestPerson.json";
    SSNDBTable *table2 = [SSNDBTable tableWithDB:db2 tableJSONDescriptionFilePath:path2];
    [table2 update];
    
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
    
    [table2 upinsertObject:user];
    [table2 upinsertObject:user1];
}

- (void)test_db_attach2
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScope:@"attach1"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestPerson.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];
    [table update];
    
//    SSNDB *db2 = [pool dbWithScope:@"attach2"];
//    NSString *path2 = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestPerson.json";
//    SSNDBTable *table2 = [SSNDBTable tableWithDB:db2 tableJSONDescriptionFilePath:path2];
//    [table2 update];
    
    [db executeSql:@"ATTACH DATABASE '/Users/lingminjun/Library/Developer/CoreSimulator/Devices/B106EDFD-2A7E-413E-9CE1-8BB7E681987F/data/Documents/ssndb/attach2/db.sqlite' AS attach_db"];
    
    [db executeSql:@"INSERT OR IGNORE INTO person SELECT * FROM attach_db.person"];
    
    [db executeSql:@"DETACH DATABASE attach_db"];
    
    //SELECT t1.first_col FROM testtable t1, mydb.testtable t2 WHERE t.first_col = t2.first_col; first_col
    //INSERT INTO Subscription SELECT OrderId, “”, ProductId FROM __temp__Subscription
    NSPredicate *where = [NSPredicate predicateWithFormat:@"uid = '11'"];
    NSArray *objs = [table objectsWithClass:[TSPerson class] forPredicate:where];
    NSLog(@"%@", objs);
    
}

- (void)test_db_attach3
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScope:@"attach1"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestPerson.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];
    [table update];
    
    [db addAttachDatabase:@"attach_db" arduousBlock:^(SSNDB *attachDB) {
        
        //一项艰巨的任务【耗时比较长的事，如大批量数据插入】
        SSNDBTable *tb = [SSNDBTable tableWithDB:attachDB tableJSONDescriptionFilePath:path];
        [tb update];
        
        TSPerson *user1 = [[TSPerson alloc] init];
        user1.uid = @"14";
        user1.name = @"name:张居阔";
        user1.age = 26;
        user1.sex = 0;
        
        [tb upinsertObject:user1];
        
    } attachBlock:^(SSNDB *db, NSString *attachDatabase) {
        NSString *sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO person SELECT * FROM %@.person", attachDatabase];
        [db executeSql:sql];
        
        [db removeAttachDatabase:@"attach_db"];
    }];
    
    
    NSPredicate *where = [NSPredicate predicateWithFormat:@"uid = '11'"];
    NSArray *objs = [table objectsWithClass:[TSPerson class] forPredicate:where];
    NSLog(@"%@", objs);
    
    sleep(100);
    
}


- (id)objectTest {
    return [[TSPerson alloc] init];
}


- (void)test_ock {
    // This is an example of a functional test case.
    
    @autoreleasepool {
        __autoreleasing TSPerson *p = [self objectTest];
        
        [self addObserver:p forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    @autoreleasepool {
        __autoreleasing TSPerson *p = [[TSPerson alloc] init];
        [self addObserver:p forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    
}


@end

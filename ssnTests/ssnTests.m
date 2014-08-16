//
//  ssnTests.m
//  ssnTests
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SSNRigidCache.h"

#import "ssnbase.h"
#import "SSNDB.h"
#import "SSNDBPool.h"
#import "SSNDBTable.h"

@interface TSUser : NSObject
@property (nonatomic) NSInteger uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger age;
@property (nonatomic) BOOL sex;
@end

@implementation TSUser
@end

@interface ssnTests : XCTestCase

@end

@implementation ssnTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testRigidDictionary
{
    SSNRigidCache *set = [[SSNRigidCache alloc]
        initWithConstructor:^id(id key, NSDictionary *userInfo) { return [[NSObject alloc] init]; }];

    set.countLimit = 1;

    @autoreleasepool
    {
        id obj = [set objectForKey:@"1"];
        NSLog(@"%@", obj);
    }

    __weak id o = nil;
    @autoreleasepool
    {
        id obj = [set objectForKey:@"2"];
        NSLog(@"%@", obj);
        o = obj;
    }

    [set removeObjectForKey:@"2"];

    NSLog(@"%@", o);
}

- (void)testDB
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScop:@"test"];

    [db executeSql:@"DROP TABLE tst_tb", nil];

    [db executeSql:@"CREATE TABLE IF NOT EXISTS tst_tb (name TEXT, value INTEGER,PRIMARY KEY(name))", nil];

    [db executeSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"1", @(5), nil];

    //[db executeSql:@"INSERT OR REPLACE INTO tst_tb (name,value) VALUES(?,?)", @"1", @(4), nil];

    [db executeTransaction:^(SSNDB *dataBase, BOOL *rollback) {
        [db executeSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"2", @(0), nil];

        [db executeSql:@"UPDATE tst_tb SET value = ? WHERE name = ?", @(3), @"1", nil];
        [db executeSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"1", @(3), nil];
    } sync:YES];

    //    [db executeTransaction:^(SSNDB *dataBase, BOOL *rollback) {
    //        //        [db executeSql:@"DELETE FROM tst_tb WHERE name = ?", @"1", nil];
    //        //        [db executeSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"1", @(7), nil];
    //
    //        [db executeSql:@"UPDATE tst_tb SET value = ? WHERE name = ?", @(7), @"1", nil];
    //        [db executeSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"1", @(7), nil];
    //    } sync:YES];

    NSArray *vs = [db objects:nil sql:@"SELECT value FROM tst_tb WHERE name = ?", @"2", nil];
    NSLog(@"%@", vs);
}

- (void)testDBTable0
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScop:@"test"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestUser2.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];

    [table update];

    TSUser *user = [[TSUser alloc] init];
    user.uid = 12;
    user.name = @"凌敏均";
    user.age = 26;
    user.sex = 1;

    [table upinsertObject:user];

    NSArray *objs = [db objects:nil sql:@"SELECT * FROM user WHERE uid = ?", @(user.uid), nil];

    NSLog(@"%@", objs);

    [table deleteObject:user];

    objs = [db objects:nil sql:@"SELECT * FROM user WHERE uid = ?", @(user.uid), nil];

    NSLog(@"%@", objs);
    //[db executeSql:@"INSERT INTO user (uid,name,age) VALUES(?,?,?)", @(1), @"xhc", @(25), nil];
}

- (void)testDBTable1
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScop:@"test"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestUser2.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];

    SSNDBTable *stable = [SSNDBTable tableWithName:@"user_ext" meta:table db:db];
    [stable update];
}

@end

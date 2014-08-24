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

#import "inet.h"

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

    [db prepareSql:@"DROP TABLE tst_tb", nil];

    [db prepareSql:@"CREATE TABLE IF NOT EXISTS tst_tb (name TEXT, value INTEGER,PRIMARY KEY(name))", nil];

    [db prepareSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"1", @(5), nil];

    //[db prepareSql:@"INSERT OR REPLACE INTO tst_tb (name,value) VALUES(?,?)", @"1", @(4), nil];

    [db executeTransaction:^(SSNDB *dataBase, BOOL *rollback) {
        [db prepareSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"2", @(0), nil];

        [db prepareSql:@"UPDATE tst_tb SET value = ? WHERE name = ?", @(3), @"1", nil];
        [db prepareSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"1", @(3), nil];
    } sync:YES];

    //    [db executeTransaction:^(SSNDB *dataBase, BOOL *rollback) {
    //        //        [db prepareSql:@"DELETE FROM tst_tb WHERE name = ?", @"1", nil];
    //        //        [db prepareSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"1", @(7), nil];
    //
    //        [db prepareSql:@"UPDATE tst_tb SET value = ? WHERE name = ?", @(7), @"1", nil];
    //        [db prepareSql:@"INSERT INTO tst_tb (name,value) VALUES(?,?)", @"1", @(7), nil];
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
    user.uid = 11;
    user.name = @"肖海长";
    user.age = 26;
    user.sex = 1;

    [table upinsertObject:user];

    NSArray *objs = [db objects:nil sql:@"SELECT * FROM user WHERE uid = ?", @(user.uid), nil];

    NSLog(@"%@", objs);

    //    [table deleteObject:user];
    //
    //    objs = [db objects:nil sql:@"SELECT * FROM user WHERE uid = ?", @(user.uid), nil];
    //
    //    NSLog(@"%@", objs);
    //[db prepareSql:@"INSERT INTO user (uid,name,age) VALUES(?,?,?)", @(1), @"xhc", @(25), nil];
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

static CFRunLoopRef runloop;

void read_inet(ssn::inet &inet, const unsigned char *bytes, const unsigned long &size, const unsigned int &tag)
{
    NSLog(@"%s", bytes);
    CFRunLoopStop(runloop);
}

- (void)testIentTest
{

    char *str =
        "GET /imlogingw/tcp60login?loginId=cnhhupanlmj_test&ostype=&osver=IPHONE_7.1&ver=2.8.6_IPHONE_wangxin_WW "
        "HTTP/1.0\nAccept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, "
        "application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, application/x-ms-application, "
        "application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */* \nAccept-Language: "
        "zh-cn\nUser-Agent: Mozilla/4.0\nHost:allot.im.hupan.com\nConnection: Keep-Alive\n\r\n\r\n";

    // char buf[4096];

    ssn::inet iet("allot.im.hupan.com", 443);

    iet.set_read_callback(read_inet);

    iet.start_connect();

    sleep(1);

    iet.async_write((unsigned char *)str, strlen(str), 1);

    runloop = CFRunLoopGetCurrent();

    CFRunLoopRun();

    iet.stop_connect();

    sleep(1);

    //    char *rut = "HTTP/1.1 200 OK\r\nDate: Sun, 24 Aug 2014 08:24:53 GMT\r\nServer: Apache/2.2.9 "
    //                "(Unix)\r\nCache-Control: no-cache\r\nContent-Length: 85\r\nConnection: close\r\nContent-Type: "
    //                "text/"
    //                "html;charset=utf-8\r\n\r\n42.156.153.19:80,42.156.153.27:443,42.156.153.21:80,42.156.153.1:443,42.156."
    //                "153.32:80";
}

@end

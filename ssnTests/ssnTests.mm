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

#import "SSNCuteSerialQueue.h"

#import <objc/runtime.h>

#import "KKObj.h"

#import "SSNRouter.h"
#import "NSURL+Router.h"

#import "TSUser.h"

@interface TSLObj : NSObject
{
    NSString *_name;
}
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *desp;
@end

@implementation TSLObj

@synthesize desp = _desp;

@dynamic name;
- (NSString *)name
{
    return _name;
}

@end

@interface KVOModel : NSObject {
    NSString *_name;
    int64_t _uid;
}

@property (nonatomic,strong) NSString *name;
@property (nonatomic) int64_t uid;


@end

@implementation KVOModel

- (NSUInteger)hash
{
    return (NSUInteger)self.uid;
}

- (BOOL)isEqual:(KVOModel *)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    return self.uid == object.uid;
}

@end

@interface ssnTests : XCTestCase

@property (nonatomic,strong) NSString *function_name;

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

- (void)setFunction_name:(NSString *)function_name {
    _function_name = function_name;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%@",change);
}

- (void)test_function_name {
    
    KVOModel *model0 = [[KVOModel alloc] init];
    model0.uid = 10;
    model0.name = @"10ddddd";
    KVOModel *model1 = [[KVOModel alloc] init];
    model1.uid = 11;
    model1.name = @"10dsddd";
    KVOModel *model2 = [[KVOModel alloc] init];
    model2.uid = 12;
    model2.name = @"10dxddd";
    KVOModel *model3 = [[KVOModel alloc] init];
    model3.uid = 13;
    model3.name = @"10ddghdd";
    
    NSMutableArray *ary = [NSMutableArray arrayWithObjects:model0,model1,model2,model3, nil];
    KVOModel *model4 = [[KVOModel alloc] init];
    model4.uid = 12;
    model4.name = @"10dgddd";
    [ary removeObjectsInArray:@[model4]];
    
    NSLog(@"%@",ary);
    
}

- (void)test_kkobj
{

    KKDerive *obj = [[KKDerive alloc] init];
    [obj setTestStr:@"base str value"];
    [obj setTest1Str:@"derive str value"];

    NSLog(@"%ld", class_getInstanceSize([KKDerive class]));

    NSLog(@"%@", obj.str);
    NSLog(@"%@", [obj baseStr]);
}

- (void)test_kvc_property
{

    TSLObj *obj = [[TSLObj alloc] init];
    [obj setValue:@"凌敏均" forKey:@"name"];
    [obj setValue:@"呵呵呵" forKey:@"desp"];

    NSLog(@"%@", obj.name);
    NSLog(@"%@", obj.desp);
}

static long long all_waited_time = 0ll;

- (void)testCuteSerialQueue
{

    SSNCuteSerialQueue *cuteQueue = [[SSNCuteSerialQueue alloc] initWithName:@"test"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(25);

    ssn_ntime_track_begin(all);
    for (int i = 0; i < 1000; i++)
    {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (i % 10 == 0)
        {
            dispatch_group_async(group, queue, ^{
                ssn_ntime_track_begin(t);
                [cuteQueue sync:^{
                    printf("sync =====%d\n", i);
                    ssn_ntime_track_balance(t, all_waited_time);
                }];
                dispatch_semaphore_signal(semaphore);
            });
        }
        else
        {
            dispatch_group_async(group, queue, ^{
                [cuteQueue async:^{ printf("async =====%d\n", i); }];
                dispatch_semaphore_signal(semaphore);
            });
        }
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    printf("\nwaited_time = %lld(us)\n", all_waited_time);
    ssn_ntime_track_end(all);

    // sleep(5);
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
    SSNDB *db = [pool dbWithScope:@"test"];

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
    SSNDB *db = [pool dbWithScope:@"test"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestUser2.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];

    [table update];

    TSUser *user = [[TSUser alloc] init];
    user.uid = @"11";
    user.name = @"肖海长";
    user.age = 26;
    user.sex = 1;

    [table upinsertObject:user];

    NSArray *objs = [db objects:nil sql:@"SELECT * FROM user WHERE uid = ?", user.uid, nil];

    NSLog(@"%@", objs);

    //    [table deleteObject:user];
    //
    //    objs = [db objects:nil sql:@"SELECT * FROM user WHERE uid = ?", @(user.uid), nil];
    //
    //    NSLog(@"%@", objs);
    //[db prepareSql:@"INSERT INTO user (uid,name,age) VALUES(?,?,?)", @(1), @"xhc", @(25), nil];
}


- (void)test_addcloumn_DBTable
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScope:@"test1"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestUser2.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];
    
    [table update];
    
    TSUser *user = [[TSUser alloc] init];
    user.uid = @"no11";
    user.name = @"no肖海长";
    user.age = 26;
    user.sex = 1;
    
    TSUser *user1 = [[TSUser alloc] init];
    user1.uid = @"no12";
    user1.name = @"no凌敏均";
    user1.age = 26;
    user1.sex = 0;
    
    [table upinsertObject:user];
    [table upinsertObject:user1];
    
    //[table inreplaceObject:user1];
    
    NSArray *objs = [db objects:nil sql:@"SELECT * FROM user WHERE uid = ?", user.uid, nil];
    
    NSLog(@"%@", objs);
    
    //    [table deleteObject:user];
    //
    //    objs = [db objects:nil sql:@"SELECT * FROM user WHERE uid = ?", @(user.uid), nil];
    //
    //    NSLog(@"%@", objs);
    //[db prepareSql:@"INSERT INTO user (uid,name,age) VALUES(?,?,?)", @(1), @"xhc", @(25), nil];
}


- (void)test_dic_sort
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScope:@"test1"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestUser2.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];
    
    [table update];
    
    NSArray *objs = [db objects:nil sql:@"SELECT * FROM user ORDER BY uid DESC", nil];
    
    NSLog(@"%@", objs);
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
    
    NSMutableArray *sorts = [NSMutableArray arrayWithArray:objs];
    [sorts sortedArrayUsingDescriptors:@[sort]];
    
    NSLog(@"%@", sorts);
    
    //    [table deleteObject:user];
    //
    //    objs = [db objects:nil sql:@"SELECT * FROM user WHERE uid = ?", @(user.uid), nil];
    //
    //    NSLog(@"%@", objs);
    //[db prepareSql:@"INSERT INTO user (uid,name,age) VALUES(?,?,?)", @(1), @"xhc", @(25), nil];
}



static pthread_t _thread;

void *inet_thread_main(void *arg)
{
    dispatch_queue_t callbackQueue = dispatch_get_current_queue();

    if (callbackQueue)
    {
        NSLog(@"hfjsdfdjfhjkda dhsjfsdhjf ");
    }
    else
    {
        NSLog(@"hfjsdfdjfhjkda dhsjfsdhjf ");
    }

    return NULL;
}

- (void)test_dipatch_queue
{

    pthread_create(&_thread, NULL, &inet_thread_main, NULL);

    sleep(100);
}

- (void)testDBTable1
{
    SSNDBPool *pool = [SSNDBPool shareInstance];
    SSNDB *db = [pool dbWithScope:@"test"];
    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/TestUser2.json";
    SSNDBTable *table = [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];

    SSNDBTable *stable = [SSNDBTable tableWithName:@"user_ext" meta:table db:db];
    [stable update];
}

static CFRunLoopRef runloop;

void read_inet(ssn::inet &inet, const unsigned char *bytes, const unsigned long &size, const unsigned int &tag,
               void *context)
{
    NSLog(@"\n===========================================\n%d\n%s\n===========================================\n", tag,
          bytes);
    CFRunLoopStop(runloop);
}

- (void)testIent_TimeOut
{
    const char *str = "GET "
                      "/baike/c0%3Dbaike80%2C5%2C5%2C80%2C26%3Bt%3Dgif/sign=02aac2af0824ab18f41be96554938da8/"
                      "c75c10385343fbf2e2dd81aab17eca8064388f41.jpg\n"
                      "HTTP/1.1\n"
                      "Host: a.hiphotos.baidu.com\n"
                      "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\n"
                      "Connection: Keep-Alive\n"
                      "Accept-Language: zh-cn\n"
                      "User-Agent: Mozilla/4.0\n"
                      "\r\n\r\n";

    ssn::inet iet("a.hiphotos.baidu.com", 80);

    iet.set_read_callback(read_inet);

    iet.start_connect();

    sleep(1);

    // iet.async_read(0, 1111, 1);

    iet.async_write((unsigned char *)str, strlen(str), 1);

    runloop = CFRunLoopGetCurrent();

    CFRunLoopRun();

    iet.stop_connect();

    sleep(1);
}

- (void)testIentTest
{

    const char *str =
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

    /*
     1408890591299565 poll fd result = 1
     the socket will write data
     1408890591299600 poll fd result = 1
     the socket will write data
     1408890591299609 poll fd result = 1
     the socket will write data
     1408890591299617 poll fd result = 1
     the socket will write data
     1408890591299627 poll fd result = 1
     the socket will write data
     1408890591299641 poll fd result = 1
     the socket will write data
     1408890591299651 poll fd result = 1

     the socket will write data
     1408891272558131 poll fd result = 1
     the socket will write data
     1408891272558136 poll fd result = 1
     the socket will write data
     1408891272558142 poll fd result = 1
     the socket will write data
     1408891272558147 poll fd result = 1

     //旺信
     ==============================
     1408890828737976<><><><><><><><><>
     ==============================
     1408890828838155<><><><><><><><><>
     ==============================
     1408890828939262<><><><><><><><><>
     ==============================
     1408890829040421<><><><><><><><><>
     ==============================
     1408890829141611<><><><><><><><><>
     ==============================
     1408890829242767<><><><><><><><><>

     //async
     1408894073672575<><><><><><><><><>
     1408894073672596<><><><><><><><><>
     1408894073672616<><><><><><><><><>
     1408894073672637<><><><><><><><><>
     1408894073672658<><><><><><><><><>
     1408894073672679<><><><><><><><><>
     1408894073672699<><><><><><><><><>
     1408894073672720<><><><><><><><><>
     1408894073672740<><><><><><><><><>
     1408894073672761<><><><><><><><><>
     1408894073672782<><><><><><><><><>
     1408894073672802<><><><><><><><><>
     1408894073672823<><><><><><><><><>
     1408894073672844<><><><><><><><><>
     1408894073672864<><><><><><><><><>
     1408894073672885<><><><><><><><><>
     1408894073672905<><><><><><><><><>
     1408894073672925<><><><><><><><><>
     1408894073672946<><><><><><><><><>
     1408894073672967<><><><><><><><><>
     1408894073672987<><><><><><><><><>
     1408894073673007<><><><><><><><><>
     1408894073673028<><><><><><><><><>
     1408894073673049<><><><><><><><><>
     1408894073673069<><><><><><><><><>
     1408894073676077<><><><><><><><><>

     */
}

- (void)test_RouterTest
{
    NSURL *url = [NSURL URLWithString:@"app://a/b/c?d=ggg"];
    
    NSArray *ary = @[@"fd",@"uu",@"kk"];
    NSURL *url1 = [url ssn_relativeURLWithComponents:ary];
    NSLog(@"%@",url1);
    
    ary = @[@"..",@"fd",@"uu",@"kk"];
    url1 = [url ssn_relativeURLWithComponents:ary];
    NSLog(@"%@",url1);
    
    ary = @[@"..",@"..",@"fd",@"uu",@"kk"];
    url1 = [url ssn_relativeURLWithComponents:ary];
    NSLog(@"%@",url1);
    
    ary = @[@"~",@"fd",@"uu",@"kk"];
    url1 = [url ssn_relativeURLWithComponents:ary];
    NSLog(@"%@",url1);
}


@end

//
//  ssn_fjson_test.m
//  ssn
//
//  Created by lingminjun on 16/7/6.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FJSON.h"

@interface ssn_fjson_test : XCTestCase

@end

@protocol FBaseModel <NSObject>
@end

@interface FBaseModel : NSObject <FBaseModel> {
    char xtap;
}

@property(nonatomic,getter=isTap,setter=funXtap:) char tap;
@property (nonatomic,strong) NSString *name;
@property (nonatomic) NSInteger age;
@property (nonatomic) BOOL isAffirm;
@end



@implementation FBaseModel
@synthesize tap = xtap;
@end

@interface FAModel : FBaseModel <FJSONEntity>
@property (nonatomic,copy) NSArray<FBaseModel> *childs;
@property (nonatomic,copy) NSDictionary<NSString *,FBaseModel *> *subs;
@end

@implementation FAModel

- (NSArray<NSString *> *)fjson_filter {
    return @[@"name",@"age",@"isAffirm",@"tap"];
}

- (Class)fjson_genericTypeForUndefinedKey:(NSString *)key {
    if ([@"subs" isEqualToString:key]) {
        return [FBaseModel class];
    }
    return nil;
}
@end

@interface FBModel : FAModel <FJSONEntity>
@property (nonatomic,strong) NSString *tname;
@property (nonatomic) int *myPoint;
@property (nonatomic) CGRect rect;
@end

@implementation FBModel

- (NSArray<NSString *> *)fjson_filter {
    return nil;
}


- (id)fjson_valueForKey:(NSString *)key {
    NSLog(@"valueForKey:%@",key);
    if ([key isEqualToString:@"myPoint"]) {
        if (_myPoint != NULL) {
            return @(*_myPoint);
        }
    } else if ([key isEqualToString:@"rect"]) {
        return NSStringFromCGRect(_rect);
//        return [NSValue valueWithCGRect:_rect];
    }
    return nil;
}

- (BOOL)fjson_setValue:(id)value forKey:(NSString *)key {
    NSLog(@"setValue:forKey:%@",key);
    return NO;
}

@end


@implementation ssn_fjson_test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_model {
    FBaseModel *m = [[FBaseModel alloc] init];
    [m funXtap:'A'];
    m.name = @"凌敏均";
    m.age = 21;
    m.isAffirm = YES;
    
    NSData *dt = [FJSON toJSONData:m];
    NSString *json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
    
    FBaseModel *mm = (FBaseModel *)[FJSON entity:[FBaseModel class] fromJSONData:dt];
    dt = [FJSON toJSONData:mm];
    json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
}

- (void)test_array {
    
    
    FBaseModel *m0 = [[FBaseModel alloc] init];
    [m0 funXtap:'A'];
    m0.name = @"凌敏均";
    m0.age = 21;
    m0.isAffirm = YES;
    
    FBaseModel *m1 = [[FBaseModel alloc] init];
    [m1 funXtap:'B'];
    m1.name = @"杨世亮";
    m1.age = 22;
    m1.isAffirm = YES;
    
    NSData *dt = [FJSON toJSONData:@[m0,m1]];
    NSString *json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
    
    id mm = [FJSON entity:[FBaseModel class] fromJSONData:dt];
    dt = [FJSON toJSONData:mm];
    json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
}

- (void)test_derive_entity {
    
    FBaseModel *m0 = [[FBaseModel alloc] init];
    [m0 funXtap:'A'];
    m0.name = @"凌敏均";
    m0.age = 21;
    m0.isAffirm = YES;
    
    FBaseModel *m1 = [[FBaseModel alloc] init];
    [m1 funXtap:'B'];
    m1.name = @"杨世亮";
    m1.age = 22;
    m1.isAffirm = YES;
    
    FAModel *am = [[FAModel alloc] init];
    am.childs = @[m0,m1];
    am.subs = @{@"num1":m0,@"num2":m1};
    am.name = @"这是派生类";
    [am funXtap:'D'];
    am.age = 100;
    am.isAffirm = YES;
    
    FJSONConfig *conf = [FJSONConfig config];
    conf[[FAModel class]] = @[@"---"];//小技巧，忽略FAModel的FJSONEntity协议配置
    
    NSData *dt = [FJSON toJSONData:am config:conf];
    NSString *json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
    
    id mm = [FJSON entity:[FAModel class] fromJSONData:dt config:conf];
    
    //改变其配置
    dt = [FJSON toJSONData:mm filter:^NSArray<NSString *> *(__unsafe_unretained Class entityClass) {
        if (entityClass == [FAModel class]) {
            return @[@"name"];//仅仅过滤名字
        }
        return nil;
    } mapping:^NSDictionary<NSString *,NSString *> *(__unsafe_unretained Class entityClass) {
        if (entityClass == [FAModel class]) {
            return @{@"subs":@"mappingKeys,backups"};
        } else if (entityClass == [FBaseModel class]) {
            return @{@"name":@"account,nick"};
        }
        return nil;
    }];
    json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
}

- (void)test_derive2_entity {
    
    FBaseModel *m0 = [[FBaseModel alloc] init];
    [m0 funXtap:'A'];
    m0.name = @"凌敏均";
    m0.age = 21;
    m0.isAffirm = YES;
    
    FBaseModel *m1 = [[FBaseModel alloc] init];
    [m1 funXtap:'B'];
    m1.name = @"杨世亮";
    m1.age = 22;
    m1.isAffirm = YES;
    
    FBModel *am = [[FBModel alloc] init];
    am.childs = @[m0,m1];
    am.subs = @{@"num1":m0,@"num2":m1};
    am.name = @"这是派生类";
    [am funXtap:'D'];
    am.age = 100;
    am.isAffirm = YES;
    
    static int point = 11;
    am.myPoint = &point;
    
    am.tname = @"这是二级派生类";
    
    am.rect = CGRectMake(12, 13, 14, 15);
    
    
    NSData *dt = [FJSON toJSONData:am];
    NSString *json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
    
    id mm = [FJSON entity:[FBModel class] fromJSONData:dt];
    dt = [FJSON toJSONData:mm];
    json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
}


- (void)test_index_set {
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)];
    
    NSData *dt = [FJSON toJSONData:set];
    NSString *json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
    
    id mm = [FJSON entity:[NSIndexSet class] fromJSONData:dt];
    dt = [FJSON toJSONData:mm];
    json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
}

- (void)test_dic_set {
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)];
    NSDictionary *dic = @{@"idx":set,@"msg":@"测试",@"num":@(193)};
    
    NSData *dt = [FJSON toJSONData:dic];
    NSString *json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
    
    id mm = [FJSON entity:[NSDictionary class] fromJSONData:dt];
    dt = [FJSON toJSONData:mm];
    json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
}

- (void)test_array_string {
    
    NSArray *set = @[@"dddd",@"xxxxx",@(384)];
    
    NSData *dt = [FJSON toJSONData:set];
    NSString *json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
    
    id mm = [FJSON entity:[NSArray class] fromJSONData:dt];
    dt = [FJSON toJSONData:mm];
    json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
}


- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

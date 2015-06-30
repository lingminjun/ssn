//
//  ssn_json_test.m
//  ssn
//
//  Created by lingminjun on 14-11-13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SSNJson.h"


@ssnjson_interface(TModel) : NSObject
@property (nonatomic,strong) NSString *name;
@end


@implementation TModel
@end

@ssnjson_interface(MModel) : NSObject
@property (nonatomic,strong) NSString *tname;
@property (nonatomic,strong) NSString <ssnjson_ignore>*alias;
@property (nonatomic,strong) TModel *model;
@property (nonatomic,strong) NSArray <ssnjson_convert(TModel)>*list;
@property (nonatomic,strong) NSArray *strings;
@property (nonatomic,strong) NSIndexSet *iset;
@end

@implementation MModel
@end

@interface ssn_json_test : XCTestCase

@end

@implementation ssn_json_test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_1json {
    NSError *error = nil;
    
    NSDictionary *model = @{@"name":@"lingminjun",@"age":@(29),@"tap":@('t')};
    
    NSDictionary *obj = @{@"first":model,@"secode":model};
    
    NSData *data = nil;
    NSString *str = nil;
    
    data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
}

- (void)test_json {
    NSError *error = nil;
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"1wstcfg"];
    NSIndexSet *iset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)];
    
    NSData *data = nil;
    NSString *str = nil;
    
    data = [NSJSONSerialization dataWithJSONObject:@[set] options:NSJSONWritingPrettyPrinted error:&error];
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"str");
    
    data = [NSJSONSerialization dataWithJSONObject:@[iset] options:NSJSONWritingPrettyPrinted error:&error];
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"str");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.

    
//    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/regions.json";
    
    MModel *model = [[MModel alloc] init];
    model.tname = @"lmj";
    model.alias = @"xxxxxxxx";
    TModel *tm = [[TModel alloc] init];
    tm.name = @"xxxxxxx";
    model.list = @[tm];
    model.strings = @[@"234",@"555566"];
    model.model= [[TModel alloc] init];
    model.model.name = @"dddddd";
    
//    model.set = [NSCharacterSet characterSetWithCharactersInString:@"1wstcfg"];
    
    model.iset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)];
    
    NSString *json = [model ssn_toJsonString];
    NSLog(@"%@",json);
    MModel *m = [MModel ssn_objectFromJsonString:json targetClass:[MModel class]];
    NSLog(@"%@",model.model.name);
    NSLog(@"%@",[m ssn_toJsonString]);
    
}

- (void)test_set_json {
    NSIndexSet *set = [NSIndexSet ssn_objectFromJsonString:@"[1,3,4,5,2]"];
    NSLog(@"%@",set);
}

@end

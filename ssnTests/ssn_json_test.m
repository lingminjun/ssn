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
#import "FJSON.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif


@ssnjson_interface(TModel) : NSObject {
    char xtap;
}

@property(nonatomic,getter=isTap,setter=funXtap:) char tap;

@property (nonatomic,strong) NSString *name;
@property (nonatomic) NSInteger age;
@property (nonatomic) BOOL isAffirm;

@property (nonatomic,copy) NSMutableString *txname;
@property (nonatomic,strong) NSMutableString * txrname;

@end

@interface DModel : TModel <SSNJsonCoding>
@end

@implementation DModel

- (void)encodeWithJsonCoder:(SSNJsonCoder *)aCoder {
    [super encodeWithJsonCoder:aCoder];
    
    [aCoder encodeString:self.name forKey:@"displayName"];
}
- (id)initWithJsonCoder:(SSNJsonCoder *)aDecoder {
    self = [super initWithJsonCoder:aDecoder];
    if (self) {
        
        self.name = [aDecoder decodeStringForKey:@"displayName"];
        
    }
    return self;
}

@end



@implementation TModel
@synthesize tap = xtap;
@end

@ssnjson_interface(MModel) : NSObject

@property (nonatomic,strong) NSArray<ssnjson_convert(TModel)> *nlist;

@property (nonatomic,strong) NSString *tname;
@property (nonatomic,strong) NSString <ssnjson_ignore>*alias;
@property (nonatomic,strong) TModel *model;
@property (nonatomic,strong) NSArray <ssnjson_convert(TModel)>*list;
@property (nonatomic,strong) NSArray *strings;
@property (nonatomic,strong) NSIndexSet *iset;

@property (nonatomic,strong) NSString *tdes;

@end

@implementation MModel

@dynamic tdes;
static char * tdes_cmd_key = NULL;
- (void)setTdes:(NSString *)tdes {
    NSLog(@"设置 tdes %@", tdes);
    objc_setAssociatedObject(self, &tdes_cmd_key,tdes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)tdes {
    return objc_getAssociatedObject(self, &tdes_cmd_key);
}

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

- (void)test_clazz {
    
    Class clz = NSClassFromString(@"MModel");
    NSLog(@"%@",clz);
    clz = NSClassFromString(@"XModel");
    NSLog(@"%@",clz);
    
}


- (void)test_compatibility_propert_json {
    NSError *error = nil;

    NSDictionary *model = @{@"name":@(123456),@"age":@"12",@"isAffirm":@"1",@"tap":@('t'),@"txname":@"lingminjun",@"txrname":@"0lingminjun"};
    NSData *data = nil;
    NSString *str = nil;
    data = [NSJSONSerialization dataWithJSONObject:model options:NSJSONWritingPrettyPrinted error:&error];
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    
    TModel *m = [FJSON entity:[TModel class] fromJSONData:data];//[TModel ssn_objectFromJsonString:str];
    NSLog(@"%@",m.name);
    
    [m.txrname insertString:@"0000" atIndex:1];
    NSLog(@"%@",m.txrname);
    
    [m.txname insertString:@"0000" atIndex:1];
    NSLog(@"%@",m.txname);
    
    NSString *str1 = @"1234";
    NSString *str2 = @"1234";
    if (str1 == str2) {
        NSLog(@"===============");
    }
   
    
}

- (void)test_model_setter_json {
    TModel *m = [[TModel alloc] init];
//    [m setValue:@('t') forKey:@"xtap"];
    
    [m setValue:@('t') forKey:@"xtap"];
    m.name = @"xxxxxxx";
    [m setValue:@"yyyyy" forKey:@"name"];
    
    NSLog(@"%@",@(m.isTap));
    
    if ('t' == m.isTap) {
        NSLog(@"%@",@(m.isTap));
    }
}

- (void)test_derive_model_json {
    NSError *error = nil;
    
    NSDictionary *model = @{@"displayName":@"null",@"age":@"<null>",@"isAffirm":@"(null)",@"tap":@('t')};
    NSData *data = nil;
    NSString *str = nil;
    data = [NSJSONSerialization dataWithJSONObject:model options:NSJSONWritingPrettyPrinted error:&error];
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    
    TModel *m = [DModel ssn_objectFromJsonString:str];
    NSLog(@"%@",m.name);
    
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
    [tm funXtap:'C'];
    model.list = @[tm];
    model.nlist = @[tm];
    model.strings = @[@"234",@"555566"];
    model.model= [[TModel alloc] init];
    model.model.name = @"dddddd";
    model.tdes = @"----------------------";
    
//    model.set = [NSCharacterSet characterSetWithCharactersInString:@"1wstcfg"];
    
    model.iset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)];
    
    NSData *data = [FJSON toJSONData:model];
//    NSString *json = [model ssn_toJsonString];
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    MModel *m = [FJSON entity:[MModel class] fromJSONData:data];//[MModel ssn_objectFromJsonString:json targetClass:[MModel class]];
    NSLog(@"%@",model.model.name);
//    NSLog(@"%@",[m ssn_toJsonString]);
    NSLog(@"%@",[[NSString alloc] initWithData:[FJSON toJSONData:m] encoding:NSUTF8StringEncoding]);
    
}

- (void)test_fjson_Example {
    // This is an example of a performance test case.
    
    
    //    NSString *path = @"/Users/lingminjun/Workdesk/work/ssn/ssnTests/regions.json";
    
    MModel *model = [[MModel alloc] init];
    model.tname = @"lmj";
    model.alias = @"xxxxxxxx";
    TModel *tm = [[TModel alloc] init];
    tm.name = @"xxxxxxx";
    [tm funXtap:'C'];
    model.list = @[tm];
    model.nlist = @[tm];
    model.strings = @[@"234",@"555566"];
    model.model= [[TModel alloc] init];
    model.model.name = @"dddddd";
    model.tdes = @"----------------------";
    
    //    model.set = [NSCharacterSet characterSetWithCharactersInString:@"1wstcfg"];
    
    model.iset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)];
    
    FJSONConfig *cf = [FJSONConfig config];
//    cf[[MModel class]] = @[@"nlist"];
    cf[[MModel class]] = @{@"nlist":@"array"};
    cf[[MModel class]] = @{@"nlist":[TModel class]};
    NSData *dt = [FJSON toJSONData:model config:cf];
    NSString *json = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
    MModel *dm = (MModel *)[FJSON entity:[MModel class] fromJSONData:dt config:cf];
    NSLog(@"%@",[dm ssn_toJsonString]);
//    MModel *m = [MModel ssn_objectFromJsonString:json targetClass:[MModel class]];
//    NSLog(@"%@",model.model.name);
//    NSLog(@"%@",[m ssn_toJsonString]);
    
}


- (void)test_set_json {
    NSIndexSet *set = [NSIndexSet ssn_objectFromJsonString:@"[1,3,4,5,2]"];
    NSLog(@"%@",set);
}


- (void)test_dic_json {
}


@end

//
//  ssnDTTest.m
//  ssn
//
//  Created by lingminjun on 14-10-12.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSObject+SSNTracking.h"
#import "ssnbase.h"

#define test_number 42//101010

typedef struct value_list_ {
    char aaa;
    int bbb;
} value_list;

@interface DTBaseObject : NSObject

- (void)oneObjParam:(id)one;

- (void)oneIntParam:(NSInteger)one;

- (void)oneLongParam:(long)one;

- (void)oneFloatParam:(float)one;

- (void)oneCharParam:(char)one;

- (void)twoObjParam:(id)one two:(id)two;

- (void)twoIntParam:(NSInteger)one two:(NSInteger)two;

- (void)twoStructParam:(value_list)one two:(NSInteger)two;

- (void)twoCharParam:(char)one two:(char)two;

- (id)variableParam:(id)obj, ... NS_REQUIRES_NIL_TERMINATION;

@end


@interface DTDeriveObject : DTBaseObject {
    NSString *myname;
    int length;
}

@property (nonatomic,strong) NSString *myname;
@property (nonatomic) int length;

@end



@implementation DTBaseObject

- (void)oneObjParam:(id)one
{
    NSLog(@"%@",one);
}

- (void)oneIntParam:(NSInteger)one
{
    NSLog(@"%ld",one);
}

- (void)oneLongParam:(long)one
{
    NSLog(@"%ld",one);
}

- (void)oneFloatParam:(float)one
{
    NSLog(@"%f",one);
}

- (void)oneCharParam:(char)one
{
    NSLog(@"%c",one);
}

- (void)twoObjParam:(id)one two:(id)two
{
    NSLog(@"%@===%@",one,two);
}

- (void)twoIntParam:(NSInteger)one two:(NSInteger)two
{
    NSLog(@"%ld===%ld",one,two);
}

- (void)twoCharParam:(char)one two:(char)two
{
    NSLog(@"%c===%c",one,two);
}

- (void)twoStructParam:(value_list)one two:(NSInteger)two {
    NSLog(@"struct{%c,%d}====%ld",one.aaa,one.bbb,two);
}

- (NSString *)twoDoubleParam:(double)one two:(double)two
{
    NSLog(@"%f===%f",one,two);
    return [NSString stringWithFormat:@"%f===%f",one,two];
}

- (id)variableParam:(id)obj, ... NS_REQUIRES_NIL_TERMINATION
{
    NSLog(@"%@",obj);
    va_list vaList;
    va_start(vaList, obj);
    id o = nil;
    while((o = va_arg(vaList, id))){
        NSLog(@"%@",o);
    }
    va_end(vaList);
    return obj;
}

//id variableParam(id obj,char *args)
//{
//    NSLog(@"%@",obj);
//    va_list vaList;
//    va_start(vaList, obj);
//    id o = nil;
//    while((o = va_arg(vaList, id))){
//        NSLog(@"%@",o);
//    }
//    va_end(vaList);
//    return obj;
//}

//- (void)forwardInvocation:(NSInvocation *)anInvocation
//{
//    id obj = nil;
//    [anInvocation getArgument:&obj atIndex:0];
//    
//    SEL asel = NULL;
//    [anInvocation getArgument:&asel atIndex:1];
//    
////    va_list vaList;
////    va_start(vaList, obj);
//    
//    
////    struct value_list list;
//    id abj = nil;
//    [anInvocation getArgument:&abj atIndex:2];
//    
////    unsigned char redata[32];
////    void *data = (__bridge void *)((__bridge id)(((SSInvocation *)anInvocation)->_retdata));
////    memccpy(redata,  data, 0, 32);
//    
//    void *p1 = (void *)redata;//
//    
//    void *p2 = (void *)&(redata[7]);//
//    
//    void *p3 = (void *)&(redata[15]);//
////
////    NSLog(@"%@",list.obj1);
////    NSLog(@"%@",list.obj2);
//    
//    [anInvocation invoke];
//}
//
//
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
//{
//    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
//    if (!sig)
//    {
//        sig = [DTDeriveObject instanceMethodSignatureForSelector:aSelector];
//    }
//    return sig;
//}

@end





@implementation DTDeriveObject

- (void)twoCharParam:(char)one two:(char)two
{
    NSLog(@"Derive:%c===%c",one,two);
}


- (id)variableTestParam:(id)obj, ... NS_REQUIRES_NIL_TERMINATION
{
    NSLog(@"%@",obj);
    va_list vaList;
    va_start(vaList, obj);
    id o = nil;
    while((o = va_arg(vaList, id))){
        NSLog(@"%@",o);
    }
    va_end(vaList);
    
    va_list List;
    va_start(List, obj);
    NSLogv(@"%@,%@",List);
    va_end(vaList);
    
    return obj;
}

@end


@interface ssnDTTest : XCTestCase

@end

@implementation ssnDTTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/*
 - (void)oneObjParam:(id)one;
 
 - (void)oneIntParam:(NSInteger)one;
 
 - (void)oneLongParam:(long)one;
 
 - (void)oneFloatParam:(float)one;
 
 - (void)oneCharParam:(char)one;
 
 - (void)twoObjParam:(id)one two:(id)two;
 
 - (void)twoIntParam:(NSInteger)one two:(NSInteger)two;
 
 - (void)twoCharParam:(char)one two:(char)two;
 
 - (id)variableParam:(id)obj, ... NS_REQUIRES_NIL_TERMINATION;
 */

- (void)testExample {
    
    [NSObject ssn_savePresetValue:@"22222" forKey:@"id"];
    [NSObject ssn_savePresetValue:@"ios" forKey:@"ut"];
   
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneObjParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneIntParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneLongParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneCharParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(oneFloatParam:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(twoObjParam:two:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(twoIntParam:two:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(twoDoubleParam:two:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(twoCharParam:two:)];
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(twoStructParam:two:) collectIvarList:@[@"myname",@"length"]];
    
    DTDeriveObject *obj = [[DTDeriveObject alloc] init];
    obj.myname = @"xxxxx";
    obj.length = 120;
    
    ssn_time_track_begin(t);
    [obj oneObjParam:@"abcdefg"];
    [obj oneIntParam:test_number];
    [obj oneLongParam:test_number];
    [obj oneFloatParam:1.010101];
    [obj oneCharParam:(char)(test_number)];
    
    [obj twoIntParam:test_number two:test_number];
    [obj twoObjParam:@"12345" two:@"abcdefg"];
    [obj twoCharParam:(char)(test_number) two:(char)(test_number)];
    NSString *str = [obj twoDoubleParam:1.010101 two:1.010101];
    
    ssn_time_track_end(t);
    
    NSLog(@"<<<%@>>>",str);
    
    value_list va_lst = {'*',test_number};
    [obj twoStructParam:va_lst two:test_number];
    
    XCTAssert(YES, @"Pass");
}


- (void)test_NSArrayVariableExample
{
    DTDeriveObject *obj = [[DTDeriveObject alloc] init];
    
    NSMethodSignature *sig = [obj methodSignatureForSelector:@selector(oneCharParam:)];
    NSUInteger sizep = 0;
    NSUInteger alignp = 0;
    const char *s = [sig getArgumentTypeAtIndex:2];
    const char *p = NSGetSizeAndAlignment(s, &sizep, &alignp);
    
    NSLog(@"%c",p[0]);
    
    NSLog(@"%@",sig);
}

- (void)test_variableExample
{
    [NSObject ssn_tracking_class:[DTDeriveObject class] selector:@selector(variableParam:)];
    
    DTDeriveObject *obj = [[DTDeriveObject alloc] init];
    
    [obj variableParam:@"12345",@"abcdefg",@"lllllll",nil];
}


- (void)test_variableTestExample
{
    
    DTBaseObject *obj = [[DTBaseObject alloc] init];
    
    [(DTDeriveObject *)obj variableTestParam:@"12345",@"abcdefg",@"lllllll",nil];
}

- (void)testPerformanceExample {
    
    int i = 1;
    int j = __alignof__(i);
    
    
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

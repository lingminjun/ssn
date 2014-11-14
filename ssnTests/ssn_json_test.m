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

typedef struct __attribute__((packed)) {
    BOOL flag;
    int x;
} Foo;

typedef struct _MYTStruct {
    int x;
    BOOL flag;
} MYTStruct;

typedef struct {
    float x, y, z;
} ThreeFloats;

@interface MyTTClass : NSObject {
    ThreeFloats _three;
}
//- (void)setThreeFloats:(ThreeFloats)threeFloats;
//- (ThreeFloats)threeFloats;

@property (nonatomic) ThreeFloats threeFloats;

@end

@implementation MyTTClass
@synthesize threeFloats = _three;
//- (void)setThreeFloats:(ThreeFloats)threeFloats {
//    _three = threeFloats;
//}
//- (ThreeFloats)threeFloats {
//    return _three;
//}

@end

@interface SSNJsonModel : NSObject{
    MYTStruct _stt;
    Foo _foo;
}

@property (nonatomic,strong) NSString *nickname;
@property (nonatomic) NSUInteger age;

//@property (nonatomic) char *tempname;
@property (nonatomic) MYTStruct stt;
@property (nonatomic) Foo foo;


@property (nonatomic ) CGPoint point;
@property (nonatomic ) CGRect rect;

@end


@implementation SSNJsonModel

@synthesize stt = _stt;
@synthesize foo = _foo;

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

- (void)test_encode_struct {
    ThreeFloats tt = {1,2,3};
    
    MyTTClass *model = [[MyTTClass alloc] init];
    model.threeFloats = tt;

    id obj = [model valueForKey:@"threeFloats"];
    
    //NSLog(@"rect(point(%f,%f),size(%f,%f))",m.rect.origin.x,m.rect.origin.y,m.rect.size.width,m.rect.size.height);
}

- (void)test_encode_test {
    CGPoint p = CGPointMake(13, 11);
    CGRect r = CGRectMake(1, 2, 13, 11);
    
    SSNJsonModel *model = [[SSNJsonModel alloc] init];
    model.nickname = @"lingminjun";
    model.age = 26;
    model.point = p;
    model.rect = r;
    //model.tempname = "xxxxxxx";
    
    Foo fo = {YES,13};
    model.foo = fo;
    
    MYTStruct st = {NO,11};
    model.stt = st;
    
    NSLog(@"model foo %i,%i",model.foo.flag,model.foo.x);
    NSLog(@"model stt %i,%i",model.stt.flag,model.stt.x);
    id obj = [model valueForKey:@"foo"];
    id obj1 = [model valueForKey:@"stt"];
    
    NSString *json = [model ssn_toJsonString];
    NSLog(@"[%@]",json);
    
    SSNJsonModel *m = [SSNJsonModel ssn_objectFromJsonString:json];
    NSLog(@"%@",m.nickname);
    NSLog(@"%lu",m.age);
    NSLog(@"point(%f,%f)",m.point.x,m.point.y);
    NSLog(@"rect(point(%f,%f),size(%f,%f))",m.rect.origin.x,m.rect.origin.y,m.rect.size.width,m.rect.size.height);
}


- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
    
    CGPoint p = CGPointMake(13, 11);
    CGRect r = CGRectMake(1, 2, 13, 11);
    
    SSNJsonModel *model = [[SSNJsonModel alloc] init];
    model.point = p;
    model.rect = r;
    
    NSValue *pobj = [model valueForKey:@"point"];
    NSValue *robj = [model valueForKey:@"rect"];
    
    NSLog(@"%@",pobj);
    NSLog(@"%@",robj);
    NSUInteger size = 0;
    NSGetSizeAndAlignment([robj objCType], &size, 0);
    
    CGRect r1 = CGRectMake(7, 4, 11, 13);
    char *newm = (char *)malloc(size);
    memcpy(newm, &r1, size);
    
    NSValue *vl = [NSValue value:newm withObjCType:[robj objCType]];
    [model setValue:vl forKey:@"rect"];
    
    robj = [model valueForKey:@"rect"];
    NSLog(@"%@",robj);
    
    CGRect tr;
    void *pp = malloc(size);
    [robj getValue:pp];
    memcpy(&tr, pp, size);
    
    NSLog(@"%f",tr.size.width);
    
    //NSValue *value = [NSValue valueWithCGPoint:<#(CGPoint)#>]
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

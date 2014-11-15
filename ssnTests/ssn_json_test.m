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
    ThreeFloats _threeFloats;
    ThreeFloats _threeFloatsXX;
}
//- (void)setThreeFloats:(ThreeFloats)threeFloats;
//- (ThreeFloats)threeFloats;

@property (nonatomic) ThreeFloats threeFloats;
@property (nonatomic) ThreeFloats threeFloatsXX;

@end

@implementation MyTTClass
//@synthesize threeFloats = _three;
//- (void)setThreeFloats:(ThreeFloats)threeFloats {
//    _three = threeFloats;
//}
//- (ThreeFloats)threeFloats {
//    return _three;
//}

- (NSString *)description {
    return [NSString stringWithFormat:@"<MyTTClass:%p x=%f,y=%f,z=%f>",self,_threeFloats.x,_threeFloats.y,_threeFloats.z];
}

@end

@interface SSNJsonModel : NSObject{
    MYTStruct _abc;
    Foo _foo;
}

@property (nonatomic,strong) NSString *nickname;
@property (nonatomic) NSUInteger age;

//@property (nonatomic) char *tempname;
@property (nonatomic) MYTStruct abc;
@property (nonatomic) Foo foo;


@property (nonatomic ) CGPoint point;
@property (nonatomic ) CGRect rect;

@end


@implementation SSNJsonModel

@synthesize abc = _abc;
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
    ThreeFloats tt = {1.0,2.0,3.0};
    
    MyTTClass *model = [[MyTTClass alloc] init];
    model.threeFloats = tt;
    model.threeFloatsXX = tt;

    NSString *json = [model ssn_toJsonString];
    NSLog(@"[%@]",json);
    
    MyTTClass *m = [MyTTClass ssn_objectFromJsonString:json];
    
    NSLog(@"%@",m);
    
//    id obj = [model valueForKey:@"threeFloats"];
//    id obj1 = [model valueForKey:@"threeFloatsXX"];
    
    //NSLog(@"rect(point(%f,%f),size(%f,%f))",m.rect.origin.x,m.rect.origin.y,m.rect.size.width,m.rect.size.height);
}

- (void)test_encode_array_struct {
    ThreeFloats tt = {1.0,2.0,3.0};
    
    NSMutableArray *ary = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        MyTTClass *model = [[MyTTClass alloc] init];
        model.threeFloats = tt;
        model.threeFloatsXX = tt;
        [ary addObject:model];
    }
    
    
    NSString *json = [ary ssn_toJsonString];
    NSLog(@"[%@]",json);
    
    id obj = [NSObject ssn_objectFromJsonString:json];
    
    NSLog(@"%@",obj);
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
    model.abc = st;
    
    NSLog(@"model foo %i,%i",model.foo.flag,model.foo.x);
    NSLog(@"model stt %i,%i",model.abc.flag,model.abc.x);
    id obj = [model valueForKey:@"foo"];
    id obj1 = [model valueForKey:@"abc"];
    
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

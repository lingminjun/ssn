//
//  ssnDictionaryTest.m
//  ssn
//
//  Created by lingminjun on 14-11-6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SSNSafeDictionary.h"
#import "SSNSafeArray.h"

@interface ssnDictionaryTest : XCTestCase

@end

//typedef NSMutableDictionary TestDictionary;
typedef SSNSafeDictionary TestDictionary;

//typedef NSMutableArray TestArray;
typedef SSNSafeArray TestArray;

@implementation ssnDictionaryTest

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
    //XCTAssert(YES, @"Pass");
    
    TestDictionary *dic = [[TestDictionary alloc] init];
    for (int i = 0; i < 1000; i++) {
        NSString *key = [NSString stringWithFormat:@"%d", i];
        [dic setObject:key forKey:key];
    }
    
    for (int i = 0; i < 100; i++) {
        NSString *key = [NSString stringWithFormat:@"d%d", i];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (i%3 == 0)
            {
                for (NSString *obj in dic) {
                    NSLog(@"%@",obj);
                }
            }
            else
            {
                [dic setObject:key forKey:key];
            }
            NSLog(@"%i",i);
        });
    }
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 100, false);
}

- (void)test_key_Example {
    
    TestDictionary *dic = [[TestDictionary alloc] init];
    
    NSMutableDictionary *adic = [[NSMutableDictionary alloc] init];
    
    @autoreleasepool {
        for (int i = 0; i < 100; i++) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            NSString *value = [NSString stringWithFormat:@"value%d", i];
            [dic setObject:value forKey:key];
            [adic setObject:value forKey:key];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        for (int i = 0; i < 100; i=i+2) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            [dic removeObjectForKey:key];
            NSLog(@"%dremove",i);
        }
    });
    
    for (id obj in dic) {
        NSLog(@"for%@",obj);
    }
    
    NSLog(@"==========");
    
    for (id obj in adic) {
        NSLog(@"%@",obj);
    }
    
    
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 100, false);
}


- (void)test_keys_Example {
    
    TestArray *ary = [[TestArray alloc] init];
    
    @autoreleasepool {
        for (int i = 0; i < 16; i++) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            [ary addObject:key];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        for (int i = 0; i < 100; i=i+2) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            [ary removeObject:key];
            NSLog(@"remove%@",key);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (id obj in ary) {
            NSLog(@"syncl%@",obj);
        }
    });
    
    for (id obj in ary) {
        NSLog(@"leave%@",obj);
    }
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 3, false);
}



- (void)test_dic_enum {
    // This is an example of a functional test case.
    //XCTAssert(YES, @"Pass");
    
    TestDictionary *dic = [[TestDictionary alloc] init];
    for (int i = 0; i < 100; i++) {
        NSString *key = [NSString stringWithFormat:@"%d", i];
        if (i%3 == 0)
        {
            key = [NSString stringWithFormat:@"xx%d", i];
        }
        [dic setObject:key forKey:key];
    }
    
    for (int i = 0; i < 100; i++) {
        NSString *key = [NSString stringWithFormat:@"d%d", i];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (i%3 == 0)
            {
                [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSLog(@"key=%@",key);
                }];
            }
            else
            {
                [dic setObject:key forKey:key];
            }
            //NSLog(@"%i",i);
        });
    }
    
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 100, false);
}

- (void)test_dic_enum_1 {
    // This is an example of a functional test case.
    //XCTAssert(YES, @"Pass");
    
    TestDictionary *dic = [[TestDictionary alloc] init];
    for (int i = 0; i < 100; i++) {
        NSString *key = [NSString stringWithFormat:@"%d", i];
        if (i%3 == 0)
        {
            key = [NSString stringWithFormat:@"xx%d", i];
        }
        [dic setObject:key forKey:key];
    }
    
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([key hasPrefix:@"xx"]) {
            [dic removeObjectForKey:key];
        }
        NSLog(@"%@",key);
    }];
    NSLog(@"%lu",(unsigned long)[dic count]);
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 100, false);
}


- (void)test_ArrayExample {
    // This is an example of a functional test case.
    //XCTAssert(YES, @"Pass");
    
    TestArray *ary = [[TestArray alloc] init];
    for (int i = 0; i < 1000; i++) {
        NSString *key = [NSString stringWithFormat:@"%d", i];
        [ary addObject:key];
    }
    
    for (int i = 0; i < 100; i++) {
        NSString *key = [NSString stringWithFormat:@"d%d", i];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (i%3 == 0)
            {
                for (NSString *obj in ary) {
                    NSString *str = [NSString stringWithFormat:@"=%@",obj];
                    NSLog(@"%@",str);
                }
            }
            else if (i%3 == 1)
            {
                [ary removeObjectAtIndex:i];
            }
            else {
                [ary addObject:key];
            }
            NSLog(@"%i",i);
        });
    }
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 100, false);
}


- (void)test_Array_sigle_thread {
    // This is an example of a functional test case.
    //XCTAssert(YES, @"Pass");
    
    TestArray *ary = [[TestArray alloc] init];
    for (int i = 0; i < 100; i++) {
        NSString *key = [NSString stringWithFormat:@"%d", i];
        [ary addObject:key];
    }
    
    for (NSString *obj in ary) {
        NSString *str = [NSString stringWithFormat:@"=%@",obj];
        NSLog(@"%@",str);
    }
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 100, false);
}


- (void)test_Array_enum {
    // This is an example of a functional test case.
    //XCTAssert(YES, @"Pass");
    
    TestArray *ary = [[TestArray alloc] init];
    for (int i = 0; i < 100; i++) {
        NSString *key = [NSString stringWithFormat:@"%d", i];
        [ary addObject:key];
    }
    
    for (int i = 0; i < 100; i++) {
        NSString *key = [NSString stringWithFormat:@"d%d", i];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (i%3 == 0)
            {
                [ary enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSLog(@"obj = %@",obj);
                }];
            }
            else
            {
                [ary addObject:key];
            }
            NSLog(@"%i",i);
        });
    }
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 100, false);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

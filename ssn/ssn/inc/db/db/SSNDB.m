//
//  SSNDB.m
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDB.h"
#import "ssnbase.h"

#define SSNDBFileName @"db.sqlite"

@interface SSNDB ()

@property (nonatomic, strong) NSString *dbpath;

@end

@implementation SSNDB

+ (NSString *)pathForScop:(NSString *)scop
{
    static NSString *dbDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            dbDirectory = [documentsDirectory stringByAppendingPathComponent:@"db"];
        }
    });

    NSString *dirPath = [dbDirectory stringByAppendingPathComponent:scop];
    NSString *path = [dirPath stringByAppendingPathComponent:SSNDBFileName];

    @autoreleasepool
    {
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:dirPath])
        {
            [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        }

        if (error)
        {
            ssn_log("create db dir for scop %s error:[%s]", [scop UTF8String], [[error description] UTF8String]);
            return nil;
        }
    }

    return path;
}

- (instancetype)initWithScop:(NSString *)scop
{
    NSAssert(scop, @"scop 参数");
    self = [super init];
    if (self)
    {
        if (nil == scop)
        { //效率考虑，空字符串也是可以的
            return nil;
        }

        //全部转成小写
        NSString *lowerScop = [scop lowercaseString];
        self.dbpath = [SSNDB pathForScop:lowerScop];

        NSAssert(self.dbpath, @"dbpath 无法建立");
    }
    return self;
}

- (void)dealloc
{
}

@end

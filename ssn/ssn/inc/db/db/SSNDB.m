//
//  SSNDB.m
//  ssn
//
//  Created by lingminjun on 14-7-28.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDB.h"
#import "ssnbase.h"
#import <sqlite3.h>
#import "SSNCuteSerialQueue.h"
#import "NSFileManager+SSN.h"

#define SSNDBFileName @"db.sqlite"

@interface SSNDB ()
{
    sqlite3 *_database;
    NSString *_dbpath;
    SSNCuteSerialQueue *_ioQueue;
}

@end

@implementation SSNDB

+ (NSString *)pathForScop:(NSString *)scop
{
    static NSString *dbdir = @"db";
    NSString *dirPath = [dbdir stringByAppendingPathComponent:scop];
    dirPath = [[NSFileManager defaultManager] pathDocumentDirectoryWithPathComponents:dirPath];
    return [dirPath stringByAppendingPathComponent:SSNDBFileName];
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
        _dbpath = [SSNDB pathForScop:lowerScop];

        NSAssert(self.dbpath, @"dbpath 无法建立");

        _ioQueue = [[SSNCuteSerialQueue alloc] initWithName:scop];
    }
    return self;
}

- (void)dealloc
{
    dispatch_block_t block = ^{
        if (sqlite3_close(_database) != SQLITE_OK)
        {
            //[self raiseSqliteException:@"Failed to close database with message '%S'."];
        }
    };

    [_ioQueue sync:block];
}

@end

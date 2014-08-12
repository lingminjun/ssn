//
//  NSFileManager+SSN.m
//  ssn
//
//  Created by lingminjun on 14-8-12.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "NSFileManager+SSN.h"

#import "ssnbase.h"

@implementation NSFileManager (SSN)

- (NSString *)pathDocumentDirectoryWithPathComponents:(NSString *)pathComponents
{
    static NSString *documentsDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            documentsDirectory = [paths objectAtIndex:0];
        }
    });

    if (!pathComponents)
    {
        return nil;
    }

    NSString *path = [documentsDirectory stringByAppendingPathComponent:pathComponents];

    @autoreleasepool
    {
        NSError *error = nil;
        if (![self fileExistsAtPath:path])
        {
            [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        }

        if (error)
        {
            ssn_log("create dir %s error:[%s]", [path UTF8String], [[error description] UTF8String]);
            return nil;
        }
    }

    return path;
}

@end

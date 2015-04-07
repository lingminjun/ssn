//
//  NSFileManager+SSN.m
//  ssn
//
//  Created by lingminjun on 14-8-12.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "NSFileManager+SSN.h"
#import "ssnbase.h"
#import <sys/xattr.h>

@implementation NSFileManager (SSN)

+ (instancetype)ssn_fileManager {
    return [[NSFileManager alloc] init];
}


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

- (NSString *)pathCachesDirectoryWithPathComponents:(NSString *)pathComponents {
    static NSString *cachesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            cachesDirectory = [paths objectAtIndex:0];
        }
    });
    
    if (!pathComponents)
    {
        return nil;
    }
    
    NSString *path = [cachesDirectory stringByAppendingPathComponent:pathComponents];
    
    @autoreleasepool
    {
        NSError *error = nil;
        if (![self fileExistsAtPath:path])
        {
            [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        if (error)
        {
            ssn_log("create cache dir %s error:[%s]", [path UTF8String], [[error description] UTF8String]);
            return nil;
        }
    }
    
    return path;
}

- (NSString *)pathTemporaryDirectoryWithPathComponents:(NSString *)pathComponents {
    if (!pathComponents)
    {
        return nil;
    }
    
    NSString *tmpDir =  NSTemporaryDirectory();
    NSString *path = [tmpDir stringByAppendingPathComponent:pathComponents];
    
    @autoreleasepool
    {
        NSError *error = nil;
        if (![self fileExistsAtPath:path])
        {
            [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        if (error)
        {
            ssn_log("create tmp dir %s error:[%s]", [path UTF8String], [[error description] UTF8String]);
            return nil;
        }
    }
    
    return path;
}

#pragma mark - 文件属性操作
+ (BOOL)ssn_addSkipBackupAttributeWithPath:(NSString *)path {
    if (path.length == 0) {
        return NO;
    }
    
    NSURL *url= [NSURL fileURLWithPath:path];
    if([[NSFileManager ssn_fileManager] fileExistsAtPath: [url path]]){
        return [self ssn_addSkipBackupAttributeToItemAtURL:url];
    } else{
        return NO;
    }
}


+ (BOOL)ssn_addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    if ( URL == nil ) {
        return NO;
    }
    
    if (![[NSFileManager ssn_fileManager] fileExistsAtPath: [URL path]]) {
        return NO;
    }
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    float version = [systemVersion floatValue];
    
    if (version < 5.0) {
        return YES;
    }
    
    if (version == 5.0) {
        return NO;
    }
    
    if ( version >= 5.1 ) {
        NSError *error = nil;
        BOOL success = [URL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    else
    {
        const char* filePath = [[URL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}

@end

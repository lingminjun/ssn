//
//  SSNDBTable+Factory.m
//  ssn
//
//  Created by lingminjun on 14-8-16.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBTable+Factory.h"
#import "SSNRigidCache.h"
#import "NSString+SSN.h"

@implementation SSNDBTable (Factory)

+ (SSNRigidCache *)tablePool
{
    static SSNRigidCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[SSNRigidCache alloc] initWithConstructor:^id(id key, NSDictionary *userInfo) {
            NSString *tableName = [userInfo objectForKey:@"tableName"];
            SSNDB *db = [userInfo objectForKey:@"database"];
            NSString *templateName = [userInfo objectForKey:@"templateName"];
            if (templateName && db)
            {
                SSNDBTable *temp = [self tableWithDB:nil name:tableName templateName:nil];
                return [SSNDBTable tableWithName:tableName meta:temp db:db];
            }
            else if (tableName && db)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:tableName ofType:@"json"];
                return [SSNDBTable tableWithDB:db tableJSONDescriptionFilePath:path];
            }
            else
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:tableName ofType:@"json"];
                return [SSNDBTable tableWithTemplateTableJSONDescriptionFilePath:path];
            }
        }];

        [cache setCountLimit:SSNDBTableCacheCount];
    });
    return cache;
}

+ (SSNDBTable *)tableWithDB:(SSNDB *)db name:(NSString *)name templateName:(NSString *)templateName
{
    SSNRigidCache *cache = [self tablePool];

    NSString *key = [NSString stringWithUTF8Format:"%p-%s", db, [name UTF8String]];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:db forKey:@"database"];
    [userInfo setValue:name forKey:@"tableName"];
    [userInfo setValue:templateName forKey:@"templateName"];

    SSNDBTable *table = [cache objectForKey:key userInfo:userInfo];
    [table update];
    return table;
}

+ (void)clearMemoryTableWithDB:(SSNDB *)db name:(NSString *)name
{
    SSNRigidCache *cache = [self tablePool];
    NSString *key = [NSString stringWithUTF8Format:"%p-%s", db, [name UTF8String]];
    [cache removeObjectForKey:key];
}

@end

//
//  SSNDBTable+Factory.h
//  ssn
//
//  Created by lingminjun on 14-8-16.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBTable.h"

#ifndef SSNDBTableCacheCount
#define SSNDBTableCacheCount 10 //根据固定表个数需要创建，
#endif

@interface SSNDBTable (Factory)

//按照表名字存储
+ (SSNDBTable *)tableWithDB:(SSNDB *)db name:(NSString *)name templateName:(NSString *)templateName;

+ (void)clearMemoryTableWithDB:(SSNDB *)db name:(NSString *)name;

@end

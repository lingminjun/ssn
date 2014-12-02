//
//  NSFileManager+SSN.h
//  ssn
//
//  Created by lingminjun on 14-8-12.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (SSN)

//将在document中创建对应的目录，多级目录创建，创建失败返回nil
- (NSString *)pathDocumentDirectoryWithPathComponents:(NSString *)pathComponents;

//将在Library/Caches中创建对应的目录，多级目录创建，创建失败返回nil
- (NSString *)pathCachesDirectoryWithPathComponents:(NSString *)pathComponents;

@end
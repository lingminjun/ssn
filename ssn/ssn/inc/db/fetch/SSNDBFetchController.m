//
//  SSNDBFetchController.m
//  ssn
//
//  Created by lingminjun on 14/11/29.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBFetchController.h"
#import "SSNDB.h"
#import "SSNDBTable.h"
#import "SSNDBFetch.h"
#import <sqlite3.h>

@interface SSNDBFetchController ()

@property (nonatomic, strong) dispatch_queue_t queue;//执行线程，放到db线程中执行并不是最好的选择

@property (nonatomic) BOOL isPerformed;
@property (nonatomic) BOOL isProcessing;//处理中，处理中再次调用set

- (void)dbupdatedNotification:(NSNotification *)notice;

@end


@implementation SSNDBFetchController

- (dispatch_queue_t)delegateQueue {
    if (!_delegateQueue) {
        _delegateQueue = dispatch_get_main_queue();
    }
    return _delegateQueue;
}

#pragma mark init

- (instancetype)initWithDB:(SSNDB *)db table:(SSNDBTable *)table fetch:(SSNDBFetch *)fetch {
    NSAssert(db && table, @"必须传入数据库以及操作的表");
    NSAssert(table.db == db, @"传入的数据表必须同样是当前数据下面的表");
    self = [super init];
    if (self) {
        _db = db;
        _table = table;
        _fetch = [fetch copy];
        _delegateQueue = dispatch_get_main_queue();
        
        //监听数据表变化
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dbupdatedNotification:)
                                                     name:SSNDBUpdatedNotification
                                                   object:_db];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)fetchControllerWithDB:(SSNDB *)db table:(SSNDBTable *)table fetch:(SSNDBFetch *)fetch {
    return [[[self class] alloc] initWithDB:db table:table fetch:fetch];
}

#pragma mark status
- (BOOL)performFetch {
    return NO;
}

#pragma mark object manager
- (NSUInteger)count {
    return 0;
}

- (NSArray *)objects {
    return nil;
}

- (id)objectAtIndex:(NSUInteger)index {
    return nil;
}

- (NSUInteger)indexOfObject:(id)object {
    return NSNotFound;
}

#pragma mark 核心处理
- (void)dbupdatedNotification:(NSNotification *)notice {
    //只关心数据的增删改
    NSDictionary *userInfo = notice.userInfo;
    NSString *tableName = [userInfo objectForKey:SSNDBTableNameUserInfoKey];
    if (![_table.name isEqualToString:tableName]) {
        return ;
    }
    
    int operation = [[userInfo objectForKey:SSNDBOperationUserInfoKey] intValue];
    if (SQLITE_INSERT != operation && SQLITE_UPDATE != operation && SQLITE_DELETE != operation) {
        return ;
    }
    
    int64_t row_id = [[userInfo objectForKey:SSNDBRowIdUserInfoKey] longLongValue];
    if (row_id <= 0) {
        return ;
    }
    
    //可以处理数据了
}

@end

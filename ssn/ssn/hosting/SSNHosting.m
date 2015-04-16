//
//  SSNHosting.m
//  ssn
//
//  Created by lingminjun on 14/12/7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNHosting.h"
#import "ssnbase.h"
#import <pthread.h>

NSString *const SSNHostingTaskTable = @"ssn_hosting_task";

#pragma mark - 私有方法
@interface SSNHostingDBTask : NSObject
@property (nonatomic,copy) NSString *tid;
@property (nonatomic) NSUInteger at;
@property (nonatomic,copy) NSString *clazz;
@property (nonatomic) NSUInteger times;
@property (nonatomic,copy) NSString *data;
@end

@interface SSNHosting () {
    pthread_mutex_t _mutex;
    CFRunLoopRef _runloop;
}

//数据库支持
@property (nonatomic,strong) SSNDB *db;
@property (nonatomic,strong) SSNDBTable *table;

//读写属性
@property (nonatomic,copy) NSString *identify;
@property (nonatomic) BOOL isRuning;

//执行队列
@property (nonatomic,strong) dispatch_queue_t queue;
//@property (nonatomic,strong) NSOperationQueue *queue;

//当前正在处理的任务id
@property (nonatomic,copy) NSString *currentTaskID;

@end


@interface SSNHostingTask ()

@property (nonatomic,copy) NSString *taskID;//任务id
@property (nonatomic) SSNHostingTaskStatus status;
//@property (nonatomic) NSUInteger activateTimes;
//@property (nonatomic) NSUInteger timestamp;//加入到队列的时间
@property (nonatomic,weak) SSNHosting *hosting;
@property (nonatomic,strong) SSNHostingDBTask *core;

@end

@implementation SSNHostingDBTask

+ (instancetype)dbtaskWithTask:(SSNHostingTask *)task {
    SSNHostingDBTask *dbtask = [[SSNHostingDBTask alloc] init];
    dbtask.tid = task.taskID;
    dbtask.clazz = NSStringFromClass([task class]);
    dbtask.at = ssn_sec_timestamp();
    return dbtask;
}

+ (instancetype)dbtaskWithTaskID:(NSString *)taskID {
    SSNHostingDBTask *dbtask = [[SSNHostingDBTask alloc] init];
    dbtask.tid = taskID;
    return dbtask;
}

@end

#pragma mark - imp
@implementation SSNHosting

- (instancetype)init {
    return [self initWithIdentify:nil];
}

- (instancetype)initWithIdentify:(NSString *)identify {
    if ([identify length] == 0) {
        return nil;
    }
    self = [super init];
    if (self) {
        _identify = [identify copy];
        pthread_mutex_init(&_mutex, NULL);
        
        NSString *md5 = [identify ssn_md5];
        _db = [[SSNDBPool shareInstance] dbWithScope:md5];
        _table = [SSNDBTable tableWithDB:_db name:SSNHostingTaskTable templateName:nil];
        NSAssert(_table, @"无法生产hosting数据表，缺少ssn_hosting_task.json资源文件");
        
        //执行队列
        _queue = dispatch_queue_create([_identify UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_suspend(_queue);//先暂停队列
        
        [NSNotificationCenter ssn_defaultCenterAddObserver:self selector:@selector(tableUpdatedNotify:) name:SSNDBTableUpdatedNotification object:_table];
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutex);
}

- (BOOL)run {
    BOOL result = NO;
    pthread_mutex_lock(&_mutex);
    if (!_isRuning) {
        //
    }
    pthread_mutex_unlock(&_mutex);
    return result;
}

- (BOOL)stop {
    BOOL result = NO;
    pthread_mutex_lock(&_mutex);
    if (_isRuning) {
        //
    }
    pthread_mutex_unlock(&_mutex);
    return result;
}

- (void)tableUpdatedNotify:(NSNotification *)notify {
    NSLog(@"数据表中数据发生改变");
}

/**
 *  托管一个任务，任务已经存在将被替换，时序不被改变
 *
 *  @param task 被托管的任务
 */
- (void)hostingTask:(SSNHostingTask *)task {
    
    if ([task.taskID length] == 0) {
        return;
    }
    
    SSNHostingDBTask *dbtask = [SSNHostingDBTask dbtaskWithTask:task];
    [_table upinsertObject:dbtask];//在db回调中触发
}

/**
 *  移除某个任务，任务此时处在process过程中，则会调用cancel process方法
 *
 *  @param taskID 任务id
 */
- (void)removeTaskWithTaskID:(NSString *)taskID {
    if ([taskID length] == 0) {
        return;
    }
    
    SSNHostingDBTask *dbtask = [SSNHostingDBTask dbtaskWithTaskID:taskID];
    [_table deleteObject:dbtask];
    
    //比较当前任务
    if (![_currentTaskID isEqualToString:taskID]) {
        return ;
    }
    
    //取消等待任务
    if (_runloop) {
        CFRunLoopStop(_runloop);
        _runloop = NULL;
    }
}

/**
 *  当前的任务个数（包含正在处理的）
 *
 *  @return 返回任务个数
 */
- (NSUInteger)taskCount {
    return [_table objectsCount];
}

/**
 *  获取队列中的任务
 *
 *  @param taskID 任务id
 *
 *  @return 返回id对应的任务
 */
- (SSNHostingTask *)taskWithTaskID:(NSString *)taskID {
    if ([taskID length] == 0) {
        return nil;
    }
    NSArray *objs = [_table objectsWithClass:[SSNHostingDBTask class] forConditions:@{@"tid":taskID}];
    return [objs firstObject];
}

#pragma mark - loop
//- ()

@end

@implementation SSNHostingTask

//

@end

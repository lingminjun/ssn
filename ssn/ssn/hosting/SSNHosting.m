//
//  SSNHosting.m
//  ssn
//
//  Created by lingminjun on 14/12/7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNHosting.h"
#import "ssnbase.h"
#import <sqlite3.h>
#import <pthread.h>

NSString *const SSNHostingTaskTable = @"ssn_hosting_task";

#pragma mark - 私有方法
typedef NS_ENUM(NSUInteger, SSNHostingTaskDataCodingType) {
    SSNHostingTaskDataCodingNan,//不编码
    SSNHostingTaskDataCodingObjC,//oc编码
    SSNHostingTaskDataCodingCustom,//自定义编码
};

@interface SSNHostingDBTask : NSObject
@property (nonatomic,copy) NSString *tid;
@property (nonatomic) NSUInteger at;
@property (nonatomic,copy) NSString *clazz;
@property (nonatomic,copy) NSString *selector;
@property (nonatomic) NSUInteger times;
@property (nonatomic) SSNHostingTaskDataCodingType coder;
@property (nonatomic,copy) NSData *data;
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


@implementation SSNHostingDBTask

+ (instancetype)dbtaskWithTargetClassName:(NSString *)clazzName selector:(SEL)selector coder:(SSNHostingTaskDataCodingType)type data:(NSData *)data {
    SSNHostingDBTask *dbtask = [[SSNHostingDBTask alloc] init];
    
    int64_t now = ssn_usec_timestamp();
    NSString *selecorString = NSStringFromSelector(selector);
    dbtask.tid = [NSString stringWithFormat:@"%@.%@.%@",@(now),clazzName,selecorString];
    
    dbtask.clazz = clazzName;
    dbtask.selector = selecorString;
    
    dbtask.at = now;
    
    dbtask.coder = type;
    dbtask.data = data;
    
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
//        dispatch_suspend(_queue);//先暂停队列
        
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
        _isRuning = YES;
        result =  YES;
        
        [self coreLoop];
    }
    pthread_mutex_unlock(&_mutex);
    return result;
}

- (BOOL)stop {
    BOOL result = NO;
    pthread_mutex_lock(&_mutex);
    if (_isRuning) {
        _isRuning = YES;
        result =  YES;
    }
    pthread_mutex_unlock(&_mutex);
    return result;
}

- (void)tableUpdatedNotify:(NSNotification *)notify {
    
    NSDictionary *info = notify.userInfo;
    
    NSInteger operation = [[info objectForKey:SSNDBOperationUserInfoKey] integerValue];
    
    if (SQLITE_INSERT == operation) {
        [self coreLoop];
    }
    
    NSLog(@"数据表中数据发生改变");
}

/**
 *  移除某个任务，任务此时处在process过程中，则会调用cancel process方法
 *
 *  @param taskID 任务id
 */
- (void)cancelTaskWithTaskID:(NSString *)taskID {
    if ([taskID length] == 0) {
        return ;
    }
    
    pthread_mutex_lock(&_mutex);
    //比较当前任务
    if ([_currentTaskID isEqualToString:taskID]) {
        //取消等待任务
        if (_runloop) {
            CFRunLoopStop(_runloop);
            _runloop = NULL;
        }
    }
    pthread_mutex_unlock(&_mutex);
    
    SSNHostingDBTask *dbtask = [SSNHostingDBTask dbtaskWithTaskID:taskID];
    [_table deleteObject:dbtask];
}

/**
 *  完成任务
 *
 *  @param taskID 任务id
 */
- (void)finishTaskWithTaskID:(NSString *)taskID {
    if ([taskID length] == 0) {
        return ;
    }
    
    BOOL deleted = NO;
    pthread_mutex_lock(&_mutex);
    //比较当前任务
    if ([_currentTaskID isEqualToString:taskID]) {
        //取消等待任务
        if (_runloop) {
            CFRunLoopStop(_runloop);
            _runloop = NULL;
        }
        
        deleted = YES;
    }
    pthread_mutex_unlock(&_mutex);
    
    if (deleted) {
        SSNHostingDBTask *dbtask = [SSNHostingDBTask dbtaskWithTaskID:taskID];
        [_table deleteObject:dbtask];
    }
    
}

/**
 *  失败任务
 *
 *  @param taskID 任务id
 */
- (void)failedTaskWithTaskID:(NSString *)taskID {
    if ([taskID length] == 0) {
        return ;
    }
    
    pthread_mutex_lock(&_mutex);
    //比较当前任务
    if ([_currentTaskID isEqualToString:taskID]) {
        //取消等待任务
        if (_runloop) {
            CFRunLoopStop(_runloop);
            _runloop = NULL;
        }
    }
    pthread_mutex_unlock(&_mutex);
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
 *  返回此任务被激活次数
 *
 *  @param taskID 任务id
 *
 *  @return 返回此任务激活次数
 */
- (NSUInteger)activateTimesWithTaskID:(NSString *)taskID {
    if ([taskID length] == 0) {
        return 0;
    }
    
    NSArray *result = [_table objectsWithClass:[SSNHostingDBTask class] forConditions:@{@"tid":taskID}];
    SSNHostingDBTask *task = [result lastObject];
    return task.times;
}
#pragma mark - 托管方法

- (NSString *)hostingClassName:(NSString *)className classSelector:(SEL)selector data:(NSData *)data coder:(SSNHostingTaskDataCodingType)coder {
    
    //参数验证
    Class clazz = NSClassFromString(className);
    if (!clazz) {
        return nil;
    }
    
    if (![(NSObject *)clazz respondsToSelector:selector]) {
        return nil;
    }
    
    SSNHostingDBTask *task = [SSNHostingDBTask dbtaskWithTargetClassName:className selector:selector coder:coder data:data];
    
    [_table upinsertObject:task];//db hook 回调
    
    return task.tid;
}

/**
 *  托管某个类的静态方法
 *
 *  @param className 需要托管的类
 *  @param selector 托管的方法
 *                  注意，托管的方法必须一下格式
 *                  +(SSNProcessAsync)isAsyncTaskProcess:(NSString *)data;
 *                  或者+(SSNProcessAsync)isAsyncTaskProcess:(NSString *)data taskID:(NSString *)taskID;
 *  @param data     数据（业务去保证去重逻辑）
 *
 *  @return 返回为本次托管任务分配的taskID
 */
- (NSString *)hostingClassName:(NSString *)className classSelector:(SEL)selector data:(NSData *)data {
    return [self hostingClassName:className classSelector:selector data:data coder:SSNHostingTaskDataCodingNan];
}

/**
 *  托管某个类的静态方法(可序NSCoding列化的方法)
 *
 *  @param className 需要托管的类
 *  @param selector 托管的方法
 *                  注意，托管的方法必须一下格式
 *                  +(SSNProcessAsync)isAsyncTaskProcess:(id<NSCoding>)data;
 *                  或者+(SSNProcessAsync)isAsyncTaskProcess:(id<NSCoding>)data taskID:(NSString *)taskID;
 *  @param data     数据（业务去保证去重逻辑）
 *
 *  @return 返回为本次托管任务分配的taskID
 */
- (NSString *)hostingClassName:(NSString *)className classSelector:(SEL)selector ocCodingObject:(id<NSCoding>)obj {
    if (!obj) {
        return nil;
    }
    NSData *data = nil;
    @try {
        data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        return nil;
    }
    
    if (data == nil) {
        return nil;
    }
    
    return [self hostingClassName:className classSelector:selector data:data coder:SSNHostingTaskDataCodingObjC];
}

/**
 *  托管某个类的静态方法(可序自定义列化的方法)
 *
 *  @param className 需要托管的类
 *  @param selector 托管的方法
 *                  注意，托管的方法必须一下格式
 *                  +(SSNProcessAsync)isAsyncTaskProcess:(id<SSNHostingTaskDataCoding>)data;
 *                  或者+(SSNProcessAsync)isAsyncTaskProcess:(id<SSNHostingTaskDataCoding>)data taskID:(NSString *)taskID;
 *  @param obj      数据（业务去保证去重逻辑）
 *
 *  @return 返回为本次托管任务分配的taskID
 */
- (NSString *)hostingClassName:(NSString *)className classSelector:(SEL)selector customCodingObject:(id<SSNHostingTaskDataCoding>)obj {
    if (!obj) {
        return nil;
    }
    NSData *data = [self encodeDataFromObject:obj];
    if (data == nil) {
        return nil;
    }
    return [self hostingClassName:className classSelector:selector data:data coder:SSNHostingTaskDataCodingCustom];
}



#pragma mark - loop
- (void)coreLoop {
    
    dispatch_block_t block = ^{
        
        do {
            BOOL isRunloop = NO;
            pthread_mutex_lock(&_mutex);
            isRunloop = _isRuning;
            _runloop = CFRunLoopGetCurrent();
            pthread_mutex_unlock(&_mutex);

            if (!isRunloop) {
                return ;
            }
            
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY at AES LIMI 1",SSNHostingTaskTable];
            NSArray *result = [_db objects:[SSNHostingDBTask class] sql:sql arguments:nil];
            SSNHostingDBTask *task = [result lastObject];
            
            if (!task) {//说明没有任务了
                break ;
            }
            
            Class clazz = NSClassFromString(task.clazz);
            if (!clazz && [_delegate respondsToSelector:@selector(ssn_hosting:loadTaskClassName:)]) {
                NSString *clazz_str = [_delegate ssn_hosting:self loadTaskClassName:task.clazz];
                if ([clazz_str length]) {
                    clazz = NSClassFromString(clazz_str);
                }
            }
            
            //删除此任务
            if (!clazz) {
                [_table deleteObject:task];
                continue ;
            }
            
            SEL selector = NSSelectorFromString(task.selector);
            if (![(NSObject *)clazz respondsToSelector:selector] && [_delegate respondsToSelector:@selector(ssn_hosting:taskClassName:loadTaskSelectorName:)]) {
                NSString *selector_str = [_delegate ssn_hosting:self taskClassName:task.clazz loadTaskSelectorName:task.selector];
                if ([selector_str length]) {
                    selector = NSSelectorFromString(selector_str);
                }
            }
            
            //删除此任务
            if (![(NSObject *)clazz respondsToSelector:selector]) {
                [_table deleteObject:task];
                continue ;
            }
            
            id obj = [self objectFromEncodeData:task.data encoderType:task.coder];
            
            if (!obj) {
                [_table deleteObject:task];//删除此任务
                continue;
            }
            
            pthread_mutex_lock(&_mutex);
            _currentTaskID = task.tid;//疑问，若cancel调用在runloop run之前会发生什么事
            pthread_mutex_unlock(&_mutex);
            
            SSNProcessAsync ret = NO;
            @try {
                //开始处理任务
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                ret = [(NSObject *)clazz performSelector:selector withObject:obj withObject:task.tid];
#pragma clang diagnostic pop
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
                [_table deleteObject:task];//删除此任务
                ret = NO;
            }

            
            if (ret) {
                NSLog(@"开启runloop开始等待");
                [NSThread ssn_runloopBlockUntilCondition:^SSNBreak{ return NO; } atSpellTime:0];
            }
            
            pthread_mutex_lock(&_mutex);
            _currentTaskID = nil;
            _runloop = NULL;
            pthread_mutex_unlock(&_mutex);
            
        } while (YES);
        
    };
    
    dispatch_async(_queue, block);
}

#pragma mark - other
- (id)objectFromEncodeData:(NSData *)data encoderType:(SSNHostingTaskDataCodingType)type {
    @try {
        switch (type) {
            case SSNHostingTaskDataCodingNan:
                return data;
                break;
            case SSNHostingTaskDataCodingObjC:
                return [NSKeyedUnarchiver unarchiveObjectWithData:data];
                break;
            case SSNHostingTaskDataCodingCustom:
                return [self decodeObjectFromData:data];
                break;
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        return nil;
    }
}

- (NSData *)encodeDataFromObject:(id<SSNHostingTaskDataCoding>)obj {
    @try {
        NSMutableData *data = [NSMutableData data];
        NSData *clazzName = [NSStringFromClass([obj class]) dataUsingEncoding:NSUTF8StringEncoding];
        char c = [clazzName length];//256 个字符，足够了
        [data appendBytes:&c length:1];
        [data appendData:clazzName];
        NSData *objData = [obj ssn_hostingTaskDataEncode];
        if (objData) {
            [data appendData:objData];
        }
        return data;
    }
    @catch (NSException *exception) {
        NSLog(@"encodeData %@",exception);
        return nil;
    }
}

- (id<SSNHostingTaskDataCoding>)decodeObjectFromData:(NSData *)data {
    @try {
        char c = 0;
        [data getBytes:&c length:1];
        char *c_str = (char *)malloc(sizeof(char));
        [data getBytes:c_str range:NSMakeRange(1, c)];
        NSString *clazz_str = [[NSString alloc] initWithBytesNoCopy:c_str length:c encoding:NSUTF8StringEncoding freeWhenDone:YES];
        Class clazz = NSClassFromString(clazz_str);
        if (!clazz) {
            return nil;
        }
        NSData *subData = [data subdataWithRange:NSMakeRange(c+1, [data length] - (c+1))];
        return [[clazz alloc] initWithHostingTaskData:subData];
    }
    @catch (NSException *exception) {
        NSLog(@"decodeData %@",exception);
        return nil;
    }
}

@end

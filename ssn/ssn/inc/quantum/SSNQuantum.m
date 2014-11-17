//
//  SSNQuantum.m
//  ssn
//
//  Created by lingminjun on 14-11-16.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNQuantum.h"
#import <pthread.h>

NSString *const SSNQuantumProcessorNotification = @"SSNQuantumProcessorNotification";
NSString *const SSNQuantumObjectsKey = @"SSNQuantumObjectsKey";

@interface SSNQuantum ()
{
    NSMutableArray *_arr;
    pthread_mutex_t _mutex;
    dispatch_queue_t _queue;
    dispatch_source_t _timer;
}

@property (nonatomic) NSTimeInterval interval;//间隔时间
@property (nonatomic) NSUInteger maxCount;//最大播发量

@end

@implementation SSNQuantum

- (instancetype)initWithInterval:(NSTimeInterval)interval maxCount:(NSUInteger)count {
    self = [super init];
    if (self) {
        _interval = interval;
        _maxCount = count;
        _queue = dispatch_queue_create("SSNQuantum", DISPATCH_QUEUE_SERIAL);
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (instancetype)quantumWithInterval:(NSTimeInterval)interval maxCount:(NSUInteger)count {
    return [[[self class] alloc] initWithInterval:interval maxCount:count];
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutex);
}

- (void)setExpressQueue:(dispatch_queue_t)queue {
    _queue = queue;
}

#pragma mark -

- (void)pushObject:(id)object {
    if (!object) {
        return ;
    }
    
    [self pushObjects:@[object]];
}

- (void)pushObjects:(NSArray *)objects {
    if ([objects count] == 0) {
        return ;
    }
    
    pthread_mutex_lock(&_mutex);
    
    if (_arr) //已经有一个待处理的任务在_queue中了
    {
        [_arr addObjectsFromArray:objects];
        
        //一旦被加入的数据超过最大值，就立即播发
        if ([_arr count] >= _maxCount) {
            [self cancelTimer];
            
            NSArray *arry = [NSArray arrayWithArray:_arr];
            dispatch_async(_queue, ^{ NSLog(@"over count prior express %@",arry); [self processorWithObjects:arry]; });
            _arr = nil;
        }
        
    }
    else
    {
        __block NSMutableArray *t_lists = [NSMutableArray array]; //生产临时变量
        
        [t_lists addObjectsFromArray:objects];
        
        if ([t_lists count] >= _maxCount) {
            dispatch_async(_queue, ^{ NSLog(@"over count express %@",t_lists); [self processorWithObjects:t_lists]; });
        }
        else {
            _arr = t_lists;//记录放到block中数组
            [self scheduledProcessorWithInterval:_interval objects:t_lists];//注入__block array，实际是可变的__block值
        }
    }
    
    pthread_mutex_unlock(&_mutex);
}

- (void)express {
    pthread_mutex_lock(&_mutex);
    
    //1 先停止加载的timer
    [self cancelTimer];
    
    //2 将所有的数据播发
    if ([_arr count]) {
        NSArray *arry = [NSArray arrayWithArray:_arr];
        dispatch_async(_queue, ^{  NSLog(@"direct express %@",arry); [self processorWithObjects:arry]; });
        _arr = nil;
    }
    
    pthread_mutex_unlock(&_mutex);
}


- (void)processorWithObjects:(NSArray *)objects {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(quantum:objects:)]) {
            [self.delegate quantum:self objects:objects];
        }
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SSNQuantumProcessorNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:objects
                                                                                               forKey:SSNQuantumObjectsKey]];
    }
}



- (void)scheduledProcessorWithInterval:(NSTimeInterval)timeOut objects:(NSArray *)objects {
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_time_t del = dispatch_time(DISPATCH_TIME_NOW, timeOut * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, del, timeOut * NSEC_PER_SEC, 1ull * NSEC_PER_USEC);
    __weak typeof(self) w_self = self;
    dispatch_source_set_event_handler(timer, ^{ __strong typeof(w_self) self = w_self; if (!self) {return ;}
        NSLog(@"time out express %@",objects);
        [self processorWithObjects:objects];
        [self cancelTimer];
    });
    _timer = timer;
    
    dispatch_resume(timer);
    
}

- (void)cancelTimer {

    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

@end

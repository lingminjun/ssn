//
//  NiceQueue.m
//  Routable
//
//  Created by lingminjun on 14-6-10.
//  Copyright (c) 2014年 TurboProp Inc. All rights reserved.
//

#import "NiceQueue.h"

@interface NiceQueue ()

@property (nonatomic,strong) NSString *identify;
#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t actionQueue;
@property (nonatomic, strong) dispatch_source_t timer;
#else
@property (nonatomic, readwrite) dispatch_queue_t actionQueue;
@property (nonatomic, readwrite) dispatch_source_t timer;
#endif

@property (nonatomic,strong) NSString *currentTag;
@property (nonatomic) BOOL isSuspend;

- (void)startTimer:(NSTimeInterval)timeOut tag:(NSString *)tag;
- (void)cancelTimerForTag:(NSString *)tag;

@end

@implementation NiceQueue

@synthesize identify = _identify;

- (NSString *)identify {
    if (_identify) {
        return _identify;
    }
    
    _identify = [NSString stringWithFormat:@"%@",self];
    return _identify;
}

@synthesize actionQueue = _actionQueue;

- (void)setActionQueue:(dispatch_queue_t)actionQueue {
#if OS_OBJECT_USE_OBJC
    _actionQueue = actionQueue;
#else
    if (actionQueue) {
        dispatch_retain(actionQueue);
    }
    
    if (_actionQueue) {
        dispatch_release(_actionQueue);
    }
    
    _actionQueue = actionQueue;
#endif
}

@synthesize timer = _timer;
- (void)setTimer:(dispatch_source_t)timer {
#if OS_OBJECT_USE_OBJC
    _timer = timer;
#else
    if (timer) {
        dispatch_retain(timer);
    }
    
    if (_timer) {
        dispatch_release(_timer);
    }
    
    _timer = timer;
#endif
}

- (dispatch_queue_t)actionQueue {
    if (_actionQueue) {
        return _actionQueue;
    }
    
    self.actionQueue  = dispatch_queue_create([self.identify UTF8String], DISPATCH_QUEUE_SERIAL);
    
    //将父队列设置为主队列，有益于对动画操作，也不需要对isSuspend加锁控制
    dispatch_queue_t superQueue = dispatch_get_main_queue();
    
    dispatch_set_target_queue(_actionQueue,superQueue);
    
    return _actionQueue;
}

- (id)initWithIdentify:(NSString *)identify {
    self = [super init];
    if (self) {
        self.identify = identify;
    }
    return self;
}

//添加执行任务，返回yes表示不需要等待，返回no，则要等待
- (void)addAction:(BOOL (^)(NSString *tag))action forTag:(NSString *)tag timeOut:(NSTimeInterval)timeOut {
    
    if (nil == tag || nil == action) {
        return ;
    }
    
    __weak typeof(self) w_self = self;
    dispatch_block_t block = ^{
        __strong typeof(w_self) s_self = w_self;
        
        if (nil == s_self) {
            return ;
        }
        
        s_self.currentTag = tag;
        
        BOOL notWait = action(tag);
        
        //需要等待
        if (notWait == NO) {
            
            if (timeOut > 0.0005) {
                [self startTimer:timeOut tag:tag];
            }
            
            s_self.isSuspend = YES;
            dispatch_suspend(s_self.actionQueue);
            NSLog(@"%@ queue freeze！tag = %@",s_self.identify,tag);
        }
        else {
            s_self.currentTag = nil;
        }
    };
    
    dispatch_async(self.actionQueue, block);
}

- (void)addAction:(BOOL (^)(NSString *))action {
    NSString *tag = [NSString stringWithFormat:@"%p",action];
    [self addAction:action forTag:tag timeOut:0];
}

- (void)fireForTag:(NSString *)tag {
    if (nil == tag) {
        return ;
    }
    
    if (self.currentTag == tag
        || [self.currentTag isEqualToString:tag]) {
        
        //保证在主线程中执行
        dispatch_block_t block = ^{
            if (self.isSuspend) {
                
                [self cancelTimerForTag:tag];
                
                dispatch_resume(self.actionQueue);
                self.isSuspend = NO;
                self.currentTag = nil;
                NSLog(@"%@ queue fire！tag = %@",self.identify, tag);
            }
        };
        
        if ([NSThread isMainThread]) {
            block();
        }
        else {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

- (void)fire {
    [self fireForTag:self.currentTag];
}

- (void)startTimer:(NSTimeInterval)timeOut tag:(NSString *)tag {
    __weak typeof(self) w_self = self;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, mainQueue);
    dispatch_time_t del = dispatch_time(DISPATCH_TIME_NOW, timeOut * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, del, timeOut * NSEC_PER_SEC, 1ull * NSEC_PER_USEC);
    dispatch_source_set_event_handler(timer, ^{
        __strong typeof(w_self) s_self = w_self;
        NSLog(@"%@ queue timeOut！tag = %@",s_self.identify, tag);
        [s_self fireForTag:tag];
    });
    self.timer = timer;
    dispatch_resume(timer);
}

- (void)cancelTimerForTag:(NSString *)tag {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

@end
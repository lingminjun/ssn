//
//  NiceQueue.h
//  Routable
//
//  Created by lingminjun on 14-6-10.
//  Copyright (c) 2014年 TurboProp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL NoWaiting;

//简单队列控制，继承自主线程队列（如果不想继承主线程队列，自己去修改，记得临界资源控制）
@interface NiceQueue : NSObject

- (id)initWithIdentify:(NSString *)identify;//identify主要起调试作用

//添加执行任务，返回yes表示不需要等待，返回no，则要等待，任务主线程执行，timeOut单位为秒，设置为0表示永不超时
- (void)addAction:(NoWaiting (^)(NSString *tag))action forTag:(NSString *)tag timeOut:(NSTimeInterval)timeOut;
- (void)addAction:(NoWaiting (^)(NSString *))action;

- (void)fireForTag:(NSString *)tag;//指定事件开启

- (void)fire;

@end

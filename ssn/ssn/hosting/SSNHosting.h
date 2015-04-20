//
//  SSNHosting.h
//  ssn
//
//  Created by lingminjun on 14/12/7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

//依赖数据操作
#import "SSNDBPool.h"
#import "SSNDBTable+Factory.h"

@class SSNHosting;

/**
 *  托管任务状态
 */
typedef NS_ENUM(NSUInteger, SSNHostingTaskStatus){
    /**
     *  等待状态，若执行失败可以转为等待状态
     */
    SSNHostingTaskWaiting,
    /**
     *  处理中
     */
    SSNHostingTaskProcessing,
    /**
     *  结束状态，结束后将释放
     */
    SSNHostingTaskClosed,
};

/**
 *  托管服务委托
 */
@protocol SSNHostingDelegate <NSObject>

@optional
/**
 *  从数据库队列中加载任务时类名找不到时调用
 *
 *  @param hosting       当前的服务
 *  @param taskClassName 数据库中的类名
 *
 *  @return 返回新的类名，若返回nil，将丢弃此任务
 */
- (NSString *)ssn_hosting:(SSNHosting *)hosting loadTaskClassName:(NSString *)taskClassName;

/**
 *  从数据库队列中加载任务时方法找不到时调用
 *
 *  @param hosting       当前的服务
 *  @param taskClassName 数据库中的类名
 *  @param selectorName  数据库中的方法名
 *
 *  @return 返回新的方法，若返回nil，将丢弃此任务
 */
- (NSString *)ssn_hosting:(SSNHosting *)hosting taskClassName:(NSString *)taskClassName loadTaskSelectorName:(NSString *)selectorName;

@end

/**
 *  满足json code协议的序列化
 */
@protocol SSNHostingTaskDataCoding <NSObject>

- (NSData *)ssn_hostingTaskDataEncode;//自定义序列换（建议json序列）
- (instancetype)initWithHostingTaskData:(NSData *)data;//(反序列)

@end

/**
 *  是否异步
 */
typedef BOOL SSNProcessAsync;


/**
 * @brief 提供托管服务，任务执行按照FIFO方式
 */
@interface SSNHosting : NSObject

/**
 *  唯一初始化方法
 *
 *  @param identify 标示，不能为空
 *
 *  @return 返回实例
 */
- (instancetype)initWithIdentify:(NSString *)identify;

/**
 *  托管服务唯一标示
 */
@property (nonatomic,copy,readonly) NSString *identify;

/**
 *  处理任务状态回调
 */
@property (nonatomic,weak) id<SSNHostingDelegate> delegate;

/**
 *  是否为运行状态，你可以调用run and stop来启动和停止服务端运行
 */
@property (nonatomic,readonly) BOOL isRuning;

/**
 *  启动服务，若已经启动，忽略
 *
 *  @return 操作是否成功，忽略操作返回NO
 */
- (BOOL)run;

/**
 *  停止服务，若已经停止，忽略
 *
 *  @return 操作是否成功，忽略操作返回NO
 */
- (BOOL)stop;

/**
 *  取消任务
 *
 *  @param taskID 任务id
 */
- (void)cancelTaskWithTaskID:(NSString *)taskID;

/**
 *  完成任务
 *
 *  @param taskID 任务id
 */
- (void)finishTaskWithTaskID:(NSString *)taskID;

/**
 *  失败任务，任务就继续重试
 *
 *  @param taskID 任务id
 */
- (void)failedTaskWithTaskID:(NSString *)taskID;

/**
 *  当前的任务个数（包含正在处理的）
 *
 *  @return 返回任务个数
 */
- (NSUInteger)taskCount;

/**
 *  返回此任务被激活次数
 *
 *  @param taskID 任务id
 *
 *  @return 返回此任务激活次数
 */
- (NSUInteger)activateTimesWithTaskID:(NSString *)taskID;

#pragma mark 托管任务方法，请根据参数是否需要序列化，选取合适的托管

/**
 *  托管某个类的静态方法
 *
 *  @param className 需要托管的类
 *  @param selector 托管的方法
 *                  注意，托管的方法必须一下格式
 *                  +(SSNProcessAsync)isAsyncTaskProcess:(NSData *)data;
 *                  或者+(SSNProcessAsync)isAsyncTaskProcess:(NSData *)data taskID:(NSString *)taskID;
 *  @param data     数据（业务去保证去重逻辑）
 *
 *  @return 返回为本次托管任务分配的taskID
 */
- (NSString *)hostingClassName:(NSString *)className classSelector:(SEL)selector data:(NSData *)data;

/**
 *  托管某个类的静态方法(可序NSCoding列化的方法)
 *
 *  @param className 需要托管的类
 *  @param selector 托管的方法
 *                  注意，托管的方法必须一下格式
 *                  +(SSNProcessAsync)isAsyncTaskProcess:(id<NSCoding>)data;
 *                  或者+(SSNProcessAsync)isAsyncTaskProcess:(id<NSCoding>)data taskID:(NSString *)taskID;
 *  @param obj      数据（业务去保证去重逻辑）
 *
 *  @return 返回为本次托管任务分配的taskID
 */
- (NSString *)hostingClassName:(NSString *)className classSelector:(SEL)selector ocCodingObject:(id<NSCoding>)obj;

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
- (NSString *)hostingClassName:(NSString *)className classSelector:(SEL)selector customCodingObject:(id<SSNHostingTaskDataCoding>)obj;

@end








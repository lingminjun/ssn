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

@class SSNHosting,SSNHostingTask;

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
 *  某个任务将要被处理
 *
 *  @param hosting 当前的服务
 *  @param task    将要处理的任务
 */
- (void)ssn_hosting:(SSNHosting *)hosting willProcessTask:(SSNHostingTask *)task;

/**
 *  某个任务被处理完了（失败和成功）
 *
 *  @param hosting 当前的服务
 *  @param task    当前处理的任务
 *  @param status  任务被转到什么状态，失败后，并不会立即重试，而是先转入到waiting状态
 */
- (void)ssn_hosting:(SSNHosting *)hosting didProcessTask:(SSNHostingTask *)task turnStatus:(SSNHostingTaskStatus)status;

/**
 *  某个任务被移除了
 *
 *  @param hosting 当前服务
 *  @param task    被移除的任务
 */
- (void)ssn_hosting:(SSNHosting *)hosting cancelProcessTask:(SSNHostingTask *)task;

/**
 *  从数据库队列中加载任务时类名找不到时调用
 *
 *  @param hosting       当前的服务
 *  @param taskClassName 数据库中的类名
 *
 *  @return 返回新的类名，若返回nil，将丢弃此任务
 */
- (NSString *)ssn_hosting:(SSNHosting *)hosting loadTaskWithTaskClassName:(NSString *)taskClassName;

@end

//@protocol SSNHostingTaskSelector <NSObject>
//
//@required
//+ ()
//
//@end

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
 *  托管一个任务，任务已经存在将被替换，时序不被改变
 *
 *  @param task 被托管的任务
 */
//- (void)hostingTask:(SSNHostingTask *)task;

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
- (NSString *)hostingClassName:(NSString *)className classSelector:(SEL)selector data:(NSString *)data;

/**
 *  移除某个任务，任务此时处在process过程中，则会调用cancel process方法
 *
 *  @param taskID 任务id
 */
- (void)removeTaskWithTaskID:(NSString *)taskID;

/**
 *  当前的任务个数（包含正在处理的）
 *
 *  @return 返回任务个数
 */
- (NSUInteger)taskCount;

/**
 *  <#Description#>
 *
 *  @param taskID <#taskID description#>
 *
 *  @return <#return value description#>
 */
- (NSUInteger)activateTimesWithTaskID:(NSString *)taskID;

/**
 *  获取队列中的任务
 *
 *  @param taskID 任务id
 *
 *  @return 返回id对应的任务
 */
//- (SSNHostingTask *)taskWithTaskID:(NSString *)taskID;

@end

///**
// *  托管任务，要加入到托管服务的操作，必须继承task
// */
//@interface SSNHostingTask : NSObject
//
///**
// *  任务id
// */
//@property (nonatomic,copy,readonly) NSString *taskID;//任务id
//
///**
// *  任务状态
// */
//@property (nonatomic,readonly) SSNHostingTaskStatus status;
//
///**
// *  任务被激活的次数，使用者可以根据此值做删除操作
// */
//@property (nonatomic,readonly) NSUInteger activateTimes;
//
///**
// *  任务所携带的数据，更改他的值是，hosting会讲数据记录下来
// */
//@property (nonatomic,copy) NSString *data;//
//
///**
// *  通知任务已经完成，状态将转向SSNHostingTaskClosed，不要重载
// */
//- (void)finish;
//
///**
// *  通知任务失败，状态将转向SSNHostingTaskWaiting，不要重载
// */
//- (void)failure;
//
///**
// *  通知任务取消，状态将转向SSNHostingTaskClosed，不要重载
// */
//- (void)cancel;
//
//#pragma mark - override selector 供重载的方法
///**
// *  正在执行
// *
// *  @return 返回是否异步执行，若返回异步执行，需要调用finish方法结束
// */
//- (SSNProcessAsync)onProcess;
//
///**
// *  取消
// */
//- (void)onCancel;
//
//@end








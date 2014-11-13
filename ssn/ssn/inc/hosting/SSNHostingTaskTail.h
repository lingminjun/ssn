//
//  SSNHostingTaskTail.h
//  ssn
//
//  Created by lingminjun on 14-11-6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 托管任务状态
 */
typedef NS_ENUM(NSUInteger, SSNHostingTaskStatus) {
    SSNHostingTaskReady,//!< 就绪状态 在此状态，说明动作已经发生并记录到磁盘
    SSNHostingTaskProcess,//!< 处理状态
    SSNHostingTaskFailure,//!< 失败状态
    SSNHostingTaskSuccess,//!< 成功状态
};

/**
 * 托管任务历程记录
 */
@interface SSNHostingTaskTail : NSObject

@property (nonatomic,strong,readonly) NSString *taskId;//任务唯一id

@property (nonatomic,readonly) SSNHostingTaskStatus status;//当前状态

@property (nonatomic,readonly) NSUInteger retryTimes;//可重试次数

@property (nonatomic,readonly) NSUInteger times;//当前次数

/**
 *  记录任务切换到指定某种状态，
 *      状态切换要求：
 *          SSNHostingTaskReady to SSNHostingTaskProcess|SSNHostingTaskFailure|SSNHostingTaskSuccess
 *          SSNHostingTaskProcess to SSNHostingTaskFailure|SSNHostingTaskSuccess
 *          SSNHostingTaskFailure to SSNHostingTaskReady|SSNHostingTaskProcess
 *          SSNHostingTaskSuccess 状态溢出，不能再切换到其他状态
 *  @param status 将要切换到的状态
 *  @return 本次切换状态操作是否成功
 */
- (BOOL)logTaskToStatus:(SSNHostingTaskStatus)status;

@end

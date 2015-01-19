//
//  SSNJob.h
//  ssn
//
//  Created by lingminjun on 15/1/19.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSNJob;

/**
 *  活动输出回调
 *
 *  @param nextJob  下一个活动
 *  @param obj      nextJob承载者，任务分配过程
 *  @param userInfo 活动产生的其他参数
 */
typedef void (^SSNJobBlock)(SSNJob *nextJob, id obj, NSDictionary *userInfo);

/**
 *  活动处理方法
 *
 *  @param job      当前的活动
 *  @param obj      当前活动
 *  @param userInfo 参数
 *  @param block    活动处理完回调（输出口）
 */
typedef void (^SSNJobProcess)(SSNJob *job, id obj, NSDictionary *userInfo, SSNJobBlock block);

/**
 *  将活动抽象出来，便于组成活动链路（动态任务链）
 *  概念：活动----处理一个实际事件的一个动作
 *       执行者----活动承载者，他来参与执行此次活动
 *       活动输入输出----输入表示一个活动必要的参数，输出下一个活动和承载者，以及其他参数
 *  要点：每个活动必须非常清楚自己做的事情，所以每个活动处理结果后都要派发下一个活动并且分配给对应的执行者（任务分配）
 */
@interface SSNJob : NSObject

/**
 *  活动名字
 */
@property (nonatomic, copy, readonly) NSString *jobName;

/**
 *  活动初始化
 *
 *  @param name    活动名字
 *  @param process 活动处理内容
 *
 *  @return 返回一个活动
 */
- (id)initWithName:(NSString *)name process:(SSNJobProcess)process; //具体的工作内容

/**
 *  返回一个活动
 *
 *  @param name    活动名字
 *  @param process 活动处理内容
 *
 *  @return 返回一个活动实例
 */
+ (instancetype)jobWithName:(NSString *)name process:(SSNJobProcess)process;

/**
 *  执行此活动
 *
 *  @param obj        执行者
 *  @param userInfo   参数
 *  @param compeleted 输出
 */
- (void)processObj:(id)obj userInfo:(NSDictionary *)userInfo compeleted:(SSNJobBlock)compeleted;

@end

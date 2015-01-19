//
//  SSNJob.m
//  ssn
//
//  Created by lingminjun on 15/1/19.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNJob.h"

#ifdef DEBUG
#define lw_job_log(s, ...) ((void)0)//printf(s, ##__VA_ARGS__)
#else
#define lw_job_log(s, ...) ((void)0)
#endif

@interface SSNJob ()

@property (nonatomic, copy) NSString *jobName;
@property (nonatomic, copy) SSNJobProcess process;

@end

@implementation SSNJob

- (id)initWithName:(NSString *)name process:(SSNJobProcess)process
{
    self = [super init];
    if (self)
    {
        self.jobName = name;
        self.process = process;
    }
    return self;
}

+ (instancetype)jobWithName:(NSString *)name process:(SSNJobProcess)process
{
    return [[[self class] alloc] initWithName:name process:process];
}

//执行某个工作
- (void)processObj:(id)obj userInfo:(NSDictionary *)userInfo compeleted:(SSNJobBlock)compeleted
{
    if (self.process)
    {
        lw_job_log("[DTJob:%s processing! userInfo[%s]]", [self.jobName UTF8String],
                   [[userInfo description] UTF8String]);
        self.process(self, obj, userInfo, compeleted);
    }
}

@end

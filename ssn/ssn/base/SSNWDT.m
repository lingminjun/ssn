//
//  SSNWDT.m
//  ssn
//
//  Created by lingminjun on 15/6/8.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNWDT.h"
#import "NSString+SSN.h"
#import "NSObject+SSNBlock.h"
#import "SSNSafeSet.h"

NSString *const SSNWDT_DAILY_FORMAT = @"yyyy-MM-dd";
NSString *const SSNWDT_HOUR_FORMAT = @"yyyy-MM-dd HH";
NSString *const SSNWDT_WEEK_FORMAT = @"yyyy-MM-EEE";

#define SSNWDT_MAX_RETRY (1800)

@interface SSNWDT ()

@property (nonatomic,strong) NSString *key;

@property (nonatomic,copy) NSString *identify;//标记

@property (nonatomic) SSNWDTIntervalUnit unit;//计时单位

@property (nonatomic) NSUInteger interval;//触发间隔时间

@end

@implementation SSNWDT

- (void)setRetry:(NSUInteger)retry {
    if (retry > SSNWDT_MAX_RETRY) {
        retry = SSNWDT_MAX_RETRY;
    }
    _retry = retry;
}

/**
 *  唯一初始化
 *
 *  @param uint     计时单位
 *  @param interval 触发间隔时间
 *
 *  @return wdt
 */
- (instancetype)initWithIdentify:(NSString *)identify unit:(SSNWDTIntervalUnit)uint interval:(NSUInteger)interval {
    self = [super init];
    if (self) {
        if ([identify length] == 0) {
            NSLog(@"Waring ... 请设置唯一identify");
            @throw [NSException exceptionWithName:@"SSNWDT" reason:@"请设置唯一identify" userInfo:nil];
        }
        _identify = [identify copy];
        _unit = uint;
        _interval = interval;
        if (interval == 0) {
            NSLog(@"Waring ... 请设置注册间隔时间");
            @throw [NSException exceptionWithName:@"SSNWDT" reason:@"请设置注册间隔时间" userInfo:nil];
        }
    }
    return self;
}

/**
 *  工厂方法
 *
 *  @param uint     计时单位
 *  @param interval 触发间隔时间
 *
 *  @return wdt
 */
+ (instancetype)WDTWithIdentify:(NSString *)identify unit:(SSNWDTIntervalUnit)uint interval:(NSUInteger)interval {
    return [[[self class] alloc] initWithIdentify:identify unit:uint interval:interval];
}

- (NSTimeInterval)timeInterval {
    switch (_unit) {
        case SSNWDTDailyUnit:
            return _interval*24*3600;
            break;
        case SSNWDTHourUnit:
            return _interval*3600;
            break;
        case SSNWDTWeekUnit:
            return _interval*24*3600*7;
            break;
        default:
            break;
    }
    return 0;
}

- (NSString *)currentSeed {
    NSDate *date = [NSDate date];
    NSString *format = nil;
    switch (_unit) {
        case SSNWDTDailyUnit:
            format = SSNWDT_DAILY_FORMAT;
            break;
        case SSNWDTHourUnit:
            format = SSNWDT_HOUR_FORMAT;
            break;
        case SSNWDTWeekUnit:
            format = SSNWDT_WEEK_FORMAT;
            break;
        default:
            break;
    }
    
    if (_unit == SSNWDTWeekUnit) {
        int day = [[NSString ssn_stringWithDate:date formatter:@"dd"] intValue];
        int weakNum = (day + 6)/7;
        return [NSString stringWithFormat:@"%@-%d",[NSString ssn_stringWithDate:date formatter:format],weakNum];
    }
    else {
        return [NSString ssn_stringWithDate:date formatter:format];
    }
}

- (NSString *)userDefaultKey {
    if (_key) {
        return _key;
    }
    _key = [NSString stringWithFormat:@"ssn.wdt.%@",self.identify];
    return _key;
}

- (void)callback {/*此函数保证在主线程中执行*/
    //将前面的重试cancel掉
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callback) object:nil];

    //记过通知
    __block NSInteger flag1 = 0;//0没处理，1成功，2失败
    __block NSInteger flag2 = 0;//0没处理，1成功，2失败
    NSInteger retry = _retry;
    __weak typeof(self) w_self = self;
    void(^result)(SSNWDTTaskSuccess success) = ^(SSNWDTTaskSuccess success){
        __weak typeof(w_self) self = w_self; if (!self) { return ; }
        [self ssn_mainThreadAsyncBlock:^{
            //将时间点更新
            NSString *currentSeed = [self currentSeed];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *akey = [self userDefaultKey];
            
            if (flag1 == 0) {
                flag1 = success?1:2;
            }
            else {
                if (flag2 != 1 && success) {//若使用者第二次调用或者多次调用，只check成功
                    flag2 = 1;
                }
            }
            
            if (flag1 == 1 || flag2 == 1) {
                NSLog(@"%@更新至%@",akey,currentSeed);
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callback) object:nil];
                [userDefaults setObject:currentSeed forKey:akey];
                [userDefaults synchronize];
            }
            else {
                if (retry > 0) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callback) object:nil];
                    [self performSelector:@selector(callback) withObject:nil afterDelay:retry];
                    NSLog(@"%@在%@点开始重试",akey,currentSeed);
                }
            }
        }];
    };
    
    BOOL respondSelector = [_delegate respondsToSelector:@selector(scheduledTaskTriggerWDT:result:)];
    
    //需要校验是否重试
    
    if (_scheduledTask || respondSelector) {
        
        //先检查block
        if (_scheduledTask) {
            _scheduledTask(self,result);
        }
        
        if (respondSelector) {
            [_delegate scheduledTaskTriggerWDT:self result:result];
        }
    }
    else {//没有回调，直接更新
        result(YES);
    }
}

+ (SSNSafeSet *)launchs {
    static SSNSafeSet *launchs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        launchs = [[SSNSafeSet alloc] initWithCapacity:1];
    });
    return launchs;
}

/**
 *  启动
 *
 *  @return 返回是否已经启动过
 */
- (BOOL)launch {
    
    //说明已经启动过
    SSNSafeSet *set = [[self class] launchs];
    if ([set containsObject:_identify]) {
        return NO;
    }
    [set addObject:_identify];//标记已经启动
    
    dispatch_block_t block = ^{
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *seed = [userDefaults objectForKey:[self userDefaultKey]];
        NSString *currentSeed = [self currentSeed];
        
        if (![seed isEqualToString:currentSeed]) {//不同，立即触发回调
            [self callback];
        }
        
        [NSTimer scheduledTimerWithTimeInterval:[self timeInterval]
                                         target:self//将self holder住
                                       selector:@selector(callback)
                                       userInfo:nil
                                        repeats:YES];
        
    };
    
    //只在主线程中执行，因为timer需要在主线程中holder
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        [self ssn_mainThreadAsyncBlock:block];
    }
    
    return YES;
}

@end

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

@interface SSNWDT ()

@property (nonatomic,strong) NSString *key;

@property (nonatomic,copy) NSString *identify;//标记

@property (nonatomic) SSNWDTIntervalUnit unit;//计时单位

@property (nonatomic) NSUInteger interval;//触发间隔时间

@end

@implementation SSNWDT

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
        default:
            break;
    }
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
//        case SSNWDTWeekUnit:
//            format = SSNWDT_HOUR_FORMAT;
//            break;
        default:
            break;
    }
    
    return [NSString ssn_stringWithDate:date formatter:format];
}

- (NSString *)userDefaultKey {
    if (_key) {
        return _key;
    }
    _key = [NSString stringWithFormat:@"ssn.wdt.%@",self.identify];
    return _key;
}

- (void)callback {
    //将时间点更新
    NSString *currentSeed = [self currentSeed];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *akey = [self userDefaultKey];
    [userDefaults setObject:currentSeed forKey:akey];
    [userDefaults synchronize];

    NSLog(@"%@更新至%@",akey,currentSeed);
    
    if (_scheduledTask) {
        _scheduledTask(self);
        //是否继续holder
    }
    
    if ([_delegate respondsToSelector:@selector(scheduledTaskTriggerWDT:)]) {
        [_delegate scheduledTaskTriggerWDT:self];
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

//
//  FRPC.m
//  ssn
//
//  Created by lingminjun on 16/7/29.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import "FRPC.h"

NSString *const FRPCErrorDomain = @"FRPCErrorDomain";

@interface FRPCResWrapper : NSObject <FRPCRes>
@property (nonatomic,copy) frpc_res_block_t block;
@end

@implementation FRPCResWrapper

+ (instancetype)res:(frpc_res_block_t)block {
    FRPCResWrapper *res = [[FRPCResWrapper alloc] init];
    res.block = block;
    return res;
}

- (void)frpc_res_main:(FRPCReq *)main_req req:(FRPCReq *)req result:(id<FRPCEntity>)entity cache:(BOOL)is_cache index:(NSUInteger)index error:(NSError *)error {
    self.block(main_req,req,entity,is_cache,index,error);
}

@end

@interface FRPCReq()
@property (nonatomic,weak) FRPCReq * main_req;//主请求
@property (nonatomic,weak) FRPCReq * prev_req;//前一个请求
@property (nonatomic,strong) FRPCReq * next_req;//后一个请求

@property (nonatomic,strong) id<FRPCEntity> result;

@property (nonatomic) BOOL cancel;

@property (nonatomic,copy) id<FRPCEntity>(^call_block)(FRPCReq *req, NSUInteger *tryTimes);
@property (nonatomic,copy) id<FRPCEntity>(^cache_block)(FRPCReq *req, NSUInteger maxAge);
@property (nonatomic,copy) FRPCReqStrategy(^strategy_block)(FRPCReq *req);
@property (nonatomic,copy) void(^assembly_block)(FRPCReq *req,FRPCReq *mainReq,FRPCReq *preReq,id<FRPCEntity> result,BOOL is_cache);
@end


@implementation FRPC

+ (void)work_thread_sync:(dispatch_block_t)block {
    static dispatch_queue_t work = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        work = dispatch_queue_create("frpc.work.queue", DISPATCH_QUEUE_CONCURRENT);//并发queue
    });
    dispatch_async(work, block);
}

+ (void)main_thread_sync:(dispatch_block_t)block {
    //不采用main_queue是为了防止使用者在回调中使用嵌套runloop，从而阻塞main_queue. // dispatch_async(dispatch_get_main_queue(), block);
    [(id)self performSelectorOnMainThread:@selector(exec_main_block:) withObject:block waitUntilDone:NO];
}

+ (void)exec_main_block:(dispatch_block_t)block {
    block();
}

+ (id<FRPCCancelable>)call_req:(FRPCReq *)req res:(id<FRPCRes>)res {
    if (req == nil || res == nil) {
        return nil;
    }
    
    //启动工作线程
    [self work_thread_sync:^{
        [self chainCallIMP:req res:res];
    }];
    
    return req;
}

+ (void)reset:(FRPCReq *)areq {
    FRPCReq *req = areq;
    do {
        if (req != nil) {
            [req reset];
            req = req.next_req;
        }
    } while (req);
}

+ (void)chainCallIMP:(FRPCReq *)mainReq res:(id<FRPCRes>) res {
    //检查是否取消请求
    if (mainReq.cancel) {
        [self reset:mainReq];
        return;
    }
    
    //开始请求
    BOOL has_begin = [res respondsToSelector:@selector(frpc_res_start:)];
    if (has_begin) {
        [self main_thread_sync:^{
            //        if (checkInterceptor(mainReq,res)) {
            //            return;
            //        }
            [res frpc_res_start:mainReq];
        }];
    }
    
    
    //读取文件缓存
    NSUInteger idx = 0;
    FRPCReq * req = mainReq;
    while (req != nil) {
        
        req.main_req = mainReq;//防止主请求取不到
        
        //询问是否继续
        BOOL isSkip = false;
        if (idx > 0) {
            FRPCReqStrategy isContinue = FRPCContinue;
            @try {
                isContinue = [req shouldContinue];
            } @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
            
            //不需要继续，直接跳出循环
            if (isContinue == FRPCBreak) {
                break;
            } else if (isContinue == FRPCSkip) {
                isSkip = true;
            }
        }
        
        if (!isSkip) {
            //请求已经取消，cancel连续性考虑
            if (req.cancel) {
                [self reset:mainReq];
                return;
            }
            
            //请求已经取消，检查是否取消请求
            if (mainReq.cancel) {
                [self reset:mainReq];
                return;
            }
            
            FRPCReqStrategy st = [self callIMP:req res:res index:idx++];
            if (st == FRPCBreak) {//表明已经中断
                [self reset:mainReq];
                return;
            }
            
            //请求失败时，若标明不忽略错误，则停止继续请求
            if (st == FRPCSkip && !req.ignoreError) {
                break;
            }
        } else {
            idx++;
        }
        
        //设置其前一个请求体,在请求中形成
        if (req.next_req != nil) {
            req.next_req.prev_req = req;
        }
        
        //继续下一个响应，向基类转换，若转换失败，则此处不符合链式请求条件
        req = req.next_req;
    }
    
    //最终回调
    if (has_begin && [res respondsToSelector:@selector(frpc_res_finish:)]) {
        [self main_thread_sync:^{
//            if (checkInterceptor(mainReq,res)) {
//                return;
//            }
            [res frpc_res_finish:mainReq];
        }];
    }
    
    //还原请求体，防止多次请求数据被重用
    [self reset:mainReq];
}

//成功继续，失败skip，中断break
+ (FRPCReqStrategy)callIMP:(FRPCReq *)req res:(id<FRPCRes>)res index:(NSUInteger)idx {
    
    //读取文件缓存
    BOOL needReq = true;
    NSUInteger maxAge = req.maxAge;
    if (maxAge > 0) {
        @try {
            id<FRPCEntity> o = [req cache:maxAge];
            if (o) {
                [self main_thread_sync:^{
//                    if (checkInterceptor(req, res)) {
//                        return;
//                    }
                    
                    //组合数据
                    @try {
                        [req onAssembly:req.main_req prev:req.prev_req result:o cache:YES];
                    } @catch (NSException *exception) {
                        NSLog(@"%@",exception);
                    }
                    
                    [res frpc_res_main:req.main_req req:req result:o cache:YES index:idx error:nil];
                }];
                
                //直接使用缓存数据
                if (req.usedCache) {
                    req.result = o;
                    needReq = false;
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
    }
    
    if (!needReq) {
        return FRPCContinue;
    }
    
    FRPCReqStrategy result = FRPCContinue;
    @try {
        NSUInteger out_times = 0;
        id<FRPCEntity> o = [req call:&out_times];
        NSUInteger times = out_times;
        
        //开始重试
        while (times > 0 && o == nil) {
            NSLog(@"rpc retry %@",req);
            times--;
            o = [req call:&out_times];
        }
        
        //直接中断
        //            if (checkInterceptor(req, res)) {
        //                result = FRPCBreak;
        //            }
        
        //若没有请求到继续使用cache的值
        if (o != nil) {
            req.result = o;
            
            //成功回调
            [self main_thread_sync:^{
//                if (checkInterceptor(req,res)) {
//                    return;
//                }
                
                //组合数据
                @try {
                    [req onAssembly:req.main_req prev:req.prev_req result:o cache:NO];
                } @catch (NSException *exception) {
                    NSLog(@"%@",exception);
                }
                
                [res frpc_res_main:req.main_req req:req result:o cache:NO index:idx error:nil];
            }];
        }
        
    } @catch (NSException *exception) {
//        NSLog(@"%@",exception);
        //直接中断
//        if (checkInterceptor(req,res)) {
//            result = FRPCBreak;
//        } else {
            //异常回调
        [self main_thread_sync:^{
//            if (checkInterceptor(req, res)) {
//                return;
//            }
#ifndef FRPC_NO_NULL
#define FRPC_NO_NULL(str) ((str) == nil ? @"" : (str))
#endif
            NSDictionary *info = @{NSLocalizedDescriptionKey:FRPC_NO_NULL(exception.reason),
                                   NSLocalizedFailureReasonErrorKey:FRPC_NO_NULL(exception.reason),
                                   NSLocalizedRecoverySuggestionErrorKey:FRPC_NO_NULL(exception.name)};
            NSError *error = [NSError errorWithDomain:FRPCErrorDomain code:-1 userInfo:info];
            [res frpc_res_main:req.main_req req:req result:nil cache:NO index:idx error:error];
        }];
        result = FRPCSkip;
//        }
    }
    return result;
}

+ (id<FRPCCancelable>)call_req:(FRPCReq *)req res_block:(frpc_res_block_t)block {
    if (req == nil || block == nil) {
        return nil;
    }
    return [self call_req:req res:[FRPCResWrapper res:block]];
}

@end


@implementation FRPCReq

@dynamic nextRequest;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.main_req = self;
    }
    return self;
}

/**
 * 请求调用，务必实现
 */
- (id<FRPCEntity>)call:(NSUInteger *)tryTimes {
    if (_call_block) {
        return _call_block(self,tryTimes);
    }
    return nil;
}

/**
 * 文件缓存，可实现
 */
- (id<FRPCEntity>)cache:(NSUInteger)maxAge {
    if (_cache_block) {
        return _cache_block(self,maxAge);
    }
    return nil;
}

/**
 * 询问是否继续发起请求，主要用于链式请求，当前一个请求完成后，后一个请求将会询问是否继续
 * @return
 */
- (FRPCReqStrategy)shouldContinue {
    if (_strategy_block) {
        return _strategy_block(self);
    }
    return FRPCContinue;
}

/**
 * 链式请求使用的方法，当获得本请求数据时，你可以在此方法中组装数据【main thread】(线程安全区域)
 * @param mainReq
 * @param prevReq
 * @param result
 * @param isCache 为true时表示缓存数据，当cache()数据有返回时将触发此回调
 */
- (void)onAssembly:(FRPCReq *)mainReq prev:(FRPCReq *)prevReq result:(id<FRPCEntity>)result cache:(BOOL)is_cache {
    if (_assembly_block) {
        _assembly_block(self,mainReq,prevReq,result,is_cache);
    }
}

/**
 * 链式请求支持
 */
- (void)setNextRequest:(FRPCReq *) req {
    self.next_req = req;
    req.prev_req = self;
    req.main_req = self.main_req;//重置main_req
}

/**
 * 获取请求响应值，只有请求完成后才有值
 * @return
 */
- (id<FRPCEntity>)getResult {
    return _result;
}

/**
 * 获取前一个请求体，可以获取请求的值，前一个必须成功才能走到当前响应
 * @return
 */
- (FRPCReq *)getPrevRequest {
    return _prev_req;
}

/**
 * 主请求，既链式请求第一个请求
 * @return
 */
- (FRPCReq *)getMainRequest {
    return _main_req;
}

/**
 *  下一个请求
 *  @return 获取下一个请求
 */
- (FRPCReq *)getNextRequest {
    return _next_req;
}

/**
 * 重置请求状态，复用请求体，若一个请求cancel后需要重新被发起，需要调用此方法重置
 */
- (void)reset {
    _cancel = NO;
    _result = nil;
}

/**
 *  构建通用型的
 *
 *  @param call     主体函数实现
 *  @param cache    缓存主体实现
 *  @param strategy 是否继续
 *  @param assembly 组装数据
 *
 *  @return 返回req实例
 */
+ (instancetype)reqWithCall:(id<FRPCEntity>(^)(FRPCReq *req, NSUInteger *tryTimes))call
                      cache:(id<FRPCEntity>(^)(FRPCReq *req, NSUInteger maxAge))cache
                    control:(FRPCReqStrategy(^)(FRPCReq *req))strategy
                   assembly:(void(^)(FRPCReq *req,FRPCReq *mainReq,FRPCReq *preReq,id<FRPCEntity> result,BOOL is_cache))assembly {
    FRPCReq *req = [[[self class] alloc] init];
    req.call_block = call;
    req.cache_block = cache;
    req.strategy_block = strategy;
    req.assembly_block = assembly;
    return req;
}


//@protocol FRPCCancelable impl
- (void)frpc_cancel {
    _cancel = YES;
}

@end

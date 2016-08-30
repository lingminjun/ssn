//
//  FRPC.h
//  ssn
//
//  Created by lingminjun on 16/7/29.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FRPCCancelable,FRPCRes,FRPCEntity;
@class FRPC,FRPCReq,FRPCResultWrapper;

FOUNDATION_EXTERN NSString *const FRPCErrorDomain; //rpc错误异常domain

/**
 *  block回调请求定义
 *
 *  @param main_req 主请求，组合请求则取第一个
 *  @param req      当前请求(支持一组请求)
 *  @param result   返回结果集，根据请求体位置取值
 *  @param index    链式请求中第几个请求，主请求为0
 *  @param error    错误描述，只有reqs的第一个请求错误会被暴露出来，其他错误可以到result中按照位置取error
 *
 *  @return 返回当前请求cancel类
 */
typedef id<FRPCCancelable>(^frpc_res_block_t)(FRPCReq *main_req, NSArray<FRPCReq *> *reqs, FRPCResultWrapper *result, NSUInteger index, NSError *error);

/**
 *  请求策略控制
 */
typedef NS_ENUM(NSUInteger, FRPCReqStrategy) {
    /**
     *  正常继续
     */
    FRPCContinue,
    /**
     *  跳过
     */
    FRPCSkip,
    /**
     *  中断
     */
    FRPCBreak
};

///**
// *  请求状态
// */
//typedef NS_ENUM(NSUInteger, FRPCReqStatus) {
//    /**
//     *  准备开始
//     */
//    FRPCReqWill,
//    /**
//     *  请求中
//     */
//    FRPCReqDoing,
//    /**
//     *  请求完
//     */
//    FRPCReqDid,
//    /**
//     *  失败
//     */
//    FRPCReqFailed
//};
//
///**
// *  请求过滤器
// */
//@protocol FRPCFilter <NSObject>
//
//@required
///**
// *  请求过滤器实现方法
// *
// *  @param rpc    请求器
// *  @param req    请求体
// *  @param status 请求状态
// *
// *  @return 返回新的请求体，返回nil时表示禁用此请求
// */
//- (FRPCReq *)frpc_filter:(FRPCReq *)req status:(FRPCReqStatus)status;
//
//@end



/**
 *  rpc调用定义
 */
@interface FRPC : NSObject

//调用方法
+ (id<FRPCCancelable>)call_req:(FRPCReq *)req res:(id<FRPCRes>)res;
+ (id<FRPCCancelable>)call_req:(FRPCReq *)req res_block:(frpc_res_block_t)block;

//增加过滤器
//+ (void)add_filter:(id<FRPCFilter>)filter;

//组合请求调用，若组合请求需要支持链式，仅仅只有req[0].getNextRequest会被处理
+ (id<FRPCCancelable>)call_reqs:(NSArray<FRPCReq *> *)reqs res:(id<FRPCRes>)res;
+ (id<FRPCCancelable>)call_reqs:(NSArray<FRPCReq *> *)reqs res_block:(frpc_res_block_t)block;

@end


/**
 *  可取消的请求体
 */
@protocol FRPCCancelable <NSObject>

@required
- (void)frpc_cancel;//取消此次请求调用

@end

/**
 *  PRC请求对象定义
 */
@protocol FRPCEntity <NSObject>

@required
/**
 *  数据填充方式
 *
 *  @param obj  元数据
 *  @param type 序列方式，自行定义
 */
- (void)frpc_fill:(NSObject *)obj type:(NSString *)type;

@end

/**
 *  组合请求返回值包装体
 *  支持objectAtIndexedSubscript取值:
 *  SampleEntity *entity = result[0];
 */
@interface FRPCResultWrapper : NSObject<FRPCEntity>

/**
 *  按照请求放入的位置取参数
 *
 *  @param index
 *
 *  @return 若数据不存在，可能返回NSError
 */
- (id<FRPCEntity>)getResultAtIndex:(NSUInteger)index;

/**
 *  是否为缓存数据
 *
 *  @param index 请求位置
 *
 *  @return 返回是否为缓存
 */
- (BOOL)isCacheAtIndex:(NSUInteger)index;

/**
 *  获取错误信息
 *
 *  @param index
 *
 *  @return 返回对应请求的错误
 */
- (NSError *)getErrorAtIndex:(NSUInteger)index;

@end

/**
 *  error弱协议支持
 */
@interface NSError (FRPCEntity) <FRPCEntity>
@end


/**
 *  请求体定义
 */
@interface FRPCReq : NSObject <FRPCCancelable,NSObject>

@property (nonatomic) BOOL ignoreError;//忽略失败，主要用于链式响应参数，默认不忽略前一个失败
@property (nonatomic) NSUInteger maxAge;//(毫秒)缓存有效时长，小于或者等于零表示无缓存，默认值30分钟
@property (nonatomic) BOOL usedCache;//使用缓存数据，缓存数据一旦取到，则停止请求，maxAge必须大于零

@property (nonatomic,strong) NSObject *tag;//用于请求体标记，你可以使用tag携带一些信息


/**
 * 请求调用，务必实现
 * @param tryTimes 输出参数，尝试次数，只在第一次设置有效，
 * @return
 */
- (id<FRPCEntity>)call:(NSUInteger *)tryTimes;

/**
 * 文件缓存，可实现
 * @param maxAge 参考值，如果你实现想修改其缓存时长，完全可以无视他
 * @return
 */
- (id<FRPCEntity>)cache:(NSUInteger)maxAge;

/**
 * 询问是否继续发起请求，主要用于链式请求，当前一个请求完成后，后一个请求将会询问是否继续
 * @return
 */
- (FRPCReqStrategy)shouldContinue;

/**
 * 链式请求使用的方法，当获得本请求数据时，你可以在此方法中组装数据【main thread】(线程安全区域)
 * call:返回数据后将触发，若cache:有数据返回时也将触发此回调，is_cache表示是否为缓存数据
 * @param mainReq
 * @param prevReq
 * @param result
 * @param is_cache 是否为缓存数据
 */
- (void)onAssembly:(FRPCReq *)mainReq prev:(FRPCReq *)prevReq result:(id<FRPCEntity>)result cache:(BOOL)is_cache;

/**
 * 链式请求支持
 */
@property (nonatomic,strong,getter=getNextRequest) FRPCReq *nextRequest;

/**
 * 获取请求响应值，只有请求完成后才有值
 * @return
 */
- (id<FRPCEntity>)getResult;

/**
 * 获取前一个请求体，可以获取请求的值，前一个必须成功才能走到当前响应
 * @return
 */
- (FRPCReq *)getPrevRequest;

/**
 * 主请求，既链式请求第一个请求
 * @return
 */
- (FRPCReq *)getMainRequest;

/**
 *  下一个请求
 *  @return 获取下一个请求
 */
- (FRPCReq *)getNextRequest;

/**
 * 重置请求状态，复用请求体，若一个请求cancel后需要重新被发起，需要调用此方法重置
 */
- (void)reset;

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
                   assembly:(void(^)(FRPCReq *req,FRPCReq *mainReq,FRPCReq *preReq,id<FRPCEntity> result,BOOL is_cache))assembly;

@end

/**
 *  响应体定义
 */
@protocol FRPCRes <NSObject>

@optional
- (void)frpc_res_start:(FRPCReq *)main_req;//链式请求开始
- (void)frpc_res_finish:(FRPCReq *)main_req;//链式请求结束

@required
/**
 *  回调请求定义
 *
 *  @param main_req 主请求，组合请求则取第一个
 *  @param req      当前请求(支持一组请求)
 *  @param result   返回体实例
 *  @param index    链式请求中第几个请求，主请求为0
 *  @param error    错误描述
 */
- (void)frpc_res_main:(FRPCReq *)main_req req:(NSArray<FRPCReq *> *)reqs result:(FRPCResultWrapper *)result index:(NSUInteger)index error:(NSError *)error;


@end

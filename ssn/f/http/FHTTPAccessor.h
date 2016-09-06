//
//  FHTTPAccessor.h
//  ssn
//
//  Created by lingminjun on 16/9/2.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@class FSecurityPolicy;
@protocol FHTTPRequest;


/**
 *  HTTP/HTTPS读取器
 */
@interface FHTTPAccessor : NSObject

/**
 *  初始化方法
 */
- (instancetype __nonnull)init;
- (instancetype __nonnull)initWithSessionConfiguration:(NSURLSessionConfiguration * __nullable)configuration;

@property (nonatomic, strong, nullable) FSecurityPolicy *securityPolicy;

/**
 *  NSURLSessionConfiguration可配置支持
 */
@property (nullable, copy) NSDictionary *HTTPAdditionalHeaders;
@property (nullable, retain) NSHTTPCookieStorage *HTTPCookieStorage;
@property (nullable, retain) NSURLCredentialStorage *URLCredentialStorage;
@property (nullable, retain) NSURLCache *URLCache;

/**
 *  获取网络请求
 *
 *  @param request 请求体
 *  @param data    返回的数据
 *  @param error   请求是否出错
 *
 *  @return 返回的数据body
 */
- (NSData * __nullable)syncRequest:(id<FHTTPRequest> __nonnull)request response:(NSHTTPURLResponse * __nullable * __nullable)response error:(NSError *__nullable* __nullable)error;

/**
 *  单通道获取网络请求，限制端口串行，一般使用在认证权限接口，防止客户端并发造成服务端返回多个access_token，瞬间互踢
 *
 *  @param request 请求体
 *  @param data    返回的数据
 *  @param error   请求是否出错
 *  @param expt    输出回调，既然此请求需要设置栅栏，就请在栅栏的出口处将数据储存好，一般此时修改HTTPAdditionalHeaders中的验权字段，切记此处不可嵌套使用FHTTPAccessor的方法，返回值直接被设置成HTTPAdditionalHeaders
 *
 *  @return 返回的数据body
 */
- (NSData * __nullable)barrierRequest:(id<FHTTPRequest> __nonnull)request response:(NSHTTPURLResponse * __nullable * __nullable)response error:(NSError *__nullable* __nullable)error exportHeaders:(NSDictionary *__nullable (^ __nonnull)(NSData * __nullable data, NSHTTPURLResponse * __nullable res,NSError *__nullable err))expt;

/**
 *  默认的Accessor
 *
 *  @return 返回默认的Accessor
 */
+ (instancetype __nonnull)defaultInstance;
@end

/**
 *  获取http请求体
 */
@protocol FHTTPRequest <NSObject>

@required
/**
 *  获得可用的http请求方式
 *
 *  @return NSURLRequest请求体,返回nil表示取消本次请求
 */
- (NSURLRequest * __nullable)fhttp_mixHTTPRequest;

@end

/**
 *  FHTTPRequest支持
 */
@interface NSURLRequest (FHTTPRequest) <FHTTPRequest>
@end

/**
 *  证书认证
 */
@interface FSecurityPolicy : NSObject

@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;//额外或者自定义证书设置

@property (nonatomic, assign) BOOL isAllAllowed;//忽略证书，全部允许，默认值为NO，建议不要设置

@property (nonatomic, assign) BOOL ignoreDomain;//忽略域名去校验（有时为了抓包需要，就忽略）

/**
 *  寻找资源包中所有的证书文件
 */
+ (NSSet <NSData *> * _Nonnull)certificatesInBundle:(nonnull NSBundle *)bundle;
+ (NSSet <NSData *> * _Nonnull)defaultPinnedCertificates;//直接到当前bundle中寻找

/**
 *  工程方法
 *
 *  @return 返回默认实例
 */
+ (instancetype _Nonnull)policy;

/**
 *  查看是否授信
 *
 *  @param serverTrust 服务单证书下发
 *  @param domain      所在域名
 *
 *  @return 是否可授信
 */
- (BOOL)evaluateServerTrust:(nonnull SecTrustRef)serverTrust forDomain:(nullable NSString *)domain;
@end

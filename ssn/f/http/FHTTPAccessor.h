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
 *  获取网络请求
 *
 *  @param request 请求体
 *  @param data    返回的数据
 *  @param error   请求是否出错
 *
 *  @return 响应体
 */
- (NSData * __nullable)syncRequest:(NSURLRequest * __nonnull)request response:(NSHTTPURLResponse * __nullable * __nullable)response error:(NSError *__nullable* __nullable)error;


/**
 *  默认的Accessor
 *
 *  @return 返回默认的Accessor
 */
+ (instancetype __nonnull)defaultInstance;
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

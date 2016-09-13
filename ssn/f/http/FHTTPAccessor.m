//
//  FHTTPAccessor.m
//  ssn
//
//  Created by lingminjun on 16/9/2.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import "FHTTPAccessor.h"

#import <AssertMacros.h>

#import <netinet/in.h>
#import <arpa/inet.h>
#import <pthread.h>

#import <Foundation/NSObjCRuntime.h>


@interface FHTTPAccessor () <NSURLSessionDelegate>
@property (nonatomic,strong) NSURLSession *session;
@end

@implementation FHTTPAccessor {
    pthread_mutex_t _mutex;
    pthread_cond_t _cond;
    /*volatile*//*效率稍微低一点，考虑是否要用*/ int flag;//
}

@dynamic HTTPAdditionalHeaders;
@dynamic HTTPCookieStorage;
@dynamic URLCredentialStorage;
@dynamic URLCache;

- (NSDictionary *)HTTPAdditionalHeaders {
    return _session.configuration.HTTPAdditionalHeaders;
}

- (void)setHTTPAdditionalHeaders:(NSDictionary *)HTTPAdditionalHeaders {
    _session.configuration.HTTPAdditionalHeaders = HTTPAdditionalHeaders;
}

- (NSHTTPCookieStorage *)HTTPCookieStorage {
    return _session.configuration.HTTPCookieStorage;
}
- (void)setHTTPCookieStorage:(NSHTTPCookieStorage *)HTTPCookieStorage {
    _session.configuration.HTTPCookieStorage = HTTPCookieStorage;
}

- (NSURLCredentialStorage *)URLCredentialStorage {
    return _session.configuration.URLCredentialStorage;
}
- (void)setURLCredentialStorage:(NSURLCredentialStorage *)URLCredentialStorage {
    _session.configuration.URLCredentialStorage = URLCredentialStorage;
}

- (NSURLCache *)URLCache {
    return _session.configuration.URLCache;
}
- (void)setURLCache:(NSURLCache *)URLCache {
    _session.configuration.URLCache = URLCache;
}

- (instancetype)init {
    return [self initWithSessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
//    configuration.HTTPShouldUsePipelining = YES;
    
    //构建锁
    pthread_mutex_init(&_mutex, NULL);
    pthread_cond_init(&_cond,NULL);
    
    //结果处理队列
//    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
//    operationQueue.maxConcurrentOperationCount = 4;
    
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    self.securityPolicy = [FSecurityPolicy policy];
    
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_mutex);
    pthread_cond_destroy(&_cond);
}

- (void)check_single_channel_and_wait {
    if (flag > 0) {//一般条件下不需要进入wait
        pthread_mutex_lock(&_mutex);
        while (flag > 0) {
            pthread_cond_wait(&_cond,&_mutex);
        }
        pthread_mutex_unlock(&_mutex);
    }
}

//- (void)broadcast_condition {
//    pthread_cond_broadcast(&_cond);
//}

//- (void)signal {
//    pthread_cond_signal(&_cond);
//}

+ (instancetype)defaultInstance {
    static FHTTPAccessor *accessor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        accessor = [[[self class] alloc] init];
    });
    return accessor;
}

#pragma mark - 添加task
- (NSData * __nullable)syncRequest:(id<FHTTPRequest> __nonnull)request response:(NSHTTPURLResponse * __nullable * __nullable)out_response error:(NSError *__nullable* __nullable)out_error
{
    if (request == nil) {
        return nil;
    }
    
    NSData *data = nil;
    
    [self check_single_channel_and_wait];
    
    @try {
        data = [self dataWithRequest:request response:out_response error:out_error];
    } @catch (NSException *exception) {
        if (out_error) {
            *out_error = [[NSError alloc] initWithDomain:@"FHTTPAccessor" code:-1 userInfo:@{NSLocalizedDescriptionKey:exception.name,NSLocalizedFailureReasonErrorKey:(exception.reason ? @"" : exception.reason)}];
        }
    } @finally {
    }
    
    return data;
}

- (NSData * __nullable)barrierRequest:(id<FHTTPRequest> __nonnull)request response:(NSHTTPURLResponse * __nullable * __nullable)response error:(NSError *__nullable* __nullable)error exportHeaders:(NSDictionary *__nullable (^ __nonnull)(NSData * __nullable data, NSHTTPURLResponse * __nullable res,NSError *__nullable err))expt
{
    if (request == nil) {
        return nil;
    }
    
    NSData *data = nil;
    
    pthread_mutex_lock(&_mutex);
    flag = 1;
    
    @try {
        NSHTTPURLResponse *res = nil;
        NSError *err = nil;
        data = [self dataWithRequest:request response:&res error:&err];
        
        if (response) {
            *response = res;
        }
        
        if (error) {
            *error = err;
        }
        
        if (expt) {
            NSDictionary *headers = expt(data,res,err);
            
            if (headers) {//若设置了值，则设置headers
                self.HTTPAdditionalHeaders = headers;
            }
        }
    } @catch (NSException *exception) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:@"FHTTPAccessor" code:-1 userInfo:@{NSLocalizedDescriptionKey:exception.name,NSLocalizedFailureReasonErrorKey:(exception.reason ? @"" : exception.reason)}];
        }
    } @finally {
        flag = 0;
        pthread_cond_broadcast(&_cond);
        pthread_mutex_unlock(&_mutex);
    }
}

//防止没有定义宏
#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug 1140.11
#else
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug NSFoundationVersionNumber_iOS_8_0
#endif

- (NSData *)dataWithRequest:(id<FHTTPRequest> __nonnull)request response:(NSHTTPURLResponse * __nullable * __nullable)out_response error:(NSError *__nullable* __nullable)out_error {
    
    NSURLRequest *httpReq = [request fhttp_mixHTTPRequest];
    if (httpReq == nil) {
        return nil;
    }
    
    
    
    // 如果是iOS7.x时，使用串行队列同步执行NSURLSession创建Task的操作
    //索性iOS7一下就采用NSURLConnenction
    /*
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_With_Fixed_5871104061079552_bug) {
        //若考虑需要配置一些header,cookie等等，此举修改并不是非常合理
        return [NSURLConnection sendSynchronousRequest:httpReq returningResponse:out_response error:out_error];
    } else {
        */
        NSURLSession * session = self.session;
        
        //采用型号锁存在假死状态，暂时还没发现原因
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
        __block NSData *out_data = nil;
        // 基本网络请求
        void (^handler)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) = ^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (out_response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
                *out_response = (NSHTTPURLResponse *)response;
            } else {
                NSLog(@"FHTTPAccessor: 不关心response！！！");
            }
            
            out_data = data;//填充数据
            
            if (out_error != NULL && error) {
                *out_error = error;
            }
            dispatch_semaphore_signal(semaphore);
        };
        
        __block NSURLSessionDataTask *dataTask = nil;
        url_session_manager_create_task_safely(^{
            dataTask = [session dataTaskWithRequest:[request fhttp_mixHTTPRequest] completionHandler:handler];
        });
        
        [dataTask resume];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    /*}*/
    
    return out_data;
}

static void url_session_manager_create_task_safely(dispatch_block_t block) {
    static dispatch_queue_t _queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create("fhttp.session.manager.creation", DISPATCH_QUEUE_SERIAL);
    });
    // 如果是iOS7.x时，使用串行队列同步执行NSURLSession创建Task的操作
    // 如果是iOS8.x时，随便....
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_With_Fixed_5871104061079552_bug) {
        // Fix of bug
        // Open Radar:http://openradar.appspot.com/radar?id=5871104061079552 (status: Fixed in iOS8)
        // Issue about:https://github.com/AFNetworking/AFNetworking/issues/2093
        dispatch_sync(_queue, block);
    } else {
        block();
    }
}

- (void)serial:(dispatch_block_t __nonnull)block {
    if (block == nil) {
        return ;
    }
    
    BOOL lock = NO;
    if (flag != 1) {//等于1表示嵌套
        lock = YES;
        pthread_mutex_lock(&_mutex);
        flag = 1;
    }
    
    @try {
        block();
    } @catch (NSException *exception) {
        NSLog(@"FHTTPAccessor %@",exception);
    } @finally {
        if (lock) {
            flag = 0;
            pthread_cond_broadcast(&_cond);
            pthread_mutex_unlock(&_mutex);
        }
    }
}

- (void)session:(NSURLSession *)session authChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    
    //需要检验证书
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    //将处理结果回调回去
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge 
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    [self session:session authChallenge:challenge completionHandler:completionHandler];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    //同样的处理
    [self session:session authChallenge:challenge completionHandler:completionHandler];
}

@end





/**
 *  FHTTPRequest支持
 */
@implementation NSURLRequest (FHTTPRequest)
- (NSURLRequest * __nullable)fhttp_mixHTTPRequest {
    return self;
}
@end






#if !TARGET_OS_IOS && !TARGET_OS_WATCH && !TARGET_OS_TV
static NSData * FSecKeyGetData(SecKeyRef key) {
    CFDataRef data = NULL;
    
    __Require_noErr_Quiet(SecItemExport(key, kSecFormatUnknown, kSecItemPemArmour, NULL, &data), _out);
    
    return (__bridge_transfer NSData *)data;
    
_out:
    if (data) {
        CFRelease(data);
    }
    
    return nil;
}
#endif



static BOOL AFServerTrustIsValid(SecTrustRef serverTrust) {
    BOOL isValid = NO;
    SecTrustResultType result;
    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);
    
    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    
_out:
    return isValid;
}

static NSArray * AFCertificateTrustChainForServerTrust(SecTrustRef serverTrust) {
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
    
    for (CFIndex i = 0; i < certificateCount; i++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
    }
    
    return [NSArray arrayWithArray:trustChain];
}


@implementation FSecurityPolicy
+ (NSSet <NSData *> * _Nonnull)certificatesInBundle:(NSBundle *)bundle {
    NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];
    
    NSMutableSet *certificates = [NSMutableSet setWithCapacity:[paths count]];
    for (NSString *path in paths) {
        NSData *certificateData = [NSData dataWithContentsOfFile:path];
        [certificates addObject:certificateData];
    }
    
    return [NSSet setWithSet:certificates];
}

+ (NSSet <NSData *> * _Nonnull)defaultPinnedCertificates {
    static NSSet *_defaultPinnedCertificates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        _defaultPinnedCertificates = [self certificatesInBundle:bundle];
    });
    
    return _defaultPinnedCertificates;
}

+ (instancetype _Nonnull)policy {
    return [[self alloc] init];
}

#pragma mark -

BOOL isValidIpAddress(const char *ipAddress)
{
    struct sockaddr_in sa;
    int result = inet_pton(AF_INET, ipAddress, &(sa.sin_addr));
    return result != 0;
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain
{
    //不管什么情况，都允许，不建议这样做，非常不安全
    if (self.isAllAllowed) {
        NSLog(@"FSecurityPolicy: Trust all certificates");
        return YES;//NSURLSessionAuthChallengeUseCredential||NSURLSessionAuthChallengePerformDefaultHandling
    }
    
    if ([self.pinnedCertificates count] == 0) {
        NSLog(@"FSecurityPolicy: Using system calibration");
        return NO;
    }
    
    //不根据域名验证，debug场景需要
    if (self.ignoreDomain) {
        NSMutableArray *policies = [NSMutableArray array];
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];//x509基本安全策略
        SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
        NSLog(@"FSecurityPolicy: Don't verify the domain name");
    } else if ([domain length] > 0 && isValidIpAddress([domain UTF8String])) {//如果是ip地址的域名，增加重置域名方式
        NSMutableArray *policies = [NSMutableArray array];
        //https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/NetworkingTopics/Articles/OverridingSSLChainValidationCorrectly.html
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
        SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
        NSLog(@"FSecurityPolicy: Considering the special case of IP request");
    } else {
        //Nothing
    }
    
    
    NSMutableArray *pinnedCertificates = [NSMutableArray array];
    for (NSData *certificateData in self.pinnedCertificates) {
        [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
    }
    SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);
    
    //证书验证不通过
    if (!AFServerTrustIsValid(serverTrust)) {
        NSLog(@"FSecurityPolicy: Certificate authentication is not through");
        return NO;
    }
    
    // obtain the chain after being validated, which *should* contain the pinned certificate in the last position (if it's the Root CA)
    NSArray *serverCertificates = AFCertificateTrustChainForServerTrust(serverTrust);
    
    for (NSData *trustChainCertificate in [serverCertificates reverseObjectEnumerator]) {
        if ([self.pinnedCertificates containsObject:trustChainCertificate]) {
            return YES;
        }
    }
    
    return NO;
}

@end

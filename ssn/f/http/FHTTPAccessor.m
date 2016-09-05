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


@interface FHTTPAccessor () <NSURLSessionDelegate>
@property (nonatomic,strong) NSURLSession *session;
@end

@implementation FHTTPAccessor

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
    
    //结果处理队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 4;
    
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:operationQueue];
    
    self.securityPolicy = [FSecurityPolicy policy];
    
    return self;
}

+ (instancetype)defaultInstance {
    static FHTTPAccessor *accessor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        accessor = [[FHTTPAccessor alloc] init];
    });
    return accessor;
}

#pragma mark - 添加task
- (NSData * __nullable)syncRequest:(NSURLRequest * __nonnull)request response:(NSHTTPURLResponse * __nullable * __nullable)out_response error:(NSError *__nullable* __nullable)out_error
{
    
    NSURLSession * session = self.session;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSData *out_data = nil;
    
    // 基本网络请求
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (out_response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            *out_response = (NSHTTPURLResponse *)response;
        } else {
            NSLog(@"FHTTPAccessor: 位置类型的请求！！！");
        }
        
        out_data = data;//填充数据
        
        if (out_error != NULL && error) {
            *out_error = error;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    
    [dataTask resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return out_data;
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

//
//  FSecurityPolicy.h
//  ssn
//
//  Created by lingminjun on 16/9/2.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Security/Security.h>

/**
 *  策略
 */
typedef NS_ENUM(NSUInteger, FSSLPinningMode) {
    /**
     *  不校验服务端证书
     */
    FSSLPinningModeNone,
    /**
     *  采用公钥比较
     */
    FSSLPinningModePublicKey,
    /**
     *  校验证书
     */
    FSSLPinningModeCertificate,
};

/**
 *  权限校验
 */
@interface FSecurityPolicy : NSObject

@property (readonly, nonatomic, assign) FSSLPinningMode SSLPinningMode;

/**
 The certificates used to evaluate server trust according to the SSL pinning mode.
 
 By default, this property is set to any (`.cer`) certificates included in the target compiling AFNetworking. Note that if you are using AFNetworking as embedded framework, no certificates will be pinned by default. Use `certificatesInBundle` to load certificates from your target, and then create a new policy by calling `policyWithPinningMode:withPinnedCertificates`.
 
 Note that if pinning is enabled, `evaluateServerTrust:forDomain:` will return true if any pinned certificate matches.
 */
@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;//证书设置，多个

@property (nonatomic, assign) BOOL allowInvalidCertificates;//非法证书是否通过

/**
 Whether or not to validate the domain name in the certificate's CN field. Defaults to `YES`.
 */
@property (nonatomic, assign) BOOL validatesDomainName;//是否以域名去校验

///-----------------------------------------
/// @name Getting Certificates from the Bundle
///-----------------------------------------

/**
 Returns any certificates included in the bundle. If you are using AFNetworking as an embedded framework, you must use this method to find the certificates you have included in your app bundle, and use them when creating your security policy by calling `policyWithPinningMode:withPinnedCertificates`.
 
 @return The certificates included in the given bundle.
 */
+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle;

///-----------------------------------------
/// @name Getting Specific Security Policies
///-----------------------------------------

/**
 Returns the shared default security policy, which does not allow invalid certificates, validates domain name, and does not validate against pinned certificates or public keys.
 
 @return The default security policy.
 */
+ (instancetype)defaultPolicy;

///---------------------
/// @name Initialization
///---------------------

/**
 Creates and returns a security policy with the specified pinning mode.
 
 @param pinningMode The SSL pinning mode.
 
 @return A new security policy.
 */
+ (instancetype)policyWithPinningMode:(FSSLPinningMode)pinningMode;

/**
 Creates and returns a security policy with the specified pinning mode.
 
 @param pinningMode The SSL pinning mode.
 @param pinnedCertificates The certificates to pin against.
 
 @return A new security policy.
 */
+ (instancetype)policyWithPinningMode:(FSSLPinningMode)pinningMode withPinnedCertificates:(NSSet <NSData *> *)pinnedCertificates;

///------------------------------
/// @name Evaluating Server Trust
///------------------------------

/**
 Whether or not the specified server trust should be accepted, based on the security policy.
 
 This method should be used when responding to an authentication challenge from a server.
 
 @param serverTrust The X.509 certificate trust of the server.
 @param domain The domain of serverTrust. If `nil`, the domain will not be validated.
 
 @return Whether or not to trust the server.
 */
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(nullable NSString *)domain;
@end

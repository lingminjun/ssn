//
//  NSURL+SSN.h
//  ssn
//
//  Created by lingminjun on 15/3/28.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SSN)

- (NSDictionary *)ssn_queryStringToDictionaryWithURLDecode:(BOOL)decode;//将参数转化为字典形式，同一个key的value放入NSArray中

- (NSDictionary *)ssn_queryStringToDictionary;//将参数转化为字典形式，并且解码

//比较“<scheme>://<net_loc>/<path>;<params>?<query>#<fragment>”所有段
- (BOOL)ssn_isEqualToURL:(NSURL *)url;

//比较“<scheme>://<net_loc>/<path>;<params>?<query>” fragment之前的所有段
- (BOOL)ssn_isEqualToURLNoFragment:(NSURL *)url;

//返回一个新的url，参数扩充，不支持多参数(exclusive == YES)
- (NSURL *)ssn_URLByAppendQuery:(NSDictionary *)query;

//返回一个新的url，参数扩充，每个key是否都唯一（原url某个key对应的values将随机取一个值）
- (NSURL *)ssn_URLByAppendQuery:(NSDictionary *)query isExclusiveKey:(BOOL)exclusive;

//重置url,path传入nil时保持不变，query传入nil时保持不变
- (NSURL *)ssn_resetURLForPath:(NSString *)path appendQuery:(NSDictionary *)query;

//重置url,path传入nil时保持不变，query传入nil时保持不变
- (NSURL *)ssn_resetURLForPath:(NSString *)path appendQuery:(NSDictionary *)query isExclusiveKey:(BOOL)exclusive;

- (NSArray *)ssn_validPathComponents;//去掉中间的“/”

- (BOOL)ssn_isHTTPURL;

- (BOOL)ssn_isAppStoreURL;

@end

@interface NSDictionary (SSNURL)

//转换成queryString,元素仅仅支持字符串内容，key升序，当一个key有多个values时，values升序(编码前)
- (NSString *)ssn_toQueryStringWithURLEncode:(BOOL)encode;

//转换成queryString,元素仅仅支持字符串内容，key升序，当一个key有多个values时，values升序
- (NSString *)ssn_toQueryString;

@end

//
//  SSNRouter.h
//  ssn
//
//  Created by lingminjun on 14-7-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNPage.h"

#import "SSNVC+Router.h" //关注实现

@protocol SSNRouterDelegate;

@interface SSNRouter : NSObject

@property (nonatomic, weak) id<SSNRouterDelegate> delegate;

@property (nonatomic, strong) UIWindow *window; // window的rootViewController将作为第一个目录

@property (nonatomic, strong) NSString *scheme; // app内部scheme

// open url接口，与app不符的scheme将提交给Application打开
- (BOOL)openURL:(NSURL *)url; //如果url query中没有animated，默认有动画
- (BOOL)openURL:(NSURL *)url query:(NSDictionary *)query;//如果url query中没有animated，默认有动画
- (BOOL)openURL:(NSURL *)url query:(NSDictionary *)query animated:(BOOL)animated;

//返回
- (void)back;

/** url中path都已经被注册过且仅仅最后一个路径元素没有被找到实例的，都将返回yes */
- (BOOL)canOpenURL:(NSURL *)url;
- (BOOL)canOpenURL:(NSURL *)url query:(NSDictionary *)query;

//与url对应的page发送消息
- (BOOL)noticeURL:(NSURL *)url query:(NSDictionary *)query;

//返回对应的实例
- (id<SSNPage>)pageWithURL:(NSURL *)url query:(NSDictionary *)query;

@property (nonatomic, copy) NSDictionary *map; //页面与页面类之间映射

//添加页面对应的key(或者叫元组)
- (void)addComponent:(NSString *)component pageClass:(Class<SSNPage>)pageClass;

- (void)removeComponent:(NSString *)component;

@end

@interface NSObject (SSNRouter) //弱协议实现

- (SSNRouter *)ssn_router;

- (id<SSNParentPage>)ssn_parentPage;

- (NSURL *)ssn_currentURLPath; //当前url路径,注册进入的实例才会找到

// open url接口，与app不符的scheme将提交给Application打开
- (BOOL)openURL:(NSURL *)url; //如果url query中没有animated，默认有动画
- (BOOL)openURL:(NSURL *)url query:(NSDictionary *)query;//如果url query中没有animated，默认有动画
- (BOOL)openURL:(NSURL *)url query:(NSDictionary *)query animated:(BOOL)animated;

//与url对应的page发送消息
- (BOOL)noticeURL:(NSURL *)url query:(NSDictionary *)query;

//从当前目录打开url，path格式定义如：“/component1/component2”，你也可以使用NSURLComponents方法生产
- (BOOL)openRelativePath:(NSString *)path;
- (BOOL)openRelativePath:(NSString *)path query:(NSDictionary *)query;
- (BOOL)openRelativePath:(NSString *)path query:(NSDictionary *)query animated:(BOOL)animated;

//从当前目录通知url，path格式定义如：“/component1/component2”，你也可以使用NSURLComponents方法生产
- (BOOL)noticeRelativePath:(NSString *)path query:(NSDictionary *)query;

@end

@interface NSObject (SSNPage)

/**
 *  query参数，当新建一个page时，参数自动被填充
 */
@property (nonatomic,copy) NSDictionary *ssn_query;

@end


// open 流程控制
@protocol SSNRouterDelegate<NSObject>

@optional
//重定向url,返回需要重定向的url，如果返回nil表示不跳转
- (NSURL *)ssn_router:(SSNRouter *)router redirectURL:(NSURL *)url query:(NSDictionary *)query;


@end

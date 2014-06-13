//
//  Navigator.h
//  Routable
//
//  Created by lingminjun on 14-6-4.
//  Copyright (c) 2014年 TurboProp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PageProtocol,ParentPageProtocol;
@class Navigator;


/*
 Navigator使用细则：
 1、Navigator基于UINavigationController设计，故所有打开页面都会在UINavigationController内，UINavigationController被默认指定pathComponent ==> nav，使用者不要再使用 "nav" 来作为 page的component。
 
 2、在UINavigationController下的页面，可以省略"nav"路径，如“app://nav/userProfile”与“app://userProfile”是一个意思。
 
 3、UITabBarController被默认指定路径 pathComponent ==> tab，所以在UITabBarController中打开某个页面路径必须是“app://tab/friendList”。UITabBarController不能省略路径结点
 
 4、除了上面已经提到的nav，tab关键路径外，还有一些特殊参数也被使用，请使用者注意：handler（handler ==> EventHandler），isModal(模态)，animated(动画)，hideTabbar（对应控制器hidesBottomBarWhenPushed），hideNavgationBar（隐藏导航栏），isRoot（更换成跟控制器）。
 
 5、Navigator并不会根据多重路径来创建多个实例，比如像路径“app://root/mytab/list”上有多个元组，只有root/mytab已经能找到的情况才会成功创建list页面（目录结构暂时不支持）。
 
 6、isModal参数为YES时，系统不支持多重模态显示，所以路径深度过深都算作无意义
 */
@interface Navigator : NSObject

+ (instancetype)shareInstance;

@property (nonatomic,strong) NSString *navigationControllerClass;//默认UINavigationController
@property (nonatomic,strong) UINavigationController *rootViewController;//如果没有设置，默认生产一个

@property (nonatomic,strong) NSString *scheme;//app内部scheme，

@property (nonatomic,strong) NSDictionary *componentMap;//页面与页面类之间映射

//open url接口，与app不符的scheme将提交给Application打开
- (BOOL)openURL:(NSURL*)url;//如果url query中没有animated，默认有动画
- (BOOL)openURL:(NSURL*)url query:(NSDictionary *)query animated:(BOOL)animated;
- (BOOL)openURL:(NSURL *)url query:(NSDictionary *)query isModal:(BOOL)isModal animated:(BOOL)animated;

//返回
- (void)back;

/*url中path都已经被注册过且仅仅最后一个路径元素没有被找到实例的，都将返回yes*/
- (BOOL)canOpenURL:(NSURL *)url;
- (BOOL)canOpenURL:(NSURL *)url query:(NSDictionary *)query;
- (BOOL)canOpenURL:(NSURL *)url query:(NSDictionary *)query isModal:(BOOL)isModal;

//返回对应的实例
- (id <PageProtocol>)pageWithURL:(NSURL *)url query:(NSDictionary *)query;

//添加页面对应的key(或者叫元组)
- (void)addComponent:(NSString *)component pageClass:(Class)pageClass;

////兼容老的调用
//- (void)open:(NSString *)url;
//- (void)open:(NSString *)url animated:(BOOL)animated;
//- (void)map:(NSString *)format toController:(Class)controllerClass;
//- (void)pop;

@end


//URL基本支持
@interface NSURL (Navigator)

- (NSArray *)navigatorPaths;

- (NSDictionary *)queryInfo;

@end


@protocol PageProtocol <NSObject> //不一定是真实的页面

@required
- (id <ParentPageProtocol>)parentPage;

@optional
//是否可以响应，默认返回NO，已存在界面如果可以响应，将重新被打开
- (BOOL)canRespondURL:(NSURL *)url query:(NSDictionary *)query;

//当前面返回YES后，此方法将被询问调用，如果一个页面第一次被创建，也会被询问调用此方法
- (void)handleURL:(NSURL *)url query:(NSDictionary *)query;//将要打开此界面

@end


@protocol ParentPageProtocol <PageProtocol>

@optional
//如果要自己定义父控制器，一定要实现此方法
- (NSArray *)containedPages;

//最外层
- (id<PageProtocol>)topPage;

//具体打开子页面方法
- (BOOL)openPage:(id <PageProtocol>)page root:(BOOL)root animated:(BOOL)animated;

//子页面返回
- (void)pageBack;

@end


@interface UIViewController (Navigator) <PageProtocol>
@end

@interface UINavigationController (Navigator) <ParentPageProtocol>
@end

@interface UITabBarController (Navigator) <ParentPageProtocol>
@end

//事件响应类
@interface EventHandler : NSObject <PageProtocol>

- (id)initWithEventBlock:(void (^)(NSURL *url,NSDictionary *query))event;

+ (instancetype)eventBlock:(void (^)(NSURL *url,NSDictionary *query))event;

- (id)initWithEventBlock:(void (^)(NSURL *url,NSDictionary *query))event filter:(BOOL (^)(NSURL *url,NSDictionary *query))filter;

+ (instancetype)eventBlock:(void (^)(NSURL *url,NSDictionary *query))event filter:(BOOL (^)(NSURL *url,NSDictionary *query))filter;

@end


@interface NSObject (Navigator)//弱协议实现

- (Navigator *)navigator;

- (id <ParentPageProtocol>)parentPage;

- (NSURL *)currentURLPath;//当前url路径,注册进入的实例才会找到

@end



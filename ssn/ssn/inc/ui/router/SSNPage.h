//
//  SSNPage.h
//  ssn
//
//  Created by lingminjun on 14-7-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSNPage,SSNParentPage;


@protocol SSNPage <NSObject>

@required
- (id<SSNParentPage>)parentPage;

@optional

//是否可以响应，默认返回NO，已存在界面如果可以响应，将重新被打开
- (BOOL)canRespondURL:(NSURL *)url query:(NSDictionary *)query;

//当前面返回YES后，此方法将被询问调用，如果一个页面第一次被创建，也会被询问调用此方法
- (void)handleURL:(NSURL *)url query:(NSDictionary *)query;//将要打开此界面


@end


@protocol SSNParentPage <SSNPage>

@optional
//如果要自己定义父控制器，一定要实现此方法
- (NSArray *)containedPages;

//最外层
- (id<SSNPage>)topPage;

//具体打开子页面方法
- (BOOL)openPage:(id <SSNPage>)page query:(NSDictionary *)query animated:(BOOL)animated;

//子页面返回
- (void)pageBack;


@end
//
//  SSNPage.h
//  ssn
//
//  Created by lingminjun on 14-7-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSNPage,SSNParentPage;

///page并不仅限于叶面，可以拓展出很多组件
@protocol SSNPage <NSObject>

@required
- (id<SSNParentPage>)ssn_parentPage;//

//新建一个page时将被自动赋值
@property (nonatomic,copy) NSDictionary *ssn_query;

@optional

//是否可以响应，默认返回NO，已存在界面如果可以响应，将重新被打开
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query;

//当ssn_canRespondURL:query:返回YES后，openURL将调用此方法，如果一个页面第一次被创建，也会被询问调用此方法
- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query;//将要打开此界面

//当ssn_canRespondURL:query:返回YES后，noticeURL将调用此方法，
- (void)ssn_handleNoticeURL:(NSURL *)url query:(NSDictionary *)query;


@end


@protocol SSNParentPage <SSNPage>

@optional
//如果要自己定义父控制器，一定要实现此方法
- (NSArray *)ssn_containedPages;

//最外层
- (id<SSNPage>)ssn_topPage;

//具体打开子页面方法
- (BOOL)ssn_openPage:(id <SSNPage>)page query:(NSDictionary *)query animated:(BOOL)animated;

//子页面返回
- (void)ssn_pageBack;


@end
//
//  SSNRouter.m
//  ssn
//
//  Created by lingminjun on 14-7-26.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNRouter.h"
#import "NSURL+Router.h"
#import "SSNVC+Router.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@interface SSNSearchResult : NSObject

@property (nonatomic,strong) id<SSNParentPage> theParentPage;
@property (nonatomic,strong) NSString *lastPath;
@property (nonatomic,strong) id<SSNPage> targetPage;//不一定有值

@end


@interface SSNRouter ()
{
    NSMutableDictionary *_pmap;
}

@property (nonatomic,strong) NSMutableDictionary *pmap;

- (NSURL *)searchURLWithPage:(id<SSNPage>)page;//寻找url

@end


@implementation SSNRouter

+ (instancetype)shareInstance {
    static SSNRouter *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

#pragma - mark 属性相关
- (NSMutableDictionary *)pmap {
    if (nil == _pmap) {
        _pmap = [NSMutableDictionary dictionary];
    }
    return _pmap;
}

- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _window;
}

@dynamic map;
- (NSDictionary *)map {
    return [self.pmap copy];
}
- (void)setMap:(NSDictionary *)map {
    if (map) {
        [self.pmap setDictionary:map];
    }
    else {
        [self.pmap removeAllObjects];
    }
}

- (NSString *)scheme {
    if (nil == _scheme) {
        NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        for (NSDictionary* dic in infoDictionary[@"CFBundleURLTypes"]) {
            _scheme = dic[@"CFBundleURLSchemes"][0];
            break ;
        }
    }
    return _scheme;
}


#pragma - mark 基本API
- (BOOL)openURL:(NSURL*)url {
    if (nil == url) {
        return NO;
    }
    
    return [self openURL:url query:nil];
}

- (BOOL)openURL:(NSURL *)url query:(NSDictionary *)query {
    if (nil == url) {
        return NO;
    }
    
    BOOL animated = YES;
    
    NSString *an = [query objectForKey:@"animated"];
    if (!an) {
        NSDictionary *url_query = [url ssn_queryInfo];
        an = [url_query objectForKey:@"animated"];
    }
    
    if ([an length] > 0
        && ([an compare:@"no" options:NSCaseInsensitiveSearch] == NSOrderedSame
            || [an compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
        animated = [an boolValue];
    }
    
    return [self openURL:url query:query animated:animated];
}

- (BOOL)canOpenURL:(NSURL *)url {
    if (nil == url) {
        return NO;
    }
    
    NSDictionary *query = [url ssn_queryInfo];
    
    return [self canOpenURL:url query:query];
}

- (void)back {
    if ([self.window respondsToSelector:@selector(ssn_pageBack)]) {
        return [(id<SSNParentPage>)self.window ssn_pageBack];
    }
}

- (NSURL *)delegateFilterURL:(NSURL*)aurl query:(NSDictionary *)query {
    
    NSURL *url = aurl;
    
    //让委托有控制权
    if ([self.delegate respondsToSelector:@selector(ssn_router:redirectURL:query:)]) {
        NSURL *rurl = [self.delegate ssn_router:self redirectURL:aurl query:query];
        if (rurl) {
            url = rurl;
        }
    }
    
    return url;
}

//更佳细致的接口
- (BOOL)openURL:(NSURL*)aurl query:(NSDictionary *)query animated:(BOOL)animated {
    
    if (nil == aurl) {
        return NO;
    }
    
    //让委托有控制权
    NSURL *url = [self delegateFilterURL:aurl query:query];
    if (nil == url) {
        return NO;
    }
    
    NSString *urlscheme = [url scheme];
    if (![urlscheme isEqualToString:self.scheme]) {
        return [[UIApplication sharedApplication] openURL:url];
    }
    
    //找到目标url
    SSNSearchResult *result = [self loadPageWithURL:url query:query];
    if (nil == result) {
        return NO;
    }
    
    BOOL openSuccess = NO;
    
    //递归打开界面
    id<SSNParentPage> parent_page = result.theParentPage;
    id<SSNPage>current_page = result.targetPage;
    while (parent_page) {
        if ([parent_page respondsToSelector:@selector(ssn_openPage:query:animated:)]) {
            openSuccess = [parent_page ssn_openPage:current_page query:query animated:animated];
        }
        
        if (!openSuccess) {
            break ;
        }
        
        current_page = parent_page;
        if (parent_page == self.window.rootViewController) {
            parent_page = self.window;
        }
        else {
            parent_page = [parent_page ssn_parentPage];
        }
    }
    
    return openSuccess;
}

- (BOOL)canOpenURL:(NSURL *)aurl query:(NSDictionary *)query {
    if (nil == aurl) {
        return NO;
    }
    
    //让委托有控制权
    NSURL *url = [self delegateFilterURL:aurl query:query];
    if (nil == url) {
        return NO;
    }
    
    NSString *urlscheme = [url scheme];
    if (![urlscheme isEqualToString:self.scheme]) {
        return [[UIApplication sharedApplication] canOpenURL:url];
    }
    
    SSNSearchResult *result = [self searchPageWithURL:url query:query];
    if (nil != result) {
        return YES;
    }
    
    return NO;
}

//与url对应的page发送消息
- (BOOL)noticeURL:(NSURL *)url query:(NSDictionary *)query {
    if (nil == url) {
        return NO;
    }
    
    NSString *urlscheme = [url scheme];
    if (![urlscheme isEqualToString:self.scheme]) {
        return NO;
    }
    
    //找到对应的对象
    SSNSearchResult *result = [self searchPageWithURL:url query:query];
    if (nil == result.targetPage) {
        return NO;
    }
    
    result.targetPage.ssn_query = query;//参数赋值
    
    //notice该对象
    if ([result.targetPage respondsToSelector:@selector(ssn_handleNoticeURL:query:)]) {
        [result.targetPage ssn_handleNoticeURL:url query:query];
        return YES;
    }
    
    return NO;
}


- (SSNSearchResult *)searchPathWithURL:(NSURL *)url
                                 query:(NSDictionary *)query
                                parent:(id<SSNParentPage>)parent
                                 index:(NSInteger)index
                                 paths:(NSArray *)paths {
    
    //防越界
    const NSInteger path_count = [paths count];
    if (index >= path_count) {
        return nil;
    }
    
    //当前path对应的对象类型
    NSString *path = [paths objectAtIndex:index];
    id class_type = [self.pmap objectForKey:path];
    if (nil == class_type) {
        return nil;
    }
    
    //看父控制器是否能打开
    BOOL canOpen = NO;
    if ([parent respondsToSelector:@selector(ssn_canRespondURL:query:)]) {
        canOpen = [parent ssn_canRespondURL:url query:query];
    }
    if (!canOpen) {//父节点无法打开
        return nil;
    }
    
    //父节点打开后先找已经存在的
    NSArray *pages = nil;
    if ([parent respondsToSelector:@selector(ssn_containedPages)]) {
        pages = [parent ssn_containedPages];
    }
    
    //需要分是不是最后一个来处理
    if (index + 1 == path_count) {//已经到了path末端，构建Result，只需要确定末端节点对象是否已经存在与否
        
        SSNSearchResult *rt = [[SSNSearchResult alloc] init];
        rt.theParentPage = parent;
        rt.lastPath = path;
        
        for (id<SSNPage> page in pages) {
            
            if (![page isKindOfClass:class_type]) {
                continue ;
            }
            
            //可能存在，需要校验是否能响应
            BOOL canRespond = NO;
            if ([page respondsToSelector:@selector(ssn_canRespondURL:query:)]) {
                canRespond = [page ssn_canRespondURL:url query:query];
            }
            
            //第一个找到后就退出
            if (canRespond) {
                rt.targetPage = page;
                break ;
            }
        }
        
        return rt;
    }
    
    //非末端节点需要递归寻找
    SSNSearchResult *rt = nil;
    for (id<SSNPage> page in pages) {
        
        if (![page isKindOfClass:class_type]) {
            continue ;
        }
        
        rt = [self searchPathWithURL:url
                               query:query
                              parent:(id<SSNParentPage>)page
                               index:index + 1
                               paths:paths];
        //一旦找到就跳出
        if (rt) {
            break;
        }
    }

    return rt;
}

- (SSNSearchResult *)searchPageWithURL:(NSURL *)url query:(NSDictionary *)query {
    
    NSArray *paths = [url ssn_routerPaths];
    
    id<SSNParentPage> parent_page = self.window;
    
    SSNSearchResult *rt = [self searchPathWithURL:url
                                            query:query
                                           parent:parent_page
                                            index:0
                                            paths:paths];
    
    return rt;
}

- (SSNSearchResult *)loadPageWithURL:(NSURL *)url query:(NSDictionary *)query {
    
    SSNSearchResult *result = [self searchPageWithURL:url query:query];
    
    if (nil == result) {
        return nil;
    }
    
    //新建page
    if (nil == result.targetPage) {
        
        Class class = [self.map objectForKey:result.lastPath];
        
        result.targetPage = [[class alloc] init];
        result.targetPage.ssn_query = query;//参数赋值
        
        if ([result.targetPage respondsToSelector:@selector(ssn_handleOpenURL:query:)]) {
            [result.targetPage ssn_handleOpenURL:url query:query];
        }
    }
    else {
        result.targetPage.ssn_query = query;//参数赋值
    }
    
    return result;
}

- (id <SSNPage>)pageWithURL:(NSURL *)url query:(NSDictionary *)query {
    if (nil == url) {
        return nil;
    }
    
    NSString *urlscheme = [url scheme];
    if (![urlscheme isEqualToString:self.scheme]) {
        return nil;
    }
    
    SSNSearchResult *result = [self loadPageWithURL:url query:query];
    
    return result.targetPage;
}

//注册页面对应的key(或者叫元组)
- (void)addComponent:(NSString *)component pageClass:(Class)pageClass {
    [self.pmap setValue:pageClass forKey:component];
}

- (void)removeComponent:(NSString *)component {
    [self.pmap removeObjectForKey:component];
}

#pragma mark 反向寻找路径

- (void)findParent:(id<SSNPage>)page inArrary:(NSMutableArray *)array {
    id<SSNParentPage> parent = [page ssn_parentPage];
    if (parent) {
        [self findParent:parent inArrary:array];
        [array addObject:parent];
    }
}

- (NSURL *)searchURLWithPage:(id<SSNPage>)page {
    
    if (!page) {
        return nil;
    }
    
    NSURL *url = nil;
    
    @autoreleasepool {
        
        NSMutableArray *parents = [NSMutableArray arrayWithCapacity:1];
        [self findParent:page inArrary:parents];
        
        if ([parents count] == 0) {
            return nil;
        }
        
        if ([parents objectAtIndex:0] != self.window.rootViewController) {
            return nil;
        }
        
        [parents addObject:page];
        
        NSMutableString *urlstr = [NSMutableString stringWithCapacity:1];
        [urlstr appendFormat:@"%@://",self.scheme];
        BOOL isFirst = YES;
        for (id<SSNPage> apage in parents) {
            id class = [apage class];
            NSArray *ary = [self.map allKeysForObject:class];
            if ([ary count] == 0) {
                continue ;
            }
            
            if (isFirst) {
                isFirst = NO;
            }
            else {
                [urlstr appendString:@"/"];
            }
            
            NSString *path = [ary lastObject];
            [urlstr appendString:path];
        }
        
        url = [NSURL URLWithString:urlstr];
    }
    
    return url;
}

@end

@implementation SSNSearchResult
@end


@implementation NSObject (SSNRouter)

- (SSNRouter *)ssn_router {
    return [SSNRouter shareInstance];
}

- (id <SSNParentPage>)ssn_parentPage {
    return nil;
}

- (NSURL *)ssn_currentURLPath {
    
    if (self.ssn_parentPage == nil) {
        return nil;
    }
    
    if (![self conformsToProtocol:@protocol(SSNPage)]) {
        return nil;
    }
    
    return [self.ssn_router searchURLWithPage:(id<SSNPage>)self];
}

// open url接口，与app不符的scheme将提交给Application打开
- (BOOL)openURL:(NSURL *)url {
    return [[self ssn_router] openURL:url];
}
- (BOOL)openURL:(NSURL *)url query:(NSDictionary *)query {
    return [[self ssn_router] openURL:url query:query];
}
- (BOOL)openURL:(NSURL *)url query:(NSDictionary *)query animated:(BOOL)animated {
    return [[self ssn_router] openURL:url query:query animated:animated];
}

//与url对应的page发送消息
- (BOOL)noticeURL:(NSURL *)url query:(NSDictionary *)query {
    return [[self ssn_router] noticeURL:url query:query];
}

//从当前目录打开url，path格式定义如：“/component1/component2”，你也可以使用NSURLComponents方法生产
- (BOOL)openRelativePath:(NSString *)path {
    return [self openRelativePath:path query:nil];
}

//从当前目录打开url，path格式定义如：“/component1/component2”，你也可以使用NSURLComponents方法生产
- (BOOL)openRelativePath:(NSString *)path query:(NSDictionary *)query {
    BOOL animated = YES;
    
    NSString *an = [query objectForKey:@"animated"];
    if (!an) {
        NSURL *u = [NSURL URLWithString:path];
        if (u) {
            NSDictionary *url_query = [u ssn_queryInfo];
            an = [url_query objectForKey:@"animated"];
        }
    }
    
    if ([an length] > 0
        && ([an compare:@"no" options:NSCaseInsensitiveSearch] == NSOrderedSame
            || [an compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
        animated = [an boolValue];
    }
    
    return [self openRelativePath:path query:query animated:animated];
}

- (BOOL)openRelativePath:(NSString *)path query:(NSDictionary *)query animated:(BOOL)animated {
    
    NSURL *url = [self ssn_currentURLPath];
    NSArray *comps = [path pathComponents];
    NSURL *target_url = [url ssn_relativeURLWithComponents:comps];
    
    return [[self ssn_router] openURL:target_url query:query animated:animated];
}

- (BOOL)noticeRelativePath:(NSString *)path query:(NSDictionary *)query {
    
    NSURL *url = [self ssn_currentURLPath];
    NSArray *comps = [path pathComponents];
    NSURL *target_url = [url ssn_relativeURLWithComponents:comps];
    
    return [[self ssn_router] noticeURL:target_url query:query];
}

@end

@implementation NSObject (SSNPage)

/**
 *  query参数
 */
@dynamic ssn_query;
static char * ssn_router_query_key = NULL;
- (NSDictionary *)ssn_query {
    return objc_getAssociatedObject(self, &ssn_router_query_key);
}
- (void)setSsn_query:(NSDictionary *)ssn_query {
    objc_setAssociatedObject(self, &ssn_router_query_key, ssn_query, OBJC_ASSOCIATION_COPY_NONATOMIC); 
}

@end



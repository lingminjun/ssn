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

@interface SSNSearchResult : NSObject

@property (nonatomic,strong) id<SSNParentPage> parentPage;
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
    
    BOOL animated = YES;
    
    //对参数简单支持
    NSDictionary *query = [url queryInfo];
    NSString *an = [query objectForKey:@"animated"];
    if ([an isEqualToString:@"NO"] || [an isEqualToString:@"false"]) {
        animated = [an boolValue];
    }
    
    return [self openURL:url query:query animated:animated];
}

- (BOOL)canOpenURL:(NSURL *)url {
    if (nil == url) {
        return NO;
    }
    
    NSDictionary *query = [url queryInfo];
    
    return [self canOpenURL:url query:query];
}

- (void)back {
    if ([self.window respondsToSelector:@selector(pageBack)]) {
        return [(id<SSNParentPage>)self.window pageBack];
    }
}

- (NSURL *)delegateFilterURL:(NSURL*)aurl query:(NSDictionary *)query {
    
    NSURL *url = aurl;
    
    //让委托有控制权
    if ([self.delegate respondsToSelector:@selector(router:redirectURL:query:)]) {
        NSURL *rurl = [self.delegate router:self redirectURL:aurl query:query];
        if (rurl) {
            url = rurl;
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(router:canOpenURL:query:)]) {
            BOOL canOpen = [self.delegate router:self canOpenURL:aurl query:query];
            
            if (!canOpen) {
                url = nil;
            }
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
    
    SSNSearchResult *result = [self loadPageWithURL:url query:query];
    if (nil == result) {
        return NO;
    }
    
    //如果目标是一个事件，则不继续询问打开
    if ([result.targetPage isKindOfClass:[SSNEventHandler class]]) {
        return YES;
    }
    
    BOOL openSuccess = NO;
    
    //递归打开界面
    id<SSNParentPage> parent_page = result.parentPage;
    id<SSNPage>current_page = result.targetPage;
    while (parent_page) {
        if ([parent_page respondsToSelector:@selector(openPage:query:animated:)]) {
            openSuccess = [parent_page openPage:current_page query:query animated:animated];
        }
        
        if (!openSuccess) {
            break ;
        }
        
        parent_page = [parent_page parentPage];
        current_page = parent_page;
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

- (id<SSNParentPage>)martchParentPageWithParent:(id<SSNParentPage>)parent
                                    targetClass:(Class)class
                                     respondURL:(NSURL *)respondURL
                                          query:(NSDictionary *)query {
    if (NO == [parent respondsToSelector:@selector(containedPages)]) {
        return nil;
    }
    
    NSArray *pages = [parent containedPages];
    
    //找到已经存在的父控制器
    for (id<SSNPage> page in pages) {
        if ([page isKindOfClass:class] && [page conformsToProtocol:@protocol(SSNParentPage)]) {
            if ([self page:page targetClass:class respondURL:respondURL query:query]) {
                return (id<SSNParentPage>)page;
            }
        }
    }
    
    return nil;
}

- (BOOL)page:(id <SSNPage>)page targetClass:(Class)targetClass respondURL:(NSURL *)url query:(NSDictionary *)query {
    if (![page isKindOfClass:targetClass]) {
        return NO;
    }
    
    SEL sel = @selector(canRespondURL:query:);
    
    if (![page respondsToSelector:sel]) {
        return NO;
    }
    
    if (![page canRespondURL:url query:query]) {
        return NO;
    }
    
    return YES;
}

- (SSNSearchResult *)resultWithParent:(id <SSNParentPage>)parent
                              lastPath:(NSString *)lastPath
                           targetClass:(Class)targetClass
                           originalURL:(NSURL *)url
                                 query:(NSDictionary *)query {
    SSNSearchResult *result = [[SSNSearchResult alloc] init];
    result.parentPage = parent;
    result.lastPath = lastPath;
    
    if ([parent respondsToSelector:@selector(containedPages)]) {
        NSArray *pages = [parent containedPages];
        for (id<SSNPage> page in pages) {
            //尽管找到类似的路径，还是需要确定叶子节点是否响应url
            if ([self page:page targetClass:targetClass respondURL:url query:query]) {
                result.targetPage = page;
                break ;
            }
        }
    }
    
    return result;
}

- (SSNSearchResult *)searchPageWithURL:(NSURL *)url query:(NSDictionary *)query {
    
    NSUInteger path_depth = 0;
    
    NSArray *paths = [url routerPaths];
    
    Class pre_class_type = nil;
    NSString *lastPath = nil;
    
    id<SSNParentPage> parent_page = self.window.rootViewController;
    
    //遍历按照路径去校验
    for (NSString *path in paths) {
        if ([path length] == 0) {
            continue ;
        }
        
        if ([path isEqualToString:@"/"]) {
            continue ;
        }
        
        id class_type = [self.pmap objectForKey:path];
        
        //特殊的handler，不需要注册
        if ([path isEqualToString:@"handler"]) {
            class_type = [SSNEventHandler class];
        }
        
        if (nil == class_type) {
            return nil;
        }
        
        //深度超过1，需要向前确认目录是否已经存在，如果不存在，不需要继续校验
        if (pre_class_type && ![parent_page isKindOfClass:pre_class_type]) {
            return nil;
        }
        
        //寻找对应的父控制器
        parent_page = [self martchParentPageWithParent:parent_page
                                           targetClass:pre_class_type
                                            respondURL:url
                                                 query:query];
        
        if (nil == parent_page) {//没有找到，不再继续，router无法完成
            return nil;
        }

        
        pre_class_type = class_type;
        lastPath = path;
        path_depth++;
    }
    
    //路径为零，无法路由
    if (path_depth == 0) {
        return nil;
    }
    
    return [self resultWithParent:parent_page
                         lastPath:lastPath
                      targetClass:pre_class_type
                      originalURL:url
                            query:query];
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
        
        if ([result.targetPage respondsToSelector:@selector(handleURL:query:)]) {
            [result.targetPage handleURL:url query:query];
        }
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
    id<SSNParentPage> parent = [page parentPage];
    if (parent) {
        [self findParent:parent inArrary:array];
        [array addObject:parent];
    }
}

- (NSURL *)searchURLWithPage:(id<SSNPage>)page {
    
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

- (SSNRouter *)router {
    return [SSNRouter shareInstance];
}

- (id <SSNParentPage>)parentPage {
    return nil;
}

- (NSURL *)currentURLPath {
    
    if (self.parentPage == nil) {
        return nil;
    }
    
    if (![self conformsToProtocol:@protocol(SSNPage)]) {
        return nil;
    }
    
    return [self.router searchURLWithPage:(id<SSNPage>)self];
}

@end


//事件响应类
@interface SSNEventHandler ()
@property (nonatomic,copy) void (^handlerBlock)(NSURL *url,NSDictionary *query);
@property (nonatomic,copy) BOOL (^filterBlock)(NSURL *url,NSDictionary *query);
@end

@implementation SSNEventHandler
@synthesize handlerBlock = _handlerBlock;
@synthesize filterBlock = _filterBlock;

- (id)initWithEventBlock:(SSNEventBlock)event {
    return [self initWithEventBlock:event filter:nil];
}

+ (instancetype)eventBlock:(SSNEventBlock)event {
    return [[[self class] alloc] initWithEventBlock:event filter:nil];
}

- (id)initWithEventBlock:(SSNEventBlock)event filter:(SSNFilterBlock)filter {
    self = [super init];
    if (self) {
        self.handlerBlock = event;
        self.filterBlock = filter;
    }
    return self;
}

+ (instancetype)eventBlock:(SSNEventBlock)event filter:(SSNFilterBlock)filter {
    return [[[self class] alloc] initWithEventBlock:event filter:filter];
}

- (id <SSNParentPage>)parentPage {
    return nil;
}

- (BOOL)canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    BOOL canRespond = YES;
    if (self.filterBlock) {
        canRespond = self.filterBlock(url,query);
    }
    
    if (canRespond) {
        if (self.handlerBlock) {
            self.handlerBlock(url,query);
        }
    }
    
    return canRespond;
}


@end




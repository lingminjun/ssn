//
//  Navigator.m
//  Routable
//
//  Created by lingminjun on 14-6-4.
//  Copyright (c) 2014年 TurboProp Inc. All rights reserved.
//

#import "Navigator.h"


@interface PageSearchResult : NSObject

@property (nonatomic,strong) id<ParentPageProtocol> parentPage;
@property (nonatomic,strong) NSString *lastPathComponent;
@property (nonatomic,strong) id<PageProtocol> targetPage;//不一定有值

@end


@interface Navigator ()
{
    NSMutableDictionary *_map;
}

@property (nonatomic,strong) NSMutableDictionary *map;

- (NSURL *)searchURLWithPage:(id<PageProtocol>)page;//寻找url

@end


@implementation Navigator

+ (instancetype)shareInstance {
    static Navigator *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

#pragma - mark 属性相关
- (NSMutableDictionary *)map {
    if (nil == _map) {
        _map = [NSMutableDictionary dictionary];
    }
    return _map;
}

@dynamic componentMap;
- (NSDictionary *)componentMap {
    return [self.map copy];
}
- (void)setComponentMap:(NSDictionary *)componentMap {
    if (componentMap) {
        [self.map setDictionary:componentMap];
    }
    else {
        [self.map removeAllObjects];
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

- (NSString *)navigationControllerClass {
    if (nil == _navigationControllerClass) {
        _navigationControllerClass = NSStringFromClass([UINavigationController class]);
    }
    return _navigationControllerClass;
}

- (UINavigationController *)rootViewController {
    if (nil == _rootViewController) {
        Class nav_class = NSClassFromString(self.navigationControllerClass);
        if (![nav_class isSubclassOfClass:[UINavigationController class]]) {
            nav_class = [UINavigationController class];
        }
        _rootViewController = [[nav_class alloc] init];
    }
    return _rootViewController;
}


#pragma - mark 基本API
- (BOOL)openURL:(NSURL*)url {
    if (nil == url) {
        return NO;
    }
    
    NSDictionary *query = [url queryInfo];
    BOOL animated = YES;
    NSNumber *an = [query objectForKey:@"animated"];
    if (an) {
        animated = [an boolValue];
    }
    
    BOOL isModal = [[query objectForKey:@"isModal"] boolValue];
    
    return [self openURL:url query:query isModal:isModal animated:animated];
}

- (BOOL)canOpenURL:(NSURL *)url {
    if (nil == url) {
        return NO;
    }
    
    NSDictionary *query = [url queryInfo];
    
    return [self canOpenURL:url query:query];
}

- (void)back {
    if (self.rootViewController.presentedViewController) {
        [self.rootViewController dismissViewControllerAnimated:YES completion:^{
        }];
    }
    else {
        [self.rootViewController pageBack];
    }
}

- (void)presentPage:(UIViewController *)page URL:(NSURL*)url query:(NSDictionary *)query animated:(BOOL)animated {
    
    void (^block)(void) = ^{
        UINavigationController *targetPage = nil;
        if ([page isKindOfClass:[UINavigationController class]]) {
            targetPage = (UINavigationController *)page;
        }
        else {
            Class nav_class = NSClassFromString(self.navigationControllerClass);
            targetPage = [[nav_class alloc] initWithRootViewController:page];
        }
        
        [self.rootViewController presentViewController:targetPage
                                              animated:animated
                                            completion:^{
                                            }];
        
    };
    
    if (self.rootViewController.presentedViewController) {
        [self.rootViewController dismissViewControllerAnimated:NO
                                                    completion:^{
                                                        block();
                                                    }];
    }
    else {
        block();
    }
}

//更佳细致的接口
- (BOOL)openURL:(NSURL*)url query:(NSDictionary *)query animated:(BOOL)animated {

    if (nil == url) {
        return NO;
    }
    
    NSString *urlscheme = [url scheme];
    if (![urlscheme isEqualToString:self.scheme]) {
        return [[UIApplication sharedApplication] openURL:url];
    }
    
    BOOL isModal = [[query objectForKey:@"isModal"] boolValue];
    
    return [self openURL:url query:query isModal:isModal animated:animated];
}

- (BOOL)openURL:(NSURL *)url query:(NSDictionary *)query isModal:(BOOL)isModal animated:(BOOL)animated {
    if (nil == url) {
        return NO;
    }
    
    NSString *urlscheme = [url scheme];
    if (![urlscheme isEqualToString:self.scheme]) {
        return [[UIApplication sharedApplication] openURL:url];
    }
    
    PageSearchResult *result = [self loadPageWithURL:url query:query isModal:isModal];
    if (nil == result) {
        return NO;
    }
    
    //如果目标是一个事件，则不继续询问打开
    if ([result.targetPage isKindOfClass:[EventHandler class]]) {
        return YES;
    }
    
    if (isModal) {
        
        //模态的只支持 viewController
        if (![result.targetPage isKindOfClass:[UIViewController class]]) {
            return YES;
        }

        [self presentPage:(UIViewController *)result.targetPage URL:url query:query animated:animated];
    }
    else {
        BOOL isRoot = [[query objectForKey:@"isRoot"] boolValue];
        
        void (^block)(void) = ^{
            
            //需要向上递归打开
            [self parentPage:result.parentPage openPage:result.targetPage root:isRoot animated:animated];
        };
        
        if (self.rootViewController.presentedViewController) {
            [self.rootViewController dismissViewControllerAnimated:NO
                                                        completion:^{
                                                            block();
                                                        }];
        }
        else {
            block();
        }
    }
    
    return YES;
}

- (BOOL)parentPage:(id<ParentPageProtocol>)parent openPage:(id<PageProtocol>)page root:(BOOL)root animated:(BOOL)animated {
    
    BOOL openSuccess = NO;
    
    //递归打开界面
    id<ParentPageProtocol> grandfather = [parent parentPage];
    if (grandfather) {
        openSuccess = [self parentPage:grandfather openPage:parent root:root animated:animated];
    }
    
    if ([parent respondsToSelector:@selector(openPage:root:animated:)]) {
        openSuccess = [parent openPage:page root:root animated:animated];
    }
    
    return openSuccess;
}

- (BOOL)canOpenURL:(NSURL *)url query:(NSDictionary *)query {
    if (nil == url) {
        return NO;
    }
    
    NSString *urlscheme = [url scheme];
    if (![urlscheme isEqualToString:self.scheme]) {
        return [[UIApplication sharedApplication] canOpenURL:url];
    }
    
    BOOL isModal = [[query objectForKey:@"isModal"] boolValue];
    
    return [self canOpenURL:url query:query isModal:isModal];
}

- (BOOL)canOpenURL:(NSURL *)url query:(NSDictionary *)query isModal:(BOOL)isModal {
    if (nil == url) {
        return NO;
    }
    
    NSString *urlscheme = [url scheme];
    if (![urlscheme isEqualToString:self.scheme]) {
        return [[UIApplication sharedApplication] canOpenURL:url];
    }
    
    PageSearchResult *result = [self searchPageWithURL:url query:query isModal:isModal];
    if (nil != result) {
        return YES;
    }
    
    return NO;
}

- (id<ParentPageProtocol>)martchParentPageWithParent:(id<ParentPageProtocol>)parent targetClass:(Class)class {
    if (NO == [parent respondsToSelector:@selector(containedPages)]) {
        return nil;
    }
    
    NSArray *pages = [parent containedPages];
    
    //找到已经存在的父控制器
    for (id<PageProtocol> page in pages) {
        if ([page isKindOfClass:class] && [page conformsToProtocol:@protocol(ParentPageProtocol)]) {
            return (id<ParentPageProtocol>)page;
        }
    }
    
    return nil;
}

- (BOOL)page:(id <PageProtocol>)page targetClass:(Class)targetClass respondURL:(NSURL *)url query:(NSDictionary *)query {
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

- (PageSearchResult *)resultWithParent:(id <ParentPageProtocol>)parent
                              lastPath:(NSString *)lastPath
                           targetClass:(Class)targetClass
                           originalURL:(NSURL *)url
                                 query:(NSDictionary *)query
                               isModal:(BOOL)isModal {
    PageSearchResult *result = [[PageSearchResult alloc] init];
    result.parentPage = parent;
    result.lastPathComponent = lastPath;
    
    if (isModal) {
        UIViewController *presentVC = self.rootViewController.presentedViewController;
        if ([self page:presentVC targetClass:targetClass respondURL:url query:query]) {
            result.targetPage = self.rootViewController.presentedViewController;
        }
    }
    else {
        
        if ([parent respondsToSelector:@selector(containedPages)]) {
            NSArray *pages = [parent containedPages];
            for (id<PageProtocol> page in pages) {
                if ([self page:page targetClass:targetClass respondURL:url query:query]) {
                    result.targetPage = page;
                    break ;
                }
            }
        }
    }
    
    return result;
}

- (PageSearchResult *)searchPageWithURL:(NSURL *)url query:(NSDictionary *)query isModal:(BOOL)isModal {
    
    NSUInteger path_depth = 0;
    
    NSArray *paths = [url navigatorPaths];
    
    Class pre_class_type = nil;
    NSString *lastPath = nil;
    id<ParentPageProtocol> parent_page = self.rootViewController;
    
    //遍历按照路径去校验
    for (NSString *path in paths) {
        if ([path length] == 0) {
            continue ;
        }
        
        if ([path isEqualToString:@"/"]) {
            continue ;
        }
        
        if ([path isEqualToString:@"nav"]) {
            continue ;
        }
        
        id class_type = [self.map objectForKey:path];
        
        //特殊的handler
        if ([path isEqualToString:@"handler"]) {
            class_type = [EventHandler class];
        }
        
        if (nil == class_type) {
            return nil;
        }
        
        //深度超过1，需要向前确认路劲是否已经存在，如果不存在，不需要继续校验
        if (pre_class_type) {
            
            if (isModal && path_depth > 1) {//说明模态路径肯定不对
                return nil;
            }
            
            //先判断是否为当前路径，还是经过省略
            if ([parent_page isKindOfClass:pre_class_type]) {
                //表示当前路径是父控制器
            }
            else {//并不是父控制器，已经省略nav
                
                if (isModal) {//肯定不是正确的路径
                    return nil;
                }
                
                //寻找对应的父控制器
                parent_page = [self martchParentPageWithParent:parent_page
                                                   targetClass:pre_class_type];
                
                if (nil == parent_page) {//没有找到，不再继续，router无法完成
                    return nil;
                }
            }
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
                            query:query
                          isModal:isModal];
}

- (PageSearchResult *)loadPageWithURL:(NSURL *)url query:(NSDictionary *)query isModal:(BOOL)isModal {
    
    PageSearchResult *result = [self searchPageWithURL:url query:query isModal:isModal];
    
    if (nil == result) {
        return nil;
    }
    
    //新建page
    if (nil == result.targetPage) {
        
        Class class = [self.map objectForKey:result.lastPathComponent];
        
        result.targetPage = [[class alloc] init];
        
        if ([result.targetPage isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)result.targetPage;
            vc.hidesBottomBarWhenPushed = [[query objectForKey:@"hideTabbar"] boolValue];
        }
        
        if ([result.targetPage respondsToSelector:@selector(handleURL:query:)]) {
            [result.targetPage handleURL:url query:query];
        }
    }
    
    return result;
}

- (id <PageProtocol>)pageWithURL:(NSURL *)url query:(NSDictionary *)query {
    if (nil == url) {
        return nil;
    }
    
    NSString *urlscheme = [url scheme];
    if (![urlscheme isEqualToString:self.scheme]) {
        return nil;
    }
    
    BOOL isModal = [[query objectForKey:@"isModal"] boolValue];
    
    PageSearchResult *result = [self loadPageWithURL:url query:query isModal:isModal];
    
    return result.targetPage;
}

//注册页面对应的key(或者叫元组)
- (void)addComponent:(NSString *)component pageClass:(Class)pageClass {
    [self.map setValue:pageClass forKey:component];
}

#pragma mark 反向寻找路径

- (void)findParent:(id<PageProtocol>)page inArrary:(NSMutableArray *)array {
    id <ParentPageProtocol> parent = [page parentPage];
    if (parent) {
        [self findParent:parent inArrary:array];
        [array addObject:parent];
    }
}

- (NSURL *)searchURLWithPage:(id<PageProtocol>)page {

    NSURL *url = nil;
    
    @autoreleasepool {
        
        NSMutableArray *parents = [NSMutableArray arrayWithCapacity:1];
        [self findParent:page inArrary:parents];
        
        if ([parents count] == 0) {
            return nil;
        }
        
        if ([parents objectAtIndex:0] != self.rootViewController) {
            return nil;
        }
        
        NSMutableString *urlstr = [NSMutableString stringWithCapacity:1];
        [urlstr appendFormat:@"%@://",self.scheme];
        BOOL isFirst = YES;
        for (id<PageProtocol> apage in parents) {
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

#pragma - mark 调试
- (void)open:(NSString *)url {
    NSURL *aurl = [NSURL URLWithString:url];
    [self openURL:aurl];
}
- (void)open:(NSString *)url animated:(BOOL)animated {
    NSURL *aurl = [NSURL URLWithString:url];
    NSDictionary *info = [aurl queryInfo];
    [self openURL:aurl query:info animated:animated];
}
- (void)map:(NSString *)format toController:(Class)controllerClass {
    [self.map setValue:controllerClass forKey:format];
}
- (void)pop {
    [self back];
}

@end

@implementation PageSearchResult
@end


//URL基本支持
@implementation NSURL (Navigator)

- (NSArray *)navigatorPaths {
    NSMutableArray *paths = [NSMutableArray array];
    NSString *url_host = [self host];
    if (url_host) {
        [paths addObject:url_host];
    }
    
    NSArray *url_paths = [self pathComponents];
    if (url_paths) {
        [paths addObjectsFromArray:url_paths];
    }
    
    return paths;
}

- (NSString *)urlDecodeString:(NSString *)string {
    NSString *resultString = string;
    NSString *temString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                              (CFStringRef)string,
                                                                              CFSTR(""),
                                                                              kCFStringEncodingUTF8));
    
    if ([temString length]) {
        resultString = [NSString stringWithString:temString];
    }
    
    return temString;
}

- (NSDictionary *)queryInfo {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    //username和password
    @autoreleasepool {
        NSString *user = [self user];
        [dic setValue:user forKey:@"user"];
        
        NSString *password = [self password];
        [dic setValue:password forKey:@"password"];
    }
    
    //query中的数据
    @autoreleasepool {
        NSString *queryString = [self query];
        
        if ([queryString length] == 0) {
            return dic;
        }
        
        NSString *string = [queryString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";?#"]];
        NSArray *params = [string componentsSeparatedByString:@"&"];
        
        for (NSString *param in params) {
            
            NSString *key = nil;
            NSString *value = nil;
            
            NSRange range = [param rangeOfString:@"="];
            if (range.length > 0) {
                key = [param substringToIndex:range.location];
                value = [param substringFromIndex:(range.location + range.length)];
            }
            else {
                key = param;
            }
            
            if (value == nil) {
                value = @"";
            }
            else {
                value = [self urlDecodeString:value];
            }
            
            id pre_value = [dic objectForKey:key];
            if (pre_value) {
                if ([pre_value isKindOfClass:[NSMutableArray class]]) {
                    [(NSMutableArray *)pre_value addObject:value];
                }
                else {
                    NSMutableArray *values = [NSMutableArray arrayWithCapacity:2];
                    [values addObject:pre_value];
                    [values addObject:value];
                    [dic setObject:values forKey:key];
                }
            }
            else {
                [dic setObject:value forKey:key];
            }
        }
    }
    
    return dic;
}

@end


@implementation UIViewController (Navigator)

- (id <ParentPageProtocol>)parentPage {
    return (id <ParentPageProtocol>)self.parentViewController;
}

@end

@implementation UINavigationController (Navigator)

- (NSArray *)containedPages {
    return self.viewControllers;
}

- (id<PageProtocol>)topPage {
    id<PageProtocol> page = [self.viewControllers lastObject];
    if ([page respondsToSelector:@selector(topPage)]) {
        return [(id<ParentPageProtocol>)page topPage];
    }
    return page;
}

- (BOOL)openPage:(id <PageProtocol>)page root:(BOOL)root animated:(BOOL)animated {
    
    if (![page isKindOfClass:[UIViewController class]]) {
        return NO;
    }
    
    UIViewController *vc = (UIViewController *)page;
    
    NSArray *vcs = self.viewControllers;
    
    if (root) {
        if ([vcs count]) {
            if ([vcs objectAtIndex:0] == vc) {
                return YES;
            }
        }
        
        [self setViewControllers:[NSArray arrayWithObject:vc] animated:animated];
        
        return YES;
    }
    
    if ([vcs containsObject:vc]) {
        [self popToViewController:vc animated:animated];
    }
    else {
        [self pushViewController:vc animated:animated];
    }
    
    return YES;
}

- (void)pageBack {
    UIViewController *top = self.topViewController;
    
    if ([top respondsToSelector:@selector(pageBack)]) {
        [(id<ParentPageProtocol>)top pageBack];
    }
    else {
        [self popViewControllerAnimated:YES];
    }
}

@end

@implementation UITabBarController (Navigator)

- (NSArray *)containedPages {
    return self.viewControllers;
}

- (id<PageProtocol>)topPage {
    id<PageProtocol> page = self.selectedViewController;
    if ([page respondsToSelector:@selector(topPage)]) {
        return [(id<ParentPageProtocol>)page topPage];
    }
    return page;
}

- (BOOL)openPage:(id <PageProtocol>)page root:(BOOL)root animated:(BOOL)animated {
    if (![page isKindOfClass:[UIViewController class]]) {
        return NO;
    }
    
    UIViewController *vc = (UIViewController *)page;
    
    //回退其他栈
    UIViewController *old_vc = self.selectedViewController;
    if (old_vc != vc && [old_vc isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)old_vc popToRootViewControllerAnimated:NO];
    }
    
    NSArray *vcs = self.viewControllers;
    
    if ([vcs containsObject:vc]) {
        self.selectedViewController = vc;
    }
    
    return YES;
}

- (void)pageBack {
    UIViewController *top = self.selectedViewController;
    
    if ([top respondsToSelector:@selector(pageBack)]) {
        [(id<ParentPageProtocol>)top pageBack];
    }
    else {
        //[self popViewControllerAnimated:YES];
    }
}

@end

//事件响应类
@interface EventHandler ()
@property (nonatomic,copy) void (^handlerBlock)(NSURL *url,NSDictionary *query);
@property (nonatomic,copy) BOOL (^filterBlock)(NSURL *url,NSDictionary *query);
@end

@implementation EventHandler
@synthesize handlerBlock = _handlerBlock;
@synthesize filterBlock = _filterBlock;

- (id)initWithEventBlock:(void (^)(NSURL *url,NSDictionary *query))event {
    return [self initWithEventBlock:event filter:nil];
}

+ (instancetype)eventBlock:(void (^)(NSURL *url,NSDictionary *query))event {
    return [[[self class] alloc] initWithEventBlock:event filter:nil];
}

- (id)initWithEventBlock:(void (^)(NSURL *url,NSDictionary *query))event filter:(BOOL (^)(NSURL *url,NSDictionary *query))filter {
    self = [super init];
    if (self) {
        self.handlerBlock = event;
        self.filterBlock = filter;
    }
    return self;
}

+ (instancetype)eventBlock:(void (^)(NSURL *url,NSDictionary *query))event filter:(BOOL (^)(NSURL *url,NSDictionary *query))filter {
    return [[[self class] alloc] initWithEventBlock:event filter:filter];
}

- (id <ParentPageProtocol>)parentPage {
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

@implementation NSObject (Navigator)

- (Navigator *)navigator {
    return [Navigator shareInstance];
}

- (id <ParentPageProtocol>)parentPage {
    return nil;
}

- (NSURL *)currentURLPath {
    
    if (self.parentPage == nil) {
        return nil;
    }
    
    if ([self conformsToProtocol:@protocol(PageProtocol)]) {
        return nil;
    }
    
    return [self.navigator searchURLWithPage:(id <PageProtocol>)self];
}

@end

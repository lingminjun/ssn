//
//  SSNNavigationController.m
//  Routable
//
//  Created by lingminjun on 14-6-10.
//  Copyright (c) 2014年 TurboProp Inc. All rights reserved.
//

#import "SSNNavigationController.h"
#import "NiceQueue.h"

#define AnimatdTimeOut(animated) ((animated)?0.7f:0.3f)

@interface ForwardDelegate : NSObject <UINavigationControllerDelegate>

@property (nonatomic,weak) id<UINavigationControllerDelegate> delegate;

- (id)initWithDelegate:(id<UINavigationControllerDelegate>)delegate;

@end


@interface SSNNavigationController ()

@property (nonatomic,strong) NSMutableArray *finalVCS;
@property (nonatomic,strong) NiceQueue *queue;
@property (nonatomic,strong) ForwardDelegate *fdelegate;

#ifdef __IPHONE_7_0
@property (nonatomic,strong) NSArray *undoVCS;//用于动画过程中保留
@property (nonatomic) BOOL isUndo;
#endif

@end

@implementation SSNNavigationController

@synthesize finalVCS = _finalVCS;
@synthesize queue = _queue;
@synthesize fdelegate = _fdelegate;

#ifdef __IPHONE_7_0
@synthesize undoVCS = _undoVCS;
@synthesize isUndo = _isUndo;
#endif

- (NSMutableArray *)finalVCS {
    if (_finalVCS) {
        return _finalVCS;
    }
    
    _finalVCS = [[NSMutableArray alloc] initWithCapacity:1];
    return _finalVCS;
}

- (NiceQueue *)queue {
    if (_queue) {
        return _queue;
    }
    
    _queue = [[NiceQueue alloc] initWithIdentify:[NSString stringWithFormat:@"%@",self]];
    return _queue;
}

- (ForwardDelegate *)fdelegate {
    if (_fdelegate) {
        return _fdelegate;
    }
    
    _fdelegate = [[ForwardDelegate alloc] init];
    return _fdelegate;
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    self.fdelegate.delegate = delegate;
}

- (void)setNavigationDelegate:(id<UINavigationControllerDelegate>)navigationDelegate {
    self.fdelegate.delegate = navigationDelegate;
}

- (id<UINavigationControllerDelegate>)navigationDelegate {
    return self.fdelegate.delegate;
}

- (id)init {
    self = [super init];
    if (self) {
        [super setDelegate:self.fdelegate];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [super setDelegate:self.fdelegate];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [super setDelegate:self.fdelegate];
    }
    return self;
}

#pragma mark - push和pop动作
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (nil == viewController) {
        return ;
    }
    
    if ([self.finalVCS containsObject:viewController]) {
        return ;
    }
    
    [self.finalVCS addObject:viewController];
    
    NSString *tag = [NSString stringWithFormat:@"%@",viewController];
    
    BOOL (^block)(NSString *tag) = ^(NSString *tag) {
        [super pushViewController:viewController animated:animated];
        return NO;
    };
    
    [self.queue addAction:block
                   forTag:tag
                  timeOut:AnimatdTimeOut(animated)];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    if ([self.finalVCS count] <= 1) {
        return nil;
    }
    
    UIViewController *last = [self.finalVCS lastObject];
    
#ifdef __IPHONE_7_0
    if (animated) {
        self.undoVCS = [NSArray arrayWithArray:self.finalVCS];
    }
#endif
    
    [self.finalVCS removeLastObject];
    
    UIViewController *top = [self.finalVCS lastObject];

    NSString *tag = [NSString stringWithFormat:@"%@",top];
    
    BOOL (^block)(NSString *tag) = ^(NSString *tag) {
        [super popViewControllerAnimated:animated];
        return NO;
    };
    
    [self.queue addAction:block
                   forTag:tag
                  timeOut:AnimatdTimeOut(animated)];
    
    return last;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSInteger index = [self.finalVCS indexOfObject:viewController];
    NSInteger count = [self.finalVCS count];
    if (index + 1 >= count) {//最后一个不需要继续pop to
        return nil;
    }
    
    NSRange range = NSMakeRange(index + 1, count - (index + 1));
    
    NSArray *rsl = [self.finalVCS subarrayWithRange:range];
    [self.finalVCS removeObjectsInRange:range];
    
    UIViewController *last = [self.finalVCS lastObject];
    NSString *tag = [NSString stringWithFormat:@"%@",last];
    
    BOOL (^block)(NSString *tag) = ^(NSString *tag) {
        [super popToViewController:viewController animated:animated];
        return NO;
    };
    
    [self.queue addAction:block
                   forTag:tag
                  timeOut:AnimatdTimeOut(animated)];
    
    return rsl;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    
    if ([self.finalVCS count] <= 1) {
        return nil;
    }
    
    NSRange range = NSMakeRange(1, [self.finalVCS count] - 1);
    
    NSArray *rsl = [self.finalVCS subarrayWithRange:range];
    [self.finalVCS removeObjectsInRange:range];
    
    UIViewController *rootVC = [self.finalVCS lastObject];
    NSString *tag = [NSString stringWithFormat:@"%@",rootVC];
    
    BOOL (^block)(NSString *tag) = ^(NSString *tag) {
        [super popToRootViewControllerAnimated:animated];
        return NO;
    };
    
    [self.queue addAction:block
                   forTag:tag
                  timeOut:AnimatdTimeOut(animated)];
    
    return rsl;
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    
    if (0 == [viewControllers count]) {
        return ;
    }
    
    UIViewController *old_last = [self.finalVCS lastObject];
    UIViewController *new_last = [viewControllers lastObject];
    
    [self.finalVCS setArray:viewControllers];
    
    BOOL notWait = NO;
    if (old_last == new_last) {//不需要动画
        animated = NO;
        notWait = YES;
    }
    
    NSString *tag = [NSString stringWithFormat:@"%@",new_last];
    
    BOOL (^block)(NSString *tag) = ^(NSString *tag) {
        [super setViewControllers:viewControllers animated:animated];
        return notWait;
    };
    
    [self.queue addAction:block
                   forTag:tag
                  timeOut:AnimatdTimeOut(animated)];
}

@end


@implementation ForwardDelegate

@synthesize delegate = _delegate;

- (id)initWithDelegate:(id<UINavigationControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)undoPopAction:(SSNNavigationController *)navigationController {
    if (navigationController.undoVCS) {
        NSLog(@"undo navigation vcs[%lud]",(unsigned long)[navigationController.undoVCS count]);
        [navigationController.finalVCS setArray:navigationController.undoVCS];
        
        navigationController.undoVCS = nil;
        navigationController.isUndo = YES;
        
        //解除循环引用
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(undoPopAction:)
                                                   object:navigationController];
    }
}

- (void)redoPopAction:(SSNNavigationController *)navigationController viewController:(UIViewController *)viewController {
    
    navigationController.undoVCS = nil;
    
    //先cancel
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(undoPopAction:)
                                               object:navigationController];
    
    if (navigationController.isUndo) {
        navigationController.isUndo = NO;
        NSArray *vcs = navigationController.viewControllers;
        [navigationController.finalVCS setArray:vcs];
        
        NSLog(@"redo navigation vcs[%lud]",(unsigned long)[vcs count]);
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
#ifdef __IPHONE_7_0
    if ([navigationController isKindOfClass:[SSNNavigationController class]]) {
        SSNNavigationController *queueNav = (SSNNavigationController *)navigationController;
        queueNav.isUndo = NO;
        if (queueNav.undoVCS) {
            //先还原操作（pop可能只是ios中的拖拽）
            [self performSelector:@selector(undoPopAction:)
                       withObject:queueNav
                       afterDelay:0.7f];
        }
    }
    NSLog(@"willShowViewController");
#endif
    
    if ([self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if ([navigationController isKindOfClass:[SSNNavigationController class]]) {
        SSNNavigationController *queueNav = (SSNNavigationController *)navigationController;
#ifdef __IPHONE_7_0
        [self redoPopAction:queueNav viewController:viewController];
#endif
        NSString *tag = [NSString stringWithFormat:@"%@",viewController];
        [queueNav.queue fireForTag:tag];
    }
    NSLog(@"didShowViewController");
    if ([self.delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.delegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

@end


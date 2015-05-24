//
//  SSNNavigationBarAnimator.m
//  ssn
//
//  Created by lingminjun on 15/5/17.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNNavigationBarAnimator.h"

//#define T_LOG(fmt, ...)          NSLog((fmt), ##__VA_ARGS__)
#define T_LOG(fmt, ...)         ((void)0)

@interface SSNNavigationBarAnimator() <UIGestureRecognizerDelegate>

@property (strong, nonatomic,readonly) UIPanGestureRecognizer* panGesture;

@end

@implementation SSNNavigationBarAnimator {
    __weak UIViewController *_controller;
    __weak UIView *_view;
    __weak UIView *_navigationBarSuperView;
    CGFloat _prevContentOffsetY;
}

+ (UIImageView *)topStateView {
    static UIImageView *_topStateView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _topStateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
        _topStateView.clipsToBounds = YES;
        _topStateView.alpha = 0.9f;
    });
    return _topStateView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGesture.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackgroundNotification:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UINavigationController *)navigationController {
    return self.targetViewController.navigationController;
}

- (UIView *)targetView {
    return _view;
}

- (UIViewController *)targetViewController {
    if (_controller) {
        return _controller;
    }
    if (!_view) {
        return nil;
    }
    
    UIResponder *responder = _view;
    
    Class vc_class = [UIViewController class];
    
    do {
        responder = responder.nextResponder;
        if (!responder) {
            break ;
        }
        if ([responder isKindOfClass:vc_class]) {
            _controller = (UIViewController *)responder;
            break ;
        }
    } while (YES);
    
    return _controller;
}

- (UIView *)navigationBarSuperView {
    if (_navigationBarSuperView) {
        return _navigationBarSuperView;
    }
    _navigationBarSuperView = self.navigationController.navigationBar.superview;
    return _navigationBarSuperView;
}

//- (void)viewWillAppear:(BOOL)animated {
//    [self setNavigationBarHidden:NO animated:animated];
//    [self setEnabled:YES];
//    
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [self setNavigationBarHidden:NO animated:animated];
//    [self setEnabled:NO];
//}

@dynamic enabled;
- (void)setEnabled:(BOOL)enabled {
    if (enabled) {
        if (_view) {
            // remove gesture from current panGesture's view
            if (_panGesture.view) {
                [_panGesture.view removeGestureRecognizer:_panGesture];
            }
            [_view addGestureRecognizer:_panGesture];
        }
    }
    else {
        if (_panGesture.view) {
            [_panGesture.view removeGestureRecognizer:_panGesture];
        }
    }
}
- (BOOL)enabled {
    return (_view && _view == _panGesture.view);
}


@dynamic statusBarColor;
- (void)setStatusBarColor:(UIColor *)statusBarColor {
    UIView *topStateView = [[self class] topStateView];
    topStateView.backgroundColor = statusBarColor;
}
- (UIColor *)statusBarColor {
    UIView *topStateView = [[self class] topStateView];
    return topStateView.backgroundColor;
}

@dynamic statusBarImage;
- (void)setStatusBarImage:(UIImage *)statusBarImage {
    UIImageView *topStateView = [[self class] topStateView];
    topStateView.image = statusBarImage;
}
- (UIImage *)statusBarImage {
    UIImageView *topStateView = [[self class] topStateView];
    return topStateView.image;
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark public api
- (void)setTargetView:(UIView *)view {
    
    if (_view != view) {
        // remove gesture from current panGesture's view
        if (_panGesture.view) {
            [_panGesture.view removeGestureRecognizer:self.panGesture];
        }
        
        _view = view;
        _controller = nil;
    }
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden) {
        if (self.navigationController) {
            UIView *topStateView = [[self class] topStateView];
            [self.navigationController.view addSubview:topStateView];
        }
    }
    else {
        BOOL inner_hidden = [self isNavigationBarHidden];
        if (inner_hidden != hidden) {
            UIView *view = [[self class] topStateView];
            if (animated) {
                [UIView animateWithDuration:0.75f animations:^{
                    view.alpha = 0.001f;
                } completion:^(BOOL finished) {
                    [view removeFromSuperview];
                    view.alpha = 1.0f;
                }];
            }
            else {
                [[[self class] topStateView] removeFromSuperview];
            }
        }
    }
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
    
    if ([self.delegate respondsToSelector:@selector(animator:didSetNavigationBarHidden:animated:)]) {
        [self.delegate animator:self didSetNavigationBarHidden:hidden animated:animated];
    }
}

- (BOOL)isNavigationBarHidden {
    return [self.navigationController isNavigationBarHidden];
}

#pragma mark notify
- (void)applicationDidBecomeActive:(NSNotification *)notify {
    [self setNavigationBarHidden:NO animated:YES];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notify {
    //回复window检查
    [self resumeChangeViewFrame];
}

- (void)resumeChangeViewFrame {
    //恢复window检查
    UINavigationController *navigationController = self.navigationController;
    UINavigationBar *bar = navigationController.navigationBar;
    
    //修改导航contentView
    UIView *barSuperView = self.navigationBarSuperView;
    for (UIView *subview in barSuperView.subviews) {
        if (subview == bar) {
            continue ;
        }
        
        if (subview == [[self class] topStateView]) {
            continue ;
        }
        
        if (!CGRectEqualToRect(subview.frame, barSuperView.bounds)) {
            subview.frame = barSuperView.bounds;
        }
    }
    
    //transform恢复
//    for (UIView* view in bar.subviews) {
//        bool isBackgroundView = view == [bar.subviews objectAtIndex:0];
//        if (!isBackgroundView) {
//            view.transform = CGAffineTransformIdentity;
//        }
//    }
}



#pragma mark - panGesture handler
- (void)setFrame:(CGRect)frame alpha:(CGFloat)alpha animated:(BOOL)animated completion:(void (^)(BOOL finish))completion {
    
    UINavigationController *navigationController = self.navigationController;
    UINavigationBar *bar = navigationController.navigationBar;
    
    CGFloat offsetY = CGRectGetMinY(frame) - CGRectGetMinY(bar.frame);
    CGFloat duration = 0.15f*(ABS(offsetY)/frame.size.height);
    
    void (^animations)(void)= ^{
        for (UIView* view in bar.subviews) {
            bool isBackgroundView = view == [bar.subviews objectAtIndex:0];
            bool isViewHidden = view.hidden || view.alpha == 0.0f;
            if (isBackgroundView || isViewHidden)
                continue;
            view.alpha = alpha;
        }
        T_LOG(@"animatedfrom:%f to:%f",bar.frame.origin.y,frame.origin.y);
        bar.frame = frame;
        
        //修改导航contentView
        UIView *barSuperView = self.navigationBarSuperView;
        for (UIView *subview in barSuperView.subviews) {
            if (subview == bar) {
                continue ;
            }
            
            if (subview == [[self class] topStateView]) {
                continue ;
            }
            
            T_LOG(@"<<%@>>",subview);
            CGRect viewFrame = subview.frame;
            viewFrame.origin.y += offsetY;
            viewFrame.size.height -= offsetY;
            subview.frame = viewFrame;
            
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    }
    else {
        animations();
        if (completion) {
            completion(YES);
        }
    }
}

- (CGFloat)statusBarTopOffset
{
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) +
            [UIApplication sharedApplication].statusBarFrame.origin.y;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);
        default:
            break;
    };
    return 64.0f;
}

#define kNearZero 0.000001f

- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    UIView *view = self.targetView;
    if (!view || gesture.view != view) {
        return ;
    }
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if (!navigationBar) {
        return ;
    }
    
    
    //    CGFloat contentOffsetY = scrollView.contentOffset.y;
    UIWindow *window = view.window;
    CGFloat contentOffsetY = [gesture locationInView:window].y;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        gesture.maximumNumberOfTouches = gesture.numberOfTouches;
        _prevContentOffsetY = contentOffsetY;
        T_LOG(@"1first content off set:%f",contentOffsetY);
        return;
    }
    
    CGFloat deltaY = contentOffsetY - _prevContentOffsetY;
    _prevContentOffsetY = contentOffsetY;
    T_LOG(@"1delay:%f contentOffsetY:%f",deltaY,contentOffsetY);
    
    BOOL isDown = NO;
    if (deltaY > 0) {//朝下
        isDown = YES;
    }
    else if (deltaY < 0) {//朝上
        isDown = NO;
    }
    else {//没有变化，changed并没有改变值
        if (gesture.state == UIGestureRecognizerStateChanged) {
            return ;
        }
    }
    
    const CGRect  barFrame = navigationBar.frame;
    CGRect  frame = barFrame;
    CGFloat alpha = 1.0f;
    CGFloat maxY = [self statusBarTopOffset];
    CGFloat minY = maxY - CGRectGetHeight(frame);
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        if (isDown && frame.origin.y >= maxY) {//已经是最下面了
            T_LOG(@"已经到了最下面了");
            return ;
        }
        
        if (!isDown && frame.origin.y <= minY) {//已经是最下面了
            T_LOG(@"已经到了最上面了");
            return ;
        }
        
        //因为隐藏的导航栏无法实行动画，所以需要将导航栏设置出来
        if ([self.navigationController isNavigationBarHidden]) {
            T_LOG(@"因为导航隐藏无法展示展示动画");
            [self setNavigationBarHidden:NO animated:NO];
            [self resumeChangeViewFrame];
            
            CGRect aframe = frame;
            aframe.origin.y = minY;
            [self setFrame:aframe alpha:alpha animated:NO completion:nil];
        }
        
        //滑动边界控制，防止划过头
        frame.origin.y += deltaY;
        if (frame.origin.y < minY) {
            frame.origin.y = minY;
        }
        if (frame.origin.y > maxY) {
            frame.origin.y = maxY;
        }
        
        alpha = (frame.origin.y - (minY + maxY)) / (maxY - (minY + maxY));
        alpha = MAX(kNearZero, alpha);
        
        [self setFrame:frame alpha:alpha animated:NO completion:nil];
        
        T_LOG(@"1change bar frame(%f,%f %f,%f)",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    }
    else {
        // Set the max number of touches back to the default
        gesture.maximumNumberOfTouches = NSUIntegerMax;
        
        //最终拖拽方向，此函数取值必须在改变手势时取值比较靠谱
        CGPoint velocity = [gesture velocityInView:window];
        
        BOOL shouldShow;
        if (velocity.y < 0) {
            shouldShow = NO;
            frame.origin.y = minY;
            alpha = kNearZero;
            T_LOG(@"发现此时方向时朝着上的");
        }
        else {
            frame.origin.y = maxY;
            shouldShow = YES;
            T_LOG(@"发现此时方向时朝着下的");
        }
        
        if (shouldShow && barFrame.origin.y == maxY) {//已经是最下面了
            [self setNavigationBarHidden:!shouldShow animated:NO];
            [self resumeChangeViewFrame];
            T_LOG(@"导航栏本来就显示着，故不需要动画了");
            return ;
        }
        
        if (!shouldShow && [self.navigationController isNavigationBarHidden]) {//已经是最下面了
            T_LOG(@"导航栏本来就隐藏着，故不需要动画了");
            return ;
        }
        
        T_LOG(@"2change bar frame(%f,%f %f,%f)",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
        
        window.userInteractionEnabled = NO;
        __weak typeof(self) w_self = self;
        [self setFrame:frame alpha:alpha animated:YES completion:^(BOOL finish) {
            __strong typeof(w_self) self = w_self;
            //最终调整导航bare
            CGRect aframe = frame;
            aframe.origin.y = maxY;
            T_LOG(@"3change bar frame(%f,%f %f,%f)",aframe.origin.x,aframe.origin.y,aframe.size.width,aframe.size.height);
            
            [self setFrame:aframe alpha:alpha animated:NO completion:nil];
            [self setNavigationBarHidden:!shouldShow animated:NO];
            [self resumeChangeViewFrame];
            
            window.userInteractionEnabled = YES;
        }];
    }
    
    
}

@end

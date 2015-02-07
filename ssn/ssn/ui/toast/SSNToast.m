//
//  SSNToast.m
//  ssn
//
//  Created by lingminjun on 15/2/5.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNToast.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

#define SSNTOAST_DEFAULT_FONT [UIFont boldSystemFontOfSize:15]
#define SSNTOAST_MIN_WIDTH    (100)
#define SSNTOAST_MIN_SPACE    (10)
#define SSNTOAST_RADIUS       (5)

NSString *const SSNToastShowKey = @"show";
NSString *const SSNToastHideKey = @"hide";

#pragma mark 专门显示的window，最外层
@interface SSNToastWindow : UIWindow
@end

@implementation SSNToastWindow
+ (instancetype)sharedInstance {
    static SSNToastWindow *window = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#define SSNToastWindowHeight (4)
        CGRect mainBounds = [UIScreen mainScreen].bounds;
        window = [[SSNToastWindow alloc] initWithFrame:CGRectMake(0, -SSNToastWindowHeight, mainBounds.size.width, SSNToastWindowHeight)];
        window.bounds = CGRectMake(0, -SSNToastWindowHeight, mainBounds.size.width, SSNToastWindowHeight);
        window.windowLevel = UIWindowLevelStatusBar;
        window.hidden = NO;
    });
    return window;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    NSArray *subviews = [self subviews];
    for (UIView *subview in subviews) {
        if (subview.userInteractionEnabled && CGRectContainsPoint(subview.frame, point)) {
            return YES;
        }
    }
    
    return [super pointInside:point withEvent:event];
}
@end

#pragma mark SSNToast绑定到target
@interface SSNToastBanding : NSObject
@property (nonatomic, weak) SSNToast *toast;
//@property (nonatomic, weak) id target;
@end

@implementation SSNToastBanding

+ (instancetype)toastBandingWithToast:(SSNToast *)toast {
    SSNToastBanding *banding = [[[self class] alloc] init];
    banding.toast = toast;
    return banding;
}

- (void)dealloc {
    SSNToast *atoast = _toast;
    if (atoast) {
        [atoast hideAnimated:YES];
    }
    _toast = nil;
//    _target = nil;
}

@end

#define ssn_toast_obj_synthesize(type,get,set) _ssn_toast_obj_synthesize_(type,get,set)
#define _ssn_toast_obj_synthesize_(t,g,s) \
static char * g ## _key = NULL;\
- (t) g { \
return objc_getAssociatedObject(self, &(g ## _key)); \
} \
- (void) set ## s :(t) g { \
objc_setAssociatedObject(self, &(g ## _key), ( g ), OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
}
@interface NSObject (SSNToastBanding)
@property (nonatomic,strong) SSNToastBanding *ssn_toastBanding;
@end

@implementation NSObject (SSNToastBanding)
ssn_toast_obj_synthesize(SSNToastBanding *, ssn_toastBanding, Ssn_toastBanding)
@end

#pragma mark SSNToast 实现
@interface SSNToast ()

@property (nonatomic,copy) NSString *message;
@property (nonatomic) SSNToastDisplayPosition position;

@property (nonatomic,strong) UIView *contentView;//toast显示层
@property (nonatomic) BOOL activityIndicator;

@property (nonatomic,strong) UIActivityIndicatorView *indicator;
@property (nonatomic,strong) UILabel *label;

@property (nonatomic) SSNToastAnimation animation;

@property (nonatomic,strong) NSString *showTimestamp;
@property (nonatomic,strong) NSString *hideTimestamp;

@end

@implementation SSNToast

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _position = SSNToastCenterPosition;
        _modalStyle = SSNToastFocusModalStyle;
        _activityIndicator = NO;
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:_contentView];
    }
    return self;
}

- (UIActivityIndicatorView *)indicator {
    if (!_activityIndicator) {
        return nil;
    }
    
    if (_indicator) {
        return _indicator;
    }
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_indicator sizeToFit];
    [self.contentView addSubview:_indicator];
    [_indicator startAnimating];
    return _indicator;
}

- (UILabel *)label {
    if (_label) {
        return _label;
    }
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.numberOfLines = 0;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor whiteColor];
    _label.font = SSNTOAST_DEFAULT_FONT;
    [self.contentView addSubview:_label];
    return _label;
}

- (void)setDisplayCenter:(CGPoint)displayCenter {
    _displayCenter = displayCenter;
}

@dynamic opacity;
- (CGFloat)opacity {
    return 1.0f-self.contentView.alpha;
}
- (void)setOpacity:(CGFloat)opacity {
    if (opacity >= 1.0f) {
        self.contentView.alpha = 0.0f;
    }
    else {
        self.contentView.alpha = 1.0f - opacity;
    }
}

@dynamic color;
- (UIColor *)color {
    return self.contentView.backgroundColor;
}
- (void)setColor:(UIColor *)backgroundColor {
    self.contentView.backgroundColor = backgroundColor;
}

@dynamic font;
- (UIFont *)font {
    return self.label.font;
}
- (void)setFont:(UIFont *)font {
    self.label.font = font;
}

#pragma mark 显示
- (instancetype)initWithTarget:(NSObject *)target message:(NSString *)message activityIndicator:(BOOL)activityIndicator {
    self = [super init];
    if (self) {
        self.label.text = message;
        self.activityIndicator = activityIndicator;
        if (target) {
            target.ssn_toastBanding = [SSNToastBanding toastBandingWithToast:self];
        }
    }
    return self;
}

+ (instancetype)toastWithTarget:(NSObject *)target message:(NSString *)message activityIndicator:(BOOL)activityIndicator {
    return [[[self class] alloc] initWithTarget:target message:message activityIndicator:activityIndicator];
}

/**
 *  展示一个toast
 */
- (void)show {
    [self showForView:nil atPosition:SSNToastCenterPosition animation:SSNToastAnimationFade];
}

/**
 *  显示
 *
 *  @param view      展示视图所在view画布，传入nil表示整个屏幕
 *  @param position  在view画布中的位置
 *  @param animation 展示动画
 */
- (void)showForView:(UIView *)view atPosition:(SSNToastDisplayPosition)position animation:(SSNToastAnimation)animation {
    CGRect rect = [UIScreen mainScreen].bounds;
    if (view && view.window) {//取view在window上的位置
        rect = [view convertRect:view.frame toView:view.window];
    }
    [self showForRect:rect atPosition:position animation:animation];
}

/**
 *  显示
 *
 *  @param rect      展示视图所在画布（rect是以[UIScreen mainScreen].bounds为坐标）
 *  @param position  在view画布中的位置
 *  @param animation 展示动画
 */
- (void)showForRect:(CGRect)rect atPosition:(SSNToastDisplayPosition)position animation:(SSNToastAnimation)animation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.position = position;
    self.animation = animation;
    
    [self layoutContentSubviewsWithFrame:rect];
    
    UIWindow *window = [SSNToastWindow sharedInstance];
    [window addSubview:self];

    //如果存在自定义view
    if (self.customView) {
        [self addSubview:self.customView];
    }
    
    //显示动画执行
    [self showUsingAnimation];
}

- (void)hideAnimated:(BOOL)animated {
    [self hideAnimated:YES afterDelay:0];
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    if (delay == 0) {
        [self hideUsingAnimation:animated];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(inlineHideAnimated:) withObject:@(animated) afterDelay:delay];
    }
}

- (void)inlineHideAnimated:(NSNumber *)animated {
    [self hideUsingAnimation:[animated boolValue]];
}

#pragma mark 高级方法
/**
 *  隐藏所有toast
 */
+ (void)hideAllToast {
    SSNToastWindow *window = [SSNToastWindow sharedInstance];
    NSArray *subviews = [window subviews];
    for (UIView *v in subviews) {
        if (![v isKindOfClass:[SSNToast class]]) {
            continue ;
        }
        
        [(SSNToast *)v hideAnimated:YES];
    }
}

#pragma mark - Internal show & hide operations

- (void)showUsingAnimation {
    
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    if (_animation == SSNToastAnimationZoomIn) {
        self.contentView.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
    } else if (_animation == SSNToastAnimationZoomOut) {
        self.contentView.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
    }
    
    self.hideTimestamp = nil;//指针消失
    self.showTimestamp = [NSString stringWithFormat:@"%@",[NSDate date]];
    [UIView beginAnimations:SSNToastShowKey context:(__bridge void *)((self.showTimestamp))];
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    self.contentView.alpha = 1.0f;
    if (_animation == SSNToastAnimationZoomIn || _animation == SSNToastAnimationZoomOut) {
        self.contentView.transform = rotationTransform;
    }
    [UIView commitAnimations];
}

- (void)hideUsingAnimation:(BOOL)animated {
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    // Fade out
    if (animated) {
        self.showTimestamp = nil;//指针消失
        self.hideTimestamp = [NSString stringWithFormat:@"%@",[NSDate date]];
        [UIView beginAnimations:SSNToastHideKey context:(__bridge void *)((self.hideTimestamp))];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        // 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
        // in the done method
        if (_animation == SSNToastAnimationZoomIn) {
            self.contentView.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
        } else if (_animation == SSNToastAnimationZoomOut) {
            self.contentView.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
        }
        
        self.contentView.alpha = 0.02f;
        [UIView commitAnimations];
    }
    else {
        self.contentView.alpha = 0.0f;
        self.hideTimestamp = nil;//指针消失
    }
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    if (animationID == SSNToastHideKey && context == (__bridge void *)(self.hideTimestamp)) {
        [self removeFromSuperview];
    }
    
    if (animationID == SSNToastHideKey) {
        self.hideTimestamp = nil;
    }
    else if (animationID == SSNToastShowKey) {
        self.showTimestamp = nil;
    }
}


#pragma mark 布局
- (CGSize)resizeLabelWithMaxWidth:(NSUInteger)maxWidth {
    CGSize goal_size = CGSizeMake(maxWidth, 3000);
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary *attributes = @{ NSFontAttributeName:self.label.font };
        CGRect rect = [self.label.text boundingRectWithSize:goal_size
                                                    options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                 attributes:attributes
                                                    context:nil];
        return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    CGSize size = [self.label.text sizeWithFont:self.label.font constrainedToSize:goal_size lineBreakMode:NSLineBreakByWordWrapping];
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
#pragma clang diagnostic pop
}

- (void)layoutactivitySize:(CGSize)actSize textSize:(CGSize)txtSize bounds:(CGRect)bounds position:(SSNToastDisplayPosition)position {
    CGPoint actCenter = CGPointZero;
    CGPoint txtCenter = CGPointZero;
    
    if (actSize.width > 0) {
        self.indicator.frame = CGRectMake(0, 0, actSize.width, actSize.height);
    }
    
    if (txtSize.width > 0) {
        self.label.frame = CGRectMake(0, 0, txtSize.width, txtSize.height);
    }
    
    actCenter.x = ceilf(bounds.size.width/2);
    txtCenter.x = ceilf(bounds.size.width/2);
    
    switch (position) {
        case SSNToastCenterPosition:
            if (actSize.height > 0 && txtSize.height > 0) {
                NSUInteger contentHeight = actSize.height + txtSize.height + SSNTOAST_MIN_SPACE;
                actCenter.y = ceilf((bounds.size.height - contentHeight + actSize.height)/2);
                txtCenter.y = ceilf(actCenter.y + actSize.height/2 + SSNTOAST_MIN_SPACE + txtSize.height/2);
            }
            else {
                actCenter.y = ceilf(bounds.size.height/2);
                txtCenter.y = ceilf(bounds.size.height/2);
            }
            break;
        case SSNToastTopPosition:
            if (actSize.height > 0 && txtSize.height > 0) {
                actCenter.y = ceilf(SSNTOAST_MIN_SPACE + actSize.height/2);
                txtCenter.y = ceilf(actCenter.y + actSize.height/2 + SSNTOAST_MIN_SPACE + txtSize.height/2);
            }
            else {
                actCenter.y = ceilf(SSNTOAST_MIN_SPACE + actSize.height/2);
                txtCenter.y = ceilf(SSNTOAST_MIN_SPACE + txtSize.height/2);
            }
            break;
        case SSNToastBottomPosition:
            if (actSize.height > 0 && txtSize.height > 0) {
                NSUInteger contentHeight = actSize.height + txtSize.height + SSNTOAST_MIN_SPACE;
                actCenter.y = ceilf(bounds.size.height - contentHeight - SSNTOAST_MIN_SPACE + actSize.height/2);
                txtCenter.y = ceilf(actCenter.y + actSize.height/2 + SSNTOAST_MIN_SPACE + txtSize.height/2);
            }
            else {
                actCenter.y = ceilf(bounds.size.height - actSize.height/2 - SSNTOAST_MIN_SPACE);
                txtCenter.y = ceilf(bounds.size.height - txtSize.height/2 - SSNTOAST_MIN_SPACE);
            }
            break;
        default:
            actCenter.x = self.displayCenter.x;
            txtCenter.x = self.displayCenter.x;
            
            if (actSize.height > 0 && txtSize.height > 0) {
                NSUInteger contentHeight = actSize.height + txtSize.height + SSNTOAST_MIN_SPACE;
                actCenter.y = ceilf(self.displayCenter.y - contentHeight/2 + actSize.height/2);
                txtCenter.y = ceilf(actCenter.y + actSize.height/2 + SSNTOAST_MIN_SPACE + txtSize.height/2);
            }
            else {
                actCenter.y = self.displayCenter.y;
                txtCenter.y = self.displayCenter.y;
            }
            break;
    }
    
    if (actSize.width > 0) {
        self.indicator.center = actCenter;
    }
    
    if (txtSize.width > 0) {
        self.label.center = txtCenter;
    }
}

- (void)layoutContentSubviewsWithFrame:(CGRect)frame {
    self.frame = frame;
    
    CGSize actSize = CGSizeZero;
    CGSize txtSize = CGSizeZero;
    
    //求出指示器大小
    if (_activityIndicator) {
        actSize = self.indicator.frame.size;
    }
    
    //求出label大小
    if ([_label.text length] > 0) {
        txtSize = [self resizeLabelWithMaxWidth:(frame.size.width - 2*SSNTOAST_MIN_SPACE)];
    }
    
    //计算content位置
    CGRect cntRect = CGRectZero;
    SSNToastDisplayPosition position = SSNToastCenterPosition;
    if (self.modalStyle == SSNToastFullModalStyle) {
        self.contentView.layer.cornerRadius = 0;
        
        cntRect = self.bounds;
        position = _position;
    }
    else {
        self.contentView.layer.cornerRadius = SSNTOAST_RADIUS;
        
        position = SSNToastCenterPosition;
        
        if (actSize.width > 0) {//有指示器最小值被放大
            cntRect.size.width = MAX(SSNTOAST_MIN_WIDTH, (2*SSNTOAST_MIN_SPACE + txtSize.width));
            NSUInteger space = 0;
            if (txtSize.width > 0) {
                space = SSNTOAST_MIN_SPACE;
            }
            cntRect.size.height = MAX(SSNTOAST_MIN_WIDTH, (2*SSNTOAST_MIN_SPACE + txtSize.height + space));
        }
        else {
            cntRect.size.width = 2*SSNTOAST_MIN_SPACE + txtSize.width;
            cntRect.size.height = 2*SSNTOAST_MIN_SPACE + txtSize.height;
        }
        
        //content的位置计算
        cntRect.origin.x = ceilf((self.bounds.size.width - cntRect.size.width)/2);
        switch (_position) {
            case SSNToastCenterPosition:
                cntRect.origin.y = ceilf((self.bounds.size.height - cntRect.size.height)/2);
                break;
            case SSNToastTopPosition:
                cntRect.origin.y = SSNTOAST_MIN_SPACE;
                break;
            case SSNToastBottomPosition:
                cntRect.origin.y = self.bounds.size.height - cntRect.size.height - SSNTOAST_MIN_SPACE;
                break;
            default:
                cntRect.origin.x = ceilf(self.displayCenter.x - cntRect.size.width/2);
                cntRect.origin.y = ceilf(self.displayCenter.y - cntRect.size.height/2);
                break;
        }
    }
    self.contentView.frame = cntRect;
    
    //布局元素位置
    [self layoutactivitySize:actSize textSize:txtSize bounds:self.contentView.bounds position:position];
}

@end

#pragma mark toast 拓展实现
@implementation SSNToast (Convenient)

+ (instancetype)showProgressLoading:(NSString *)loading {
    SSNToast *toast = [SSNToast toastWithTarget:nil message:loading activityIndicator:YES];
    [toast show];
    return toast;
}

+ (instancetype)showTarget:(NSObject *)target progressLoading:(NSString *)loading {
    SSNToast *toast = [SSNToast toastWithTarget:target message:loading activityIndicator:YES];
    [toast show];
    return toast;
}

+ (instancetype)awhileToastMessage:(NSString *)message {
    SSNToast *toast = [SSNToast toastWithTarget:nil message:message activityIndicator:NO];
    [toast show];
    [toast hideAnimated:YES afterDelay:1];
    return toast;
}

+ (instancetype)showToastMessage:(NSString *)message {
    SSNToast *toast = [SSNToast toastWithTarget:nil message:message activityIndicator:NO];
    [toast show];
    return toast;
}

#pragma mark 黄金分割点
#define toast_golden_ratio 0.618f
+ (CGPoint)goldenSectionPoint {
    static CGPoint point;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect bounds = [UIScreen mainScreen].bounds;
        point = CGPointMake(ceilf(bounds.size.width/2), ceilf(bounds.size.height * (1 - toast_golden_ratio)));
    });
    return point;
}

+ (instancetype)showProgressLoadingAtGoldenSection:(NSString *)loading {
    SSNToast *toast = [SSNToast toastWithTarget:nil message:loading activityIndicator:YES];
    toast.displayCenter = [self goldenSectionPoint];
    [toast showForView:nil atPosition:SSNToastCustomPosition animation:SSNToastAnimationFade];
    return toast;
}

/**
 *  显示一个居中加载等待菊花
 *
 *  @param target  关联到某个对象上
 *  @param loading 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)showTarget:(NSObject *)target progressLoadingAtGoldenSection:(NSString *)loading {
    SSNToast *toast = [SSNToast toastWithTarget:target message:loading activityIndicator:YES];
    toast.displayCenter = [self goldenSectionPoint];
    [toast showForView:nil atPosition:SSNToastCustomPosition animation:SSNToastAnimationFade];
    return toast;
}

/**
 *  显示一秒钟的一个居中提示
 *
 *  @param message 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)awhileToastMessageAtGoldenSection:(NSString *)message {
    SSNToast *toast = [SSNToast toastWithTarget:nil message:message activityIndicator:NO];
    toast.displayCenter = [self goldenSectionPoint];
    [toast showForView:nil atPosition:SSNToastCustomPosition animation:SSNToastAnimationFade];
    [toast hideAnimated:YES afterDelay:1];
    return toast;
}

/**
 *  显示一个居中提示
 *
 *  @param message 提示内容
 *
 *  @return SSNToast实例
 */
+ (instancetype)showToastMessageAtGoldenSection:(NSString *)message {
    SSNToast *toast = [SSNToast toastWithTarget:nil message:message activityIndicator:NO];
    toast.displayCenter = [self goldenSectionPoint];
    [toast showForView:nil atPosition:SSNToastCustomPosition animation:SSNToastAnimationFade];
    return toast;
}

@end
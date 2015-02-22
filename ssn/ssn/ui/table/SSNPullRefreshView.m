//
//  SSNPullRefreshView.m
//  ssn
//
//  Created by lingminjun on 15/2/11.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNPullRefreshView.h"

@interface SSNPullRefreshView ()
{
    
    __weak id _delegate;
    
    UIScrollView *_scrollView;
    
    SSNPullRefreshState _state;
    
    NSString *_lastUpdatedTimestamp;
    
    UIImage *_arrowImage;
    
    UILabel *_lastUpdatedLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImageLayer;
    UIActivityIndicatorView *_activityView;
    
    BOOL _isLoading;
    
}

- (void)setState:(SSNPullRefreshState)aState;
@end

@implementation SSNPullRefreshView

@synthesize delegate=_delegate;

- (instancetype)initWithStyle:(SSNPullRefreshStyle)style delegate:(id<SSNPullRefreshDelegate>)delegate frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
        _delegate = delegate;
        _isLoading = NO;
        
        self.backgroundColor = SSNPullRefreshBackgroudColor;
        
        self.arrowImage = SSNPullRefreshArrowImage;
        
        CGFloat midY = frame.size.height - _arrowImage.size.height/2;
        if (_style == SSNPullRefreshFooterLoadMore) {
            midY = _arrowImage.size.height/2;
        }
        
        if (_style == SSNPullRefreshHeaderRefresh) {
            /* Config Last Updated Label */
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY, self.frame.size.width, 20.0f)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont systemFontOfSize:12.0f];
            label.textColor = SSNPullRefreshTextColor;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            _lastUpdatedLabel=label;
        }
        
        /* Config Status Updated Label */
        CGFloat status_y = midY - 18;
        if (_style == SSNPullRefreshFooterLoadMore) {
            status_y = midY - 10;
        }
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, status_y, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textColor = SSNPullRefreshTextColor;
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _statusLabel=label;
        
        /* Config Arrow Image */
        CGFloat layer_y = midY - 35;
        if (_style == SSNPullRefreshFooterLoadMore) {
            layer_y = midY - 20;
        }
        CALayer *layer = [[CALayer alloc] init];
        layer.frame = CGRectMake(25.0f,layer_y, 30.0f, 55.0f);
        layer.contentsGravity = kCAGravityResizeAspect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
#endif
        [[self layer] addSublayer:layer];
        _arrowImageLayer=layer;
         _arrowImageLayer.contents = (id)(self.arrowImage.CGImage);
        
        
        /* Config activity indicator */
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:SSNPullRefreshActivityIndicatorStyle];
        view.frame = CGRectMake(25.0f,midY - 8, 20.0f, 20.0f);
        [self addSubview:view];
        _activityView = view;
        
        [self setState:SSNPullRefreshNarmal];
        
        [self refreshLastUpdatedDate];
    }
    
    return self;
}

- (instancetype)initWithStyle:(SSNPullRefreshStyle)style delegate:(id<SSNPullRefreshDelegate>)delegate {
    CGRect frame = CGRectZero;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    if (style == SSNPullRefreshHeaderRefresh) {
        frame.origin.y = -([UIScreen mainScreen].bounds.size.height);
        frame.size.height = [UIScreen mainScreen].bounds.size.height;
    }
    else {
        frame.size.height = 44;
    }
    
    return [self initWithStyle:style delegate:delegate frame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithStyle:SSNPullRefreshHeaderRefresh delegate:nil frame:frame];
}

- (UIScrollView *)scrollView {
    if (_scrollView) {
        return _scrollView;
    }
    
    UIView *supview = self.superview;
    if ([supview isKindOfClass:[UIScrollView class]]) {
        _scrollView = (UIScrollView *)supview;
    }
    else {//取不到算了
    }
    return _scrollView;
}

- (BOOL)isLoading {
    return _isLoading;
}

#pragma mark -
#pragma mark Setters

@dynamic textColor;
- (UIColor *)textColor {
    return _lastUpdatedLabel.textColor;
}
- (void)setTextColor:(UIColor *)textColor {
    _lastUpdatedLabel.textColor = textColor;
    _statusLabel.textColor = textColor;
}

@synthesize arrowImage = _arrowImage;
- (void)setArrowImage:(UIImage *)arrowImage {
    _arrowImage = arrowImage ? arrowImage : SSNPullRefreshArrowImage;
    _arrowImageLayer.contents = (id)(_arrowImage.CGImage);
}

- (void)refreshLastUpdatedDate {
    NSInteger img_height = _arrowImage.size.height;
    
    NSString *string = _lastUpdatedTimestamp;
    if ([_delegate respondsToSelector:@selector(ssn_pullRefreshViewLastUpdatedCopywriting:)]) {
        string = [_delegate ssn_pullRefreshViewLastUpdatedCopywriting:self];
    }
    _lastUpdatedLabel.text = string;
        
    // Center the status label if the lastupdate is not available
    CGFloat midY = self.frame.size.height - img_height/2;
    if(![_lastUpdatedLabel.text length]) {
        _statusLabel.frame = CGRectMake(0.0f, midY - 8, self.frame.size.width, 20.0f);
    } else {
        _statusLabel.frame = CGRectMake(0.0f, midY - 18, self.frame.size.width, 20.0f);
    }
    
}

- (void)setState:(SSNPullRefreshState)aState{
    
    switch (aState) {
        case SSNPullRefreshPulling:
            
            if (_style == SSNPullRefreshHeaderRefresh) {
                _statusLabel.text = SSNPullRefreshHeaderPullingCopywriting;
            }
            else {
                _statusLabel.text = SSNPullRefreshFooterPullingCopywriting;
            }
            [CATransaction begin];
            [CATransaction setAnimationDuration:SSNPullRefreshAnimationDuration];
            _arrowImageLayer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];
            
            break;
        case SSNPullRefreshNarmal:
            
            if (_state == SSNPullRefreshPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:SSNPullRefreshAnimationDuration];
                _arrowImageLayer.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            
            if (_style == SSNPullRefreshHeaderRefresh) {
                _statusLabel.text = SSNPullRefreshHeaderNarmalCopywriting;
            }
            else {
                _statusLabel.text = SSNPullRefreshFooterNarmalCopywriting;
            }
            
            [_activityView stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImageLayer.hidden = NO;
            _arrowImageLayer.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            [self refreshLastUpdatedDate];
            
            break;
        case SSNPullRefreshLoading:
            
            if (_style == SSNPullRefreshHeaderRefresh) {
                _statusLabel.text = SSNPullRefreshHeaderLoadingCopywriting;
            }
            else {
                _statusLabel.text = SSNPullRefreshFooterLoadingCopywriting;
            }
            
            [_activityView startAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImageLayer.hidden = YES;
            [CATransaction commit];
            
            break;
        default:
            break;
    }
    
    _state = aState;
}

#pragma mark - 私有方法
#pragma mark - Util
- (CGFloat)scrollViewOffsetFromBottom:(UIScrollView *) scrollView
{
    CGFloat scrollAreaContenHeight = scrollView.contentSize.height;
    
    CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollAreaContenHeight);
    CGFloat scrolledDistance = scrollView.contentOffset.y + visibleTableHeight; // If scrolled all the way down this should add upp to the content heigh.
    
    CGFloat normalizedOffset = scrollAreaContenHeight -scrolledDistance;
    
    return normalizedOffset;
    
}

- (CGFloat)visibleTableHeightDiffWithBoundsHeight:(UIScrollView *) scrollView
{
    return (scrollView.bounds.size.height - MIN(scrollView.bounds.size.height, scrollView.contentSize.height));
}

- (CGFloat)valveOffsetWithScrollView:(UIScrollView *) scrollView {
    CGFloat valve_offset = 0;
    if (_style == SSNPullRefreshHeaderRefresh) {
        valve_offset = scrollView.contentOffset.y;
    }
    else {
        valve_offset = [self scrollViewOffsetFromBottom:scrollView];
    }
    return valve_offset;
}

- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView {
    _isLoading = YES;
    
    NSInteger img_height = _arrowImage.size.height;
    NSInteger trigger_height = img_height + 5;
    
    [self setState:SSNPullRefreshLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    if (_style == SSNPullRefreshHeaderRefresh) {
        currentInsets.top = img_height;
    }
    else {
        currentInsets.bottom = img_height + [self visibleTableHeightDiffWithBoundsHeight:scrollView];
    }
    scrollView.contentInset = currentInsets;
    [UIView commitAnimations];
    
    if (_style == SSNPullRefreshHeaderRefresh) {
        if(scrollView.contentOffset.y == 0){
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -trigger_height) animated:YES];
        }
    }
    else {
        if([self scrollViewOffsetFromBottom:scrollView] == 0){
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + trigger_height) animated:YES];
        }
    }
}
#pragma mark -
#pragma mark ScrollView Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIScrollView *scl = [self scrollView];
    if (scrollView != scl) {
        return ;
    }
    
    CGFloat img_height = _arrowImage.size.height;
    CGFloat trigger_height = img_height + 5;
    
    //计算其实offset
    CGFloat valve_offset = [self valveOffsetWithScrollView:scrollView];
    
    //开始计算动作
    if (_state == SSNPullRefreshLoading) {
        
        CGFloat offset = MAX(valve_offset * -1, 0);
        offset = MIN(offset, img_height);
        UIEdgeInsets currentInsets = scrollView.contentInset;
        
        if (_style == SSNPullRefreshHeaderRefresh) {
            currentInsets.top = offset;
        }
        else {
            currentInsets.bottom = offset? offset + [self visibleTableHeightDiffWithBoundsHeight:scrollView]: 0;
        }
        
        scrollView.contentInset = currentInsets;
        
    }
    else if (scrollView.isDragging) {
        
        if (_state == SSNPullRefreshPulling && valve_offset > -trigger_height && valve_offset < 0.0f && !_isLoading) {
            [self setState:SSNPullRefreshNarmal];
        } else if (_state == SSNPullRefreshNarmal && valve_offset < -trigger_height && !_isLoading) {
            [self setState:SSNPullRefreshPulling];
        }
        
        UIEdgeInsets currentInsets = scrollView.contentInset;
        if (_style == SSNPullRefreshHeaderRefresh) {
            if (currentInsets.top != 0) {
                currentInsets.top = 0;
            }
        }
        else {
            if (currentInsets.bottom != 0) {
                currentInsets.bottom = 0;
            }
        }
        scrollView.contentInset = currentInsets;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    UIScrollView *scl = [self scrollView];
    if (scrollView != scl) {
        return ;
    }
    
    CGFloat img_height = _arrowImage.size.height;
    CGFloat trigger_height = img_height + 5;
    
    //计算其实offset
    CGFloat valve_offset = [self valveOffsetWithScrollView:scrollView];
    
    if (valve_offset <= - trigger_height && !_isLoading) {
        if ([_delegate respondsToSelector:@selector(ssn_pullRefreshViewDidTriggerRefresh:)]) {
            [_delegate ssn_pullRefreshViewDidTriggerRefresh:self];
        }
        [self startAnimatingWithScrollView:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UIScrollView *scl = [self scrollView];
    if (scrollView != scl) {
        return ;
    }
    
    if (_style == SSNPullRefreshHeaderRefresh) {
        [self refreshLastUpdatedDate];
    }
}

- (void)finishedLoading {	
    
    _isLoading = NO;
    
    UIScrollView *scrollView = [self scrollView];
    
    if (scrollView) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        UIEdgeInsets currentInsets = scrollView.contentInset;
        if (_style == SSNPullRefreshHeaderRefresh) {
            currentInsets.top = 0;
        }
        else {
            currentInsets.bottom = 0;
        }
        scrollView.contentInset = currentInsets;
        [UIView commitAnimations];
        
    }
    
    [self setState:SSNPullRefreshNarmal];
}

@end

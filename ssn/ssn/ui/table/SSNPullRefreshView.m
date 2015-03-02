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
    
    __weak id<SSNPullRefreshDelegate> _delegate;
    
    __weak UIScrollView *_scrollView;
    
    SSNPullRefreshState _state;
    
    NSDate *_lastUpdatedTimestamp;
    
    UIImage *_arrowImage;
    
    UIView *_contentView;
    
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
        
        if (_style == SSNPullRefreshHeaderRefresh) {
            _triggerHeight = SSNPullRefreshHeaderTriggerHeight;
        }
        else {
            _triggerHeight = SSNPullRefreshFooterTriggerHeight;
        }
        
        self.backgroundColor = SSNPullRefreshBackgroudColor;
        self.arrowImage = SSNPullRefreshArrowImage;
        
        //展示区域
        if (_style == SSNPullRefreshHeaderRefresh) {
            _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - _triggerHeight, frame.size.width, _triggerHeight)];
            _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        }
        else {
            _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, _triggerHeight)];
            _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
        [self addSubview:_contentView];
        
        
        CGRect content_frame = _contentView.bounds;
        CGFloat status_label_height = 20.0f;
        CGFloat date_label_height = 20.0f;
        CGFloat label_space_height = SSNPullRefreshLabelSpaceHeight;
        
        CGFloat label_sum_height = date_label_height + label_space_height + status_label_height;
        if (_style == SSNPullRefreshFooterLoadMore) {//load more 只有一个文案需要显示
            date_label_height = 0;
            label_space_height = 0;
            label_sum_height = date_label_height + label_space_height + status_label_height;
        }
        
        /* Config Status Updated Label */
        CGFloat status_label_y = (content_frame.size.height-label_sum_height)/2;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, status_label_y, content_frame.size.width, status_label_height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textColor = SSNPullRefreshTextColor;
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:label];
        _statusLabel=label;
        
        if (_style == SSNPullRefreshHeaderRefresh) {
            /* Config Last Updated Label */
            CGFloat date_label_y = (content_frame.size.height-label_sum_height)/2 + label_space_height + status_label_height;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, date_label_y, content_frame.size.width, date_label_height)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont systemFontOfSize:12.0f];
            label.textColor = SSNPullRefreshTextColor;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            [_contentView addSubview:label];
            _lastUpdatedLabel=label;
        }
        
        /* Config Arrow Image */
        CGSize image_size = self.arrowImage.size;
        CALayer *layer = [[CALayer alloc] init];
        layer.frame = CGRectMake(25.0f,(content_frame.size.height - image_size.height)/2, image_size.width, image_size.height);
        layer.contentsGravity = kCAGravityResizeAspect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
#endif
        [[_contentView layer] addSublayer:layer];
        _arrowImageLayer=layer;
        _arrowImageLayer.contents = (id)(self.arrowImage.CGImage);
        
        
        /* Config activity indicator */
        CGSize activity_size = CGSizeMake(20, 20);
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:SSNPullRefreshActivityIndicatorStyle];
        view.frame = CGRectMake(25.0f,(content_frame.size.height - activity_size.height)/2, activity_size.width, activity_size.height);
        [_contentView addSubview:view];
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
    
    NSString *string = nil;
    if ([_delegate respondsToSelector:@selector(ssn_pullRefreshView:copywritingAtLatestUpdatedTime:)]) {
        string = [_delegate ssn_pullRefreshView:self copywritingAtLatestUpdatedTime:_lastUpdatedTimestamp];
    }
    else {
        if (_lastUpdatedTimestamp) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setAMSymbol:@"AM"];
//            [formatter setPMSymbol:@"PM"];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            string = [NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:_lastUpdatedTimestamp]];
        }
    }
    _lastUpdatedLabel.text = string;
        
    // Center the status label if the lastupdate is not available
    if (_style == SSNPullRefreshHeaderRefresh) {
        
        CGRect content_frame = _contentView.bounds;
        CGFloat status_label_height = _statusLabel.frame.size.height;
        CGFloat date_label_height = _lastUpdatedLabel.frame.size.height;
        CGFloat label_space_height = SSNPullRefreshLabelSpaceHeight;
        CGFloat label_sum_height = date_label_height + label_space_height + status_label_height;
        CGFloat status_label_y = (content_frame.size.height-label_sum_height)/2;
        
        if([_lastUpdatedLabel.text length] > 0) {
            status_label_y = (content_frame.size.height-label_sum_height)/2;
        } else {
            status_label_y = (content_frame.size.height-status_label_height)/2;
        }
        _statusLabel.frame = CGRectMake(0.0f, status_label_y, _statusLabel.frame.size.width, status_label_height);
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
            if (_style == SSNPullRefreshHeaderRefresh) {
                _arrowImageLayer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            }
            else {
                _arrowImageLayer.transform = CATransform3DIdentity;
            }
            [CATransaction commit];
            
            break;
        case SSNPullRefreshNarmal:
            
            if (_state == SSNPullRefreshPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:SSNPullRefreshAnimationDuration];
                if (_style == SSNPullRefreshHeaderRefresh) {
                    _arrowImageLayer.transform = CATransform3DIdentity;
                }
                else {
                    _arrowImageLayer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                }
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
            if (_style == SSNPullRefreshHeaderRefresh) {
                _arrowImageLayer.transform = CATransform3DIdentity;
            }
            else {
                _arrowImageLayer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            }
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
    CGFloat scrollAreaContenHeight = scrollView.contentSize.height - _startOffset;
    
    CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollAreaContenHeight);
    CGFloat scrolledDistance = scrollView.contentOffset.y + visibleTableHeight; // If scrolled all the way down this should add upp to the content heigh.
    
    CGFloat normalizedOffset = scrollAreaContenHeight -scrolledDistance;
    
    return normalizedOffset;
    
}

- (CGFloat)visibleTableHeightDiffWithBoundsHeight:(UIScrollView *) scrollView
{
    CGFloat scrollAreaContenHeight = scrollView.contentSize.height - _startOffset;
    CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollAreaContenHeight);
    return visibleTableHeight;
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
    
    NSInteger trigger_height = _triggerHeight + _startOffset;
    
    [self setState:SSNPullRefreshLoading];
    
    if (_style == SSNPullRefreshHeaderRefresh) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        UIEdgeInsets currentInsets = scrollView.contentInset;
        if (_style == SSNPullRefreshHeaderRefresh) {
            currentInsets.top = trigger_height;
        }
        scrollView.contentInset = currentInsets;
        [UIView commitAnimations];
        
        if(scrollView.contentOffset.y != -trigger_height){
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -trigger_height) animated:YES];
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
    //第一次取_crollview时需要找到偏移值
    if (_startOffset == 0) {
        if (_style == SSNPullRefreshHeaderRefresh) {
            _startOffset = scl.contentInset.top;
        }
        else {
            _startOffset = scl.contentInset.bottom;
        }
    }
    
    CGFloat trigger_height = _triggerHeight + _startOffset;
    
    //计算其实offset
    CGFloat valve_offset = [self valveOffsetWithScrollView:scrollView];
    
    //开始计算动作
    if (_state == SSNPullRefreshLoading) {
        
    }
    else if (scrollView.isDragging) {
        
        if (_state == SSNPullRefreshPulling && valve_offset > - trigger_height && valve_offset < 0.0f && !_isLoading) {
            [self setState:SSNPullRefreshNarmal];
        } else if (_state == SSNPullRefreshNarmal && valve_offset < -trigger_height && !_isLoading) {
            [self setState:SSNPullRefreshPulling];
        }
        
        
        if (_style == SSNPullRefreshHeaderRefresh) {
            UIEdgeInsets currentInsets = scrollView.contentInset;
            if (currentInsets.top != _startOffset) {
                currentInsets.top = _startOffset;
            }
            scrollView.contentInset = currentInsets;
        }
        else {//footer 不需要处理contentInset
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    UIScrollView *scl = [self scrollView];
    if (scrollView != scl) {
        return ;
    }
    
    CGFloat trigger_height = _triggerHeight + _startOffset;
    
    //计算其实offset
    CGFloat valve_offset = [self valveOffsetWithScrollView:scrollView];
    
    if (valve_offset <= - trigger_height && !_isLoading) {
        
        if ([_delegate respondsToSelector:@selector(ssn_pullRefreshViewDidTriggerRefresh:)]) {
            //先开启动画
            [self startAnimatingWithScrollView:scrollView];
            
            [_delegate ssn_pullRefreshViewDidTriggerRefresh:self];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    UIScrollView *scl = [self scrollView];
    if (scrollView != scl) {
        return ;
    }
    
    if (_style == SSNPullRefreshFooterLoadMore) {//因为是在foot view上，所以尽量不要显示
        CGFloat trigger_height = _triggerHeight + _startOffset;
        
        //计算其实offset
        CGFloat valve_offset = [self valveOffsetWithScrollView:scrollView];
        
        if (valve_offset <= - trigger_height && !_isLoading) {
            
            if ([_delegate respondsToSelector:@selector(ssn_pullRefreshViewDidTriggerRefresh:)]) {
                //先开启动画
                [self startAnimatingWithScrollView:scrollView];
                
                [_delegate ssn_pullRefreshViewDidTriggerRefresh:self];
            }
        }
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
    
    if (_isLoading) {
        _lastUpdatedTimestamp = [NSDate date];
    }
    
    _isLoading = NO;
    
    UIScrollView *scrollView = [self scrollView];
    
    if (scrollView) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        UIEdgeInsets currentInsets = scrollView.contentInset;
        if (_style == SSNPullRefreshHeaderRefresh) {
            currentInsets.top = _startOffset;
        }
        else {
            currentInsets.bottom = _startOffset;
        }
        scrollView.contentInset = currentInsets;
        [UIView commitAnimations];
        
    }
    
    [self setState:SSNPullRefreshNarmal];
    
    if (_style == SSNPullRefreshHeaderRefresh) {
        if(scrollView.contentOffset.y != -_startOffset){
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -_startOffset) animated:YES];
        }
    }
    else {
        if([self scrollViewOffsetFromBottom:scrollView] != _startOffset){
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + _startOffset) animated:YES];
        }
    }
}

@end

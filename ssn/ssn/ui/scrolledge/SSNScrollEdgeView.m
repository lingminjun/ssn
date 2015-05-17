//
//  SSNScrollEdgeView.m
//  ssn
//
//  Created by lingminjun on 15/5/9.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNScrollEdgeView.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

static char * ssn_scroll_edge_view_key = NULL;

@interface SSNScrollEdgeView ()
{
    __weak id<SSNScrollEdgeViewDelegate> _delegate;
    __unsafe_unretained UIScrollView *_scrollView;
    __unsafe_unretained UIView<SSNScrollEdgeContentView> *_contentSubview;
    BOOL _canRespondPullingSelector;//是否能够响应-scrollEdgeView:didPullingWithStretchForce:方法
    
    SSNScrollEdgeState _state;
    
    UIImageView *_backgroudImageView;
    
    UIView *_damBoard;//挡板
    UIView *_contentPanel;//呈现动画的view
    
    BOOL _isLoading;
    
    CGFloat _startOffset;
    
    BOOL _prevScrollViewDragging;//记录ScrollView上一次是否为拖拽
}
@end

@implementation SSNScrollEdgeView

@synthesize delegate=_delegate;

- (void)setTriggerHeight:(CGFloat)triggerHeight {
    if (triggerHeight < 20) {
        triggerHeight = 20;
    }
    _triggerHeight = triggerHeight;
    
    //底部始终保持 triggerHeight 与 height相同
    if (_isBottomEdge) {
        CGRect frame = self.frame;
        frame.size.height = triggerHeight;
        self.frame = frame;
    }
    else {
        CGRect frame = _contentPanel.frame;
        frame.size.height = triggerHeight;
        frame.origin.y = self.bounds.size.height - triggerHeight;
        _contentPanel.frame = frame;
    }
}

- (void)setFrame:(CGRect)frame {
    //不允许修改宽度和x值，高度和垂直位置可以调整
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    frame.origin.x = 0;
    
    //最小高度不能小于触发值
    if (frame.size.height <= _triggerHeight) {
        frame.size.height = _triggerHeight;
    }
    
    //放在scroll底部，_triggerHeight始终等于frame.size.height
    if (_isBottomEdge) {
        _triggerHeight = frame.size.height;
    }
    
    [super setFrame:frame];
}

- (void)setIsBottomEdge:(BOOL)isBottomEdge {
    if (isBottomEdge == _isBottomEdge) {
        return ;
    }
    
    _isBottomEdge = isBottomEdge;
    
    //设置为scroll bottom 时，content必须填充整个view，view的大小瞬间调整成triggerHeight高度
    if (isBottomEdge) {
        _contentPanel.frame = self.bounds;
        _contentPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        CGRect frame = self.frame;
        frame.size.height = _triggerHeight;
        self.frame = frame;
        
        _damBoard.hidden = YES;
    }
    else {//默认给屏幕高度
        CGRect frame = self.frame;
        frame.size.height = [UIScreen mainScreen].bounds.size.height;
        frame.origin.y = -frame.size.height;
        self.frame = frame;
        
        frame = _contentPanel.frame;
        frame.size.height = _triggerHeight;
        frame.origin.y = self.bounds.size.height - _triggerHeight;
        _contentPanel.frame = frame;
        _contentPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        
        _damBoard.hidden = NO;
    }
}

//忽略外面设置的大小
- (instancetype)initWithFrame:(CGRect)aframe {
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, aframe.size.height);
    if (frame.size.height == 0) {
        frame.size.height = [UIScreen mainScreen].bounds.size.height;
    }
    else if (frame.size.height < 20) {
        frame.size.height = 20;
    }
    self = [super initWithFrame:frame];
    if (self) {
        _isLoading = NO;
        if (frame.size.height > 60) {
            _triggerHeight = 60;
        }
        else {
            _triggerHeight = frame.size.height;
        }
        self.backgroundColor = [UIColor clearColor];
        
        _backgroudImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroudImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroudImageView];
        
        //展示区域
        _contentPanel = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - _triggerHeight, frame.size.width, _triggerHeight)];
        _contentPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_contentPanel];
        
        //挡板
        _damBoard = [[UIView alloc] initWithFrame:self.bounds];
        _damBoard.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _damBoard.backgroundColor = [UIColor clearColor];
        [self addSubview:_damBoard];
        
        _state = SSNScrollEdgeStill;
    }
    
    return self;
}

- (void)dealloc {
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
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

/**
 *  依赖的scrollview
 *
 *  @return 返回正在作用的scrollView
 */
- (UIScrollView *)contextScrollView {
    return [self scrollView];
}

- (void)removeFromSuperview {
    UIScrollView *scrollView = [self scrollView];
    if (scrollView) {
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
        _scrollView = nil;
    }
    
    [super removeFromSuperview];
}

/**
 *  将其安装到scrollview上
 *
 *  @param scrollView 依赖的scrollview，非空
 */
- (void)installToScrollView:(UIScrollView *)scrollView {
    if (scrollView == nil) {
        return ;
    }
    
    if (_scrollView == scrollView) {
        return ;
    }
    
    if (_scrollView) {
        objc_setAssociatedObject(_scrollView, &(ssn_scroll_edge_view_key),nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
        _scrollView = nil;
    }
    
    //挡板颜色
    if (scrollView.backgroundColor == nil || [scrollView.backgroundColor isEqual:[UIColor clearColor]]) {
        _damBoard.backgroundColor = scrollView.superview.backgroundColor;
    }
    else {
        _damBoard.backgroundColor = scrollView.backgroundColor;
    }
    
    //记录起始位置
    if (_isBottomEdge) {
        _startOffset = scrollView.contentInset.bottom;
    }
    else {
        _startOffset = scrollView.contentInset.top;
    }
    
    //将对象保存至scrollView
    objc_setAssociatedObject(scrollView, &(ssn_scroll_edge_view_key),self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //放置位置
    if (_isBottomEdge) {
        CGRect frame = self.frame;
        frame.origin.x = 0;
        frame.origin.y = MAX(scrollView.frame.size.height, scrollView.contentSize.height);
        self.frame = frame;
        [scrollView addSubview:self];

    }
    else {
        CGRect frame = self.frame;
        frame.origin.x = 0;
        frame.origin.y = -([UIScreen mainScreen].bounds.size.height);
        self.frame = frame;
        [scrollView addSubview:self];
    }
    
    //监听变化
    _scrollView = scrollView;
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

/**
 *  设置内容view
 *
 *  @param subview 设置可以展示view
 */
@dynamic contentView;
- (void)setContentView:(UIView<SSNScrollEdgeContentView> *)subview {
    if (!subview) {
        return ;
    }
    
    if (_contentSubview == subview) {
        return ;
    }
    
    if (_contentSubview) {
        [_contentSubview removeFromSuperview];
    }
    
    subview.frame = _contentPanel.bounds;
    subview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_contentPanel addSubview:subview];
    _contentSubview = subview;
    
    //
    _canRespondPullingSelector = [subview respondsToSelector:@selector(scrollEdgeView:didPullingWithStretchForce:)];
}
- (UIView<SSNScrollEdgeContentView> *)contentView {
    return _contentSubview;
}

#pragma mark kvo
- (CGFloat)valveOffsetWithScrollView:(UIScrollView *)scrollView {
    if (_isBottomEdge) {
        CGFloat scrollAreaContenHeight = scrollView.contentSize.height - _startOffset;
        
        CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollAreaContenHeight);
        CGFloat scrolledDistance = scrollView.contentOffset.y + visibleTableHeight; // If scrolled all the way down this should add upp to the content heigh.
        
        CGFloat normalizedOffset = scrollAreaContenHeight -scrolledDistance;
        return normalizedOffset;
    }
    else {
        return scrollView.contentOffset.y;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UIScrollView *scl = [self scrollView];
    if (object != scl) {
        [object removeObserver:self forKeyPath:keyPath];
        return ;
    }
    
    if (_disabled) {
        return ;
    }
    
    //第一次取_crollview时需要找到偏移值
    if (_startOffset == 0 && _state != SSNScrollEdgeLoading) {
        if (_isBottomEdge) {
            _startOffset = scl.contentInset.bottom;
        }
        else {
            _startOffset = scl.contentInset.top;
        }
    }
    
    CGFloat trigger_height = _triggerHeight + _startOffset;
    
    //计算其实offset
    CGFloat valve_offset = [self valveOffsetWithScrollView:scl];
    
    //header遮罩调整
    if (!_isBottomEdge) {
        if (-valve_offset >= _startOffset) {
            CGRect aframe = _damBoard.frame;
            aframe.size.height = self.bounds.size.height + _startOffset + valve_offset;
            _damBoard.frame = aframe;
        }
        else {
            CGRect aframe = _damBoard.frame;
            aframe.size.height = self.bounds.size.height;
            _damBoard.frame = aframe;
        }
    }
    
    //记录拖拽
    BOOL isDragging = (scl.isDragging || scl.isTracking);
    
    //说明手指不在拖拽
    BOOL stopDragging = NO;
    if (!isDragging && _prevScrollViewDragging) {
        stopDragging = YES;
    }
    _prevScrollViewDragging = isDragging;
    
    //触发阀值逻辑判断
    if (stopDragging && valve_offset <= - trigger_height && !_isLoading) {
        
        //将状态转化成加载
        _isLoading = YES;
        _state = SSNScrollEdgeLoading;
        
        if (!_isBottomEdge) {
            //让scrollView平滑滚动
            [UIView beginAnimations:@"changed_inset" context:NULL];
            [UIView setAnimationDuration:0.2];
            UIEdgeInsets currentInsets = scl.contentInset;
            currentInsets.top = trigger_height;
            scl.contentInset = currentInsets;
            [UIView commitAnimations];
        }
        
        //动画将要开始
        [_contentSubview scrollEdgeViewWillTrigger:self];
        
        //委托回调
        if ([_delegate respondsToSelector:@selector(ssn_scrollEdgeViewDidTrigger:)]) {
            [_delegate ssn_scrollEdgeViewDidTrigger:self];
        }
        
        //让scrollView平滑滚动
        if(!_isBottomEdge && scl.contentOffset.y != -trigger_height){
            [scl setContentOffset:CGPointMake(scl.contentOffset.x, -trigger_height) animated:YES];
        }
    }
    
    //开始计算动作
    if (scl.isDragging && _state != SSNScrollEdgeLoading) {
        
        if (_state == SSNScrollEdgePulling && valve_offset > - trigger_height && valve_offset < 0.0f && !_isLoading) {
            _state = SSNScrollEdgeStill;
            [_contentSubview scrollEdgeViewDidFinish:self];
        } else if (_state == SSNScrollEdgeStill && valve_offset < -trigger_height && !_isLoading) {
            _state = SSNScrollEdgePulling;
            [_contentSubview scrollEdgeViewWillDragging:self];
        }
        
        //还原到原点
        UIEdgeInsets currentInsets = scl.contentInset;
        if (_isBottomEdge) {
            if (currentInsets.bottom != _startOffset) {
                currentInsets.bottom = _startOffset;
            }
        }
        else {
            if (currentInsets.top != _startOffset) {
                currentInsets.top = _startOffset;
            }
        }
        scl.contentInset = currentInsets;
    }
    
    //计算拖拽力度回调
    if (isDragging && _canRespondPullingSelector && -valve_offset >= _startOffset) {
        CGFloat force = 0.0;
        if (_isBottomEdge) {//若为底部，一般自己出现的高度要算在内（因为是在edge.bottom上面，即contentSize内部）
            force = -(valve_offset + _startOffset)/([UIScreen mainScreen].bounds.size.height - _startOffset);
        }
        else {
            force = -(valve_offset)/([UIScreen mainScreen].bounds.size.height - _startOffset);
        }
        [_contentSubview scrollEdgeView:self didPullingWithStretchForce:force];
    }
    
    //不在loading过程，不需要记录start,因为不能确定每次拉取动画_startOffset都是一样的
    if (_state == SSNScrollEdgeStill) {
        _startOffset = 0;
    }
}


- (void)finishedLoading {
    
    if (!_isLoading) {
        return ;
    }
    
    _isLoading = NO;
    
    UIScrollView *scl = [self scrollView];
    if (!scl) {
        return ;
    }
    
    //将_startOffset清零，因为不能确定每次动画_startOffset都是一样的
    const CGFloat startOffset = _startOffset;
    _startOffset = 0;
    _state = SSNScrollEdgeStill;
    
    if (!_isBottomEdge) {
        //修改offset
        [UIView beginAnimations:@"changed_inset" context:NULL];
        [UIView setAnimationDuration:0.3f];
        UIEdgeInsets currentInsets = scl.contentInset;
        currentInsets.top = startOffset;
        scl.contentInset = currentInsets;
        [UIView commitAnimations];
    }
    
    
    
    //显示内容回调
    [_contentSubview scrollEdgeViewDidFinish:self];
    
    //内容平滑滚动
    if(!_isBottomEdge && scl.contentOffset.y != -startOffset){
        [scl setContentOffset:CGPointMake(scl.contentOffset.x, -startOffset) animated:YES];
    }
}


@end

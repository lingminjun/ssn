//
//  SSNScrollHeader.m
//  ssn
//
//  Created by lingminjun on 15/5/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNScrollHeader.h"

@interface SSNScrollHeader ()
{
    
    __weak id<SSNScrollHeaderDelegate> _delegate;
    __unsafe_unretained UIScrollView *_scrollView;
    __unsafe_unretained UIView<SSNScrollHeaderContentView> *_contentSubview;
    
    SSNScrollHeaderState _state;
    
    UIImageView *_backgroudImageView;
    
    UIView *_damBoard;//挡板
    UIView *_contentView;//呈现动画的view
    
    BOOL _isLoading;
    
    CGFloat _startOffset;
    
    BOOL _prevScrollViewDragging;//记录ScrollView上一次是否为拖拽
}

@end

@implementation SSNScrollHeader

@synthesize delegate=_delegate;

- (void)setTriggerHeight:(CGFloat)triggerHeight {
    if (triggerHeight < 20) {
        triggerHeight = 20;
    }
    _triggerHeight = triggerHeight;
    
    CGRect frame = _contentView.frame;
    frame.size.height = triggerHeight;
    frame.origin.y = self.bounds.size.height - triggerHeight;
    _contentView.frame = frame;
}

- (void)setFrame:(CGRect)frame {
    //不允许改变frame
    frame.size = [UIScreen mainScreen].bounds.size;
    [super setFrame:frame];
}

//忽略外面设置的大小
- (instancetype)initWithFrame:(CGRect)aframe {
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        _isLoading = NO;
        _triggerHeight = 60;
        self.backgroundColor = [UIColor clearColor];
        
        _backgroudImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroudImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_backgroudImageView];
        
        //展示区域
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - _triggerHeight, frame.size.width, _triggerHeight)];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_contentView];
        
        //挡板
        _damBoard = [[UIView alloc] initWithFrame:self.bounds];
        _damBoard.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _damBoard.backgroundColor = [UIColor clearColor];
        [self addSubview:_damBoard];
        
        _state = SSNScrollHeaderStill;
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
    _startOffset = scrollView.contentInset.top;
    
    //放置位置
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = -([UIScreen mainScreen].bounds.size.height);
    self.frame = frame;
    [scrollView addSubview:self];
    
    //监听变化
    _scrollView = scrollView;
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

/**
 *  设置内容view
 *
 *  @param subview 设置可以展示view
 */
- (void)setContentViewClass:(UIView<SSNScrollHeaderContentView> *)subview {
    if (!subview) {
        return ;
    }
    
    if (_contentSubview == subview) {
        return ;
    }
    
    if (_contentSubview) {
        [_contentSubview removeFromSuperview];
    }
    
    subview.frame = _contentView.bounds;
    subview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_contentView addSubview:subview];
    _contentSubview = subview;
}

#pragma mark kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UIScrollView *scl = [self scrollView];
    if (object != scl) {
        [object removeObserver:self forKeyPath:keyPath];
        return ;
    }
    
    NSValue *chaned_new_value = [change objectForKey:NSKeyValueChangeNewKey];
    CGPoint contentOffset = [chaned_new_value CGPointValue];
    
    //第一次取_crollview时需要找到偏移值
    if (_startOffset == 0 && _state != SSNScrollHeaderLoading) {
        _startOffset = scl.contentInset.top;
    }
    
    CGFloat trigger_height = _triggerHeight + _startOffset;
    
    //计算其实offset
    CGFloat valve_offset = contentOffset.y;
    
    //header遮罩调整
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
        _state = SSNScrollHeaderLoading;
        
        //让scrollView平滑滚动
        [UIView beginAnimations:@"changed_inset" context:NULL];
        [UIView setAnimationDuration:0.2];
        UIEdgeInsets currentInsets = scl.contentInset;
        currentInsets.top = trigger_height;
        scl.contentInset = currentInsets;
        [UIView commitAnimations];
        
        //动画将要开始
        [_contentSubview scrollHeaderWillTrigger:self];
        
        //委托回调
        if ([_delegate respondsToSelector:@selector(ssn_scrollHeaderDidTrigger:)]) {
            [_delegate ssn_scrollHeaderDidTrigger:self];
        }
        
        //让scrollView平滑滚动
        if(scl.contentOffset.y != -trigger_height){
            [scl setContentOffset:CGPointMake(scl.contentOffset.x, -trigger_height) animated:YES];
        }
    }
    
    //开始计算动作
    if (scl.isDragging && _state != SSNScrollHeaderLoading) {
        
        if (_state == SSNScrollHeaderPulling && valve_offset > - trigger_height && valve_offset < 0.0f && !_isLoading) {
            _state = SSNScrollHeaderStill;
            [_contentSubview scrollHeaderDidFinish:self];
        } else if (_state == SSNScrollHeaderStill && valve_offset < -trigger_height && !_isLoading) {
            _state = SSNScrollHeaderPulling;
            [_contentSubview scrollHeaderWillDragging:self];
        }
        
        //还原到原点
        UIEdgeInsets currentInsets = scl.contentInset;
        if (currentInsets.top != _startOffset) {
            currentInsets.top = _startOffset;
        }
        scl.contentInset = currentInsets;
    }
    
    //计算拖拽力度回调
    if (isDragging) {
        CGFloat force = -(valve_offset)/([UIScreen mainScreen].bounds.size.height - _startOffset);
        [_contentSubview scrollHeader:self didPullingWithStretchForce:force];
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
    
    //修改offset
    [UIView beginAnimations:@"changed_inset" context:NULL];
    [UIView setAnimationDuration:0.3f];
    UIEdgeInsets currentInsets = scl.contentInset;
    currentInsets.top = _startOffset;
    scl.contentInset = currentInsets;
    [UIView commitAnimations];
    
    _state = SSNScrollHeaderStill;
    
    //显示内容回调
    [_contentSubview scrollHeaderDidFinish:self];
    
    //内容平滑滚动
    if(scl.contentOffset.y != -_startOffset){
        [scl setContentOffset:CGPointMake(scl.contentOffset.x, -_startOffset) animated:YES];
    }
}


@end

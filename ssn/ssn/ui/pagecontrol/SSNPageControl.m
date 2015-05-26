//
//  SSNPageControl.m
//  ssn
//
//  Created by lingminjun on 15/5/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNPageControl.h"

//#define T_LOG(fmt, ...)          NSLog((fmt), ##__VA_ARGS__)
#define T_LOG(fmt, ...)         ((void)0)

@interface SSNPageControl ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic) NSUInteger pageCount;

@property (nonatomic,strong) NSArray *panels;

@property (nonatomic) BOOL animating;//动画过程中

@property (nonatomic) CGFloat preOffset;

@property (nonatomic,strong) NSMutableIndexSet *passIndexs;

@end


@implementation SSNPageControl

/**
 *  唯一初始化方法
 *
 *  @param pageCount 也数
 *  @param pageWidth 宽度
 *
 *  @return 返回实例
 */
- (instancetype)initWithPageCount:(NSUInteger)pageCount {
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
    self = [super initWithFrame:frame];
    if (self) {
        
        _pageCount = pageCount;
        _selectedIndex = 0;
        
        _passIndexs = [NSMutableIndexSet indexSet];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.contentSize = CGSizeMake(pageCount * frame.size.width, frame.size.height);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:pageCount];
        for (NSInteger i = 0; i < pageCount; i++) {
            
            frame.origin.x = i*frame.size.width;
            
            UIView *panel = [[UIView alloc] initWithFrame:frame];
            [_scrollView addSubview:panel];
            [array addObject:panel];
        }
        
        _panels = array;
    }
    return self;
}

/**
 *  添加子view到page中
 *
 *  @param view  子view
 *  @param index 位置，越界忽略
 */
- (void)addView:(UIView *)view atIndex:(NSUInteger)index {
    if (index >= _pageCount) {
        return ;
    }
    
    UIView *panel = [_panels objectAtIndex:index];
    [panel addSubview:view];
}

/**
 *  越界忽略
 *
 *  @param index 位置
 */
- (void)removeViewsAtIndex:(NSUInteger)index {
    if (index >= _pageCount) {
        return ;
    }
    
    UIView *panel = [_panels objectAtIndex:index];
    NSArray *subviews = [panel subviews];
    
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
}

/**
 *  当前选中页所有子view
 *
 *  @param index 位置
 *
 *  @return 所有子view
 */
- (NSArray *)subviewsAtIndex:(NSUInteger)index {
    if (index >= _pageCount) {
        return nil;
    }
    
    UIView *panel = [_panels objectAtIndex:index];
    return [panel subviews];
}

- (void)setSelectedIndex:(NSUInteger)index
{
    [self selectIndex:index animated:NO];
}

/**
 *  选中某个页面
 *
 *  @param index    位置
 *  @param animated 是否要动画
 */
- (void)selectIndex:(NSInteger)index animated:(BOOL)animated {
    if (index >= _pageCount) {
        return ;
    }
    
    if (_selectedIndex == index) {
        return ;
    }
    
    UIView *panel = [_panels objectAtIndex:index];
    
    if ([_delegate respondsToSelector:@selector(ssn_control:willEnterPage:atIndex:)]) {
        [_delegate ssn_control:self willEnterPage:panel atIndex:index];
    }
    
    _animating = YES;
    T_LOG(@"%p标记动画开始3:%lud",self,(unsigned long)index);
    [_passIndexs removeAllIndexes];
    [_passIndexs addIndex:index];//当前页默认加入
    
    _selectedIndex = index;
    [_scrollView setContentOffset:CGPointMake(index*self.frame.size.width, 0) animated:animated];
    
    if (!animated) {
        if (_animating) {
            T_LOG(@"%p标记动画结束3:%lud",self,(unsigned long)_selectedIndex);
            
            _animating = NO;
            [_passIndexs removeAllIndexes];
            
            if ([_delegate respondsToSelector:@selector(ssn_control:didEnterPage:atIndex:)]) {
                [_delegate ssn_control:self didEnterPage:panel atIndex:index];
            }
        }
    }
    
}

- (void)layoutPanels {
    CGRect frame = self.bounds;
    CGFloat width = self.bounds.size.width;
    
    _scrollView.frame = frame;
    _scrollView.contentSize = CGSizeMake(_pageCount * width, frame.size.height);
    
    frame.size.width -= (_pageInsets.left + _pageInsets.right);
    frame.size.height -= (_pageInsets.top + _pageInsets.bottom);
    frame.origin.y += _pageInsets.top;
    for (NSInteger index = 0; index < _pageCount; index++) {
        frame.origin.x = index*width + _pageInsets.left;
        UIView *panel = [_panels objectAtIndex:index];
        panel.frame = frame;
    }
}

- (void)setPageInsets:(UIEdgeInsets)pageInsets {
    _pageInsets = pageInsets;
    [self layoutPanels];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self layoutPanels];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutPanels];
}

- (void)dealloc {
    _scrollView.delegate = nil;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        return ;
    }
    
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger pageIndex;
    if (offset > _preOffset) {
        pageIndex = ceilf(offset / self.frame.size.width);
    } else {
        pageIndex = floor(offset / self.frame.size.width);
    }
        
    pageIndex = MAX(0, pageIndex);
    pageIndex = MIN(pageIndex, _pageCount - 1);
    
    _preOffset = offset;
    
    if (!_animating) {
        T_LOG(@"%p标记动画开始1:%lud",self,(unsigned long)_selectedIndex);
        _animating = YES;
        [_passIndexs removeAllIndexes];
        [_passIndexs addIndex:_selectedIndex];//当前页默认加入
    }
    
    _selectedIndex = pageIndex;
    
    if (![_passIndexs containsIndex:pageIndex]) {
        UIView *panel = [_panels objectAtIndex:pageIndex];
        if ([_delegate respondsToSelector:@selector(ssn_control:willEnterPage:atIndex:)]) {
            [_delegate ssn_control:self willEnterPage:panel atIndex:pageIndex];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        return ;
    }
    
    if (!_animating) {
        T_LOG(@"%p标记动画开始2:%lud",self,(unsigned long)_selectedIndex);
        _animating = YES;
        [_passIndexs removeAllIndexes];
        [_passIndexs addIndex:_selectedIndex];//当前页默认加入
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        return ;
    }
    
    if (_animating) {
        T_LOG(@"%p标记动画结束1:%lud",self,(unsigned long)_selectedIndex);
        _animating = NO;
        [_passIndexs removeAllIndexes];
        [_passIndexs addIndex:_selectedIndex];//当前页默认加入
        
        UIView *panel = [_panels objectAtIndex:_selectedIndex];
        if ([_delegate respondsToSelector:@selector(ssn_control:didEnterPage:atIndex:)]) {
            [_delegate ssn_control:self didEnterPage:panel atIndex:_selectedIndex];
        }
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        return ;
    }
    
    if (_animating) {
        T_LOG(@"%p标记动画结束2:%lud",self,(unsigned long)_selectedIndex);
        _animating = NO;
        [_passIndexs removeAllIndexes];
        [_passIndexs addIndex:_selectedIndex];//当前页默认加入
        
        UIView *panel = [_panels objectAtIndex:_selectedIndex];
        if ([_delegate respondsToSelector:@selector(ssn_control:didEnterPage:atIndex:)]) {
            [_delegate ssn_control:self didEnterPage:panel atIndex:_selectedIndex];
        }
    }
}

@end

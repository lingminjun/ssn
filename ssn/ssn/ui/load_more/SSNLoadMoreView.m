//
//  SSNLoadMoreView.m
//  ssn
//
//  Created by lingminjun on 15/5/8.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNLoadMoreView.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

NSString *const SSN_LOAD_MORE_REDRAPE_MESSAGE   = @"上提加载更多";
NSString *const SSN_LOAD_MORE_LOOSEN_MESSAGE    = @"松开开始加载";
NSString *const SSN_LOAD_MORE_LOADING_MESSAGE   = @"加载...";


static char * ssn_table_footer_load_more_key = NULL;

#define SSN_LOAD_MORE_EDGE_WIDTH (10)
#define SSN_LOAD_MORE_SPACE_WIDTH (8)

typedef NS_ENUM(NSUInteger, SSNLoadMoreState){
    SSNLoadMoreStill,
    SSNLoadMorePulling,
    SSNLoadMoreLoading,
};

@interface SSNLoadMoreView () {
    __weak id<SSNLoadMoreViewDelegate> _delegate;
    __unsafe_unretained UITableView *_tableView;
    
    UIActivityIndicatorView *_indicatorView;
    UILabel *_descriptionLabel;
    
    SSNLoadMoreState _state;
    
    BOOL _isLoading;
    CGFloat _startOffset;
    BOOL _prevScrollViewDragging;//记录ScrollView上一次是否为拖拽
}
@end

@implementation SSNLoadMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect aframe = CGRectMake(0, frame.origin.y, [UIScreen mainScreen].bounds.size.width, frame.size.height);
    
    if (aframe.size.height == 0) {//默认高度
        aframe.size.height = 44;
    }
    
    self = [super initWithFrame:aframe];
    if (self) {        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidden = YES;
        [self addSubview:_indicatorView];
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [_descriptionLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_descriptionLabel setNumberOfLines:1];
        [_descriptionLabel setTextAlignment:NSTextAlignmentLeft];
        [_descriptionLabel setFont:[UIFont systemFontOfSize:14]];
        [_descriptionLabel setTextColor:[UIColor blackColor]];
        [self addSubview:_descriptionLabel];
        
        _state = SSNLoadMoreStill;
    }
    return self;
}

- (void)dealloc {
    if (_tableView) {
        [_tableView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    
    UIView *supview = self.superview;
    if ([supview isKindOfClass:[UITableView class]]) {
        _tableView = (UITableView *)supview;
    }
    else {//取不到算了
    }
    return _tableView;
}

- (BOOL)isLoading {
    return _isLoading;
}

/**
 *  依赖的tableView
 *
 *  @return 返回正在作用的tableView
 */
- (UITableView *)contextTableView {
    return [self tableView];
}

- (void)removeFromSuperview {
    UIScrollView *scrollView = [self tableView];
    if (scrollView) {
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
        _tableView = nil;
    }
    
    [super removeFromSuperview];
}

/**
 *  将其安装到tableView上，其实就赋值给tableView.tableFooterView
 *
 *  @param tableView 依赖的tableView，非空
 */
- (void)installToTableView:(UITableView *)tableView {
    if (tableView == nil) {
        return ;
    }
    
    if (_tableView == tableView) {
        return ;
    }
    
    if (_tableView) {
        objc_setAssociatedObject(_tableView, &(ssn_table_footer_load_more_key),nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [_tableView removeObserver:self forKeyPath:@"contentOffset"];
        _tableView = nil;
    }
    
    if (_hasMore) {
        tableView.tableFooterView = self;
    }
    //加入到table
    objc_setAssociatedObject(tableView, &(ssn_table_footer_load_more_key),self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //监听变化
    _tableView = tableView;
    [tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark setter overide
- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    
    CGSize goal_size = CGSizeMake(maxWidth, 3000);
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary *attributes = @{ NSFontAttributeName:font };
        CGRect rect = [string boundingRectWithSize:goal_size
                                         options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
        return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    CGSize size = [string sizeWithFont:font constrainedToSize:goal_size lineBreakMode:NSLineBreakByWordWrapping];
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
#pragma clang diagnostic pop
    
}

- (CGSize)sizeWithAttributedString:(NSAttributedString *)string maxWidth:(CGFloat)maxWidth {
    CGSize goal_size = CGSizeMake(maxWidth, 3000);
    CGRect rect = [string boundingRectWithSize:goal_size
                                     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

- (CGSize)calculateTextSize {
    if ([_descriptionLabel.text length] == 0) {
        return CGSizeZero;
    }
    
    NSUInteger maxWidth = [UIScreen mainScreen].bounds.size.width - 2*SSN_LOAD_MORE_EDGE_WIDTH - _indicatorView.frame.size.width - SSN_LOAD_MORE_SPACE_WIDTH;
    //可变字体和不可变字体都应该计算后取最大的
    CGSize size1 = CGSizeZero;
    if (_descriptionLabel.attributedText) {
        size1 = [self sizeWithAttributedString:_descriptionLabel.attributedText maxWidth:maxWidth];
    }
    
    NSString *text = _descriptionLabel.text;
    if (!text) {
        text = @"";
    }
    CGSize size2 = [self sizeWithString:text font:_descriptionLabel.font maxWidth:maxWidth];
    
    CGSize size = size1;
    if (size2.height > size.height) {
        size = size2;
    }
    
    return size;
}

- (void)layoutDisplaySubviews {
    CGRect indicatorFrame = _indicatorView.frame;
    CGRect textFrame = _descriptionLabel.frame;
    CGSize labelSize = [self calculateTextSize];
    
    if (_indicatorView.hidden) {
        textFrame.size = labelSize;
        textFrame.origin.y = floorf((self.bounds.size.height - textFrame.size.height)/2);
        textFrame.origin.x = floorf((self.bounds.size.width - labelSize.width)/2);
        _descriptionLabel.frame = textFrame;
    }
    else
    {
        indicatorFrame.origin.y = floorf((self.bounds.size.height - indicatorFrame.size.height)/2);
        indicatorFrame.origin.x = floorf((self.bounds.size.width - labelSize.width - SSN_LOAD_MORE_SPACE_WIDTH - indicatorFrame.size.width)/2);
        _indicatorView.frame = indicatorFrame;
        
        textFrame.size = labelSize;
        textFrame.origin.y = floorf((self.bounds.size.height - textFrame.size.height)/2);
        textFrame.origin.x = indicatorFrame.origin.x + indicatorFrame.size.width + SSN_LOAD_MORE_SPACE_WIDTH;
        _descriptionLabel.frame = textFrame;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutDisplaySubviews];
}

#pragma mark kvo
- (CGFloat)scrollViewOffsetFromBottom:(UIScrollView *) scrollView
{
    CGFloat scrollAreaContenHeight = scrollView.contentSize.height - _startOffset;
    
    CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollAreaContenHeight);
    CGFloat scrolledDistance = scrollView.contentOffset.y + visibleTableHeight; // If scrolled all the way down this should add upp to the content heigh.
    
    CGFloat normalizedOffset = scrollAreaContenHeight -scrolledDistance;
    return normalizedOffset;
}

- (void)setDescriptionMessage:(NSString *)message hiddenIndicator:(BOOL)hiddenIndicator animted:(BOOL)animted {
    _descriptionLabel.text = message;
    _indicatorView.hidden = hiddenIndicator;
    if (!hiddenIndicator) {
        [_indicatorView startAnimating];
    }
    else {
        [_indicatorView stopAnimating];
    }
    [self layoutDisplaySubviews];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UIScrollView *scl = [self tableView];
    if (object != scl) {
        [object removeObserver:self forKeyPath:keyPath];
        return ;
    }
    
    if (!_hasMore) {
        return ;
    }
    
    //第一次取_crollview时需要找到偏移值
    if (_startOffset == 0 && !_isLoading) {
        _startOffset = scl.contentInset.bottom;
    }
    
    CGFloat trigger_height = self.bounds.size.height + _startOffset;
    
    //计算其实offset
    CGFloat valve_offset = [self scrollViewOffsetFromBottom:scl];
    
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
        _state = SSNLoadMoreLoading;
        
        //开启动画
        NSString *msg = self.loadingMessage;
        if ([msg length] == 0) {
            msg = SSN_LOAD_MORE_LOADING_MESSAGE;
        }
        [self setDescriptionMessage:msg hiddenIndicator:NO animted:YES];
        
        //委托回调
        if ([_delegate respondsToSelector:@selector(ssn_loadMoreViewDidTrigger:)]) {
            [_delegate ssn_loadMoreViewDidTrigger:self];
        }
    }
    
    //开始计算动作
    if (scl.isDragging && !_isLoading) {
        
        if (_state == SSNLoadMorePulling && valve_offset > - trigger_height && valve_offset < 0.0f && !_isLoading) {
            _state = SSNLoadMoreStill;
            NSString *msg = self.redrapeMessage;
            if ([msg length] == 0) {
                msg = SSN_LOAD_MORE_REDRAPE_MESSAGE;
            }
            [self setDescriptionMessage:msg hiddenIndicator:YES animted:NO];
        } else if (_state == SSNLoadMoreStill && valve_offset < -trigger_height && !_isLoading) {
            _state = SSNLoadMorePulling;
            NSString *msg = self.loosenMessage;
            if ([msg length] == 0) {
                msg = SSN_LOAD_MORE_LOOSEN_MESSAGE;
            }
            [self setDescriptionMessage:msg hiddenIndicator:YES animted:NO];
        }
    }
}


- (void)finishedLoading {
    
    if (!_isLoading) {
        return ;
    }
    
    _isLoading = NO;
    _state = SSNLoadMoreStill;
    
    UIScrollView *scl = [self tableView];
    if (!scl) {
        return ;
    }

    NSString *msg = self.redrapeMessage;
    if ([msg length] == 0) {
        msg = SSN_LOAD_MORE_REDRAPE_MESSAGE;
    }
    [self setDescriptionMessage:msg hiddenIndicator:YES animted:NO];
}

/**
 *  是否有更多加载
 */
@synthesize hasMore = _hasMore;
- (void)setHasMore:(BOOL)hasMore {
    
    UITableView *tableView = [self tableView];
    if (hasMore) {
        tableView.tableFooterView = self;
    }
    else {
        tableView.tableFooterView = nil;
    }
    
    _hasMore = hasMore;
}


@end

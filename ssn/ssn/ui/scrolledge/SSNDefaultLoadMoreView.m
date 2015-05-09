//
//  SSNDefaultLoadMoreView.m
//  ssn
//
//  Created by lingminjun on 15/5/8.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNDefaultLoadMoreView.h"

NSString *const SSN_LOAD_MORE_REDRAPE_MESSAGE   = @"上提加载更多";
NSString *const SSN_LOAD_MORE_LOOSEN_MESSAGE    = @"松开开始加载";
NSString *const SSN_LOAD_MORE_LOADING_MESSAGE   = @"加载...";


#define SSN_LOAD_MORE_EDGE_WIDTH (10)
#define SSN_LOAD_MORE_SPACE_WIDTH (8)


@implementation SSNDefaultLoadMoreView

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
        [_descriptionLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [_descriptionLabel setTextColor:[UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]];
        [self addSubview:_descriptionLabel];
    }
    return self;
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

#pragma mark SSNScrollEdgeContentView
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

/**
 *  当scrollEdgeView将要触发阀值时回调，此时可以开始加载动画
 *
 *  @param scrollEdgeView 当前的scrollEdgeView
 */
- (void)scrollEdgeViewWillTrigger:(SSNScrollEdgeView *)scrollEdgeView {
    //开启动画
    NSString *msg = self.loadingMessage;
    if ([msg length] == 0) {
        msg = SSN_LOAD_MORE_LOADING_MESSAGE;
    }
    [self setDescriptionMessage:msg hiddenIndicator:NO animted:YES];
}

/**
 *  当scrollEdgeView将被拖拽时回调，此时可以改变提示语句
 *
 *  @param scrollEdgeView 当前的scrollEdgeView
 */
- (void)scrollEdgeViewWillDragging:(SSNScrollEdgeView *)scrollEdgeView {
    NSString *msg = self.loosenMessage;
    if ([msg length] == 0) {
        msg = SSN_LOAD_MORE_LOOSEN_MESSAGE;
    }
    [self setDescriptionMessage:msg hiddenIndicator:YES animted:NO];
}

/**
 *  当headerView结束加载过程后回调，此时可以停止加载动画
 *
 *  @param scrollHeader 当前的scrollHeader
 */
/**
 *  当scrollEdgeView结束加载过程后回调，此时可以停止加载动画
 *
 *  @param scrollEdgeView 当前的scrollEdgeView
 */
- (void)scrollEdgeViewDidFinish:(SSNScrollEdgeView *)scrollEdgeView {
    NSString *msg = self.redrapeMessage;
    if ([msg length] == 0) {
        msg = SSN_LOAD_MORE_REDRAPE_MESSAGE;
    }
    [self setDescriptionMessage:msg hiddenIndicator:YES animted:NO];
}

#pragma mark factory
/**
 *  下拉刷新View
 *
 *  @return 下拉刷新view
 */
+ (SSNScrollEdgeView *)loadMoreView {
    SSNScrollEdgeView *loadMore = [[SSNScrollEdgeView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    loadMore.isBottomEdge = YES;
    loadMore.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    SSNDefaultLoadMoreView *content = [[SSNDefaultLoadMoreView alloc] initWithFrame:loadMore.bounds];
    [loadMore setContentView:content];
    return loadMore;
}

@end

@implementation SSNScrollEdgeView(SSNLoadMoreView)

/**
 *  返回依赖的tableView
 *
 *  @return 依赖的tableView
 */
- (UITableView *)contextTableView {
    return (UITableView *)[self contextScrollView];
}

/**
 *  将其安装到tableView上，即tableView.tableFooterView
 *
 *  @param tableView 依赖的tableView，非空
 */
- (void)installToTableView:(UITableView *)tableView {
    [self installToScrollView:tableView];
    
    if (tableView && self.hasMore) {
        tableView.tableFooterView = self;
    }
}

/**
 *  是否有更多加载
 */
@dynamic hasMore;
- (void)setHasMore:(BOOL)hasMore {
    
    UITableView *tableView = [self contextTableView];
    if (hasMore) {
        tableView.tableFooterView = self;
    }
    else {
        tableView.tableFooterView = nil;
    }
    
    self.disabled = !hasMore;
}
- (BOOL)hasMore {
    return ![self disabled];
}

@end

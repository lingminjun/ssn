//
//  LoadMoreTableView.m
//  EGOTableViewPullRefreshDemo
//
//  Created by wanyakun on 13-11-6.
//  Copyright (c) 2013年 The9. All rights reserved.
//

#import "LoadMoreTableView.h"

@interface LoadMoreTableView (Private) <UIScrollViewDelegate>
- (void) config;
- (void) configDisplayProperties;
@end

@implementation LoadMoreTableView

@synthesize loadMoreDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self config];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self config];
}


- (void)dealloc {
    [loadMoreArrowImage release];
    [loadMoreBackgroundColor release];
    [loadMoreTextColor release];
    
    [loadMoreView release];
    [delegateInterceptor release];
    delegateInterceptor = nil;
    [super dealloc];
}

# pragma mark - Custom view configuration

- (void) config
{
    /* Message interceptor to intercept scrollView delegate messages */
    delegateInterceptor = [[MessageInterceptor alloc] init];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = self.delegate;
    super.delegate = (id)delegateInterceptor;
    
    /* Status Properties */
    loadMoreTableIsLoadingMore = NO;
    
    /* Load more view init */
    loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    loadMoreView.delegate = self;
    [self addSubview:loadMoreView];
    
}


# pragma mark - View changes

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
    
    CGRect loadMoreFrame = loadMoreView.frame;
    loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
    loadMoreView.frame = loadMoreFrame;
}

#pragma mark - Preserving the original behaviour

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if(delegateInterceptor) {
        super.delegate = nil;
        delegateInterceptor.receiver = delegate;
        super.delegate = (id)delegateInterceptor;
    } else {
        super.delegate = delegate;
    }
}

- (void)reloadData
{
    [super reloadData];
    // Give the footers a chance to fix it self.
    [loadMoreView egoRefreshScrollViewDidScroll:self];
}

#pragma mark - Status Propreties

@synthesize loadMoreTableIsLoadingMore;

- (void)setLoadMoreTableIsLoadingMore:(BOOL)isLoadingMore
{
    if(!loadMoreTableIsLoadingMore && isLoadingMore) {
        // If not allready loading more start refreshing
        [loadMoreView startAnimatingWithScrollView:self];
        loadMoreTableIsLoadingMore = YES;
    } else if(loadMoreTableIsLoadingMore && !isLoadingMore) {
        [loadMoreView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        loadMoreTableIsLoadingMore = NO;
    }
}

#pragma mark - Display properties

@synthesize loadMoreArrowImage;
@synthesize loadMoreBackgroundColor;
@synthesize loadMoreTextColor;

- (void)configDisplayProperties
{
    [loadMoreView setBackgroundColor:self.loadMoreBackgroundColor textColor:self.loadMoreTextColor arrowImage:self.loadMoreArrowImage];
}

- (void)setLoadMoreArrowImage:(UIImage *)aLoadMorelArrowImage
{
    if(aLoadMorelArrowImage != loadMoreArrowImage) {
        [loadMoreArrowImage release];
        loadMoreArrowImage = [aLoadMorelArrowImage retain];
        [self configDisplayProperties];
    }
}

- (void)setLoadMoreBackgroundColor:(UIColor *)aColor
{
    if(aColor != loadMoreBackgroundColor) {
        [loadMoreBackgroundColor release];
        loadMoreBackgroundColor = [aColor retain];
        [self configDisplayProperties];
    }
}

- (void)setLoadMoreTextColor:(UIColor *)aColor
{
    if(aColor != loadMoreTextColor) {
        [loadMoreTextColor release];
        loadMoreTextColor = [aColor retain];
        [self configDisplayProperties];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [loadMoreView egoRefreshScrollViewDidScroll:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    [loadMoreView egoRefreshScrollViewDidEndDragging:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [delegateInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [delegateInterceptor.receiver scrollViewWillBeginDragging:scrollView];
    }
}

#pragma mark - LoadMoreTableViewDelegate

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view
{
    loadMoreTableIsLoadingMore = YES;
    [loadMoreDelegate loadMoreTableViewDidTriggerLoadMore:self];
}

@end

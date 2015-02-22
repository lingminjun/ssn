//
//  RefreshTableView.m
//  MyBank
//
//  Created by wanyakun on 13-11-20.
//  Copyright (c) 2013年 MyBank.cc. All rights reserved.
//

#import "RefreshTableView.h"

@interface RefreshTableView (Private) <UIScrollViewDelegate>
- (void) config;
- (void) configDisplayProperties;
@end

@implementation RefreshTableView

# pragma mark - Initialization / Deallocation

@synthesize refreshDelegate;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
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
    [refreshArrowImage release];
    [refreshBackgroundColor release];
    [refreshTextColor release];
    [refreshLastRefreshDate release];
    
    [refreshView release];
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
    refreshTableIsRefreshing = NO;
    
    /* Refresh View */
    refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    refreshView.delegate = self;
    [self addSubview:refreshView];
    
}


# pragma mark - View changes

- (void)layoutSubviews
{
    [super layoutSubviews];
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
}

#pragma mark - Status Propreties

@synthesize refreshTableIsRefreshing;

- (void)setRefreshTableIsRefreshing:(BOOL)isRefreshing
{
    if(!refreshTableIsRefreshing && isRefreshing) {
        // If not allready refreshing start refreshing
        [refreshView startAnimatingWithScrollView:self];
        refreshTableIsRefreshing = YES;
    } else if(refreshTableIsRefreshing && !isRefreshing) {
        [refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        refreshTableIsRefreshing = NO;
    }
}

#pragma mark - Display properties

@synthesize refreshArrowImage;
@synthesize refreshBackgroundColor;
@synthesize refreshTextColor;
@synthesize refreshLastRefreshDate;

- (void)configDisplayProperties
{
    [refreshView setBackgroundColor:self.refreshBackgroundColor textColor:self.refreshTextColor arrowImage:self.refreshArrowImage];
}

- (void)setRefreshArrowImage:(UIImage *)aRefreshArrowImage
{
    if(aRefreshArrowImage != refreshArrowImage) {
        [refreshArrowImage release];
        refreshArrowImage = [aRefreshArrowImage retain];
        [self configDisplayProperties];
    }
}

- (void)setRefreshBackgroundColor:(UIColor *)aColor
{
    if(aColor != refreshBackgroundColor) {
        [refreshBackgroundColor release];
        refreshBackgroundColor = [aColor retain];
        [self configDisplayProperties];
    }
}

- (void)setRefreshTextColor:(UIColor *)aColor
{
    if(aColor != refreshTextColor) {
        [refreshTextColor release];
        refreshTextColor = [aColor retain];
        [self configDisplayProperties];
    }
}

- (void)setRefreshLastRefreshDate:(NSDate *)aDate
{
    if(aDate != refreshLastRefreshDate) {
        [refreshLastRefreshDate release];
        refreshLastRefreshDate = [aDate retain];
        [refreshView refreshLastUpdatedDate];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [refreshView egoRefreshScrollViewDidScroll:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    [refreshView egoRefreshScrollViewDidEndDragging:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [delegateInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [refreshView egoRefreshScrollViewWillBeginDragging:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [delegateInterceptor.receiver scrollViewWillBeginDragging:scrollView];
    }
}



#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    refreshTableIsRefreshing = YES;
    [refreshDelegate refreshTableViewDidTriggerRefresh:self];
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return self.refreshLastRefreshDate;
}

@end

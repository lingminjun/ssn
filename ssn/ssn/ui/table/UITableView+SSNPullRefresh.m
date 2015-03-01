//
//  UITableView+SSNPullRefresh.m
//  ssn
//
//  Created by lingminjun on 15/2/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UITableView+SSNPullRefresh.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@implementation UITableView (SSNPullRefresh)

static char * table_header_pull_refresh_key = NULL;
static char * table_footer_load_more_key = NULL;

#pragma mark pullRefresh

- (void)setSsn_pullRefreshEnabled:(BOOL)ssn_pullRefreshEnabled {
    SSNPullRefreshView *subview = [self ssn_headerPullRefreshView];
    if (ssn_pullRefreshEnabled) {
        
        if (!subview) {
            subview = [[SSNPullRefreshView alloc] initWithStyle:SSNPullRefreshHeaderRefresh delegate:nil];
            objc_setAssociatedObject(self, &(table_header_pull_refresh_key),subview, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        CGRect frame = subview.frame;
        frame.origin.y = -(frame.size.height);
        subview.frame = frame;
        [self addSubview:subview];
    }
    else if (!ssn_pullRefreshEnabled && subview) {
        [subview removeFromSuperview];
    }
}
- (BOOL)ssn_pullRefreshEnabled {
    SSNPullRefreshView *subview = [self ssn_headerPullRefreshView];
    return subview.superview == self;
}

- (SSNPullRefreshView *)ssn_headerPullRefreshView {
    return objc_getAssociatedObject(self, &(table_header_pull_refresh_key));
}

#pragma mark loadMore

- (void)setSsn_loadMoreEnabled:(BOOL)ssn_loadMoreEnabled {
    SSNPullRefreshView *subview = [self ssn_footerLoadMoreView];
    if (ssn_loadMoreEnabled) {
        
        if (!subview) {
            subview = [[SSNPullRefreshView alloc] initWithStyle:SSNPullRefreshFooterLoadMore delegate:nil];
            objc_setAssociatedObject(self, &(table_footer_load_more_key),subview, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        self.tableFooterView = subview;
    }
    else if (!ssn_loadMoreEnabled && subview) {
        self.tableFooterView = nil;
        [subview removeFromSuperview];
    }
}

- (BOOL)ssn_loadMoreEnabled {
    SSNPullRefreshView *subview = [self ssn_footerLoadMoreView];
    return subview.superview == self;
}

- (SSNPullRefreshView *)ssn_footerLoadMoreView {
    return objc_getAssociatedObject(self, &(table_footer_load_more_key));
}

@end

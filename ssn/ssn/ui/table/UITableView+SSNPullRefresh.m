//
//  UITableView+SSNPullRefresh.m
//  ssn
//
//  Created by lingminjun on 15/2/13.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UITableView+SSNPullRefresh.h"
#import "SSNDefaultPullRefreshView.h"
#import "SSNDefaultLoadMoreView.h"
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
    SSNScrollEdgeView *subview = [self ssn_headerPullRefreshView];
    if (ssn_pullRefreshEnabled) {
        
        if (!subview) {
            subview = [SSNDefaultPullRefreshView pullRefreshView];
            objc_setAssociatedObject(self, &(table_header_pull_refresh_key),subview, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        subview.disabled = !ssn_pullRefreshEnabled;
        [subview installToScrollView:self];
    }
    else if (!ssn_pullRefreshEnabled && subview) {
        subview.disabled = !ssn_pullRefreshEnabled;
        [subview removeFromSuperview];
    }
}
- (BOOL)ssn_pullRefreshEnabled {
    SSNScrollEdgeView *subview = [self ssn_headerPullRefreshView];
    if (subview) {
        return !subview.disabled;
    }
    return NO;
}

- (SSNScrollEdgeView *)ssn_headerPullRefreshView {
    return objc_getAssociatedObject(self, &(table_header_pull_refresh_key));
}

#pragma mark loadMore

- (void)setSsn_loadMoreEnabled:(BOOL)ssn_loadMoreEnabled {
    SSNScrollEdgeView *subview = [self ssn_footerLoadMoreView];
    if (ssn_loadMoreEnabled) {
        
        if (!subview) {
            subview = [SSNDefaultLoadMoreView loadMoreView];
            objc_setAssociatedObject(self, &(table_footer_load_more_key),subview, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        subview.disabled = !ssn_loadMoreEnabled;
        [subview installToTableView:self];
    }
    else if (!ssn_loadMoreEnabled && subview) {
        subview.disabled = !ssn_loadMoreEnabled;
        if (self.tableFooterView == subview) {
            self.tableFooterView = nil;
        }
        [subview removeFromSuperview];
    }
}

- (BOOL)ssn_loadMoreEnabled {
    SSNScrollEdgeView *subview = [self ssn_headerPullRefreshView];
    if (subview) {
        return !subview.disabled;
    }
    return NO;
}

- (SSNScrollEdgeView *)ssn_footerLoadMoreView {
    return objc_getAssociatedObject(self, &(table_footer_load_more_key));
}

@end

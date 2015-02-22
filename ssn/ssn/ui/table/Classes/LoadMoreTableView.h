//
//  LoadMoreTableView.h
//  EGOTableViewPullRefreshDemo
//
//  Created by wanyakun on 13-11-6.
//  Copyright (c) 2013年 The9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageInterceptor.h"
#import "LoadMoreTableFooterView.h"

@protocol LoadMoreTableViewDelegate;

@interface LoadMoreTableView : UITableView<LoadMoreTableFooterDelegate>
{
    
    LoadMoreTableFooterView *loadMoreView;
    
    // Since we use the contentInsets to manipulate the view we need to store the the content insets originally specified.
    UIEdgeInsets realContentInsets;
    
    // For intercepting the scrollView delegate messages.
    MessageInterceptor * delegateInterceptor;
    
    // Config
    UIImage *loadMoreArrowImage;
    UIColor *loadMoreBackgroundColor;
    UIColor *loadMoreTextColor;
    
    // Status
    BOOL loadMoreTableIsLoadingMore;
    
    // Delegate
    id<LoadMoreTableViewDelegate> loadMoreDelegate;
    
}

/* The configurable display properties of PullTableView. Set to nil for default values */
@property (nonatomic, retain) UIImage *loadMoreArrowImage;
@property (nonatomic, retain) UIColor *loadMoreBackgroundColor;
@property (nonatomic, retain) UIColor *loadMoreTextColor;


/* Properties to set the status of the refresh/loadMore operations. */
/* After the delegate methods are triggered the respective properties are automatically set to YES. After a refresh/reload is done it is necessary to set the respective property to NO, otherwise the animation won't disappear. You can also set the properties manually to YES to show the animations. */
@property (nonatomic, assign) BOOL loadMoreTableIsLoadingMore;

/* Delegate */
@property (nonatomic, assign) id<LoadMoreTableViewDelegate> loadMoreDelegate;

@end

@protocol LoadMoreTableViewDelegate <NSObject>

/* After one of the delegate methods is invoked a loading animation is started, to end it use the respective status update property */
- (void)loadMoreTableViewDidTriggerLoadMore:(LoadMoreTableView*)loadMoreTableView;

@end
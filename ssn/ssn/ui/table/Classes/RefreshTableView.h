//
//  RefreshTableView.h
//  MyBank
//
//  Created by wanyakun on 13-11-20.
//  Copyright (c) 2013年 MyBank.cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageInterceptor.h"
#import "EGORefreshTableHeaderView.h"


@protocol RefreshTableViewDelegate;
@interface RefreshTableView : UITableView<EGORefreshTableHeaderDelegate>
{
    
    EGORefreshTableHeaderView *refreshView;
    
    // Since we use the contentInsets to manipulate the view we need to store the the content insets originally specified.
    UIEdgeInsets realContentInsets;
    
    // For intercepting the scrollView delegate messages.
    MessageInterceptor * delegateInterceptor;
    
    // Config
    UIImage *refreshArrowImage;
    UIColor *refreshBackgroundColor;
    UIColor *refreshTextColor;
    NSDate *refreshLastRefreshDate;
    
    // Status
    BOOL refreshTableIsRefreshing;
    
    // Delegate
    id<RefreshTableViewDelegate> refreshDelegate;
    
}

/* The configurable display properties of PullTableView. Set to nil for default values */
@property (nonatomic, retain) UIImage *refreshArrowImage;
@property (nonatomic, retain) UIColor *refreshBackgroundColor;
@property (nonatomic, retain) UIColor *refreshTextColor;

/* Set to nil to hide last modified text */
@property (nonatomic, retain) NSDate *refreshLastRefreshDate;

/* Properties to set the status of the refresh/loadMore operations. */
/* After the delegate methods are triggered the respective properties are automatically set to YES. After a refresh/reload is done it is necessary to set the respective property to NO, otherwise the animation won't disappear. You can also set the properties manually to YES to show the animations. */
@property (nonatomic, assign) BOOL refreshTableIsRefreshing;

/* Delegate */
@property (nonatomic, assign) id<RefreshTableViewDelegate> refreshDelegate;




@end


@protocol RefreshTableViewDelegate <NSObject>

- (void)refreshTableViewDidTriggerRefresh:(RefreshTableView*)refreshTableView;

@end
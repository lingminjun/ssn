//
//  SSNDefaultPullRefreshView.h
//  ssn
//
//  Created by lingminjun on 15/5/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNScrollEdgeView.h"

/**
 *  实现一个默认的refresh view
 */
@interface SSNDefaultPullRefreshView : UIView<SSNScrollEdgeContentView> {
    UIImage *_arrowImage;
    
    UILabel *_lastUpdatedLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImageLayer;
    UIActivityIndicatorView *_activityView;
    
    NSDate *_lastUpdatedTimestamp;
}

/**
 *  获得一个默认风格的refresh view
 *
 *  @return edgeView
 */
+ (SSNScrollEdgeView *)pullRefreshView;

@end

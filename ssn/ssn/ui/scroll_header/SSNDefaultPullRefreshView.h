//
//  SSNDefaultPullRefreshView.h
//  ssn
//
//  Created by lingminjun on 15/5/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNScrollHeader.h"

@interface SSNDefaultPullRefreshView : UIView<SSNScrollHeaderContentView> {
    UIImage *_arrowImage;
    
    UILabel *_lastUpdatedLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImageLayer;
    UIActivityIndicatorView *_activityView;
    
    NSDate *_lastUpdatedTimestamp;
}

@end

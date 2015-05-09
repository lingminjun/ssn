//
//  SSNDefaultPullRefreshView.m
//  ssn
//
//  Created by lingminjun on 15/5/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNDefaultPullRefreshView.h"

@implementation SSNDefaultPullRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect content_frame = self.bounds;
        CGFloat status_label_height = 20.0f;
        CGFloat date_label_height = 20.0f;
        CGFloat label_space_height = 0;
        
        CGFloat label_sum_height = date_label_height + label_space_height + status_label_height;
        
        _arrowImage = [UIImage imageNamed:@"ssn_pull_refresh_blue_arrow"];
        
        /* Config Status Updated Label */
        {
            CGFloat status_label_y = (content_frame.size.height-label_sum_height)/2;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, status_label_y, content_frame.size.width, status_label_height)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.textColor = [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0];
            label.font = [UIFont boldSystemFontOfSize:13.0f];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            _statusLabel=label;
        }
        
        /* Config Last Updated Label */
        {
            CGFloat date_label_y = (content_frame.size.height-label_sum_height)/2 + label_space_height + status_label_height;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, date_label_y, content_frame.size.width, date_label_height)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont systemFontOfSize:12.0f];
            label.textColor = [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            _lastUpdatedLabel=label;
        }
        
        /* Config Arrow Image */
        CGSize image_size = _arrowImage.size;
        CALayer *layer = [[CALayer alloc] init];
        layer.frame = CGRectMake(25.0f,(content_frame.size.height - image_size.height)/2, image_size.width, image_size.height);
        layer.contentsGravity = kCAGravityResizeAspect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
#endif
        [[self layer] addSublayer:layer];
        _arrowImageLayer=layer;
        _arrowImageLayer.contents = (id)(_arrowImage.CGImage);
        
        
        /* Config activity indicator */
        CGSize activity_size = CGSizeMake(20, 20);
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        view.frame = CGRectMake(25.0f,(content_frame.size.height - activity_size.height)/2, activity_size.width, activity_size.height);
        [self addSubview:view];
        _activityView = view;
        
        [self refreshLastUpdatedDate];
    }
    return self;
}

/**
 *  当scrollEdgeView将要触发阀值时回调，此时可以开始加载动画
 *
 *  @param scrollEdgeView 当前的scrollEdgeView
 */
- (void)scrollEdgeViewWillTrigger:(SSNScrollEdgeView *)scrollEdgeView {
    _lastUpdatedTimestamp = [NSDate date];
    
    _statusLabel.text = @"加载中...";
    
    [_activityView startAnimating];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    _arrowImageLayer.hidden = YES;
    [CATransaction commit];
}

/**
 *  当scrollEdgeView将被拖拽时回调，此时可以改变提示语句
 *
 *  @param scrollEdgeView 当前的scrollEdgeView
 */
- (void)scrollEdgeViewWillDragging:(SSNScrollEdgeView *)scrollEdgeView {
    _statusLabel.text = @"松开即可刷新...";
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.18f];
    _arrowImageLayer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
    [CATransaction commit];
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
    _statusLabel.text = @"下拉可以刷新...";
    
    [_activityView stopAnimating];
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.18f];
    _arrowImageLayer.hidden = NO;
    _arrowImageLayer.transform = CATransform3DIdentity;
    [CATransaction commit];
    
    [self refreshLastUpdatedDate];
}

- (void)refreshLastUpdatedDate {
    
    NSString *string = nil;
    if (_lastUpdatedTimestamp) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        string = [NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:_lastUpdatedTimestamp]];
    }
    _lastUpdatedLabel.text = string;
    
    // Center the status label if the lastupdate is not available
    CGRect content_frame = self.bounds;
    CGFloat status_label_height = _statusLabel.frame.size.height;
    CGFloat date_label_height = _lastUpdatedLabel.frame.size.height;
    CGFloat label_space_height = 0;
    CGFloat label_sum_height = date_label_height + label_space_height + status_label_height;
    CGFloat status_label_y = (content_frame.size.height-label_sum_height)/2;
    
    if([_lastUpdatedLabel.text length] > 0) {
        status_label_y = (content_frame.size.height-label_sum_height)/2;
    } else {
        status_label_y = (content_frame.size.height-status_label_height)/2;
    }
    _statusLabel.frame = CGRectMake(0.0f, status_label_y, _statusLabel.frame.size.width, status_label_height);
}

/**
 *  获得一个默认风格的refresh view
 *
 *  @return edgeView
 */
+ (SSNScrollEdgeView *)pullRefreshView {
    SSNScrollEdgeView *header = [[SSNScrollEdgeView alloc] init];
    header.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    SSNDefaultPullRefreshView *refreshView = [[SSNDefaultPullRefreshView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    [header setContentView:refreshView];
    
    return header;
}

@end

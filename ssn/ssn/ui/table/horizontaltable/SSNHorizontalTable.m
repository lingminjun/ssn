//
//  SSNHorizontalTable.m
//  ssn
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNHorizontalTable.h"
#import "UIView+SSNUIFrame.h"

#define ssn_h_table_transform CGAffineTransformMakeRotation(-90 *M_PI / 180.0)

@interface SSNHorizontalTableView : UITableView

@property (nonatomic,weak) SSNHorizontalTable *dependTable;

@end

@implementation SSNHorizontalTable

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect tableFrame = self.bounds;
        tableFrame.size.height = self.bounds.size.width;
        tableFrame.size.width = self.bounds.size.height;
        
        _table = [[SSNHorizontalTableView alloc] initWithFrame:tableFrame style:style];
        _table.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _table.transform = ssn_h_table_transform;
        _table.ssn_center = ssn_center(self.bounds);
        _table.rowHeight = self.bounds.size.width;
        _table.backgroundColor = [UIColor clearColor];
        [self addSubview:_table];
    }
    return self;
}

@end


@implementation SSNHorizontalTableView

- (void)setContentInset:(UIEdgeInsets)contentInset {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = contentInset.left;
    insets.bottom = contentInset.right;
    [super setContentInset:insets];
}
- (UIEdgeInsets)contentInset {
    UIEdgeInsets contentInset = [super contentInset];
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.left = contentInset.top;
    insets.right = contentInset.bottom;
    return insets;
}

//- (void)setContentOffset:(CGPoint)contentOffset {
//    CGPoint point = CGPointMake(contentOffset.y, contentOffset.x);
//    [super setContentOffset:point];
//}
////- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
////    CGPoint point = CGPointMake(contentOffset.y, contentOffset.x);
////    [super setContentOffset:point animated:animated];
////}
//- (CGPoint)contentOffset {
//    CGPoint point = [super contentOffset];
//    return CGPointMake(point.y, point.x);
//}

- (void)setAutoresizingMask:(UIViewAutoresizing)autoresizingMask {
    [super setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}

- (void)setTransform:(CGAffineTransform)transform {
    [super setTransform:ssn_h_table_transform];
}

@end

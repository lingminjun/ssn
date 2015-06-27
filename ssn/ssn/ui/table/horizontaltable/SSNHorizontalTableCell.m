//
//  SSNHorizontalTableCell.m
//  ssn
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNHorizontalTableCell.h"
#import "UIView+SSNUIFrame.h"

@interface SSNHorizontalTableCell ()

@property (nonatomic,strong) UIView *content;

@end

@implementation SSNHorizontalTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *scontentView = [super contentView];
        CGRect frame = scontentView.bounds;
        frame.size.width = scontentView.bounds.size.height;
        frame.size.height = scontentView.bounds.size.width;
        _content = [[UIView alloc] initWithFrame:frame];
        _content.transform = CGAffineTransformMakeRotation(90 *M_PI / 180.0);
        _content.ssn_center = ssn_center(scontentView.bounds);
        _content.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _content.backgroundColor = [UIColor whiteColor];
        [scontentView addSubview:_content];
    }
    return self;
}

- (UIView *)contentView {
    return _content;
}


@end

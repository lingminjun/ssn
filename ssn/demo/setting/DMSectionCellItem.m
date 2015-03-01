//
//  DMSectionCellItem.m
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "DMSectionCellItem.h"

@implementation DMSectionCellItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [DMSectionCell class];
        self.cellHeight = 20;
        self.disabledSelect = YES;
    }
    return self;
}

+ (DMSectionCellItem *)item {
    DMSectionCellItem *item = [[DMSectionCellItem alloc] init];
    return item;
}

@end

@implementation DMSectionCell

- (void)ssn_configureCellWithModel:(DMSectionCellItem *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    self.backgroundColor = [UIColor lightGrayColor];
}

@end

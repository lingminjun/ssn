//
//  DMSettingCellItem.m
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "DMSettingCellItem.h"

@implementation DMSettingCellItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [DMSettingCell class];
        self.cellNibName = @"DMNibCell";
        self.cellHeight = 60;
        self.cellDeleteConfirmationButtonTitle = @"删除";
    }
    return self;
}

+ (SSNVMCellItem *)itemWithTitle:(NSString *)title {
    DMSettingCellItem *item = [[DMSettingCellItem alloc] init];
    item.title = title;
    return item;
}
@end


@implementation DMSettingCell

- (void)ssn_configureCellWithModel:(DMSettingCellItem *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    if (self.label) {
        self.label.text = model.title;
    }
    else {
        self.textLabel.text = model.title;
    }
    
}

@end
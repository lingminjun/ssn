//
//  DMPersonCell.m
//  ssn
//
//  Created by lingminjun on 15/3/3.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "DMPersonCell.h"

@implementation DMPersonVM
@synthesize ssn_dbfetch_rowid = _ssn_dbfetch_rowid;

@synthesize cellClass = _cellClass;
@synthesize cellNibName = _cellNibName;
@synthesize cellIdentify = _cellIdentify;
@synthesize cellHeight = _cellHeight;
@synthesize isDisabledSelect = _isDisabledSelect;
@synthesize cellDeleteConfirmationButtonTitle = _cellDeleteConfirmationButtonTitle;
@synthesize cellSectionIdentify = _cellSectionIdentify;

- (NSUInteger)hash {
    return [self.uid hash];
}

- (BOOL)isEqual:(DMPersonVM *)object {
    if (![object isKindOfClass:[DMPersonVM class]]) {
        return NO;
    }
    return [self.uid isEqualToString:object.uid];
}

- (id)copyWithZone:(NSZone *)zone {
    DMPersonVM *copy = [[DMPersonVM alloc] init];
    copy.ssn_dbfetch_rowid = self.ssn_dbfetch_rowid;
    copy.uid = self.uid;
    copy.name = self.name;
    copy.avatar = self.avatar;
    copy.mobile = self.mobile;
    copy.brief = self.brief;
    copy.address = self.address;
    return copy;
}

- (CGFloat)cellHeight {
    return 60;
}

- (Class<SSNVMCellProtocol>)cellClass {
    return [DMPersonCell class];
}

- (NSString *)cellDeleteConfirmationButtonTitle {
    return @"删除";
}

@end


@implementation DMPersonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        //
    }
    return self;
}

- (void)ssn_configureCellWithModel:(DMPersonVM *)person atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    
    self.textLabel.text = person.name;
    self.detailTextLabel.text = person.brief;
}


@end

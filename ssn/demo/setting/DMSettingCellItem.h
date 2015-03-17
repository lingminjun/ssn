//
//  DMSettingCellItem.h
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNVMCellItem.h"

@interface DMSettingCellItem : SSNVMCellItem

@property (nonatomic,copy) NSString *title;

+ (SSNVMCellItem *)itemWithTitle:(NSString *)title;

@end

@interface DMSettingCell : UITableViewCell<SSNVMCellProtocol>

@property (nonatomic,weak) IBOutlet UILabel *label;

@end

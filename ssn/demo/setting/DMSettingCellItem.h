//
//  DMSettingCellItem.h
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNCellModel.h"

@interface DMSettingCellItem : SSNCellModel

@property (nonatomic,copy) NSString *title;

+ (DMSettingCellItem *)itemWithTitle:(NSString *)title;

@end

@interface DMSettingCell : UITableViewCell<SSNVMCellProtocol>

@property (nonatomic,weak) IBOutlet UILabel *label;

@end

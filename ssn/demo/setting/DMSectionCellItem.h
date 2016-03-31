//
//  DMSectionCellItem.h
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNCellModel.h"

@interface DMSectionCellItem : SSNCellModel

+ (instancetype)item;

@end

@interface DMSectionCell : UITableViewCell<SSNVMCellProtocol>

@end
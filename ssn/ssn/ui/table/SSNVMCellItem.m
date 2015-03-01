//
//  SSNVMCellItem.m
//  ssn
//
//  Created by lingminjun on 15/2/23.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNVMCellItem.h"

@implementation SSNVMCellItem

@synthesize identify = _identify;
- (NSString *)identify {
    if (_identify) {
        return _identify;
    }
    
    _identify = [[NSString alloc] initWithFormat:@"%p",self];
    return _identify;
}

@synthesize userInfo = _userInfo;
- (NSMutableDictionary *)userInfo {
    if (_userInfo) {
        return _userInfo;
    }
    
    _userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
    return _userInfo;
}

@synthesize disabledSelect = _disabledSelect;
- (BOOL)isDisabledSelect {
    return _disabledSelect;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellHeight = SSN_VM_CELL_ITEM_DEFAULT_HEIGHT;
        self.cellIdentify = NSStringFromClass([self class]);
    }
    return self;
}

#pragma mark over write
- (NSUInteger)hash {
    return [self.identify hash];
}

- (BOOL)isEqual:(SSNVMCellItem *)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[SSNVMCellItem class]]) {
        return NO;
    }
    
    return [self.identify isEqualToString:object.identify];
}

//- (NSComparisonResult)ssn_compare:(SSNVMCellItem *)model {
//    if (self == model) {
//        return NSOrderedSame;
//    }
//    
//    if (![model isKindOfClass:[SSNVMCellItem class]]) {
//        return NSOrderedAscending;
//    }
//    
//    return [self.identify compare:model.identify];
//}

@end

@implementation UITableViewCell (SSNVMCellProtocol)

- (void)ssn_configureCellWithModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    //do nothing 
}

@end

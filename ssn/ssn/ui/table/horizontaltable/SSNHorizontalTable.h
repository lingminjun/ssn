//
//  SSNHorizontalTable.h
//  ssn
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNHorizontalTableCell.h"

@interface SSNHorizontalTable : UIView

@property (nonatomic,strong,readonly) UITableView *table;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;  

@end

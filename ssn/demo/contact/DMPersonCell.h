//
//  DMPersonCell.h
//  ssn
//
//  Created by lingminjun on 15/3/3.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNCellModel.h"
#import "DMPerson.h"

@interface DMPersonVM : NSObject<SSNDBFetchObject,SSNCellModel>
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *brief;
@property (nonatomic,copy) NSString *address;
@end

@interface DMPersonCell : UITableViewCell

@end

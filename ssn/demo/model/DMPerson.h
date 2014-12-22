//
//  DMPerson.h
//  ssn
//
//  Created by lingminjun on 14/11/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSNDBFetch.h"

@interface DMPerson : NSObject<SSNDBFetchObject>

@property (nonatomic,copy) NSString *uid;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *avatar;

@property (nonatomic,copy) NSString *mobile;

@end

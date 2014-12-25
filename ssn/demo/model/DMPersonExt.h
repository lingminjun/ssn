//
//  DMPersonExt.h
//  ssn
//
//  Created by lingminjun on 14/12/25.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSNDBFetch.h"

@interface DMPersonExt : NSObject<SSNDBFetchObject>

@property (nonatomic,copy) NSString *uid;

@property (nonatomic,copy) NSString *brief;

@property (nonatomic,copy) NSString *address;

@end

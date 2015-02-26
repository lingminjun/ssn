//
//  SSNVMSectionInfo.m
//  ssn
//
//  Created by lingminjun on 15/2/23.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNVMSectionInfo.h"

@implementation SSNVMSectionInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.height = SSN_VM_SECTION_INFO_DEFAULT_HEIGHT;
    }
    return self;
}

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

@synthesize objects = _objects;
- (NSMutableArray *)objects {
    if (_objects) {
        return _objects;
    }
    
    _objects = [[NSMutableArray alloc] initWithCapacity:1];
    return _objects;
}


- (NSUInteger)count {
    return [self.objects count];
}


- (id)objectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        return nil;
    }
    
    return [self.objects objectAtIndex:index];
}

+ (instancetype)sectionInfoWithIdentify:(NSString *)identify title:(NSString *)title {
    SSNVMSectionInfo *info = [[SSNVMSectionInfo alloc] init];
    info.identify = identify;
    info.title = title;
    return info;
}

#pragma mark over write
- (NSUInteger)hash {
    return [self.identify hash];
}

- (BOOL)isEqual:(SSNVMSectionInfo *)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[SSNVMSectionInfo class]]) {
        return NO;
    }
    
    return [self.identify isEqualToString:object.identify];
}
@end

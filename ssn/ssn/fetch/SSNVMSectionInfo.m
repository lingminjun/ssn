//
//  SSNVMSectionInfo.m
//  ssn
//
//  Created by lingminjun on 15/2/23.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNVMSectionInfo.h"

@interface SSNVMSectionInfo ()
@property (nonatomic,copy) NSString *identify;
@end

@implementation SSNVMSectionInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.headerHeight = SSN_VM_SECTION_INFO_DEFAULT_HEIGHT;
        self.footerHeight = SSN_VM_SECTION_INFO_DEFAULT_HEIGHT;
        self.hiddenFooter = YES;
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

- (NSUInteger)indexOfObject:(id)object {
    return [self.objects indexOfObject:object];
}

- (NSComparisonResult)compare:(SSNVMSectionInfo *)info {
    if (self == info) {
        return NSOrderedSame;
    }
    
    if (![info isKindOfClass:[SSNVMSectionInfo class]]) {
        return NSOrderedAscending;
    }
    
    if (self.sortIndex > info.sortIndex) {
        return NSOrderedDescending;
    }
    else if (self.sortIndex < info.sortIndex) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedSame;
    }
}

+ (instancetype)sectionInfoWithIdentify:(NSString *)identify title:(NSString *)title {
    SSNVMSectionInfo *info = [[SSNVMSectionInfo alloc] init];
    info.identify = identify;
    info.headerTitle = title;
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
    
    if (self.identify == object.identify) {//效率更高
        return YES;
    }
    
    return [self.identify isEqualToString:object.identify];
}

#pragma mark copy
- (id)copyWithZone:(NSZone *)zone {
    SSNVMSectionInfo *copy = [[[self class] alloc] init];
    
    copy.headerTitle = self.headerTitle;
    copy.headerHeight = self.headerHeight;
    copy.hiddenHeader = self.hiddenHeader;
    copy.customHeaderView = self.customHeaderView;
    
    copy.footerTitle = self.footerTitle;
    copy.footerHeight = self.footerHeight;
    copy.hiddenFooter = self.hiddenFooter;
    copy.customFooterView = self.customFooterView;
    copy.identify = self.identify;
    
    [copy.objects setArray:self.objects];
    return copy;
}
@end

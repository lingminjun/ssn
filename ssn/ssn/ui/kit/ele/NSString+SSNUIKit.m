//
//  NSString+SSNUIKit.m
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSString+SSNUIKit.h"

@implementation NSString (SSNUIKit)

- (CGSize)ssn_sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    
    CGSize goal_size = CGSizeMake(maxWidth, 3000);
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary *attributes = @{ NSFontAttributeName:font };
        CGRect rect = [self boundingRectWithSize:goal_size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    CGSize size = [self sizeWithFont:font constrainedToSize:goal_size lineBreakMode:NSLineBreakByWordWrapping];
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
#pragma clang diagnostic pop
    
}

@end

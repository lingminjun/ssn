//
//  UIView+SSNLayoutConstraint.m
//  ssn
//
//  Created by lingminjun on 15/10/17.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIView+SSNLayoutConstraint.h"
//#if TARGET_IPHONE_SIMULATOR
//#import <objc/objc-runtime.h>
//#else
#import <objc/runtime.h>
#import <objc/message.h>
//#endif

NSString *const SSN_REFER_EXCEPTION_NAME = @"SSNReferException";
#define SSN_THROW_E(msg) @throw [[NSException alloc] initWithName:SSN_REFER_EXCEPTION_NAME reason:(msg) userInfo:nil]

@interface SSNRefer : NSObject <SSNLayoutConstraint> {
    __weak UIView *_v;//作用的view
    __weak SSNRefer *_parent;//父约束参照
    
    NSLayoutConstraint *_constraint;//被view持有的约束
    
    NSLayoutAttribute _attribute;

    /*
    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:superview
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:padding.top],
     */
}

@end

@implementation SSNRefer

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _v = view;
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view parent:(SSNRefer *)parent {
    self = [super init];
    if (self) {
        _v = view;
        _parent = parent;
    }
    return self;
}

- (void)equalTo:(id<SSNLayoutConstraint>)refer {
    if ([refer isKindOfClass:[SSNRefer class]]) {
        //
    } else if ([refer isKindOfClass:[NSNumber class]]) {
    } else {
        SSN_THROW_E(@"非法的约束参数");
    }
}
- (void)greaterThanOrEqualTo:(id<SSNLayoutConstraint>)refer {}
- (void)lessThanOrEqualTo:(id<SSNLayoutConstraint>)refer {}

@end




@implementation UIView (SSNLayoutConstraint)

static char *ssn_refers_key = NULL;
- (NSMutableSet *)refers {
    NSMutableSet *refers = objc_getAssociatedObject(self, &ssn_refers_key);
    if (!refers) {
        refers = [NSMutableSet set];
        objc_setAssociatedObject(self, &ssn_refers_key, refers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return refers;
}

@end

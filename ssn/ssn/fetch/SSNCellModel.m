//
//  SSNCellModel.m
//  ssn
//
//  Created by lingminjun on 15/2/23.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNCellModel.h"
//#if TARGET_IPHONE_SIMULATOR
//#import <objc/objc-runtime.h>
//#else
#import <objc/runtime.h>
#import <objc/message.h>
//#endif

/**
 *  协议弱化
 */
@implementation NSObject (SSNCellModel)
/**
 *  对应得cell 类型
 */
- (Class<SSNVMCellProtocol>)cellClass {
    return [UITableViewCell class];
}

- (NSString *)cellNibName {
    return nil;
}

/**
 *  用于UITableView dequeueReusableCellWithIdentifier:方法，方便cell重用，默认用SSNCellModel类名字
 */
- (NSString *)cellIdentify {
    return [NSString stringWithFormat:@"%p",self];
}

/**
 *  行高
 */
- (CGFloat)cellHeight {
    return SSN_VM_CELL_ITEM_DEFAULT_HEIGHT;
}

/**
 *  是否被禁用选择
 */
- (BOOL)isDisabledSelect {
    return NO;
}

/**
 *  是否滑动删除，且删除文案配置，若返回nil表示不支持删除
 */
- (NSString *)cellDeleteConfirmationButtonTitle {
    return nil;
}

/**
 *  用于分组的key
 */
- (NSString *)cellSectionIdentify {
    return NSStringFromClass([self class]);
}
@end


@implementation SSNCellModel


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

- (NSComparisonResult)ssn_compare:(SSNCellModel *)model {
    //默认地址比较
    if (self > model) {
        return NSOrderedDescending;
    }
    else if (self < model) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedSame;
    }
}

@end

@implementation UITableViewCell (SSNVMCellProtocol)

- (void)ssn_configureCellWithModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    //do nothing 
}


- (UIViewController *)ssn_presentingViewController {
    if (!self.superview) {
        return nil;
    }
    
    UIWindow *window = self.window;
    if (window == nil) {
        return nil;
    }
    
    UIView *view = self.superview;
    UITableView *suptable = nil;
    do {
        if ([view isKindOfClass:[UITableView class]]) {
            suptable = (UITableView *)view;
            break ;
        }
        view = view.superview;
    } while (view && view != window);
    
    if (!suptable) {
        return nil;
    }
    
    UIResponder *responder = suptable;
    do {
        responder = responder.nextResponder;
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    } while (responder && responder != window);
    
    return nil;
}

@dynamic ssn_cellModel;
static char *ssn_cell_model_key = NULL;
- (void)setSsn_cellModel:(id<SSNCellModel>)cellModel {
    objc_setAssociatedObject(self, &ssn_cell_model_key, cellModel, OBJC_ASSOCIATION_ASSIGN);
}

- (id<SSNCellModel>)ssn_cellModel {
    /*此方法有点不带*/
    return objc_getAssociatedObject(self, &ssn_cell_model_key);
}

@end

//
//  UIViewController+SSNCategory.m
//  ssn
//
//  Created by lingminjun on 15/3/29.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIViewController+SSNCategory.h"

@implementation UIViewController (SSNCategory)

- (void)ssn_resetBackButtonItemWithTitle:(NSString *)back action:(SEL)action {
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.exclusiveTouch = YES;
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [leftButton setFrame:CGRectMake(0, 7, 80, 30)];
    [leftButton setImage:SSN_NAV_BAR_BACK_BUTTON_IMAGE forState:UIControlStateNormal];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [leftButton.titleLabel setFont:SSN_NAV_BAR_BUTTON_FONT];
    [leftButton setTitleColor:SSN_NAV_BAR_BUTTON_TITLE_COLOR_NORMAL forState:UIControlStateNormal];
    [leftButton setTitleColor:SSN_NAV_BAR_BUTTON_TITLE_COLOR_DISABLED forState:UIControlStateDisabled];
    [leftButton setTitleColor:SSN_NAV_BAR_BUTTON_TITLE_COLOR_SELECTED forState:UIControlStateHighlighted];
    if ([back length]) {
        [leftButton setTitle:back forState:UIControlStateNormal];
    }
    else {
        [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    }
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [leftButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
}


- (UIBarButtonItem *)ssn_barButtonItemWithTitle:(NSString *)title alignment:(UIControlContentHorizontalAlignment)alignment imageName:(NSString *)imageName action:(SEL)action
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGRect frame = CGRectMake(0, 0, 80, 30);
    if (image) {
        frame = CGRectMake(0, 0, image.size.width + 10, image.size.height);
    }
    
    UIButton *btn= [UIButton buttonWithType:UIButtonTypeCustom];
    btn.exclusiveTouch = YES;
    btn.frame = frame;
    
    if (image) {
        [btn setImage:image forState:UIControlStateNormal];
    }
    else {
        [btn setTitle:title forState:UIControlStateNormal];
        [btn.titleLabel setFont:SSN_NAV_BAR_BUTTON_FONT];
        [btn setTitleColor:SSN_NAV_BAR_BUTTON_TITLE_COLOR_NORMAL forState:UIControlStateNormal];
        [btn setTitleColor:SSN_NAV_BAR_BUTTON_TITLE_COLOR_DISABLED forState:UIControlStateDisabled];
        [btn setTitleColor:SSN_NAV_BAR_BUTTON_TITLE_COLOR_SELECTED forState:UIControlStateHighlighted];
        btn.contentHorizontalAlignment = alignment;
        
        if (alignment == UIControlContentHorizontalAlignmentLeft) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        }
        else {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -5)];
        }
    }
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)ssn_addLeftButtonItemWithTitle:(NSString *)title action:(SEL)action {
    UIBarButtonItem *backItem = [self ssn_barButtonItemWithTitle:title alignment:UIControlContentHorizontalAlignmentLeft imageName:nil action:action];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)ssn_addRightButtonItemWithTitle:(NSString *)title action:(SEL)action {
    UIBarButtonItem *backItem = [self ssn_barButtonItemWithTitle:title alignment:UIControlContentHorizontalAlignmentRight imageName:nil action:action];
    self.navigationItem.rightBarButtonItem = backItem;
}

- (void)ssn_addLeftButtonItemWithImageName:(NSString *)imageName action:(SEL)action {
    UIBarButtonItem *backItem = [self ssn_barButtonItemWithTitle:nil alignment:UIControlContentHorizontalAlignmentLeft imageName:imageName action:action];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)ssn_addRightButtonItemWithImageName:(NSString *)imageName action:(SEL)action {
    UIBarButtonItem *backItem = [self ssn_barButtonItemWithTitle:nil alignment:UIControlContentHorizontalAlignmentRight imageName:imageName action:action];
    self.navigationItem.rightBarButtonItem = backItem;
}


@end

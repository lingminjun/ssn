//
//  UIAlertView+SSNCategory.m
//  ssn
//
//  Created by lingminjun on 15/2/10.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//


#import "UIAlertView+SSNCategory.h"
#import <objc/runtime.h>


@interface SSNUIAlertViewDelegate : NSObject//防止委托重名被冲

@property (nonatomic,weak) UIAlertView *alert;

+ (instancetype)delegateAlertView:(UIAlertView *)alert;

@end


@implementation UIAlertView (SSNCategory)

#pragma mark - Showing

/*
 * Shows the receiver alert with the given handler.
 */
static void *k_ssn_handler_key = NULL;
static void *k_ssn_delegate_key = NULL;
- (void)ssn_showWithHandler:(SSNUIAlertViewHandler)handler {
    
    SSNUIAlertViewDelegate *delegate = nil;
    if (handler) {
        delegate = [SSNUIAlertViewDelegate delegateAlertView:self];
    }
    
    objc_setAssociatedObject(self, &k_ssn_handler_key, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &k_ssn_delegate_key, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setDelegate:delegate];
    
    [self show];
}

- (SSNUIAlertViewHandler)ssn_alertHandler {
    return objc_getAssociatedObject(self, &k_ssn_handler_key);
}

#pragma mark - Utility methods

/*
 * Utility selector to show an alert with a title, a message and a button to dimiss.
 */
+ (void)ssn_showWithTitle:(NSString *)title
              message:(NSString *)message
              handler:(SSNUIAlertViewHandler)handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert ssn_showWithHandler:handler];
}

/*
 * Utility selector to show an alert with an "Error" title, a message and a button to dimiss.
 */
+ (void)ssn_showErrorWithMessage:(NSString *)message
                     handler:(SSNUIAlertViewHandler)handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert ssn_showWithHandler:handler];
}

/*
 * Utility selector to show an alert with a "Warning" title, a message and a button to dimiss.
 */
+ (void)ssn_showWarningWithMessage:(NSString *)message
                       handler:(SSNUIAlertViewHandler)handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert ssn_showWithHandler:handler];
}

/*
 * Utility selector to show a confirmation dialog with a title, a message and two buttons to accept or cancel.
 */
+ (void)ssn_showConfirmationDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                handler:(SSNUIAlertViewHandler)handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    [alert ssn_showWithHandler:handler];
}

+ (void)ssn_showConfirmationDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                 cancel:(NSString *)cancel
                                confirm:(NSString *)confirm
                                handler:(SSNUIAlertViewHandler)handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancel
                                          otherButtonTitles:confirm, nil];
    
    [alert ssn_showWithHandler:handler];
}

@end


@implementation SSNUIAlertViewDelegate

+ (instancetype)delegateAlertView:(UIAlertView *)alert {
    SSNUIAlertViewDelegate *del = [[SSNUIAlertViewDelegate alloc] init];
    del.alert = alert;
    return del;
}

#pragma mark - UIAlertViewDelegate

/*
 * Sent to the delegate when the user clicks a button on an alert view.
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    SSNUIAlertViewHandler completionHandler = [alertView ssn_alertHandler];
    
    if (completionHandler != nil) {
        
        completionHandler(alertView, buttonIndex);
    }
}

@end



//
//  UIAlertView+SSNCategory.h
//  ssn
//
//  Created by lingminjun on 15/2/10.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * Completion handler invoked when user taps a button.
 *
 * @param alertView The alert view being shown.
 * @param buttonIndex The index of the button tapped.
 */
typedef void(^SSNUIAlertViewHandler)(UIAlertView *alertView, NSInteger buttonIndex);

/**
 * Category of `UIAlertView` that offers a completion handler to listen to interaction. This avoids the need of the implementation of the delegate pattern.
 *
 * @warning Completion handler: Invoked when user taps a button.
 *
 * typedef void(^SSNUIAlertViewHandler)(UIAlertView *alertView, NSInteger buttonIndex);
 *
 * - *alertView* The alert view being shown.
 * - *buttonIndex* The index of the button tapped.
 */
@interface UIAlertView (SSNCategory)

/**
 * Shows the receiver alert with the given handler.
 *
 * @param handler The handler that will be invoked in user interaction.
 */
- (void)ssn_showWithHandler:(SSNUIAlertViewHandler)handler;

/**
 * Utility selector to show an alert with a title, a message and a button to dimiss.
 *
 * @param title The title of the alert.
 * @param message The message to show in the alert.
 * @param handler The handler that will be invoked in user interaction.
 */
+ (void)ssn_showWithTitle:(NSString *)title message:(NSString *)message handler:(SSNUIAlertViewHandler)handler;

/**
 * Utility selector to show an alert with an "Error" title, a message and a button to dimiss.
 *
 * @param message The message to show in the alert.
 * @param handler The handler that will be invoked in user interaction.
 */
+ (void)ssn_showErrorWithMessage:(NSString *)message handler:(SSNUIAlertViewHandler)handler;

/**
 * Utility selector to show an alert with a "Warning" title, a message and a button to dimiss.
 *
 * @param message The message to show in the alert.
 * @param handler The handler that will be invoked in user interaction.
 */
+ (void)ssn_showWarningWithMessage:(NSString *)message handler:(SSNUIAlertViewHandler)handler;

/**
 * Utility selector to show a confirmation dialog with a title, a message and two buttons to accept or cancel.
 *
 * @param title The title of the alert.
 * @param message The message to show in the alert.
 * @param handler The handler that will be invoked in user interaction.
 */
+ (void)ssn_showConfirmationDialogWithTitle:(NSString *)title message:(NSString *)message handler:(SSNUIAlertViewHandler)handler;

+ (void)ssn_showConfirmationDialogWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm handler:(SSNUIAlertViewHandler)handler;


@end

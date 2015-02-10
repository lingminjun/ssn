//
//  UIApplication+SSNCategory.h
//  ssn
//
//  Created by lingminjun on 15/2/10.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  拓展严谨的代码
 */
@interface UIApplication (SSNCategory)

#pragma mark networkActivityIndicatorVisible Category

/**
 *  显示或者关闭network activity indicator
 *
 *  请不要直接用属性，因为无法混用
 *  @property(nonatomic,getter=isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;
 *
 *  @param visible 是否显示
 *  @param key     标记key
 */
+ (void)ssn_networkActivityIndicatorVisible:(BOOL)visible forKey:(NSString *)key;

/**
 *  在key标记下networkActivityIndicator 是否显示
 *
 *  @param key 标记key
 *
 *  @return 在key下是否表示显示
 */
+ (BOOL)ssn_isNetworkActivityIndicatorVisibleForKey:(NSString *)key;

/**
 *  networkActivityIndicator是否显示
 *
 *  @return 是否显示
 */
+ (BOOL)ssn_isNetworkActivityIndicatorVisible;

#pragma mark ignoringInteractionEvents Category
/**
 *  忽略所有点击响应事件
 *
 *  @param ignoring 是否忽略
 *  @param key      标记key
 */
+ (void)ssn_ignoringInteractionEvents:(BOOL)ignoring forKey:(NSString *)key;

/**
 *  在key标记下ignoringInteractionEvents 时候忽略
 *
 *  @param key 标记key
 *
 *  @return 在key下是否忽略
 */
+ (BOOL)ssn_isIgnoringInteractionEventsForKey:(NSString *)key;

/**
 *  isIgnoringInteractionEvents是否葫芦
 *
 *  @return 是否忽略
 */
+ (BOOL)ssn_isIgnoringInteractionEvents;

@end

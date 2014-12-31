//
//  SSNPanel.h
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNUILayout.h"

/**
 *  实现快速布局，以及所有子元素采用key方式获取，主要应用于视觉布局绑定
 */
@interface UIView (SSNPanel)

//- ()

/**
 *  获取view上面的子view
 *
 *  @param key 子view对应的key
 *
 *  @return 对应key的子view
 */
- (UIView *)subviewForKey:(NSString *)key;

/**
 *  添加子view，默认采用SSNUISiteLayout布局
 *
 *  @param view 添加的子view
 *  @param key  添加子view对应的key
 */
- (void)addSubview:(UIView *)view forKey:(NSString *)key;

/**
 *  添加子view，在layout上
 *
 *  @param view 添加的子view
 *  @param key  添加子view对应的key
 */
//- (void)addSubview:(UIView *)view forKey:(NSString *)key atLayout:(SSNUILayout *)layout;
@end

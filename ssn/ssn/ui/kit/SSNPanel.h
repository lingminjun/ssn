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

/**
 *  获取view上面的子view
 *
 *  @param key 子view对应的key
 *
 *  @return 对应key的子view
 */
- (UIView *)ssn_subviewForKey:(NSString *)key;

/**
 *  返回subview对应的key
 *
 *  @param subview 寻找的subview
 *
 *  @return 返回subview对应的key，不在此view或者找不到返回nil
 */
- (NSString *)ssn_keyOfSubview:(UIView *)subview;

/**
 *  添加子view，默认采用SSNUISiteLayout布局
 *
 *  @param view 添加的子view
 *  @param key  添加子view对应的key
 */
- (void)ssn_addSubview:(UIView *)view forKey:(NSString *)key;

/**
 *  再view层级为index处添加一个子view
 *
 *  @param view 添加子view
 *  @param index 子view的层级
 *  @param key  子view对应key
 */
- (void)ssn_insertSubview:(UIView *)view atIndex:(NSUInteger)index forKey:(NSString *)key;

/**
 *  移除一个子view
 *
 *  @param key view对应的key
 */
- (void)ssn_removeSubviewForKey:(NSString *)key;

/**
 *  返回已创建的布局
 *
 *  @param layoutID 布局ID
 *
 *  @return 返回一个布局ID
 */
- (SSNUILayout *)ssn_layoutForID:(NSString *)layoutID;//

/**
 *  移除一个布局，仅仅移除布局，不会移除子view
 *
 *  @param layoutID 要移除布局的id
 */
- (void)ssn_removeLayoutForID:(NSString *)layoutID;

/**
 *  创建一个流式布局
 *
 *  @return 返回并创建一个流式布局
 */
- (SSNUIFlowLayout *)ssn_flowLayout;

/**
 *  创建一个流式布局
 *
 *  @param rowHeight 行高
 *  @param spacing   间距
 *
 *  @return 返回并创建一个流式布局
 */
- (SSNUIFlowLayout *)ssn_flowLayoutWithRowHeight:(NSUInteger)rowHeight spacing:(NSUInteger)spacing;

/**
 *  创建一个表格布局
 *
 *  @return 返回并创建一个表格布局
 */
- (SSNUITableLayout *)ssn_tableLayout;

/**
 *  创建一个表格布局
 *
 *  @param rowHeight   行高
 *  @param columnCount 不能小于1
 *
 *  @return 返回并创建一个表格布局
 */
- (SSNUITableLayout *)ssn_tableLayoutWithRowHeight:(NSUInteger)rowHeight columnCount:(NSUInteger)columnCount;

@end

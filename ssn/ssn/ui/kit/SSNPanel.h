//
//  SSNPanel.h
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNUILayout.h"
#import "SSNUISiteLayout.h"
#import "SSNUIFlowLayout.h"
#import "SSNUITableLayout.h"

#ifndef _ssn_panel_snippet_
#define _ssn_panel_snippet_

#define ssn_panel_set(panel, subview, property) ssn_panel_set_(panel,subview,property)
#define ssn_panel_get(type, panel, property) ssn_panel_get_(type,panel,property)

#define ssn_layout_into(layout, index, property) ssn_layout_into_(layout,index,property)
#define ssn_layout_add(layout, subview, index, property) ssn_layout_add_(layout, subview, index, property)
#define ssn_layout_add_v2(layout, subview, index, cell, property) ssn_layout_add_v2_(layout, subview, index, cell, property)

#define ssn_layout_table_column(width,mode) [SSNUITableColumnInfo infoWithWidth:(width) contentMode:(mode)]
#define ssn_layout_table_column_v2(width) [SSNUITableColumnInfo infoWithWidth:(width) contentMode:SSNUIContentModeNan]

#define ssn_layout_table_row(height) [SSNUITableRowInfo infoWithHeight:(height)]

#define ssn_layout_table_cell(top, left, bottom, right, mode) [SSNUITableCellInfo infoWithContentInset:UIEdgeInsetsMake(top, left, bottom, right) contentMode:mode]
#define ssn_layout_table_cell_v2(mode) [SSNUITableCellInfo infoWithContentInset:UIEdgeInsetsZero contentMode:mode]

#define ssn_panel_set_(v,s,p) [(v) ssn_addSubview:(s) forKey: @#p ]
#define ssn_panel_get_(t,v,p) ((t *)[(v) ssn_subviewForKey: @#p ])

#define ssn_layout_into_(l,i,p) [(l) moveSubviewToIndex:(i) forKey: @#p ]
#define ssn_layout_add_(l,s,i,p) [(l) insertSubview:(s) atIndex:(i) forKey: @#p ]
#define ssn_layout_add_v2_(l, s, i, c, p) [(l) insertSubview:(s) atIndex:(i) cellInfo:(c) forKey: @#p ]

#endif

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
 *  创建一个流式布局
 *
 *  @param rowCount 行数
 *  @param spacing  间距
 *
 *  @return 返回并创建一个流式布局
 */
- (SSNUIFlowLayout *)ssn_flowLayoutWithRowCount:(NSUInteger)rowCount spacing:(NSUInteger)spacing;

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
- (SSNUITableLayout *)ssn_tableLayoutWithDefaultRowHeight:(NSUInteger)rowHeight columnCount:(NSUInteger)columnCount;

/**
 *  创建一个表格布局
 *
 *  @param rowCount    行数，填零表示不限制
 *  @param columnCount 不能小于1
 *
 *  @return 返回并创建一个表格布局
 */
- (SSNUITableLayout *)ssn_tableLayoutWithRowCount:(NSUInteger)rowCount columnCount:(NSUInteger)columnCount;

/**
 *  view 加载布局的实际，一个view此方法只会调用一次
 *  UIView中此方法什么也没做
 */
- (void)ssn_layoutDidLoad;

@end


/**
 *  控制器布局委托
 */
@interface UIViewController (SSNUILayout)

/**
 *  viewDidLoad后，viewWillAppear前调用，建议在方法中加载想要的布局
 *  被调用次数和viewDidLoad一直
 *  viewController中此方法什么也没做
 */
- (void)ssn_layoutDidLoad;

@end

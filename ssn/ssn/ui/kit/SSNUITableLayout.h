//
//  SSNUITableLayout.h
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNUILayout.h"

@class SSNUITableRowInfo,SSNUITableColumnInfo,SSNUITableCellInfo;

/**
 *  表格布局描述，所有元素只能被安放到单元格中，列是自增的，行数必须被限定，默认只有一行
 */
@interface SSNUITableLayout : SSNUILayout

/**
 *  行数，默认值为零，表示不限行数，如果设置，则认为是固定行数的表，固定行列表宽度可以自适应
 */
@property (nonatomic) NSUInteger rowCount;

/**
 *  表行高，默认行高44，如果rowCount大于零（固定行表），行高默认是剩余平均值
 *  剩余平均值 = (panel总高度 - 设定行高的行高之和 ) / 没有设定行高的行数
 *  （注意：并不一定是高度，如果orientation为left或者right，实际指的是宽度）
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) NSUInteger defaultRowHeight;

/**
 *  列数，默认值是1，（注意：并不一定是列数，如果orientation为left或者right，实际指的是行数）
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) NSUInteger columnCount;

/**
 *  表格中所有单元格的依赖关系，若列中单独定义，将参照列依赖，挼单元格中定义依赖，则参照单元格以来，默认值SSNUIContentModeNan
 */
@property (nonatomic) SSNUIContentMode contentMode;

/**
 *  行属性
 *
 *  @param row 行数，取值[0～(rowCount-1)]
 *
 *  @return 第row行属性
 */
- (SSNUITableRowInfo *)rowInfoAtRow:(NSUInteger)row;

/**
 *  设置行的属性，设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 *
 *  @param rowInfo  行属性  [不允许为空]
 *  @param row      行数，取值[0～(rowCount-1)]
 */
- (void)setRowInfo:(SSNUITableRowInfo *)rowInfo atRow:(NSUInteger)row;

/**
 *  列属性
 *
 *  @param column 列数，取值[0～(columnCount-1)]
 *
 *  @return 第column列的列属性
 */
- (SSNUITableColumnInfo *)columnInfoAtColumn:(NSUInteger)column;

/**
 *  设置列的属性，设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 *
 *  @param columnInfo  列属性  [不允许为空]
 *  @param column      列数取值[0～(columnCount-1)]
 */
- (void)setColumnInfo:(SSNUITableColumnInfo *)columnInfo atColumn:(NSUInteger)column;

/**
 *  index位置上单元格属性
 *
 *  @param index 从0开始数，每行column个单元格，直到index
 *
 *  @return 返回对应单元格属性
 */
- (SSNUITableCellInfo *)cellInfoAtIndex:(NSUInteger)index;

/**
 *  设置对应单元格属性，设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 *
 *  @param cellInfo 要设置的属性 [不允许为空]
 *  @param index    单元格位置
 */
- (void)setCellInfo:(SSNUITableCellInfo *)cellInfo atIndex:(NSUInteger)index;

/**
 *  添加子view到对应的单元格中，并且设置单元格属性
 *
 *  @param view     添加的子view [不允许为空]
 *  @param index    单元格位置
 *  @param cellInfo 单元格属性，可以为空
 *  @param key      添加view的key [不允许为空]
 */
- (void)insertSubview:(UIView *)view atIndex:(NSUInteger)index cellInfo:(SSNUITableCellInfo *)cellInfo forKey:(NSString *)key;

@end


@interface SSNUITableRowInfo : NSObject<NSCopying>

/**
 *  行高度，为0时分两种情况，若表默认行高等于0，表示自动计算剩余平均值，若表默认行高有值，则采用默认行高，默认值0
 */
@property (nonatomic) NSUInteger height;

/**
 *  返回一个表布局行属性
 *
 *  @param height       行高
 *
 *  @return 列属性
 */
+ (instancetype)infoWithHeight:(NSUInteger)height;

@end


/**
 *  表布局中列属性定义
 */
@interface SSNUITableColumnInfo : NSObject<NSCopying>

/**
 *  列宽度，为0时表示自动计算，剩余平均值，默认值0
 */
@property (nonatomic) NSUInteger width;

/**
 *  列所有单元格中元素布局模型，依赖方向，默认值是SSNUIContentModeNan
 *  da
 */
@property (nonatomic) SSNUIContentMode contentMode;

/**
 *  返回一个表布局列属性
 *
 *  @param width       列宽度
 *  @param contentMode 列元素依赖
 *
 *  @return 列属性
 */
+ (instancetype)infoWithWidth:(NSUInteger)width contentMode:(SSNUIContentMode)contentMode;

@end

/**
 *  单元格属性
 */
@interface SSNUITableCellInfo : NSObject<NSCopying>

/**
 *  内容边线控制，所有值大于零
 */
@property (nonatomic) UIEdgeInsets contentInset;

/**
 *  元素布局模型，依赖方向，默认值是SSNUIContentModeNan，
 *  注意若contentMode==SSNUIContentModeScaleToFill，且subview的autoresizingMask可以拉升，将会被改变subview尺寸
 */
@property (nonatomic) SSNUIContentMode contentMode;

/**
 *  单元格的当前的frame（会随着panel变化而改变）
 *
 *  @return 返回当前单元格的大小
 */
- (CGRect)cellFrame;

/**
 *  单元格中的subview，每个单元格中只能放一个子view，当有新的view添加进来时，前一个将被推倒下一个单元格
 *
 *  @return 当前单元格的subview
 */
- (UIView *)subview;

/**
 *  返回一个表布局列单元格属性
 *
 *  @param contentInset 单元格内边距
 *  @param contentMode 单元格元素依赖
 *
 *  @return 单元格属性
 */
+ (instancetype)infoWithContentInset:(UIEdgeInsets)contentInset contentMode:(SSNUIContentMode)contentMode;

@end


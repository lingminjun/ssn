//
//  SSNUILayout.h
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  元素布局模型
 */
typedef NS_ENUM(NSUInteger, SSNUIContentMode){
    /**
     *  依靠左上角
     */
    SSNUIContentModeTopLeft,
    /**
     *  依靠右上角
     */
    SSNUIContentModeTopRight,
    /**
     *  依靠左下角
     */
    SSNUIContentModeBottomLeft,
    /**
     *  依靠右下角
     */
    SSNUIContentModeBottomRight,
    /**
     *  填充
     */
    SSNUIContentModeScaleToFill,
    /**
     *  居中
     */
    SSNUIContentModeCenter,
    /**
     *  上边依靠
     */
    SSNUIContentModeTop,
    /**
     *  下边依靠
     */
    SSNUIContentModeBottom,
    /**
     *  左边依靠
     */
    SSNUIContentModeLeft,
    /**
     *  右边依靠
     */
    SSNUIContentModeRight,
};

/**
 *  布局计算方向，画布坐标系方向（x,y），注意，此处x,y与View frame的x,y有区别
 *  如果直接转动手机，看括号中的解释，始终保持坐标系x,y是从左到右，从上到下
 */
typedef NS_ENUM(NSInteger, SSNUILayoutOrientation){
    /**
     *  正向的，x:从左到右（isReverse时从右往左），y:从上到下，（将手机正放，home键在下面，x:从左到右，y:从上到下）
     */
    SSNUILayoutOrientationPortrait           = 0,
    /**
     *  颠倒的，x:从右往左（isReverse时从左往右），y:从下到上，（将手机倒放，home键在上面，x:从左到右，y:从上到下）
     */
    SSNUILayoutOrientationPortraitUpsideDown = 1,
    /**
     *  向左的，x:从上往下（isReverse时从下往上），y:从右至左，（将手机左转放平，home键在右边，x:从左到右，y:从上到下）
     */
    SSNUILayoutOrientationLandscapeLeft      = 2,
    /**
     *  向右的，x:从下往上（isReverse时从上往下），y:从左至右，（将手机右转放平，home键在左边，x:从左到右，y:从上到下）
     */
    SSNUILayoutOrientationLandscapeRight     = 3,
};

/**
 *  布局描述，只能依附属于view存在
 */
@interface SSNUILayout : NSObject

/**
 *  返回当前layout的id
 *
 *  @return 返回layoutid
 */
- (NSString *)layoutID;

/**
 *  一个布局只能应用于一个view上面
 *
 *  @return 返回作用的view上面
 */
- (UIView *)panel;

/**
 *  所有参与此类布局的子view
 *
 *  @return 所有参与此类布局的子view @see UIView
 */
- (NSArray *)subviews;

/**
 *  获取view所在的布局对象，返回nil可能是在位置布局上也可能是不在任何布局
 *
 *  @param view 一个子view
 *
 *  @return 返回view所在的布局对象
 */
+ (SSNUILayout *)dependentLayoutWithView:(UIView *)view;

/**
 *  添加子view到此布局中，并且加入到UIView上面，已经在UIView上的子view，仅仅添加到布局，不改变它在原来UIView中的层级
 *
 *  @param view 添加子view
 *  @param key  子view对应key
 */
- (void)addSubview:(UIView *)view forKey:(NSString *)key;

/**
 *  增加一个子view到对应的位置上，只是布局位置上的插入，与view层级没关系
 *  已经在UIView上的子view，仅仅添加到布局，不改变它在原来UIView中的层级
 *
 *  @param view 添加子view
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key  子view对应key
 */
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index forKey:(NSString *)key;

/**
 *  移动一个字view到某个位置上，只是布局位置上的移动，与view层级没关系
 *
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key   子view对应key，找不到view忽略
 */
- (void)moveSubviewToIndex:(NSInteger)index forKey:(NSString *)key;

/**
 *  将一个子view移除此布局且从panel中移除
 *
 *  @param key 需要移除的key
 */
- (void)removeSubviewForKey:(NSString *)key;

/**
 *  将一个子view移除此布局，不从panel中移除
 *
 *  @param key 需要移除的key
 */
- (void)moveOutSubviewForKey:(NSString *)key;

/**
 *  画布边界预留值，根据不同布局模型发生起作用，默认值UIEdgeInsetsZero. 所有值需大于等于零
 */
@property (nonatomic) UIEdgeInsets contentInset;

/**
 *  布局计算方向，布局坐标系方向，不会旋转子view，仅仅是布局坐标方向
 */
@property (nonatomic) SSNUILayoutOrientation orientation;

/**
 *  布局"x"轴逆向执行
 */
@property (nonatomic) BOOL isXReverse;

/**
 *  布局所有子view
 */
- (void)layoutSubviews;

@end

/**
 *  位置布局描述，遵从苹果自带的autolayout布局
 */
@interface SSNUISiteLayout : SSNUILayout

@end


/**
 *  流式布局描述，所有被布局元素按照一定顺序依次排列，没有行数限定
 */
@interface SSNUIFlowLayout : SSNUILayout

/**
 *  行高，流式布局中，按照行高进行换行，默认行号44，（注意：并不一定是高度，如果orientation为left或者right，实际指的是宽度）
 */
@property (nonatomic) NSUInteger rowHeight;

/**
 *  元素之间的间距，横向的间距，默认值时8，（注意：并不一定是宽度，如果orientation为left或者right，实际指的是高度）
 */
@property (nonatomic) NSUInteger spacing;//

/**
 *  元素布局模型，依赖方向，默认值是SSNUIContentModeTopLeft
 */
@property (nonatomic) SSNUIContentMode contentMode;

@end


/**
 *  表格布局列属性定义
 */
@class SSNUITableColumnInfo;

/**
 *  表格布局描述，所有元素只能被安放到单元格中，列是自增的，行数必须被限定，默认只有一行
 */
@interface SSNUITableLayout : SSNUILayout

/**
 *  行高，流式布局中，按照行高进行换行，默认行号44，（注意：并不一定是高度，如果orientation为left或者right，实际指的是宽度）
 */
@property (nonatomic) NSUInteger rowHeight;

/**
 *  列数，默认值是1，（注意：并不一定是列数，如果orientation为left或者right，实际指的是行数）
 */
@property (nonatomic) NSUInteger columnCount;

/**
 *  元素布局模型，依赖方向，默认值是SSNUIContentModeTopLeft
 *
 *  @param column 列数，取值[0～(columnCount-1)]
 *
 *  @return 第column列的布局模型，
 */
- (SSNUITableColumnInfo *)columnInfoAtColumn:(NSUInteger)column;

/**
 *  设置每一列中布局模型
 *
 *  @param contentMode 设置的布局模型
 *  @param column      列数取值[0～(columnCount-1)]
 */
- (void)setColumnInfo:(SSNUITableColumnInfo *)columnInfo atColumn:(NSUInteger)column;

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
 *  内容边线控制
 */
@property (nonatomic) UIEdgeInsets contentInset;

/**
 *  元素布局模型，依赖方向，默认值是SSNUIContentModeTopLeft
 */
@property (nonatomic) SSNUIContentMode contentMode;

@end



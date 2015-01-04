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
     *  默认以来，默认一般使用SSNUIContentModeTopLeft
     */
    SSNUIContentModeNan,
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
typedef NS_ENUM(NSUInteger, SSNUILayoutOrientation){
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
 *  @param view 添加子view [不允许为空]
 *  @param key  子view对应key [不允许为空]
 */
- (void)addSubview:(UIView *)view forKey:(NSString *)key;

/**
 *  增加一个子view到对应的位置上，只是布局位置上的插入，与view层级没关系
 *  已经在UIView上的子view，仅仅添加到布局，不改变它在原来UIView中的层级
 *
 *  @param view 添加子view [不允许为空]
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key  子view对应key [不允许为空]
 */
- (void)insertSubview:(UIView *)view atIndex:(NSUInteger)index forKey:(NSString *)key;

/**
 *  移动一个字view到某个位置上，只是布局位置上的移动，与view层级没关系
 *
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key   子view对应key，找不到view忽略
 */
- (void)moveSubviewToIndex:(NSUInteger)index forKey:(NSString *)key;

/**
 *  返回此布局中的subview
 *
 *  @param key subview的key
 *
 *  @return 在此布局中的subview，找不到返回nil
 */
- (UIView *)subviewForKey:(NSString *)key;

/**
 *  返回key对应subview在此布局中的位置
 *
 *  @param key subview的key
 *
 *  @return 布局中的位置，找不到时返回NSNotFound
 */
- (NSUInteger)indexForKey:(NSString *)key;

/**
 *  返回subview在此布局中的位置
 *
 *  @param subview 需要寻找的subview
 *
 *  @return 布局中的位置，找不到时返回NSNotFound
 */
- (NSUInteger)indexOfSubview:(UIView *)subview;

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
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) UIEdgeInsets contentInset;

/**
 *  布局计算方向，布局坐标系方向，不会旋转子view，仅仅是布局坐标方向
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) SSNUILayoutOrientation orientation;

/**
 *  布局"x"轴（行中元素反向）逆向执行
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) BOOL isRowReverse;

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
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) NSUInteger rowHeight;

/**
 *  元素之间的间距，横向的间距，默认值时8，（注意：并不一定是宽度，如果orientation为left或者right，实际指的是高度）
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) NSUInteger spacing;//

/**
 *  元素布局模型，依赖方向，默认值是SSNUIContentModeNan
 */
@property (nonatomic) SSNUIContentMode contentMode;

@end



@class SSNUITableColumnInfo,SSNUITableCellInfo;

/**
 *  表格布局描述，所有元素只能被安放到单元格中，列是自增的，行数必须被限定，默认只有一行
 */
@interface SSNUITableLayout : SSNUILayout

/**
 *  行高，流式布局中，按照行高进行换行，默认行号44，（注意：并不一定是高度，如果orientation为left或者right，实际指的是宽度）
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) NSUInteger rowHeight;

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

@end



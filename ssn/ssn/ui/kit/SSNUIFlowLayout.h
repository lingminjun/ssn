//
//  SSNUIFlowLayout.h
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNUILayout.h"

/**
 *  流式布局描述，所有被布局元素按照一定顺序依次排列，没有行数限定
 */
@interface SSNUIFlowLayout : SSNUILayout

/**
 *  流式布局行高，默认行高44，默认行号44，
 *  如果rowCount大于零（固定行表），行高默认是剩余平均值
 *  剩余平均值 = (panel总高度 - 设定行高的行高之和 ) / 没有设定行高的行数
 *（注意：并不一定是高度，如果orientation为left或者right，实际指的是宽度）
 *  设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 */
@property (nonatomic) NSUInteger rowHeight;

/**
 *  行数，默认值为零，表示不限行数，如果设置，则认为是固定行数的流式布局，固定行布局宽度切rowHeight为零时高度可自适应
 */
@property (nonatomic) NSUInteger rowCount;

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

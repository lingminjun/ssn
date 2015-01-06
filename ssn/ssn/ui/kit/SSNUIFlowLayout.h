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

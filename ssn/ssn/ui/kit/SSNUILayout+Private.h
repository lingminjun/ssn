//
//  SSNUILayout+Private.h
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNUILayout.h"

#define ssn_ui_layout_next_row_rect(rect,hor,asc,hgt) do{\
if (hor)    { if (asc) { rect.origin.y += rect.size.height; } else { rect.origin.y -= rect.size.height; } rect.size.height = hgt; }\
else        { if (asc) { rect.origin.x += rect.size.width; } else { rect.origin.x -= rect.size.width; } rect.size.width = hgt; }\
}while(0)


@interface SSNUILayout ()

/**
 *  返回行宽
 *
 *  @return 返回行宽
 */
- (NSUInteger)row_width;

/**
 *  返回列宽
 *
 *  @return 返回列宽
 */
- (NSUInteger)column_width;

/**
 *  返回第一行的rect坐标
 *
 *  @return 返回第一行的rect坐标
 */
- (CGRect)firstRowRectWithRowHeight:(NSUInteger)rowHeight;

/**
 *  列方向上是否为递增
 *
 *  @return 列方是否为递增
 */
- (BOOL)isColumnASC;

/**
 *  行方向上是否递增
 *
 *  @return 行是否递增排列
 */
- (BOOL)isRowASC;

/**
 *  是否按照水平方向计算行
 *
 *  @return 如果x方向是行的话返回YES，否则返回NO
 */
- (BOOL)isHOR;

/**
 *  在一固定的rect中布局一个元素
 *
 *  @param view        需要布局的元素
 *  @param rect        行尺寸
 *  @param contentMode 数据依靠点
 */
- (void)layoutSubview:(UIView *)view inRect:(CGRect)rect contentMode:(SSNUIContentMode)contentMode;

@end


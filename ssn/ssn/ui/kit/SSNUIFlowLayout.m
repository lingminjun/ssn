//
//  SSNUIFlowLayout.m
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNUIFlowLayout.h"
#import "UIView+SSNUIFrame.h"
#import "SSNUILayout+Private.h"

@implementation SSNUIFlowLayout

- (NSUInteger)rowHeight {
    if (_rowCount == 0) {//不限行数，默认值为44，限制行数后，要计算得出
        if (_rowHeight == 0) {
            return 44;
        }
    }
    else {
        if (_rowHeight == 0) {
            NSUInteger panel_height = [self column_width];
            return floorf((panel_height * 1.0f)/_rowCount);
        }
    }
    
    return _rowHeight;
}

- (void)setSpacing:(NSUInteger)spacing {
    if (spacing == 0) {
        _spacing = 8;
    }
    else {
        _spacing = spacing;
    }
}

- (void)layoutRowviews:(NSArray *)subviews inRow:(CGRect)rect sumViewWidth:(CGFloat)sumViewWidth isHOR:(BOOL)isHOR {
    __block CGRect row_rect = rect;
    
    NSInteger view_count = [subviews count];
    
    BOOL isReverse = YES;//是否需要反向排列
    SSNUIContentMode contentMode = _contentMode;
    switch (_contentMode) {
        case SSNUIContentModeNan:
        case SSNUIContentModeTopLeft: {
            isReverse = NO;
        } break;
        case SSNUIContentModeTopRight: {
            if (isHOR) {
                isReverse = YES;
            }else {
                isReverse = NO;
            }
        } break;
        case SSNUIContentModeBottomLeft: {
            if (isHOR) {
                isReverse = NO;
            }else {
                isReverse = YES;
            }
        } break;
        case SSNUIContentModeBottomRight: {
            if (isHOR) {
                isReverse = YES;
            }else {
                isReverse = YES;
            }
        } break;
        case SSNUIContentModeScaleToFill:
        case SSNUIContentModeCenter: {//需要转换成依赖左边布局
            if (isHOR) {
                isReverse = NO;
                
                contentMode = SSNUIContentModeLeft;
                
                if (row_rect.size.width >= sumViewWidth + ((view_count - 1)*_spacing)) {
                    row_rect.origin.x += (row_rect.size.width - (sumViewWidth + (view_count - 1)*_spacing))/2;
                    row_rect.size.width = sumViewWidth + ((view_count - 1)*_spacing);
                }
                else {//肯定只有一个元素的情况
                    row_rect.origin.x -= ((sumViewWidth + (view_count - 1)*_spacing) - row_rect.size.width)/2;
                }
            }
            else {
                isReverse = NO;
                
                contentMode = SSNUIContentModeTop;
                
                if (row_rect.size.height >= sumViewWidth + ((view_count - 1)*_spacing)) {
                    row_rect.origin.y += (row_rect.size.height - (sumViewWidth + (view_count - 1)*_spacing))/2;
                    row_rect.size.height = sumViewWidth + ((view_count - 1)*_spacing);
                }
                else {//肯定只有一个元素的情况
                    row_rect.origin.y -= ((sumViewWidth + (view_count - 1)*_spacing) - row_rect.size.height)/2;
                }
            }
        } break;
        case SSNUIContentModeTop: {
            if (isHOR) {
                isReverse = NO;
                
                contentMode = SSNUIContentModeTopLeft;
                
                if (row_rect.size.width >= sumViewWidth + ((view_count - 1)*_spacing)) {
                    row_rect.origin.x += (row_rect.size.width - (sumViewWidth + (view_count - 1)*_spacing))/2;
                    row_rect.size.width = sumViewWidth + ((view_count - 1)*_spacing);
                }
                else {//肯定只有一个元素的情况
                    row_rect.origin.x -= ((sumViewWidth + (view_count - 1)*_spacing) - row_rect.size.width)/2;
                }
            }
            else {
                isReverse = NO;
            }
        } break;
        case SSNUIContentModeBottom: {
            if (isHOR) {
                isReverse = NO;
                
                contentMode = SSNUIContentModeBottomLeft;
                
                if (row_rect.size.width >= sumViewWidth + ((view_count - 1)*_spacing)) {
                    row_rect.origin.x += (row_rect.size.width - (sumViewWidth + (view_count - 1)*_spacing))/2;
                    row_rect.size.width = sumViewWidth + ((view_count - 1)*_spacing);
                }
                else {//肯定只有一个元素的情况
                    row_rect.origin.x -= ((sumViewWidth + (view_count - 1)*_spacing) - row_rect.size.width)/2;
                }
            }
            else {
                isReverse = YES;
            }
        } break;
        case SSNUIContentModeLeft: {
            if (isHOR) {
                isReverse = NO;
            }
            else {
                isReverse = NO;
                
                contentMode = SSNUIContentModeTopLeft;
                
                if (row_rect.size.height >= sumViewWidth + ((view_count - 1)*_spacing)) {
                    row_rect.origin.y += (row_rect.size.height - (sumViewWidth + (view_count - 1)*_spacing))/2;
                    row_rect.size.height = sumViewWidth + ((view_count - 1)*_spacing);
                }
                else {//肯定只有一个元素的情况
                    row_rect.origin.y -= ((sumViewWidth + (view_count - 1)*_spacing) - row_rect.size.height)/2;
                }
            }
        } break;
        case SSNUIContentModeRight: {
            if (isHOR) {
                isReverse = YES;
            }
            else {
                isReverse = NO;
                
                contentMode = SSNUIContentModeTopRight;
                
                if (row_rect.size.height >= sumViewWidth + ((view_count - 1)*_spacing)) {
                    row_rect.origin.y += (row_rect.size.height - (sumViewWidth + (view_count - 1)*_spacing))/2;
                    row_rect.size.height = sumViewWidth + ((view_count - 1)*_spacing);
                }
                else {//肯定只有一个元素的情况
                    row_rect.origin.y -= ((sumViewWidth + (view_count - 1)*_spacing) - row_rect.size.height)/2;
                }
            }
        } break;
        default:
            break;
    }
    
    NSArray *rowviews = subviews;
    if (self.isRowReverse) {
        rowviews = [[subviews reverseObjectEnumerator] allObjects];
    }
    
    void (^block)(UIView *view, NSUInteger idx, BOOL *stop) = ^(UIView *view, NSUInteger idx, BOOL *stop) {
        [self layoutSubview:view inRect:row_rect contentMode:contentMode];
        
        if (isHOR) {
            row_rect.size.width -= view.ssn_width + _spacing;
        }
        else {
            row_rect.size.height -= view.ssn_height + _spacing;
        }
        
        if (!isReverse) {
            if (isHOR) {
                row_rect.origin.x += view.ssn_width + _spacing;
            }
            else {
                row_rect.origin.y += view.ssn_height + _spacing;
            }
        }
    };
    
    if (isReverse) {
        [rowviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:block];
    }
    else {
        [rowviews enumerateObjectsUsingBlock:block];
    }
}

/**
 *  布局所有子view，overwite
 */
- (void)layoutSubviews {
    
    UIView *superview = [self panel];
    if (!superview) {
        return ;
    }
    
    NSInteger row_width = [self row_width];
    
    NSUInteger rowHeight = self.rowHeight;
    
    //布局
    CGRect rect = [self firstRowRectWithRowHeight:rowHeight];
    BOOL isHOR = [self isHOR];
    BOOL isRowASC = [self isRowASC];
    
    //布局所有的子view
    NSArray *subviews = [self subviews];
    
    NSInteger cost_width = 0;
    
    NSMutableArray *rowviews = [NSMutableArray array];//用于存放一行的数据
    NSInteger sum_view_width = 0;
    
    for (UIView *view in subviews) {
        
    SSN_GOTO_FLAG:
        
        cost_width += isHOR ? view.ssn_width : view.ssn_height;
        
        if (cost_width >= row_width) {//换行
            
            BOOL reCheck = YES;
            if (cost_width == row_width || [rowviews count] == 0) {
                sum_view_width += isHOR ? view.ssn_width : view.ssn_height;
                [rowviews addObject:view];
                
                reCheck = NO;
            }
            
            //处理当前行
            [self layoutRowviews:rowviews inRow:rect sumViewWidth:sum_view_width isHOR:isHOR];
            
            //换行处理
            ssn_ui_layout_next_row_rect(rect, isHOR, isRowASC, rowHeight);
            cost_width = 0;
            sum_view_width = 0;
            [rowviews removeAllObjects];
            
            if (reCheck) {//直接到下一行处理
                goto SSN_GOTO_FLAG;
            }
        }
        else {//不换行
            cost_width += _spacing;//加上间距
            sum_view_width += isHOR ? view.ssn_width : view.ssn_height;
            [rowviews addObject:view];
        }
    }
    
    //处理最后剩余部分
    if ([rowviews count]) {
        [self layoutRowviews:rowviews inRow:rect sumViewWidth:sum_view_width isHOR:isHOR];
    }
}

@end

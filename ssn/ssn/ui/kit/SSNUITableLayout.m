//
//  SSNUITableLayout.m
//  ssn
//
//  Created by lingminjun on 15/1/6.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNUITableLayout.h"
#import "UIView+SSNUIFrame.h"
#import "SSNPanel.h"
#import "SSNUILayout+Private.h"

#pragma mark table 布局
@interface SSNUITableCellInfo ()
@property (nonatomic,weak) SSNUITableLayout *layout;
@property (nonatomic,copy) NSString *key;
@property (nonatomic,strong) UIView *subview;
@property (nonatomic) NSUInteger index;
@end

@implementation SSNUITableLayout {
    NSMutableDictionary *_rowInfos;
    NSMutableDictionary *_columnInfos;
    NSMutableDictionary *_cellInfos;
}

#define SSNUITableLayoutSynthesize(p) \
- (NSMutableDictionary *) p { if (_##p) { return _##p; } _##p = [[NSMutableDictionary alloc] initWithCapacity:1]; return _##p; }

SSNUITableLayoutSynthesize(rowInfos)
SSNUITableLayoutSynthesize(columnInfos)
SSNUITableLayoutSynthesize(cellInfos)

- (NSUInteger)defaultRowHeight {
    if (_rowCount == 0) {//不限行数，默认值为44，限制行数后，要计算得出
        if (_defaultRowHeight == 0) {
            _defaultRowHeight = 44;
        }
    }
    
    return _defaultRowHeight;
}

- (void)setColumnCount:(NSUInteger)columnCount {
    if (columnCount == 0) {
        _columnCount = 1;
    }
    else {
        _columnCount = columnCount;
    }
}

/**
 *  行属性
 *
 *  @param row 行数，取值[0～(rowCount-1)]
 *
 *  @return 第row行属性
 */
- (SSNUITableRowInfo *)rowInfoAtRow:(NSUInteger)row {
    return [[_rowInfos objectForKey:@(row)] copy];
}

/**
 *  设置行的属性，设置时不会主动刷新界面，如果需要刷新界面请调用-layoutSubviews方法重新布局
 *
 *  @param rowInfo  行属性  [不允许为空]
 *  @param row      行数，取值[0～(rowCount-1)]
 */
- (void)setRowInfo:(SSNUITableRowInfo *)rowInfo atRow:(NSUInteger)row {
    [[self rowInfos] setObject:[rowInfo copy] forKey:@(row)];
}

/**
 *  元素布局模型，依赖方向，默认值是SSNUIContentModeTopLeft
 *
 *  @param column 列数，取值[0～(columnCount-1)]
 *
 *  @return 第column列的布局模型，
 */
- (SSNUITableColumnInfo *)columnInfoAtColumn:(NSUInteger)column {
    return [[_columnInfos objectForKey:@(column)] copy];
}

/**
 *  设置每一列中布局模型
 *
 *  @param contentMode 设置的布局模型
 *  @param column      列数取值[0～(columnCount-1)]
 */
- (void)setColumnInfo:(SSNUITableColumnInfo *)columnInfo atColumn:(NSUInteger)column {
    [[self columnInfos] setObject:[columnInfo copy] forKey:@(column)];
}

/**
 *  index位置上单元格属性
 *
 *  @param index 从0开始数，每行column个单元格，直到index
 *
 *  @return 返回对应单元格属性
 */
- (SSNUITableCellInfo *)cellInfoAtIndex:(NSUInteger)index {
    return [[_cellInfos objectForKey:@(index)] copy];
}

/**
 *  设置对应单元格属性
 *
 *  @param cellInfo 要设置的属性
 *  @param index    单元格位置
 */
- (void)setCellInfo:(SSNUITableCellInfo *)cellInfo atIndex:(NSUInteger)index {
    SSNUITableCellInfo *old_cell = [self.cellInfos objectForKey:@(index)];
    if (old_cell) {
        old_cell.contentInset = cellInfo.contentInset;
        old_cell.contentMode = cellInfo.contentMode;
    }
    else {
        SSNUITableCellInfo *cell = [cellInfo copy];
        cell.layout = self;
        cell.index = index;
        [self.cellInfos setObject:cell forKey:@(index)];
    }
}

/**
 *  添加子view到对应的单元格中，并且设置单元格属性
 *
 *  @param view     添加的子view
 *  @param index    单元格位置
 *  @param cellInfo 单元格属性
 *  @param key      添加view的key
 */
- (void)insertSubview:(UIView *)view atIndex:(NSUInteger)index cellInfo:(SSNUITableCellInfo *)cellInfo forKey:(NSString *)key {
    SSNUITableCellInfo *old_cell = [self.cellInfos objectForKey:@(index)];
    
    if (old_cell && old_cell.subview) {//原来的cell上已经存在某个view需要移动到下一个cell
        [self moveSubviewToIndex:(index + 1) forKey:old_cell.key];
    }
    
    if (old_cell) {
        old_cell.subview = view;
        old_cell.key = key;
        
        if (cellInfo) {
            old_cell.contentInset = cellInfo.contentInset;
            old_cell.contentMode = cellInfo.contentMode;
        }
    }
    else {
        SSNUITableCellInfo *cell = [cellInfo copy];
        if (!cell) {
            cell = [[SSNUITableCellInfo alloc] init];
        }
        cell.layout = self;
        cell.index = index;
        cell.subview = view;
        cell.key = key;
        [self.cellInfos setObject:cell forKey:@(index)];
    }
    
    [super insertSubview:view atIndex:index forKey:key];
}

#pragma mark 重载父亲类实现
/**
 *  返回key对应subview所在的table布局中的位置
 *
 *  @param key subview的key
 *
 *  @return table布局中的位置，单元格下标，找不到时返回NSNotFound
 */
- (NSUInteger)indexForKey:(NSString *)key {
    UIView *subview = [self subviewForKey:key];
    if (!subview) {
        return NSNotFound;
    }
    
    for (NSNumber *index in [_cellInfos allKeys]) {
        SSNUITableCellInfo *cell = [_cellInfos objectForKey:index];
        
        if ([cell.key isEqualToString:key]) {
            return [index unsignedIntegerValue];
        }
    }
    
    return NSNotFound;
}

/**
 *  返回subview对应的单元格下标
 *
 *  @param subview 需要寻找的subview
 *
 *  @return table布局中的位置，单元格下标，找不到时返回NSNotFound
 */
- (NSUInteger)indexOfSubview:(UIView *)subview {
    if (subview.superview != [self panel]) {
        return NSNotFound;
    }
    
    for (NSNumber *index in [_cellInfos allKeys]) {
        SSNUITableCellInfo *cell = [_cellInfos objectForKey:index];
        
        if (cell.subview == subview) {
            return [index unsignedIntegerValue];
        }
    }
    
    return NSNotFound;
}

/**
 *  添加子view到此布局中，并且加入到UIView上面，已经在UIView上的子view，仅仅添加到布局，不改变它在原来UIView中的层级
 *
 *  @param view 添加子view
 *  @param key  子view对应key
 */
- (void)addSubview:(UIView *)view forKey:(NSString *)key {
    //寻找空缺的index
    NSArray *cellIndexs = [_cellInfos allKeys];
    NSUInteger index = 0;
    while (cellIndexs && [cellIndexs containsObject:@(index)]) {
        index++;
    }
    
    [self insertSubview:view atIndex:index cellInfo:nil forKey:key];
}

/**
 *  增加一个子view到对应的位置上，只是布局位置上的插入，与view层级没关系
 *  已经在UIView上的子view，仅仅添加到布局，不改变它在原来UIView中的层级
 *
 *  @param view 添加子view
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key  子view对应key
 */
- (void)insertSubview:(UIView *)view atIndex:(NSUInteger)index forKey:(NSString *)key {
    [self insertSubview:view atIndex:index cellInfo:nil forKey:key];
}

/**
 *  移动一个字view到某个位置上，只是布局位置上的移动，与view层级没关系
 *
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key   子view对应key，找不到view忽略
 */
- (void)moveSubviewToIndex:(NSUInteger)index forKey:(NSString *)key {
    UIView *superview = [self panel];
    UIView *subview = [superview ssn_subviewForKey:key];
    if (!subview) {
        return ;
    }
    
    NSUInteger old_index = [self indexOfSubview:subview];
    if (old_index != NSNotFound) {//view开始就在此布局中，需要从上一个单元格中移除
        SSNUITableCellInfo *old_cell = [self.cellInfos objectForKey:@(old_index)];
        old_cell.subview = nil;
        old_cell.key = nil;
    }
    
    //原来cell
    SSNUITableCellInfo *old_cell = [self.cellInfos objectForKey:@(index)];
    if (old_cell.subview == subview) {//本来就在原来位置
        return ;
    }
    
    if (old_cell.subview) {//往后移位
        [self moveSubviewToIndex:(index + 1) forKey:old_cell.key];
    }
    
    if (old_cell) {
        old_cell.key = key;
        old_cell.subview = subview;
    }
    else {//需要新建一个cellInfo
        SSNUITableCellInfo *cell = [[SSNUITableCellInfo alloc] init];
        cell.layout = self;
        cell.index = index;
        cell.subview = subview;
        cell.key = key;
        [self.cellInfos setObject:cell forKey:@(index)];
    }
    
    [super moveSubviewToIndex:index forKey:key];
}

/**
 *  将一个子view移除此类布局且从panel中移除
 *
 *  @param key 需要移除的key
 */
- (void)removeSubviewForKey:(NSString *)key {
    UIView *superview = [self panel];
    UIView *subview = [superview ssn_subviewForKey:key];
    
    if (!subview) {
        return ;
    }
    
    NSUInteger old_index = [self indexOfSubview:subview];
    if (old_index != NSNotFound) {//view开始就在此布局中，需要从上一个单元格中移除
        SSNUITableCellInfo *old_cell = [self.cellInfos objectForKey:@(old_index)];
        old_cell.subview = nil;
        old_cell.key = nil;
    }
    
    [super removeSubviewForKey:key];
}

/**
 *  将一个子view移除此布局，不从panel中移除
 *
 *  @param key 需要移除的key
 */
- (void)moveOutSubviewForKey:(NSString *)key {
    UIView *superview = [self panel];
    UIView *subview = [superview ssn_subviewForKey:key];
    
    if (!subview) {
        return ;
    }
    
    NSUInteger old_index = [self indexOfSubview:subview];
    if (old_index != NSNotFound) {//view开始就在此布局中，需要从上一个单元格中移除
        SSNUITableCellInfo *old_cell = [self.cellInfos objectForKey:@(old_index)];
        old_cell.subview = nil;
        old_cell.key = nil;
    }
    
    [super moveOutSubviewForKey:key];
}

#pragma mark 表格布局具体实现
- (NSArray *)columnInfosWithRowWidth:(NSUInteger)rowWidth {
    NSInteger cost_width = 0;
    NSMutableArray *cols = [NSMutableArray arrayWithCapacity:_columnCount];
    NSMutableArray *ave_cols = [NSMutableArray arrayWithCapacity:0];
    for (NSUInteger c_index = 0; c_index < _columnCount; c_index++) {
        SSNUITableColumnInfo *colInfo = [_columnInfos objectForKey:@(c_index)];
        if (colInfo) {
            cost_width += colInfo.width;
        }
        
        SSNUITableColumnInfo *tempCol = [colInfo copy];
        if (!tempCol) {
            tempCol = [[SSNUITableColumnInfo alloc] init];
        }
        
        if (tempCol.width == 0) {//宽度要拼粉
            [ave_cols addObject:tempCol];
        }
        
        [cols addObject:tempCol];
    }
    
    if (cost_width < rowWidth) {//有剩余
        if ([ave_cols count] > 0) {//没有可伸缩的比较麻烦，需要查看依靠点（暂时直接以topleft为基准点）
            CGFloat ave_width = ((rowWidth - cost_width) / [ave_cols count]);
            for (SSNUITableColumnInfo *col in ave_cols) {
                col.width = ave_width;
            }
        }
    }
    return cols;
}

- (NSArray *)rowInfosWithColumnWidth:(NSUInteger)columnWidth {
    if (0 == _rowCount) {
        return nil;
    }
    
    NSInteger cost_width = 0;
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:_rowCount];
    NSMutableArray *ave_rows = [NSMutableArray arrayWithCapacity:0];
    for (NSUInteger c_index = 0; c_index < _rowCount; c_index++) {
        SSNUITableRowInfo *rowInfo = [_rowInfos objectForKey:@(c_index)];
        if (rowInfo) {
            cost_width += rowInfo.height;
        }
        
        SSNUITableRowInfo *tempRow = [rowInfo copy];
        if (!tempRow) {
            tempRow = [[SSNUITableRowInfo alloc] init];
            tempRow.height = [self defaultRowHeight];//取默认行高
        }
        
        if (tempRow.height == 0) {//宽度要拼粉
            [ave_rows addObject:tempRow];
        }
        
        [rows addObject:tempRow];
    }
    
    if (cost_width < columnWidth) {//有剩余
        if ([ave_rows count] > 0) {//没有可伸缩的比较麻烦，需要查看依靠点（暂时直接以topleft为基准点）
            CGFloat ave_width = ((columnWidth - cost_width) / [ave_rows count]);
            for (SSNUITableRowInfo *col in ave_rows) {
                col.height = ave_width;
            }
        }
    }
    return rows;
}

- (NSUInteger)rowHeightWithRow:(NSUInteger)row rowInfos:(NSArray *)rowInfos {
    if (_rowCount == 0 || row >= _rowCount) {
        return [self defaultRowHeight];
    }
    SSNUITableRowInfo *rowInfo = [rowInfos objectAtIndex:row];
    return rowInfo.height;
}

- (NSUInteger)rowHeightWithRow:(NSUInteger)row {
    if (_rowCount == 0 || row >= _rowCount) {
        return [self defaultRowHeight];
    }
    NSInteger column_width = [self column_width];
    NSArray *rows = [self rowInfosWithColumnWidth:column_width];
    SSNUITableRowInfo *rowInfo = [rows objectAtIndex:row];
    return rowInfo.height;
}

- (CGRect)cellRectWithIndex:(NSUInteger)index columnInfos:(NSArray *)columnInfos rowRect:(CGRect)row_rect rowWidth:(NSInteger)row_width isHOR:(BOOL)isHOR isRowASC:(BOOL)isRowASC isColumnASC:(BOOL)isColumnASC contentMode:(SSNUIContentMode *)pcontentMode {
    
    CGRect rect = row_rect;
    
    NSUInteger column = (index % _columnCount);
    
    //取对应列单元格坐标
    SSNUIContentMode contentMode = _contentMode;
    CGRect cell_rect = [self cellRectWithRowRect:rect columnInfos:columnInfos column:column isHOR:isHOR isColumnASC:isColumnASC contentMode:&contentMode];
    
    //单元格坐标调整
    SSNUITableCellInfo *cellInfo = [_cellInfos objectForKey:@(index)];
    if (cellInfo) {
        
        if (cellInfo.contentMode != SSNUIContentModeNan) {//具备优先取cell属性
            contentMode = cellInfo.contentMode;
        }
        
        cell_rect = [self adjustRect:cell_rect contentInset:cellInfo.contentInset contentMode:contentMode];
    }
    
    if (pcontentMode) {
        *pcontentMode = contentMode;
    }
    
    return cell_rect;
}

- (CGRect)cellRectWithRowRect:(CGRect)rowRect columnInfos:(NSArray *)columnInfos column:(NSUInteger)column isHOR:(BOOL)isHOR isColumnASC:(BOOL)isColumnASC contentMode:(SSNUIContentMode *)pcontentMode {
    
    __block CGRect cell_rect = rowRect;
    __block SSNUIContentMode contentMode = _contentMode;
    void (^block)(SSNUITableColumnInfo *col, NSUInteger idx, BOOL *stop) = ^(SSNUITableColumnInfo *col, NSUInteger idx, BOOL *stop) {
        
        if ((!self.isRowReverse && idx == column) || (self.isRowReverse && _columnCount == idx + column + 1)) {
            
            if (col.contentMode != SSNUIContentModeNan) {//具备优先取列
                contentMode = col.contentMode;
            }
            
            if (isColumnASC) {
                if (isHOR) {
                    cell_rect.size.width = col.width;
                }
                else {
                    cell_rect.size.height = col.width;
                }
            }
            else {
                if (isHOR) {
                    cell_rect.origin.x += cell_rect.size.width - col.width;
                    cell_rect.size.width = col.width;
                }
                else {
                    cell_rect.origin.y += cell_rect.size.height - col.width;
                    cell_rect.size.height = col.width;
                }
            }
            *stop = YES;
        }
        else {
            if (isColumnASC) {
                if (isHOR) {
                    cell_rect.size.width -= col.width;
                    cell_rect.origin.x += col.width;
                }
                else {
                    cell_rect.size.height -= col.width;
                    cell_rect.origin.y += col.width;
                }
            }
            else {
                if (isHOR) {
                    cell_rect.size.width -= col.width;
                }
                else {
                    cell_rect.size.height -= col.width;
                }
            }
        }
    };
    
    //计算cell大小
    if (self.isRowReverse) {
        [columnInfos enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:block];
    }
    else {
        [columnInfos enumerateObjectsUsingBlock:block];
    }
    
    if (pcontentMode) {
        *pcontentMode = contentMode;
    }
    
    return cell_rect;
}

/**
 *  计算合适的尺寸
 *
 *  @param rect         原尺寸
 *  @param contentInset 内边距
 *  @param contentMode  一考点
 *
 *  @return 返回一个合适的view
 */
- (CGRect)adjustRect:(CGRect)rect contentInset:(UIEdgeInsets)contentInset contentMode:(SSNUIContentMode)contentMode {
    CGRect rtRect = rect;
    if (contentInset.top + contentInset.bottom < rect.size.height) {
        rtRect.origin.y += contentInset.top;
        rtRect.size.height = rect.size.height - (contentInset.top + contentInset.bottom);
    }
    else {
        rtRect.size.height = 0;
        
        if (contentMode == SSNUIContentModeBottomLeft
            || contentMode == SSNUIContentModeBottomRight
            || contentMode == SSNUIContentModeBottom
            ) {
            rtRect.origin.y += rect.size.height - contentInset.bottom;
        }
        else {
            rtRect.origin.y += contentInset.top;
        }
    }
    
    if (contentInset.left + contentInset.right < rect.size.width) {
        rtRect.origin.x += contentInset.left;
        rtRect.size.width = rect.size.width - (contentInset.left + contentInset.right);
    }
    else {
        rtRect.size.width = 0;
        
        if (contentMode == SSNUIContentModeTopRight
            || contentMode == SSNUIContentModeBottomRight
            || contentMode == SSNUIContentModeRight
            ) {
            rtRect.origin.x += rect.size.width - contentInset.right;
        }
        else {
            rtRect.origin.x += contentInset.left;
        }
    }
    
    return rtRect;
}

//- (CGRect)rowRect

/**
 *  布局所有子view，overwite
 */
- (void)layoutSubviews {
    UIView *superview = [self panel];
    if (!superview) {
        return ;
    }
    
    NSInteger row_width = [self row_width];
    
    BOOL isHOR = [self isHOR];
    BOOL isRowASC = [self isRowASC];
    BOOL isColumnASC = [self isColumnASC];
    
    NSArray *cols = [self columnInfosWithRowWidth:row_width];
    
    NSInteger column_width = [self column_width];
    NSArray *rows = [self rowInfosWithColumnWidth:column_width];
    NSUInteger firstRowHeight = [self rowHeightWithRow:0 rowInfos:rows];
    
    CGRect rect = [self firstRowRectWithRowHeight:firstRowHeight];
    
    //遍历所有位置
    for (NSNumber *numIndex in [_cellInfos allKeys]) {
        NSUInteger index = [numIndex unsignedIntegerValue];
        
        NSUInteger row = (index / _columnCount);
        CGRect row_rect = rect;
        for (NSUInteger idx = 1; idx <= row; idx++) {
            NSInteger rowHeight = [self rowHeightWithRow:idx rowInfos:rows];
            ssn_ui_layout_next_row_rect(row_rect, isHOR, isRowASC, rowHeight);
        }
        
        SSNUITableCellInfo *cellInfo = [_cellInfos objectForKey:numIndex];
        
        SSNUIContentMode contentMode = SSNUIContentModeTopLeft;
        CGRect cellRect = [self cellRectWithIndex:index columnInfos:cols rowRect:row_rect rowWidth:row_width isHOR:isHOR isRowASC:isRowASC isColumnASC:isColumnASC contentMode:&contentMode];
        
        [self layoutSubview:cellInfo.subview inRect:cellRect contentMode:contentMode];
    }
}
@end

@implementation SSNUITableRowInfo

- (instancetype)copyWithZone:(NSZone *)zone {
    SSNUITableRowInfo *cp = [[[SSNUITableRowInfo class] alloc] init];
    cp.height = self.height;
    return cp;
}

/**
 *  返回一个表布局行属性
 *
 *  @param height       行高
 *
 *  @return 列属性
 */
+ (instancetype)infoWithHeight:(NSUInteger)height {
    SSNUITableRowInfo *info = [[SSNUITableRowInfo alloc] init];
    info.height = height;
    return info;
}

@end


@implementation SSNUITableColumnInfo

- (instancetype)copyWithZone:(NSZone *)zone {
    SSNUITableColumnInfo *cp = [[[SSNUITableColumnInfo class] alloc] init];
    cp.width = self.width;
    cp.contentMode = self.contentMode;
    return cp;
}

/**
 *  返回一个表布局列属性
 *
 *  @param width       列宽度
 *  @param contentMode 列元素依赖
 *
 *  @return 列属性
 */
+ (instancetype)infoWithWidth:(NSUInteger)width contentMode:(SSNUIContentMode)contentMode {
    SSNUITableColumnInfo *info = [[SSNUITableColumnInfo alloc] init];
    info.width = width;
    info.contentMode = contentMode;
    return info;
}

@end

@implementation SSNUITableCellInfo

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset.top = contentInset.top > 0 ? contentInset.top : 0;
    _contentInset.bottom = contentInset.bottom > 0 ? contentInset.bottom : 0;
    _contentInset.left = contentInset.left > 0 ? contentInset.left : 0;
    _contentInset.right = contentInset.right > 0 ? contentInset.right : 0;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SSNUITableCellInfo *cp = [[[SSNUITableCellInfo class] alloc] init];
    cp.layout = self.layout;
    cp.key = self.key;
    cp.subview = self.subview;
    cp.contentInset = self.contentInset;
    cp.contentMode = self.contentMode;
    cp.index = self.index;
    return cp;
}

/**
 *  单元格的当前的frame（会随着panel变化而改变）
 *
 *  @return 返回当前单元格的大小
 */
- (CGRect)cellFrame {
    if (!_layout) {
        return CGRectZero;
    }
    
    SSNUITableLayout *layout = _layout;
    
    NSInteger row_width = [layout row_width];
    NSInteger row_height = [layout rowHeightWithRow:0];
    CGRect rect = [layout firstRowRectWithRowHeight:row_height];
    BOOL isHOR = [layout isHOR];
    BOOL isRowASC = [layout isRowASC];
    BOOL isColumnASC = [layout isColumnASC];
    
    NSArray *cols = [layout columnInfosWithRowWidth:row_width];
    
    return [layout cellRectWithIndex:self.index columnInfos:cols rowRect:rect rowWidth:row_width isHOR:isHOR isRowASC:isRowASC isColumnASC:isColumnASC contentMode:NULL ];
}

/**
 *  返回一个表布局列单元格属性
 *
 *  @param contentInset 单元格内边距
 *  @param contentMode 单元格元素依赖
 *
 *  @return 单元格属性
 */
+ (instancetype)infoWithContentInset:(UIEdgeInsets)contentInset contentMode:(SSNUIContentMode)contentMode {
    SSNUITableCellInfo *info = [[SSNUITableCellInfo alloc] init];
    info.contentInset = contentInset;
    info.contentMode = contentMode;
    return info;
}

@end

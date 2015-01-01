//
//  SSNUILayout.m
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNUILayout.h"
#import "UIView+SSNUIFrame.h"
#import "SSNPanel.h"

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

/**
 *  所有被布局的子view都需要反过来引用layout，这样就能清楚的看到他正处在什么布局中
 */
@interface SSNUILayoutWeakBox : NSObject
@property (nonatomic,weak) SSNUILayout *layout;
+ (instancetype)boxWithLayout:(SSNUILayout *)layout;
@end

@implementation SSNUILayoutWeakBox
+ (instancetype)boxWithLayout:(SSNUILayout *)layout {
    SSNUILayoutWeakBox *box = [[[self class] alloc] init];
    box.layout = layout;
    return box;
}
@end

/**
 *  子view关联布局对象
 */
@interface UIView (SSNUILayoutInner)
@end

@implementation UIView (SSNUILayoutInner)

static char *ssn_dependent_layout_key = NULL;
- (SSNUILayoutWeakBox *)ssn_dependent_layout {
    return objc_getAssociatedObject(self, &ssn_dependent_layout_key);
}

- (void)setSsn_dependent_layout:(SSNUILayoutWeakBox *)layout {
    objc_setAssociatedObject(self, &ssn_dependent_layout_key, layout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation SSNUILayout
{
    NSString *_layoutID;
    NSMutableArray *_subviews;
    __weak UIView *_panel;
}

//唯一初始化函数
- (instancetype)initWithPanel:(UIView *)panel {
    self = [super init];
    if (self) {
        _layoutID = [NSString stringWithFormat:@"%p",self];
        _subviews = [[NSMutableArray alloc] initWithCapacity:1];
        _panel = panel;
    }
    return self;
}

- (instancetype)init {
    [[NSException exceptionWithName:@"SSNUILayout" reason:@"不允许独自创建SSNUILayout实例" userInfo:nil] raise];
    return nil;
}

- (void)removeSubview:(UIView *)subview {
    NSLog(@"layout remove subview %@",subview);
    
    [subview setSsn_dependent_layout:nil];//移除弱引用
    
    [_subviews removeObject:subview];
    return ;
}

/**
 *  返回当前layout的id
 *
 *  @return 返回layoutid
 */
- (NSString *)layoutID {
    return _layoutID;
}

/**
 *  一个布局只能应用于一个view上面
 *
 *  @return 返回作用的view上面
 */
- (UIView *)panel {
    return _panel;
}

/**
 *  所有参与此类布局的子view
 *
 *  @return 所有参与此类布局的子view @see UIView
 */
- (NSArray *)subviews {
    return _subviews;
}

/**
 *  获取view所在的布局对象
 *
 *  @param view 一个子view
 *
 *  @return 返回view所在的布局对象
 */
+ (SSNUILayout *)dependentLayoutWithView:(UIView *)view {
    SSNUILayoutWeakBox *box = [view ssn_dependent_layout];
    return box.layout;
}

/**
 *  添加子view到此布局中，并且加入到UIView上面，已经在UIView上的子view，仅仅添加到布局，不改变它在原来UIView中的层级
 *
 *  @param view 添加子view
 *  @param key  子view对应key
 */
- (void)addSubview:(UIView *)view forKey:(NSString *)key {
    [_subviews removeObject:view];
    [_subviews addObject:view];
    
    //关联子view
    SSNUILayoutWeakBox *box = [SSNUILayoutWeakBox boxWithLayout:self];
    [view setSsn_dependent_layout:box];
    
    UIView *superview = [self panel];
    if (![superview ssn_subviewForKey:key]) {
        [superview ssn_addSubview:view forKey:key];
    }
}

/**
 *  增加一个子view到对应的位置上，只是布局位置上的插入，与view层级没关系
 *  已经在UIView上的子view，仅仅添加到布局，不改变它在原来UIView中的层级
 *
 *  @param view 添加子view
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key  子view对应key
 */
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index forKey:(NSString *)key {
    [_subviews removeObject:view];
    [_subviews insertObject:view atIndex:index];
    
    //关联子view
    SSNUILayoutWeakBox *box = [SSNUILayoutWeakBox boxWithLayout:self];
    [view setSsn_dependent_layout:box];
    
    UIView *superview = [self panel];
    if (![superview ssn_subviewForKey:key]) {
        [superview ssn_insertSubview:view atIndex:index forKey:key];
    }
}

/**
 *  移动一个字view到某个位置上，只是布局位置上的移动，与view层级没关系
 *
 *  @param index 位置，此布局中所包含的所有子view组中的位置，越界认定为最后
 *  @param key   子view对应key，找不到view忽略
 */
- (void)moveSubviewToIndex:(NSInteger)index forKey:(NSString *)key {
    UIView *superview = [self panel];
    UIView *subview = [superview ssn_subviewForKey:key];
    
    if (!subview) {
        return ;
    }
    
    [_subviews removeObject:subview];
    [_subviews insertObject:subview atIndex:index];
}

/**
 *  将一个子view移除此类布局且从panel中移除
 *
 *  @param key 需要移除的key
 */
- (void)removeSubviewForKey:(NSString *)key {
    UIView *superview = [self panel];
    UIView *subview = [superview ssn_subviewForKey:key];
    [subview removeFromSuperview];
}

/**
 *  将一个子view移除此布局，不从panel中移除
 *
 *  @param key 需要移除的key
 */
- (void)moveOutSubviewForKey:(NSString *)key {
    UIView *superview = [self panel];
    UIView *subview = [superview ssn_subviewForKey:key];
    [subview setSsn_dependent_layout:nil];
    [_subviews removeObject:subview];
}

/**
 *  布局所有子view
 */
- (void)layoutSubviews {
    //NSLog(@"nothing to do")
}

/**
 *  布局向量
 *
 *  @return 布局向量(1,1),(-1,1),(-1,-1),(1,-1)
 */
- (CGPoint)layoutVector {
    CGPoint vector = CGPointZero;
    switch (self.orientation) {
        case SSNUILayoutOrientationPortrait:
            vector.x = _isReverse ? -1 : 1;
            vector.y = 1;
            break;
        case SSNUILayoutOrientationPortraitUpsideDown:
            vector.x = -1;
            vector.y = -1;
            break;
        case SSNUILayoutOrientationLandscapeLeft:
            vector.x = -1;
            vector.y = 1;
            break;
        case SSNUILayoutOrientationLandscapeRight:
            vector.x = -1;
            vector.y = 1;
            break;
        default:
            break;
    }
    return vector;
}

- (NSInteger)layout_max_width {
    UIView *superview = [self panel];
    
    CGSize size = superview.ssn_size;
    if ([superview isKindOfClass:[UIScrollView class]]) {//UIScrollView需要单独处理
        CGSize t_size = [(UIScrollView *)superview contentSize];
        size.width = MAX(size.width, t_size.width);
        size.height = MAX(size.height, t_size.height);
    }
    
    NSInteger max_width = size.width - (self.contentInset.left + self.contentInset.right);
    if (self.orientation == SSNUILayoutOrientationLandscapeLeft
        || self.orientation == SSNUILayoutOrientationLandscapeRight) {
        max_width = size.height - (self.contentInset.top + self.contentInset.bottom);
    }
    
    return max_width;
}

@end

@implementation SSNUISiteLayout

@end


@implementation SSNUIFlowLayout
/**
 *  布局所有子view，overwite
 */
- (void)layoutSubviews {
    
    UIView *superview = [self panel];
    if (!superview) {
        return ;
    }
    
    //先计算x,y的移动向量
    CGPoint vector = [self layoutVector];
    
    //布局所有的子view
    NSArray *subviews = [self subviews];
    
    CGPoint origin = CGPointZero;
    
    NSInteger max_width = [self layout_max_width];
    
    for (UIView *view in subviews) {
        //
    }
}
@end


@implementation SSNUITableLayout {
    NSMutableDictionary *_columnInfos;
}

- (NSMutableDictionary *)columnInfos {
    if (_columnInfos) {
        return _columnInfos;
    }
    _columnInfos = [[NSMutableDictionary alloc] initWithCapacity:1];
    return _columnInfos;
}

/**
 *  元素布局模型，依赖方向，默认值是SSNUIContentModeTopLeft
 *
 *  @param column 列数，取值[0～(columnCount-1)]
 *
 *  @return 第column列的布局模型，
 */
- (SSNUITableColumnInfo *)columnInfoAtColumn:(NSUInteger)column {
    return [[_columnInfos objectForKey:@(column)] copyWithZone:NULL];
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
 *  布局所有子view，overwite
 */
- (void)layoutSubviews {
    //NSLog(@"nothing to do")
}
@end


@implementation SSNUITableColumnInfo

- (instancetype)copyWithZone:(NSZone *)zone {
    SSNUITableColumnInfo *cp = [[[SSNUITableColumnInfo class] alloc] init];
    cp.width = self.width;
    cp.contentInset = self.contentInset;
    cp.contentMode = self.contentMode;
    return cp;
}

@end

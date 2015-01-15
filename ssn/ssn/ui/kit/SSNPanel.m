//
//  SSNPanel.m
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNPanel.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

#define ssn_uilayout_value_synthesize(type,get,set) _ssn_uilayout_value_synthesize_(type,get,set)

#define _ssn_uilayout_value_synthesize_(t,g,s) \
static char * g ## _key = NULL;\
- (t) g { \
NSNumber *v = objc_getAssociatedObject(self, &(g ## _key)); \
return [v t ## Value ]; \
} \
- (void) set ## s :(t) g { \
objc_setAssociatedObject(self, &(g ## _key), @( g ), OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
}

@interface SSNUILayout ()

- (instancetype)initWithPanel:(UIView *)panel;

- (void)removeSubview:(UIView *)subview;//仅仅将子view移出当前布局
@end

@implementation UIView (SSNPanel)

void ssn_panel_exchange_method(Class clazz,SEL sel1, SEL sel2) {
    Method method1 = class_getInstanceMethod(clazz, sel1);
    Method method2 = class_getInstanceMethod(clazz, sel2);
    method_exchangeImplementations(method1, method2);
}

//类别需要替换的方法
+ (void)load {
    NSLog(@"已经启动了ssn布局方案，此布局将替换掉UIView的-(void)willRemoveSubview:(UIView *)subview;以及-(void)layoutSubviews;方法");
    
    Class clazz = [self class];
    
    //替换removeFromSuperview
    ssn_panel_exchange_method(clazz, @selector(willRemoveSubview:), @selector(ssn_willRemoveSubview:));
    
    //替换layoutSubviews
    ssn_panel_exchange_method(clazz, @selector(layoutSubviews), @selector(ssn_layoutSubviews));
}


static char *ssn_subviews_dictionary_key = NULL;
- (NSMutableDictionary *)ssn_subviews_dictionary {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, &ssn_subviews_dictionary_key);
    if (!dic) {
        dic = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &ssn_subviews_dictionary_key, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dic;
}

static char *ssn_layouts_dictionary_key = NULL;
- (NSMutableDictionary *)ssn_layouts_dictionary {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, &ssn_layouts_dictionary_key);
    if (!dic) {
        dic = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &ssn_layouts_dictionary_key, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dic;
}

//防止重复压栈问题
ssn_uilayout_value_synthesize(int, ssn_layout_called_flag, Ssn_layout_called_flag)

//控制已经加载layout
ssn_uilayout_value_synthesize(int, ssn_layout_did_load, Ssn_layout_did_load)

//控制依赖控制器已经加载layout
ssn_uilayout_value_synthesize(int, ssn_view_controller_layout_did_load, Ssn_view_controller_layout_did_load)

/**
 *  元素被移除
 */
- (void)ssn_willRemoveSubview:(UIView *)subview {
    SSNUILayout *layout = [SSNUILayout dependentLayoutWithView:subview];
    
    [layout removeSubview:subview];//先从布局中移除
    
    [self ssn_willRemoveSubview:subview];//继续调用原来的方法
}

/**
 *  元素需要布局
 */
- (void)ssn_layoutSubviews {
    int flag = [self ssn_layout_called_flag];
    if (flag) {
        return ;
    }
    
    self.ssn_layout_called_flag = 1;
    
    [self ssn_layoutSubviews];//继续调用原来的方法
    
    id obj = self.nextResponder;
    if ([obj isKindOfClass:[UIViewController class]]) {
        if (!self.ssn_view_controller_layout_did_load) {
            self.ssn_view_controller_layout_did_load = 1;
            
            //可以回调此方法
            self.ssn_layout_called_flag = 0;
            [(UIViewController *)obj ssn_layoutDidLoad];
            self.ssn_layout_called_flag = 1;
        }
    }
    
    if (!self.ssn_layout_did_load) {
        self.ssn_layout_did_load = 1;
        
        //可以回调此方法
        self.ssn_layout_called_flag = 0;
        [self ssn_layoutDidLoad];
        self.ssn_layout_called_flag = 1;
    }
    
    
    NSMutableDictionary *dic = [self ssn_layouts_dictionary];
    for (SSNUILayout *layout in [dic allValues]) {
        [layout layoutSubviews];//开始布局所有的子view
    }
    
    self.ssn_layout_called_flag = 0;
}


/**
 *  获取view上面的子view
 *
 *  @param key 子view对应的key
 *
 *  @return 对应key的子view
 */
- (UIView *)ssn_subviewForKey:(NSString *)key {
    return [[self ssn_subviews_dictionary] objectForKey:key];
}

/**
 *  返回subview对应的key
 *
 *  @param subview 寻找的subview
 *
 *  @return 返回subview对应的key，不在此view或者找不到返回nil
 */
- (NSString *)ssn_keyOfSubview:(UIView *)subview {
    if (subview.superview != self) {
        return nil;
    }
    
    NSMutableDictionary *dic = [self ssn_subviews_dictionary];
    for (NSString *key in [dic allKeys]) {
        UIView *view = [dic objectForKey:key];
        if (view == subview) {
            return key;
        }
    }
    
    return nil;
}

/**
 *  添加子view，默认采用SSNUISiteLayout布局
 *
 *  @param view 添加的子view
 *  @param key  添加子view对应的key
 */
- (void)ssn_addSubview:(UIView *)view forKey:(NSString *)key {
    NSMutableDictionary *dic = [self ssn_subviews_dictionary];
    [self addSubview:view];//site布局不用管
    [dic setObject:view forKey:key];
}

/**
 *  再view层级为index处添加一个子view
 *
 *  @param view 添加子view
 *  @param index 子view的层级
 *  @param key  子view对应key
 */
- (void)ssn_insertSubview:(UIView *)view atIndex:(NSUInteger)index forKey:(NSString *)key {
    NSMutableDictionary *dic = [self ssn_subviews_dictionary];
    if (index > [[self subviews] count]) {
        [self addSubview:view];
    }
    else {
        [self insertSubview:view atIndex:index];
    }
    [dic setObject:view forKey:key];
}

/**
 *  移除一个子view
 *
 *  @param key view对应的key
 */
- (void)ssn_removeSubviewForKey:(NSString *)key {
    NSMutableDictionary *dic = [self ssn_subviews_dictionary];
    UIView *subview = [dic objectForKey:key];
    [dic removeObjectForKey:key];
    [subview removeFromSuperview];
}

//一个私有接口实现
- (void)ssn_setLayout:(SSNUILayout *)layout forID:(NSString *)layoutId {
    [[self ssn_layouts_dictionary] setObject:layout forKey:layoutId];
}

/**
 *  返回已创建的布局
 *
 *  @param layoutID 布局ID
 *
 *  @return 返回一个布局ID
 */
- (SSNUILayout *)ssn_layoutForID:(NSString *)layoutID {
    return [[self ssn_layouts_dictionary] objectForKey:layoutID];
}

/**
 *  移除一个布局，仅仅移除布局，不会移除子view
 *
 *  @param layoutID 要移除布局的id
 */
- (void)ssn_removeLayoutForID:(NSString *)layoutID {
    NSMutableDictionary *dic = [self ssn_layouts_dictionary];
    
    SSNUILayout *layout = [dic objectForKey:layoutID];
    NSArray *subviews = [layout subviews];
    for (UIView *view in subviews) {
        SSNUILayout *layout = [SSNUILayout dependentLayoutWithView:view];
        
        [layout removeSubview:view];//从布局中移除
    }
    
    [dic removeObjectForKey:layoutID];
}

/**
 *  创建一个流式布局
 *
 *  @param rowHeight 行高
 *  @param rowCount  行数
 *  @param spacing   间距
 *
 *  @return 返回并创建一个流式布局
 */
- (SSNUIFlowLayout *)ssn_flowLayoutWithRowHeight:(NSUInteger)rowHeight rowCount:(NSUInteger)rowCount spacing:(NSUInteger)spacing {
    SSNUIFlowLayout *layout = [[SSNUIFlowLayout alloc] initWithPanel:self];
    layout.rowCount = rowCount;
    layout.rowHeight = rowHeight;
    layout.spacing = spacing;
    [self ssn_setLayout:layout forID:[layout layoutID]];
    return layout;
}

/**
 *  创建一个流式布局
 *
 *  @return 返回并创建一个流式布局
 */
- (SSNUIFlowLayout *)ssn_flowLayout {
    return [self ssn_flowLayoutWithRowHeight:0 rowCount:0 spacing:8];
}

/**
 *  创建一个流式布局
 *
 *  @param rowHeight 行高
 *  @param spacing   间距
 *
 *  @return 返回并创建一个流式布局
 */
- (SSNUIFlowLayout *)ssn_flowLayoutWithRowHeight:(NSUInteger)rowHeight spacing:(NSUInteger)spacing {
    return [self ssn_flowLayoutWithRowHeight:rowHeight rowCount:0 spacing:spacing];
}

/**
 *  创建一个流式布局
 *
 *  @param rowCount 行数
 *  @param spacing  间距
 *
 *  @return 返回并创建一个流式布局
 */
- (SSNUIFlowLayout *)ssn_flowLayoutWithRowCount:(NSUInteger)rowCount spacing:(NSUInteger)spacing {
    return [self ssn_flowLayoutWithRowHeight:0 rowCount:rowCount spacing:spacing];
}

/**
 *  创建一个表格布局
 *
 *  @param rowHeight   行高
 *  @param rowCount    行数，填零表示不限制
 *  @param columnCount 不能小于1
 *
 *  @return 返回并创建一个表格布局
 */
- (SSNUITableLayout *)ssn_tableLayoutWithDefaultRowHeight:(NSUInteger)rowHeight rowCount:(NSUInteger)rowCount columnCount:(NSUInteger)columnCount {
    SSNUITableLayout *layout = [[SSNUITableLayout alloc] initWithPanel:self];
    layout.defaultRowHeight = rowHeight;
    layout.columnCount = columnCount;
    layout.rowCount = rowCount;
    [self ssn_setLayout:layout forID:[layout layoutID]];
    return layout;
}


/**
 *  创建一个表格布局
 *
 *  @return 返回并创建一个表格布局
 */
- (SSNUITableLayout *)ssn_tableLayout {
    return [self ssn_tableLayoutWithDefaultRowHeight:0 rowCount:0 columnCount:1];
}

/**
 *  创建一个表格布局
 *
 *  @param rowHeight   行高
 *  @param columnCount 不能小于1
 *
 *  @return 返回并创建一个表格布局
 */
- (SSNUITableLayout *)ssn_tableLayoutWithDefaultRowHeight:(NSUInteger)rowHeight columnCount:(NSUInteger)columnCount {
    return [self ssn_tableLayoutWithDefaultRowHeight:rowHeight rowCount:0 columnCount:columnCount];
}

/**
 *  创建一个表格布局
 *
 *  @param rowCount    行数，填零表示不限制
 *  @param columnCount 不能小于1
 *
 *  @return 返回并创建一个表格布局
 */
- (SSNUITableLayout *)ssn_tableLayoutWithRowCount:(NSUInteger)rowCount columnCount:(NSUInteger)columnCount {
    return [self ssn_tableLayoutWithDefaultRowHeight:0 rowCount:rowCount columnCount:columnCount];
}


/**
 *  view 加载布局的实际，一个view此方法只会调用一次
 */
- (void)ssn_layoutDidLoad {}

@end


/**
 *  控制器布局委托
 */
@implementation UIViewController (SSNUILayout)

/**
 *  viewDidLoad后，viewWillAppear前调用，建议在方法中加载想要的布局
 *  被调用次数和viewDidLoad一直
 */
- (void)ssn_layoutDidLoad {}

@end

//
//  SSNUILayout.h
//  ssn
//
//  Created by lingminjun on 14/12/30.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef NS_ENUM(NSUInteger, SSNUILayoutStyle) {
//    SSNUISiteLayout     = 0,//位置布局
//    SSNUIFlowLayout     = 1,//流式布局
//    SSNUITableLayout    = 2,//表格布局
//};

/**
 *  布局描述，只能依附属于view存在
 */
@interface SSNUILayout : NSObject

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
 *  添加子view到此布局中，并且加入到UIView上面
 *
 *  @param view 添加子view
 *  @param key  子view对应key
 */
- (void)addSubview:(UIView *)view forKey:(NSString *)key;

@end

/**
 *  位置布局描述，遵从苹果自带的autolayout布局
 */
@interface SSNUISiteLayout : SSNUILayout

@end

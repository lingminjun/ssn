//
//  SSNKVOBound.h
//  ssn
//
//  Created by lingminjun on 14/12/11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 过滤，把不符合要求的变更过滤掉
 @param obj     绑定的目标对象
 @param field   绑定的目标对象的属性名
 @param changed_new_value 绑定目标对象对应field属性发生改变时新设置的值
 @return 是否需要影响监听者属性，返回YES表示影响，返回NO，表示不关心的变化
 */
typedef BOOL (^ssn_bound_filter)(id obj, NSString *field, id changed_new_value);

/**
 @brief 映射，对目标改变值重新转换，最后转换成监听者可以赋值(KVC)的对象
 @param obj     绑定的目标对象
 @param field   绑定的目标对象的属性名
 @param changed_new_value 绑定目标对象对应field属性发生改变时新设置的值
 @return 返回合适的对象
 */
typedef id (^ssn_bound_mapping)(id obj, NSString *field, id changed_new_value);



/**
 @brief 绑定器，绑定一个对象的属性与着另一对象属性，一对一绑定，简称KVO绑定器
        此绑定器
 */
@interface NSObject (SSNKVOBound)

/**
 @brief 添加一个绑定到某个属性上，属性值直接赋值
 @param object 绑定的目标对象，
 @param field  绑定目标对象的属性
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 */
- (void)ssn_boundObject:(id)object forField:(NSString *)field tieField:(NSString *)tieField;


/**
 @brief 添加一个绑定到某个属性上，属性值直接赋值
 @param object 绑定的目标对象，
 @param field  绑定目标对象的属性
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 @param filter      过滤器，注意不要循环引用
 @param map         映射，注意不要循环引用
 */
- (void)ssn_boundObject:(id)object forField:(NSString *)field tieField:(NSString *)tieField filter:(ssn_bound_filter)filter map:(ssn_bound_mapping)map;

@end


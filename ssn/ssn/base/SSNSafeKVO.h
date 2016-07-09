//
//  SSNSafeKVO.h
//  ssn
//
//  Created by lingminjun on 16/7/9.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  监听回调方法
 *
 *  @param keyPath sender的属性路径
 *  @param sender  sender
 *  @param change  改变值
 *  @param context 其他参数
 */
typedef void (^ssn_observe_value_changed_function)( NSString *_Nonnull keyPath, id _Nonnull sender, NSDictionary *_Nonnull change, void *_Nullable context);

/**
 @brief KVO 安全的写法，不需要移除，非线程安全
 */
@interface NSObject (SSNSafeKVO)

/**
 *  安全的添加kvo，若当前对象的keyPath值有对应的变化，将会回调
 *  observer的-observeValueForKeyPath:ofObject:change:context:方法
 *
 *  @param observer 注册者（观察者，监听者）
 *  @param keyPath  属性路径
 *  @param options  变化
 *  @param context  其他参数
 */
- (void)ssn_addObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

/**
 *  安全的添加kvo，若当前对象的keyPath值有对应的变化，将会回调callback，无法移除block
 *
 *  @param keyPath  属性路径
 *  @param options  变化
 *  @param context  其他参数
 *  @param callback 监听回调，请确保不要循环引用（⭐️重要）
 */
- (void)ssn_addObserverForKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context callback:(nonnull ssn_observe_value_changed_function)callback;

/**
 *  移除监听者
 *
 *  @param observer 注册者（观察者，监听者）
 *  @param keyPath  属性路径，若传入keyPath为空，则清空所有
 */
- (void)ssn_removeObserver:(nonnull NSObject *)observer forKeyPath:(nullable NSString *)keyPath;

/**
 *  移除所有监听者
 */
- (void)ssn_removeAllObservers;
@end

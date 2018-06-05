//
//  SSNSafeKVO.m
//  ssn
//
//  Created by lingminjun on 16/7/9.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import "SSNSafeKVO.h"
//#if TARGET_IPHONE_SIMULATOR
//#import <objc/objc-runtime.h>
//#else
#import <objc/runtime.h>
#import <objc/message.h>
//#endif

//粘合点
@interface SSNSafeKVO : NSObject

@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, weak) NSObject * observer;
@property (nonatomic, unsafe_unretained) NSObject * unsafe;//用于记录监听对象的指针地址，因为移除对象需要指针地址
@property (nonatomic, copy) ssn_observe_value_changed_function callback;

@end


@implementation SSNSafeKVO

- (void)clear {
    if (_unsafe != nil) {
        [_unsafe removeObserver:self forKeyPath:_keyPath];
    }
    _unsafe = nil;
    _callback = nil;
}

- (void)dealloc {
    [self clear];
}

//监听kvo回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object != _unsafe) {
        [self clear];
        return ;
    }
    
    if (_callback != nil) {
        _callback(keyPath,object,change,context);
    } else if (_observer != nil) {
        [_observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else {//注册者已经释放
        [self clear];
    }
}


@end



@implementation NSObject (SSNSafeKVO)

/**
 @brief observer管理器
 */
static char *ssn_observer_manager_key = NULL;
- (NSMutableDictionary<NSString *,NSMutableDictionary<NSString *,SSNSafeKVO *> *> *)ssn_observer_manager {
    
    NSMutableDictionary<NSString *,NSMutableDictionary<NSString *,SSNSafeKVO *> *> *dic = objc_getAssociatedObject(self, &ssn_observer_manager_key);
    if (dic) {
        return dic;
    }
    
//    @synchronized(self) {//已经提示非线程安全了，不需要再加锁了
        if (!dic) {
            dic = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self, &ssn_observer_manager_key, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
//    }
    
    return dic;
}

//取某个监听者观察的所有属性
- (NSMutableDictionary<NSString *,SSNSafeKVO *> *)ssn_getKeyPathsForObserver:(nonnull NSObject *)observer {
    NSString *obj_key = [NSString stringWithFormat:@"%p",observer];
    return [[self ssn_observer_manager] objectForKey:obj_key];
}

//取某个监听者
- (SSNSafeKVO *)ssn_getKVOForObserver:(nonnull NSObject *)observer keyPath:(nonnull NSString *)keyPath {
    NSString *obj_key = [NSString stringWithFormat:@"%p",observer];
    return [[[self ssn_observer_manager] objectForKey:obj_key] objectForKey:keyPath];
}

//添加监听者
- (void)ssn_setObserver:(SSNSafeKVO *)kvo {
    NSString *obj_key = [NSString stringWithFormat:@"%p",kvo.observer];
    NSMutableDictionary<NSString *,SSNSafeKVO *> *dic = [[self ssn_observer_manager] objectForKey:obj_key];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
        [[self ssn_observer_manager] setObject:dic forKey:obj_key];
    }
    [dic setObject:kvo forKey:kvo.keyPath];
}

//对象注册
- (void)ssn_addObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    [self ssn_addObserver:observer forKeyPath:keyPath options:options context:context callback:nil];
}

//block注册方式
- (void)ssn_addObserverForKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context callback:(nonnull ssn_observe_value_changed_function)callback {
    [self ssn_addObserver:nil forKeyPath:keyPath options:options context:context callback:nil];
}

//注册实现方法
- (void)ssn_addObserver:(NSObject *)observer forKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context callback:(ssn_observe_value_changed_function)callback {
    if ((nil == observer && callback == nil) || [keyPath length] == 0) {
        return ;
    }
    
    SSNSafeKVO *bound = [[SSNSafeKVO alloc] init];
    bound.unsafe = self;
    bound.observer = observer;
    bound.keyPath = keyPath;
    bound.callback = callback;
    
    //加入到管理器
    [self ssn_setObserver:bound];
    
    //注册key-value change，将bound对象传入，不要引用bound，
    [self addObserver:bound forKeyPath:keyPath options:options context:context];
}

- (void)ssn_removeObserver:(nonnull NSObject *)observer forKeyPath:(nullable NSString *)keyPath {
    if (nil == observer) {
        return ;
    }
    
    NSMutableDictionary<NSString *,SSNSafeKVO *> *dic = [self ssn_getKeyPathsForObserver:observer];
    if ([keyPath length] == 0) {
        [dic removeAllObjects];
    } else {
        [dic removeObjectForKey:keyPath];
    }
}

- (void)ssn_removeAllObservers {
    objc_setAssociatedObject(self, &ssn_observer_manager_key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    [[self ssn_observer_manager] removeAllObjects];
}


@end

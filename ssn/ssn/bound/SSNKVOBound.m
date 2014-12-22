//
//  SSNBound.m
//  ssn
//
//  Created by lingminjun on 14/12/11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNKVOBound.h"
#import "SSNBound.h"
#import "NSString+SSN.h"

@interface SSNKVOBound : NSObject <SSNBound>
@property (nonatomic, strong) NSString *field;//绑定对象属性
@property (nonatomic, strong) NSString *tiekey;//被影响的属性
@property (nonatomic, strong) NSString *tailkey;//绑定对象记录绑定key
@property (nonatomic, copy) ssn_bound_filter filter;
@property (nonatomic, copy) ssn_bound_mapping map;
@property (nonatomic, weak) id obj;
@property (nonatomic, weak) id tobj;
@property (nonatomic, unsafe_unretained) id unsafe;//用于记录监听对象的指针地址，因为移除对象需要指针地址

- (void)processChangedWithNewValue:(id)chaned_new_value;//处理监听的修改

- (void)processMainThreadChangedWithNewValue:(id)chaned_new_value;//处理监听的修改

@end


@implementation SSNKVOBound

/**
 @brief 返回另一端对象
 */
- (id)ssn_tailObject {
    return _obj;
}

/**
 @brief 返回另一端绑定的key
 */
- (NSString *)ssn_tailKey {
    return _tailkey;
}

- (void)dealloc {
    self.unsafe = nil;
    id obj = _obj;
    [obj removeObserver:self forKeyPath:_field];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id obj = _obj;
    id tobj = _tobj;
    
    if (nil == obj || nil == tobj) {
        [tobj ssn_clearTieFieldBound:_tiekey];
        return ;
    }
    
    id chaned_new_value = [change objectForKey:NSKeyValueChangeNewKey];
    
    [self processMainThreadChangedWithNewValue:chaned_new_value];
}

- (void)processMainThreadChangedWithNewValue:(id)chaned_new_value {
    __weak typeof(self) w_self = self;
    dispatch_block_t block = ^{
        __strong typeof(w_self) self = w_self;
        [self processChangedWithNewValue:chaned_new_value];
    };
    
    if ([NSThread isMainThread]) {//性能受损
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


- (void)processChangedWithNewValue:(id)chaned_new_value {
    id obj = _obj;
    id tobj = _tobj;
    
    if (nil == obj || nil == tobj) {
        [tobj ssn_clearTieFieldBound:_tiekey];
        return ;
    }
    
    BOOL isValid = YES;
    
    if (_filter) {
        isValid = _filter(_obj, _field, chaned_new_value);
    }
    
    if (!isValid) {
        return ;
    }
    
    //若有效则计算map
    id value = chaned_new_value;
    if (_map) {
        value = _map(_obj, _field, chaned_new_value);
    }
    
    if (value) {
        [_tobj setValue:value forKey:_tiekey];
    }
    else {
        [_tobj setNilValueForKey:_tiekey];
    }
}

@end

@implementation NSObject (SSNKVOBound)

/**
 @brief 添加一个绑定到某个属性上
 @param object 绑定的目标对象，
 @param field  绑定目标对象的属性
 @param tieField    绑定影响的属性
 */
- (void)ssn_boundObject:(id)object forField:(NSString *)field tieField:(NSString *)tieField {
    [self ssn_boundObject:object forField:field tieField:tieField filter:nil map:nil];
}

/**
 @brief 添加一个绑定到某个属性上，属性值直接赋值
 @param object 绑定的目标对象，
 @param field  绑定目标对象的属性
 @param tieField    绑定作用的属性，该属性必须支持setter方法
 @param filter      过滤器
 @param map         映射
 */
- (void)ssn_boundObject:(id)object forField:(NSString *)field tieField:(NSString *)tieField filter:(ssn_bound_filter)filter map:(ssn_bound_mapping)map {
    if (nil == object || [field length] == 0 || [tieField length] == 0) {
        return ;
    }
    
    SSNKVOBound *bound = [[SSNKVOBound alloc] init];
    bound.obj = object;
    bound.unsafe = object;
    bound.tobj = self;
    bound.field = [field copy];
    bound.tiekey = [tieField copy];
    bound.tailkey = [NSString stringWithUTF8Format:"%p-%s",self,[field UTF8String]];
    bound.filter = filter;
    bound.map = map;
    
    [self ssn_tieBound:bound forKey:tieField];
    
    SSNWeakBound *box = [SSNWeakBound bound:bound free:^(SSNKVOBound *b) {
        if (b.unsafe) {
            [b.unsafe removeObserver:b forKeyPath:b.field];
            b.unsafe = nil;
            b.obj = nil;
        }
    }];
    
    [object ssn_tieTailBound:box forKey:bound.tailkey];
    
    //注册key-value change，将bound对象传入，不要引用bound，
    [object addObserver:bound forKeyPath:field options:NSKeyValueObservingOptionNew context:nil];
    
    [bound processMainThreadChangedWithNewValue:[object valueForKey:field]];
}

@end
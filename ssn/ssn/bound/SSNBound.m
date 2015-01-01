//
//  SSNBound.m
//  ssn
//
//  Created by lingminjun on 14/12/13.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNBound.h"
#import "SSNSafeDictionary.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@implementation NSObject (SSNBound)

/**
 @brief 绑定器被影响端联合点
 */
static char *ssn_bound_dictionary_key = NULL;
- (SSNSafeDictionary *)ssn_bound_dictionary {
    
    SSNSafeDictionary *dic = objc_getAssociatedObject(self, &ssn_bound_dictionary_key);
    if (dic) {
        return dic;
    }
    
    @synchronized(self) {
        if (!dic) {
            dic = [[SSNSafeDictionary alloc] initWithCapacity:1];
            objc_setAssociatedObject(self, &ssn_bound_dictionary_key, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    return dic;
}

/**
 @brief 绑定器变化端联合点
 */
static char *ssn_bound_dictionary_tail_key = NULL;
- (SSNSafeDictionary *)ssn_bound_dictionary_tail {
    
    SSNSafeDictionary *dic = objc_getAssociatedObject(self, &ssn_bound_dictionary_tail_key);
    if (dic) {
        return dic;
    }
    
    @synchronized(self) {
        if (!dic) {
            dic = [[SSNSafeDictionary alloc] initWithCapacity:1];
            objc_setAssociatedObject(self, &ssn_bound_dictionary_tail_key, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    return dic;
}

/**
 @brief 作用端绑定
 @param key    绑定作用的属性
 */
- (void)ssn_tieBound:(id <SSNBound>)bound forKey:(NSString *)key {
    SSNSafeDictionary *dic = [self ssn_bound_dictionary];
    [dic setObject:bound forKey:key];
}

/**
 @brief 响应端绑定
 @param key    绑定作用的属性
 */
- (void)ssn_tieTailBound:(SSNWeakBound *)box forKey:(NSString *)key {
    SSNSafeDictionary *tail = [self ssn_bound_dictionary_tail];
    [tail setObject:box forKey:key];
}

/**
 @brief 移除属性的绑定
 @param tieField    绑定影响的属性
 */
- (void)ssn_clearTieFieldBound:(NSString *)tieField {
    if ([tieField length] == 0) {
        return ;
    }
    
    SSNSafeDictionary *dic = [self ssn_bound_dictionary];
    id<SSNBound> bound = [dic objectRemoveForKey:tieField];
    //另一端怎么移除
    [[[bound ssn_tailObject] ssn_bound_dictionary_tail] removeObjectForKey:[bound ssn_tailKey]];
}

@end


@interface SSNWeakBound ()
@property (nonatomic,weak) id<SSNBound> obj;
@property (nonatomic,copy) void(^freeBlock)(id obj);
@end

@implementation SSNWeakBound

- (void)dealloc {
    if (_freeBlock) {_freeBlock(_obj);}
}

- (id)object {
    return _obj;
}

+ (instancetype)bound:(id<SSNBound>)obj {
    return [self bound:obj free:nil];
}

+ (instancetype)bound:(id<SSNBound>)obj free:(void(^)(id obj))afree {
    if (nil == obj) {
        return nil;
    }
    SSNWeakBound *box = [[[self class] alloc] init];
    box.obj = obj;
    box.freeBlock = afree;
    return box;
}
@end

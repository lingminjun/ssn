//
//  NSObject+SSN.m
//  ssn
//
//  Created by lingminjun on 15/4/4.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "NSObject+SSN.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

NSString *const ssn_copy_push_flag = @"ssn_flag";

@implementation NSObject (SSN)

/**
 *  返回一个对象的副本
 *
 *  @return 返回新的对象
 */
- (instancetype)ssn_copy {
    Class clazz = [self class];
    
    id cp = nil;
    NSString *flag = objc_getAssociatedObject(self, &ssn_copy_push_flag);
    if (!flag) {
        BOOL override = [clazz ssn_instancesOverrideSelector:@selector(copyWithZone:)];
        if (override) {
            objc_setAssociatedObject(self, &ssn_copy_push_flag, ssn_copy_push_flag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            cp = [self copy];
            objc_setAssociatedObject(self, &ssn_copy_push_flag, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return cp;
        }
    }
    
    cp = [[clazz alloc] init];
    [cp ssn_setObject:self];
    return cp;
}

/**
 *  用一个对象来重置当前对象（仅仅影响other有的key）
 *
 *  @param other 另一个对象
 */
- (void)ssn_setObject:(id)other {
    @try {
        
        NSSet *self_properties = [self ssn_allProperties];
        NSSet *objc_properties = nil;
        if ([other isKindOfClass:[NSDictionary class]]) {
            objc_properties = [NSSet setWithArray:[(NSDictionary *)other allKeys]];
        }
        else if ([self class] == [other class]) {
            objc_properties = self_properties;
        }
        else {
            objc_properties = [other ssn_allProperties];
        }
        
        [self_properties enumerateObjectsUsingBlock:^(NSString *method, BOOL *stop) {
            
            //若目标对象包含同样的属性
            if ([objc_properties containsObject:method]) {
                id value = [other valueForKey:method];
                
                @try {
                    [self setValue:value forKey:method];
                }
                @catch (NSException *exception) {
                    NSLog(@"ssn_setObject setValue: exception %@",exception);
                }
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"ssn_setObject exception %@",exception);
    }
}

/**
 *  所有属性名（readonly以及为声明getter和setter方法的都在其中）
 *
 *  @return 属性列表
 */
- (NSSet *)ssn_allProperties {
    return [[self class] ssn_allProperties];
}

/**
 *  所有属性名（readonly以及为声明getter和setter方法的都在其中）
 *
 *  @return 属性列表
 */
+ (NSSet *)ssn_allProperties {
    NSMutableSet *properties = [[NSMutableSet alloc] init];
    
    @autoreleasepool {
        //递归寻找
        Class p_cls = [self class];
        Class ns_object_calzz = [NSObject class];
        Class ns_proxy_clazz = [NSProxy class];
        while (p_cls != nil && (p_cls != ns_object_calzz && p_cls != ns_proxy_clazz)) {
            unsigned int outCount;
            objc_property_t *c_properties = class_copyPropertyList(p_cls, &outCount);
            
            for (unsigned int i = 0; i < outCount; i++)
            {
                @autoreleasepool {
                    objc_property_t property = c_properties[i];
                    
                    const char *c_property_name = property_getName(property);
                    if (c_property_name && strlen(c_property_name) == 0) {
                        continue ;
                    }
                    
                    char *typeEncoding = property_copyAttributeValue(property, "T");
                    if (typeEncoding && strlen(typeEncoding) > 0) {
                        NSString *name = [NSString stringWithFormat:@"%s",c_property_name];
                        [properties addObject:name];
                    }
                    
                    if (typeEncoding) {
                        free(typeEncoding);
                    }
                }
            }
            
            if (c_properties) {
                free(c_properties);
            }
            
            p_cls = class_getSuperclass(p_cls);
        }
    }
    
    return properties;
}

/**
 *  某个类的实例对象是否重载了selector，这里不描述父类实现
 *
 *  @param aSelector 被重写的方法
 *
 *  @return 是否重载
 */
+ (BOOL)ssn_instancesOverrideSelector:(SEL)aSelector {
    if (!aSelector) {
        return NO;
    }
    
    Class clazz = [self class];
    unsigned int outCount = 0;
    Method *methods = class_copyMethodList(clazz, &outCount);
    BOOL result = NO;
    for (unsigned int i = 0; i < outCount; i++) {
        Method method = methods[i];
        if (sel_isEqual(aSelector, method_getName(method))) {
            result = YES;
            break ;
        }
    }
    
    if (methods) {
        free(methods);
    }
    
    return result;
}

@end

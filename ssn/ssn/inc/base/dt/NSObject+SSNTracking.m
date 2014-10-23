//
//  NSObject+SSNTracking.m
//  ssn
//
//  Created by lingminjun on 14-10-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "NSObject+SSNTracking.h"

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

#import "ssnbase.h"

#define ssn_alignof_type_size(t) (sizeof(int) * (int)((sizeof(t) + sizeof(int) - 1)/sizeof(int)))


void ssn_method_swizzle(Class c,SEL origSEL,SEL overrideSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method overrideMethod= class_getInstanceMethod(c, overrideSEL);
    
    /*
     周全起见，有两种情况要考虑一下。
     第一种情况是要复写的方法(overridden)并没有在目标类中实现(notimplemented)，而是在其父类中实现了。
     第二种情况是这个方法已经存在于目标类中(does existin the class itself)。
     
     这两种情况要区别对待。
     (译注: 这个地方有点要明确一下，它的目的是为了使用一个重写的方法替换掉原来的方法。但重写的方法可能是在父类中重写的，也可能是在子类中重写的。)
     
     对于第一种情况，应当先在目标类增加一个新的实现方法(override)，然后将复写的方法替换为原先(的实现(original one)。*/
    
    //运行时函数class_addMethod 如果发现方法已经存在，会失败返回，也可以用来做检查用:
    if(class_addMethod(c, origSEL, method_getImplementation(overrideMethod),method_getTypeEncoding(overrideMethod)))
    {
        
        //如果添加成功(在父类中重写的方法)，再把目标类中的方法替换为旧有的实现:
        class_replaceMethod(c,overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    /*
     (译注:addMethod会让目标类的方法指向新的实现，使用replaceMethod再将新的方法指向原先的实现，这样就完成了交换操作。)
     
     如果添加失败了，就是第二情况(在目标类重写的方法)。这时可以通过method_exchangeImplementations来完成交换:
     */
    else
    {
        method_exchangeImplementations(origMethod,overrideMethod);
    }
}

NSString *ssn_objc_forwarding_method_name(SEL selector)
{
    return [NSString stringWithFormat:@"ssn_forwarding_$%@", NSStringFromSelector(selector)];
}

NSInvocation *ssn_objc_invocation(id target, NSMethodSignature* signature, SEL selector, va_list argumentList)
{
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation retainArguments];
    
    [invocation setTarget:target];
    [invocation setSelector:selector];
    
    for (int index = 2; index < [signature numberOfArguments]; index++) {
        const char *type = [signature getArgumentTypeAtIndex:index];
        
        //double和float需要特殊处理
        if (type[0] == _C_FLT || type[0] == _C_DBL) {
            double value = va_arg(argumentList, double);
            [invocation setArgument:&value atIndex:index];
        }
        else {
            NSUInteger size = 0;
            NSGetSizeAndAlignment(type, &size, NULL);
            NSUInteger alignof_size = ssn_alignof_type_size(size);
#if (__GNUC__ > 2)
            char *p_area = argumentList->reg_save_area;
            p_area += argumentList->gp_offset;
            
            [invocation setArgument:p_area atIndex:index];
            
            argumentList->gp_offset += alignof_size;
#else
            [invocation setArgument:args atIndex:index];
            args += alignof_size;
#endif
        }
    }
    
    return invocation;
}

NSInvocation *ssn_objc_invocation_v2(id target, NSMethodSignature* signature, SEL selector, va_list argumentList)
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation retainArguments];
    
    [invocation setTarget:target];
    [invocation setSelector:selector];
    
    NSInteger arg_index = 2;
    
    NSUInteger arg_num = [signature numberOfArguments];
    
    if (arg_num > arg_index) {//必须具备起始值
        
        while (arg_num > arg_index) {
            
            const char* argType = [signature getArgumentTypeAtIndex:arg_index];
            while(strchr("rnNoORV", argType[0]) != NULL)
                argType += 1;
            
            if((strlen(argType) > 1) && (strchr("{^", argType[0]) == NULL))
                [NSException raise:NSInvalidArgumentException format:@"Cannot handle argument type '%s'.", argType];
            /*
             #define _C_ID       '@'
             #define _C_CLASS    '#'
             #define _C_SEL      ':'
             #define _C_CHR      'c'
             #define _C_UCHR     'C'
             #define _C_SHT      's'
             #define _C_USHT     'S'
             #define _C_INT      'i'
             #define _C_UINT     'I'
             #define _C_LNG      'l'
             #define _C_ULNG     'L'
             #define _C_LNG_LNG  'q'
             #define _C_ULNG_LNG 'Q'
             #define _C_FLT      'f'
             #define _C_DBL      'd'
             #define _C_BFLD     'b'
             #define _C_BOOL     'B'
             #define _C_VOID     'v'
             #define _C_UNDEF    '?'
             #define _C_PTR      '^'
             #define _C_CHARPTR  '*'
             #define _C_ATOM     '%'
             #define _C_ARY_B    '['
             #define _C_ARY_E    ']'
             #define _C_UNION_B  '('
             #define _C_UNION_E  ')'
             #define _C_STRUCT_B '{'
             #define _C_STRUCT_E '}'
             #define _C_VECTOR   '!'
             #define _C_CONST    'r'
             */
            switch (argType[0])
            {
                case _C_ID:
                case _C_CLASS:
                {
                    id argument = va_arg(argumentList, id);
                    [invocation setArgument:&argument atIndex:arg_index];
                    break;
                }
                case _C_SEL:
                {
                    SEL s = va_arg(argumentList, SEL);
                    [invocation setArgument:&s atIndex:arg_index];
                    break;
                }
                case _C_BOOL://bool size小于int的都用int取值
                case _C_SHT://shot size小于int的都用int取值
                case _C_USHT:
                case _C_CHR://char
                case _C_UCHR://unsigne char
                case _C_INT:
                {
                    int value = va_arg(argumentList, int);
                    [invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_UINT:
                {
                    unsigned int value = va_arg(argumentList, unsigned int);
                    [invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_LNG:
                {
                    long value = va_arg(argumentList, long);
                    [invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_ULNG:
                {
                    unsigned long value = va_arg(argumentList, unsigned long);
                    [invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_LNG_LNG:
                {
                    long long value = va_arg(argumentList, long long);
                    [invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_ULNG_LNG:
                {
                    unsigned long long value = va_arg(argumentList, unsigned long long);
                    [invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_FLT://浮点型都用double取值，__alignof__(float) == __alignof__(double) 不同操作系统可能存在影响
                case _C_DBL:
                {
                    double value = va_arg(argumentList, double);
                    [invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_PTR:
                {
                    void *value = va_arg(argumentList, void *);
                    [invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_STRUCT_B:
                {
                    NSUInteger size = 0;
                    NSGetSizeAndAlignment(argType, &size, NULL);
                    NSUInteger alignof_size = ssn_alignof_type_size(size);
#if (__GNUC__ > 2)
                    char *p_area = argumentList->reg_save_area;
                    p_area += argumentList->gp_offset;
                    
                    [invocation setArgument:p_area atIndex:arg_index];
                    
                    argumentList->gp_offset += alignof_size;
#else
                    [invocation setArgument:argumentList atIndex:arg_index];
                    argumentList += alignof_size;
#endif
                    const char *type_point = &(argType[1]);
                    while (*type_point != _C_STRUCT_E) {			// Skip "<name>=" stuff.
                        char c = *type_point++;
                        if (c == '=')
                        {
                            break;
                        }
                        
                        //拷贝类型，用于日志
                    }
                    break;
                }
                    
                case _C_UNION_B: {
                    NSUInteger size = 0;
                    NSGetSizeAndAlignment(argType, &size, NULL);
                    NSUInteger alignof_size = ssn_alignof_type_size(size);
#if (__GNUC__ > 2)
                    char *p_area = argumentList->reg_save_area;
                    p_area += argumentList->gp_offset;
                    
                    [invocation setArgument:p_area atIndex:arg_index];
                    
                    argumentList->gp_offset += alignof_size;
#else
                    [invocation setArgument:argumentList atIndex:arg_index];
                    argumentList += alignof_size;
#endif
                    
                    const char *type_point = &(argType[1]);
                    while (*type_point != _C_STRUCT_E) {			// Skip "<name>=" stuff.
                        char c = *type_point++;
                        if (c == '=')
                        {
                            break;
                        }
                        
                        //拷贝类型，用于日志
                    }
                    break;
                }
                default:{
                    NSUInteger size = 0;
                    NSGetSizeAndAlignment(argType, &size, NULL);
                    NSUInteger alignof_size = ssn_alignof_type_size(size);
#if (__GNUC__ > 2)
                    char *p_area = argumentList->reg_save_area;
                    p_area += argumentList->gp_offset;
                    
                    [invocation setArgument:p_area atIndex:arg_index];
                    
                    argumentList->gp_offset += alignof_size;
#else
                    [invocation setArgument:argumentList atIndex:arg_index];
                    argumentList += alignof_size;
#endif
                }break;
                    
            }
            
            arg_index++;
        }
        
    }
    
    return invocation;
}

//所有跟踪消息转发
id ssn_objc_forwarding_method_imp(id self,SEL _cmd, ...)
{
    NSString *rep_cmd = ssn_objc_forwarding_method_name(_cmd);
    SEL rep_sel = NSSelectorFromString(rep_cmd);
    
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:rep_sel];
    
    va_list argumentList;
    va_start(argumentList, _cmd);
    NSInvocation *rep_invocation = ssn_objc_invocation(self, methodSignature, rep_sel, argumentList);
    va_end(argumentList);

    struct timeval t_b_tv,t_e_tv;
    gettimeofday(&t_b_tv, NULL);
    [rep_invocation invoke];
    gettimeofday(&t_e_tv, NULL);
    long long t_cost = (t_e_tv.tv_sec - t_b_tv.tv_sec) * 1000000ll + (t_e_tv.tv_usec - t_b_tv.tv_usec);
    ssn_log("\n%s call -%s cost = %lld(ms)\n",[NSStringFromClass([self class]) UTF8String],[NSStringFromSelector(_cmd) UTF8String],t_cost);
    
    
//    NSValue    * ret_val  = nil;
//    NSUInteger   ret_size = [methodSignature methodReturnLength];
//    
//    if(ret_size > 0)
//    {
//        
//        void * ret_buffer = malloc( ret_size );
//        
//        [rep_invocation getReturnValue:ret_buffer];
//        
//        ret_val = [NSValue valueWithBytes:ret_buffer objCType:[methodSignature methodReturnType]];
//        
//        free(ret_buffer);
//    }
//    
//    return ret_val;
    
    return nil;
}

@implementation NSObject (SSNTracking)


/**
 *  设置需要采集的预置信息，将在每次打点发生时去用
 *
 *  @param  value       预置参数值
 *  @param  key         预置参数键值
 */
+ (void)setPresetValue:(NSString *)value forKey:(NSString *)key
{
}


/**
 *  跟踪clazz类实例的selector方法，当这个方法被调用时将会被记录，记录会自动收集预置参数
 *
 *  @param  clazz       跟踪的类
 *  @param  selector    跟踪类实例的方法，方法返回值仅仅支持id，和void类型，其他类型还不支持，方法参数不支持可变参数和联合参数，
 *                      内部采用NSInvocation转发调用，所以自然依赖“NSInvocation does not support invocations of methods
 *                      with either variable numbers of arguments or union arguments.”
 */
+ (void)ssn_tracking_class:(Class)clazz selector:(SEL)selector
{
    [self ssn_tracking_class:clazz selector:selector collectIvarList:nil];
}


/**
 *  跟踪clazz类实例的selector方法，当这个方法被调用时将会被记录，记录会自动收集预置参数
 *
 *  @param  clazz       跟踪的类
 *  @param  selector    跟踪类实例的方法，方法返回值仅仅支持id，和void类型，其他类型还不支持，方法参数不支持可变参数和联合参数，
 *                      内部采用NSInvocation转发调用，所以自然依赖“NSInvocation does not support invocations of methods
 *                      with either variable numbers of arguments or union arguments.”
 *  @param  ivarList    需要采集的当前实例属性值（若实例找不到属性将异常）
 */
+ (void)ssn_tracking_class:(Class)clazz selector:(SEL)selector collectIvarList:(NSArray *)ivarList
{
    NSAssert(clazz && selector, @"请传入正确参数");
    
    //1、先检查当前类是否响应此方法
    Method method = class_getInstanceMethod(clazz, selector);
    NSAssert(method, @"请确保要跟踪的类能响应此方法");
    
    //2、记录需要采集的参数
    //TODO : 
    
    ssn_log("\n ssn tracking class:%s selector:%s\n",[NSStringFromClass(clazz) UTF8String],[NSStringFromSelector(selector) UTF8String]);
    
    //3、再为此类添加转发方法
    SEL forwarding_sel = NSSelectorFromString(ssn_objc_forwarding_method_name(selector));
    
    const char *method_type = method_getTypeEncoding(method);
    
    if (class_addMethod(clazz, forwarding_sel, method_getImplementation(method), method_type))
    {
        //
    }
    
    //4、替换原来方法名字下的实现
    if (class_addMethod(clazz, selector, (IMP)ssn_objc_forwarding_method_imp, method_type))
    {
        ssn_log("\n ssn tracking add selector:%s\n",[NSStringFromSelector(selector) UTF8String]);
    }
    else
    {
        class_replaceMethod(clazz,selector,(IMP)ssn_objc_forwarding_method_imp, method_type);
        ssn_log("\n ssn tracking rewrite selector:%s\n",[NSStringFromSelector(selector) UTF8String]);
    }
    
}



@end

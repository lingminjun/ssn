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

struct SSNArgumentInfo
{ // internal Info about layout of arguments. Extended from the original OpenStep version - no longer available in OSX
    const char *type;				// type (pointer to first type character)
    int offset;						// can be negative (!)
    unsigned size;					// size
    unsigned align;					// alignment
    unsigned qual;					// qualifier (oneway, byref, bycopy, in, inout, out)
    unsigned index;					// argument index (to decode return=0, self=1, and _cmd=2)
    BOOL isReg;						// is passed in a register (+)
    BOOL byRef;						// argument is not passed by value but by pointer (i.e. structs)
    BOOL floatAsDouble;				// its a float value that is passed as double
    // ffi type
};


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

//所有跟踪消息转发
id ssn_objc_forwarding_method_imp(id self,SEL _cmd,...)
{
    NSString *rep_cmd = ssn_objc_forwarding_method_name(_cmd);
    SEL rep_sel = NSSelectorFromString(rep_cmd);
    
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:rep_sel];
    NSUInteger arg_num = [methodSignature numberOfArguments];
    
    NSInvocation *rep_invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    rep_invocation.target = self;
    rep_invocation.selector = rep_sel;
    
    NSInteger arg_index = 2;
    
    if (arg_num > arg_index) {
        va_list argumentList;
        va_start(argumentList, _cmd);
        
        while (arg_num > arg_index) {
            
            const char* argType = [methodSignature getArgumentTypeAtIndex:arg_index];
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
                    [rep_invocation setArgument:&argument atIndex:arg_index];
                    break;
                }
                case _C_SEL:
                {
                    SEL s = va_arg(argumentList, SEL);
                    [rep_invocation setArgument:&s atIndex:arg_index];
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
                    [rep_invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_UINT:
                {
                    unsigned int value = va_arg(argumentList, unsigned int);
                    [rep_invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_LNG:
                {
                    long value = va_arg(argumentList, long);
                    [rep_invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_ULNG:
                {
                    unsigned long value = va_arg(argumentList, unsigned long);
                    [rep_invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_LNG_LNG:
                {
                    long long value = va_arg(argumentList, long long);
                    [rep_invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_ULNG_LNG:
                {
                    unsigned long long value = va_arg(argumentList, unsigned long long);
                    [rep_invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_FLT://浮点型都用double取值，不同操作系统可能存在影响
                case _C_DBL:
                {
                    double value = va_arg(argumentList, double);
                    [rep_invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_PTR:
                {
                    void *value = va_arg(argumentList, void *);
                    [rep_invocation setArgument:&value atIndex:arg_index];
                    break;
                }
                case _C_STRUCT_B:
                {
                    /*
                     const char* typePtr = argType;
                     struct SSNArgumentInfo local;
                     //	struct { int x; double y; } fooalign;
                     struct { unsigned char x; } fooalign;
                     int acc_size = 0;
                     int acc_align = __alignof__(fooalign);
                     
                     while (*typePtr != _C_STRUCT_E)			// Skip "<name>=" stuff.
                     if (*typePtr++ == '=')
                     break;
                     // Base structure alignment
                     if (*typePtr != _C_STRUCT_E)			// on first element.
                     {
                     typePtr = mframe_next_arg(typePtr, &local);
                     if (!typePtr)
                     return typePtr;						// error
                     
                     acc_size = ROUND(acc_size, local.align);
                     acc_size += local.size;
                     acc_align = MAX(local.align, __alignof__(fooalign));
                     }
                     // Continue accumulating
                     while (*typePtr != _C_STRUCT_E)			// structure size.
                     {
                     typePtr = mframe_next_arg(typePtr, &local);
                     if (!typePtr)
                     return typePtr;						// error
                     
                     acc_size = ROUND(acc_size, local.align);
                     acc_size += local.size;
                     }
                     info->size = acc_size;
                     info->align = acc_align;
                     //printf("_C_STRUCT_B  size %d align %d\n",info->size,info->align);
                     typePtr++;								// Skip end-of-struct
                     */
                    void *value = va_arg(argumentList, void *);
                    break;
                }
                    
                case _C_UNION_B: {
                    /*
                     struct SSNArgumentInfo local;
                     int	max_size = 0;
                     int	max_align = 0;
                     
                     while (*typePtr != _C_UNION_E)			// Skip "<name>=" stuff.
                     if (*typePtr++ == '=')
                     break;
                     
                     while (*typePtr != _C_UNION_E)
                     {
                     typePtr = mframe_next_arg(typePtr, &local);
                     if (!typePtr)
                     return typePtr;						// error
                     max_size = MAX(max_size, local.size);
                     max_align = MAX(max_align, local.align);
                     }
                     info->size = max_size;
                     info->align = max_align;
                     typePtr++;								// Skip end-of-union
                     */
                    void *value = va_arg(argumentList, void *);
                    break;
                }
                default:{
                    void *value = va_arg(argumentList, void *);
                }break;
                    
            }
            
            arg_index++;
        }
        
        va_end(argumentList);
    }
    
    [rep_invocation retainArguments];
    
    [rep_invocation invoke];
    
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
 *  @param  selector    跟踪类实例的方法，方法返回值仅仅支持id，和void类型，其他类型还不支持
 */
+ (void)ssn_tracking_class:(Class)clazz selector:(SEL)selector
{
    [self ssn_tracking_class:clazz selector:selector collectIvarList:nil];
}


/**
 *  跟踪clazz类实例的selector方法，当这个方法被调用时将会被记录，记录会自动收集预置参数
 *
 *  @param  clazz       跟踪的类
 *  @param  selector    跟踪类实例的方法，方法返回值仅仅支持id，和void类型，其他类型还不支持
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
    
    printf("\n ssn tracking class:%s selector:%s\n",[NSStringFromClass(clazz) UTF8String],[NSStringFromSelector(selector) UTF8String]);
    
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
        //
    }
    else
    {
        class_replaceMethod(clazz,selector,(IMP)ssn_objc_forwarding_method_imp, method_type);
    }
    
}



@end

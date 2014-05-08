//
//  SSNModel.m
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNModel.h"
#import "SSNMeta.h"

NSString *const SSNModelException = @"SSNModelException";

@interface SSNModel ()
{
    SSNMeta * _meta;            //源数据
    NSMutableDictionary * _vls; //数据存储
    NSString *_predicateKey;    //对象主键
    
    //操作数
    NSUInteger _opt;            //操作数
    
    //状态变量
    BOOL _isFault;
    BOOL _hasChanged;
}

@property (nonatomic,strong) SSNMeta * meta;
@property (nonatomic,strong) NSMutableDictionary *vls;
@property (nonatomic,strong) NSString *predicateKey;

@property (nonatomic) NSUInteger opt;

@property (nonatomic) BOOL isFault;         //返回YES，表明数据还未加载，只有主键数据，反之。临时数据返回值没有意义，请不要关注。
@property (nonatomic) BOOL hasChanged;      //数据本身有提交与永久存储数据不同的值，临时数据永远返回NO

@end



@implementation SSNModel

@synthesize meta = _meta;
@synthesize vls = _vls;
@synthesize predicateKey = _predicateKey;
@synthesize opt = _opt;
@synthesize isFault = _isFault;
@synthesize hasChanged = _hasChanged;

- (BOOL)isTemporary {
    if (self.meta) {
        return NO;
    }
    return YES;
}

- (BOOL)needUpdate {
    if ([self isTemporary]) {
        return NO;
    }
    
    if ([self isFault]) {
        return NO;
    }
    
    if (self.opt < self.meta.opt) {//操作数小于元数据，表明可以更新
        return YES;
    }
    
    return NO;
}

#pragma mark 防止深入继承
- (id)init {
    //只有一层继承关系，
    if ([self superclass] != [SSNMeta class]) {
        [NSException raise: SSNModelException
                    format: @"SSNModel对象只能产生其直接派生类型。"];
        return nil;
    }
    
    self = [super init];
    if (self) {
        _vls = [[NSMutableDictionary alloc] initWithCapacity:0];
        _isFault = YES;
    }
    return self;
}

#pragma mark 派生类 get set方法实现
//- (void)setStrVl:(NSString *)vl {
//}
//- (NSString *)strVl {
//    return [self.vls valueForKey:<#(NSString *)#>]
//}

+ (void)initialize {
    if ([self superclass] != [SSNMeta class]) {
        return ;
    }
    
    //开始加载get和set方法
}

#pragma mark 支持拷贝
- (SSNModel *)copyWithZone:(NSZone *)zone {
    SSNModel *cp = [[[self class] alloc] init];
    cp.meta = self.meta;
    [cp.vls setDictionary:self.vls];
    cp.predicateKey = self.predicateKey;
    cp.opt = self.opt;
    cp.isFault = self.isFault;
    return cp;
}

#pragma mark API实现
- (void)refreshModel {
    if ([self needUpdate]) {
        [self.vls removeAllObjects];
        self.opt = self.meta.opt;
        self.isFault = YES;
    }
}

@end

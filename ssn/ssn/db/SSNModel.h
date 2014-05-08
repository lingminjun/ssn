//
//  SSNModel.h
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNModel : NSObject <NSCopying>

- (NSString *)predicateKey;             //数据存储主键组合，如：@"gid = '101' AND uid = '231890'"

- (BOOL)isTemporary;     //返回YES，表明数据没有关联到永久存储上，反之已然。

@property (nonatomic,readonly) BOOL isFault;         //返回YES，表明数据还未加载，只有主键数据，反之。临时数据返回值没有意义，请不要关注。
@property (nonatomic,readonly) BOOL hasChanged;      //数据本身有提交与永久存储数据不同的值，临时数据永远返回NO

- (BOOL)needUpdate;      //返回YES，数据已经加载，但是对应的永久存储数据已经发生改变，反之。

- (void)refreshModel;//needUpdate为yes时，此方法才能刷新对象数据，否则忽略

@end

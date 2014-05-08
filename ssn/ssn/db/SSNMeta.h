//
//  SSNMeta.h
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef SSNMetaFactory
#define SSNMetaFactory(cls,key)          [SSNMeta productWithModelClass:(cls) modelKey:(key)]
#endif

@interface SSNMeta : NSObject
{
    NSMutableDictionary *  _vls;   //数据项存储
    NSString            *  _tkey;  //指定元数据key(meta的key:“class-key”)
    id                     _tcls;  //指定元数据类行
    NSUInteger             _opt;   //操作数
}

@property (nonatomic,strong) NSMutableDictionary *  vls;
@property (nonatomic,strong) NSString            *  tkey;
@property (nonatomic,strong) id tcls;
@property (nonatomic) NSUInteger opt;

+ (SSNMeta *)productWithModelClass:(id)tcl modelKey:(NSString *)key;

@end

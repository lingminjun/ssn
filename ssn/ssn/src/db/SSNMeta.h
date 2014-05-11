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

#define SSNCompositeMetaKey(cls,modelKey) [NSString stringWithUTF8Format:"%p-%s",cls,[modelKey UTF8String]]
#define SSNParseModelKey(metaKey)         [metaKey substringFromIndex:([metaKey rangeOfString:@"-"].location + 1)];

@interface SSNMeta : NSObject
{
    NSMutableDictionary *  _vls;   //数据项存储
    NSString            *  _tkey;  //指定元数据key(meta的key:“modelClass-modelKey”)
    NSString            *  _mkey;  //modelKey
    id                     _tcls;  //modelClass指定元数据类行
    NSUInteger             _opt;   //操作数
    BOOL                   _isFault;//是否加载
    BOOL                   _isDeleted;//被删除
}

@property (nonatomic,strong,readonly) NSMutableDictionary *  vls;
@property (nonatomic,strong,readonly) NSString            *  mkey;
@property (nonatomic,strong,readonly) NSString            *  tkey;
@property (nonatomic,strong,readonly) id tcls;
@property (nonatomic,readonly) NSUInteger opt;
@property (nonatomic,readonly) BOOL isFault;
@property (nonatomic,readonly) BOOL isDeleted;

//加载全部数据,数据将会刷新
+ (BOOL)loadMeta:(SSNMeta *)meta datas:(NSDictionary *)datas;

//加载主键数据，仍然是isFault状态,数据已经加载则不能设置参数
+ (BOOL)loadMeta:(SSNMeta *)meta keyDatas:(NSDictionary *)keyDatas;

//删除操作
+ (BOOL)deleteMeta:(SSNMeta *)meta;

//唯一工程方法
+ (SSNMeta *)productWithModelClass:(id)tcl modelKey:(NSString *)key;

@end

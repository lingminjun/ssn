//
//  SSNBlackBox.m
//  ssn
//
//  Created by lingminjun on 14/12/11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNBlackBox.h"
#import "ssnbbox.h"

@interface SSNBlackBox () {
    NSString *_path;
    ssn_bbox_t *_box;
}
@end

@implementation SSNBlackBox

+ (instancetype)sharedInstance {
    static SSNBlackBox *box = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        box = [[SSNBlackBox alloc] init];
    });
    return box;
}

- (void)dealloc {
    if (_box) {
        ssn_bbox_destroy(_box);
    }
}

- (void)setBBoxPath:(NSString *)path {
    NSString *tpath = [path copy];
    @synchronized(self) {
        //相同不用再次赋值
        if ([_path isEqualToString:tpath]) {
            return ;
        }
        
        _path = tpath;
        
        if (_box) {
            ssn_bbox_destroy(_box);
            _box = NULL;
        }
        
        if (_path) {
            _box = ssn_bbox_create([_path UTF8String], 10);
        }
        
    }
}

/**
 @brief 根据key获取密文信息
 @param key 密文对应的key
 */
- (NSString *)securityValueForKey:(NSString *)key {
    if (!_path || [key length] == 0) {
        return nil;
    }
    
    const char *v_str = NULL;
    
    if (_box) {
        v_str = ssn_bbox_copy_value([key UTF8String], _box);
    }
    
    if (v_str) {
        return [[NSString alloc] initWithBytesNoCopy:(void *)v_str
                                              length:strlen(v_str)
                                            encoding:NSUTF8StringEncoding
                                        freeWhenDone:YES];
    }
    
    return nil;
}


/**
 @brief 在对应的key上设置密文文件
 @param value 存储密文
 @param key 密文对应的key
 */
- (void)saveSecurityValue:(NSString *)value forKey:(NSString *)key {
    if (!_path || [value length] == 0 || [key length] == 0) {
        return ;
    }
    
    if (_box) {
        ssn_bbox_set_value([value UTF8String], [key UTF8String], _box);
    }
}


/**
 @brief 根据key删除密文信息
 @param key 密文对应的key
 */
- (void)removeSecurityValueForKey:(NSString *)key {
    if (!_path || [key length] == 0) {
        return ;
    }
    
    if (_box) {
        ssn_bbox_remove_value([key UTF8String], _box);
    }
}

@end

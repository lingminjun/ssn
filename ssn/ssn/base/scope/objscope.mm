//
//  objscope.mm
//  ssn
//
//  Created by lingminjun on 15/4/11.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#include "objscope.h"

objscope::objscope() {
}
objscope::objscope(NSObject *obj) {
    hold(obj);
}
objscope::~objscope() {
    if (_obj) {
#if __has_feature(objc_arc)
        _obj = nil;
#else
        _obj = [obj release];
        _obj = nil;
#endif
    }
}
NSObject *objscope::obj() {
    return _obj;
}
int objscope::hold(NSObject *obj) {
    __block int ret = obj_scope_hold_error;
    if (obj) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
#if __has_feature(objc_arc)
            _obj = obj;
#else
            _obj = [obj retain];
#endif
            ret = obj_scope_hold_ok;
        });
    }
    return ret;
}

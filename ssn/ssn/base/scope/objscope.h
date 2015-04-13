//
//  objscope.h
//  ssn
//
//  Created by lingminjun on 15/4/11.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#ifndef __ssn__objscope__
#define __ssn__objscope__
#import <Foundation/Foundation.h>
    
#define obj_scope_hold_ok 0
#define obj_scope_hold_error 1

class objscope {
public:
    objscope();
    objscope(NSObject *obj);//if obj != nil will hold obj
    ~objscope();
    NSObject *obj();
    int hold(NSObject *obj);//if hold object return obj_scope_hold_ok; only the first call is effective
private:
    NSObject *_obj;
};

#endif /* defined(__ssn__objscope__) */

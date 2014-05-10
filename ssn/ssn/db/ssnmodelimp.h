//
//  ssnmodelimp.h
//  ssn
//
//  Created by lingminjun on 14-5-10.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef ssn_ssnmodelimp_h
#define ssn_ssnmodelimp_h


/*对于非临时model对象，主键一旦被赋值就不能再次赋值，再次赋值将会抛出异常，主键不支持null*/
#define ssnimpTextPrimary(key)      /*实现string类型主键*/            SSNSynthesizePrimaryObj(key)
#define ssnimpIntPrimary(key)       /*实现int类型主键*/               SSNSynthesizePrimaryInt(key)

#define ssnimpObj(key)              /*实现string或者data类型属性*/     SSNSynthesizeNormalObj(key)
#define ssnimpInt(key)              /*实现int,bool,long类型属性*/     SSNSynthesizeNormalInt(key)
#define ssnimpFloat(key)            /*实现float,double类型属性*/      SSNSynthesizeNormalFloat(key)




#pragma mark getter 和 setter方法实现

#define SSNSynthesizePrimaryObj(pro) dynamic pro;\
/*getter imp*/  \
SSNSynthesizeGetterObj(pro) \
/*setter imp*/  \
SSNSynthesizeSetterPrimaryObj(pro)

#define SSNSynthesizePrimaryInt(pro) dynamic pro;   \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wmismatched-return-types\"") \
/*getter imp*/  \
SSNSynthesizeGetterInt(pro) \
/*setter imp*/  \
SSNSynthesizeSetterPrimaryInt(pro) \
_Pragma("clang diagnostic pop") 

#define SSNSynthesizePrimaryFloat(pro) dynamic pro;\
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wmismatched-return-types\"") \
/*getter imp*/  \
SSNSynthesizeGetterFloat(pro) \
/*setter imp*/  \
SSNSynthesizeSetterPrimaryFloat(pro) \
_Pragma("clang diagnostic pop")

#define SSNSynthesizeNormalObj(pro) dynamic pro;\
/*getter imp*/  \
SSNSynthesizeGetterObj(pro) \
/*setter imp*/  \
SSNSynthesizeSetterNormalObj(pro)

#define SSNSynthesizeNormalInt(pro) dynamic pro;\
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wmismatched-return-types\"") \
/*getter imp*/  \
SSNSynthesizeGetterInt(pro) \
/*setter imp*/  \
SSNSynthesizeSetterNormalInt(pro) \
_Pragma("clang diagnostic pop")

#define SSNSynthesizeNormalFloat(pro) dynamic pro;\
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wmismatched-return-types\"") \
/*getter imp*/  \
SSNSynthesizeGetterFloat(pro) \
/*setter imp*/  \
SSNSynthesizeSetterNormalFloat(pro) \
_Pragma("clang diagnostic pop")

#define SSNSynthesizeGetterObj(key) \
- (id) key { \
    return [(id<SSNModel>)self getObjectValueForKey:@# key];\
}

#define SSNSynthesizeGetterInt(key) \
- (long long) key { \
    return [[(id<SSNModel>)self getObjectValueForKey:@# key] longLongValue];\
}

#define SSNSynthesizeGetterFloat(key) \
- (double) key { \
    return [[(id<SSNModel>)self getObjectValueForKey:@# key] doubleValue];\
}


#define SSNSynthesizeSetterPrimaryObj(key) \
- (void) ssn_model_set_op_ ## key:(id) tem_ ## key { \
    [(id<SSNModel>)self setObjectValue:tem_ ## key forKey:@# key];\
}

#define SSNSynthesizeSetterPrimaryInt(key) \
- (void) ssn_model_set_ip_ ## key:(long long) tem_ ## key { \
    [(id<SSNModel>)self setObjectValue:@(tem_ ## key) forKey:@# key];\
}

#define SSNSynthesizeSetterPrimaryFloat(key) \
- (void) ssn_model_set_fp_ ## key:(double) tem_ ## key { \
    [(id<SSNModel>)self setObjectValue:@(tem_ ## key) forKey:@# key];\
}

#define SSNSynthesizeSetterNormalObj(key) \
- (void) ssn_model_set_on_ ## key:(id) tem_ ## key { \
    [(id<SSNModel>)self setObjectValue:tem_ ## key forKey:@# key];\
}

#define SSNSynthesizeSetterNormalInt(key) \
- (void) ssn_model_set_in_ ## key:(long long) tem_ ## key { \
    [(id<SSNModel>)self setObjectValue:@(tem_ ## key) forKey:@# key];\
}

#define SSNSynthesizeSetterNormalFloat(key) \
- (void) ssn_model_set_fn_ ## key:(double) tem_ ## key { \
    [(id<SSNModel>)self setObjectValue:@(tem_ ## key) forKey:@# key];\
}


#endif

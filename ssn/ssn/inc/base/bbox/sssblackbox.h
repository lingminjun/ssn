//
//  sssblackbox.h
//  ssn
//
//  Created by lingminjun on 14/12/5.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__sssblackbox__
#define __ssn__sssblackbox__

#if defined(__cplusplus)
#define SSN_BBOX_EXTERN extern "C"
#else
#define SSN_BBOX_EXTERN extern
#endif

/**
 *  防止gdb调试，debug下不起作用
 */
SSN_BBOX_EXTERN void ssn_disable_gdb(void);

#endif /* defined(__ssn__sssblackbox__) */

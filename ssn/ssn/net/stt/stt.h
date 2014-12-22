//
//  stt.h
//  ssn
//
//  Created by lingminjun on 14/11/21.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__stt__
#define __ssn__stt__

#include <stdio.h>

#include "buffer.h"

#if DEBUG
#ifdef ANDROID_OS_DEBUG
#define stt_log(s, ...) __android_log_print(ANDROID_LOG_INFO, "printf", s)
#else
#define stt_log(s, ...) printf(s, ##__VA_ARGS__)
#endif
#else
#define stt_log(s, ...) ((void)0)
#endif

namespace ssn {
    
    /**
        Secure transmission tunnel，
     */
    class stt{
        public :
        int write_data();
        int read_data();
        private :
        ustring rsa_pub_key;
        ustring aes_key;
    };
    
    class rsa {
        ustring rsa_pub_key;
        ustring rsa_mod;
        ustring rsa_pri_key;
    };
}

#endif /* defined(__ssn__stt__) */

//
//  sssblackbox.c
//  ssn
//
//  Created by lingminjun on 14/12/5.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "sssblackbox.h"

#include <dlfcn.h>
#include <sys/types.h>

typedef int (*ssn_ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

void ssn_disable_gdb(void) {
#ifndef DEBUG
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ssn_ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
#endif
}

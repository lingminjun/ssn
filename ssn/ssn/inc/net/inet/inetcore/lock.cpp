//
//  lock.cpp
//  inettest
//
//  Created by jay on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


#include "lock.h"


MutexLock::MutexLock()
{
    pthread_mutex_init(&mutext,NULL);
}
MutexLock::~MutexLock()
{
    pthread_mutex_destroy(&mutext);
}
int MutexLock::Lock()
{
    return pthread_mutex_lock(&mutext);
}
int MutexLock::UnLock()
{
    return pthread_mutex_unlock(&mutext);
}

void unlock_glock(void *pArg){
  pthread_mutex_t *mutex = (pthread_mutex_t*)pArg;
  pthread_mutex_unlock(mutex);
  printf("unlock_glock.");
}

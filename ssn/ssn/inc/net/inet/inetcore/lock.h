//
//  lock.h
//  inettest
//
//  Created by jay on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef inettest_lock_h
#define inettest_lock_h

#include <pthread.h>
#include <sys/time.h>

#include <memory>

#define LOCK_DEBUG 0

class MutexLock
{
  public:
    MutexLock();
    ~MutexLock();
    int Lock();
    int UnLock();
    pthread_mutex_t &get_pthread_mutex()
    {
        return mutext;
    }

  private:
    pthread_mutex_t mutext;
};

class RecursiveMutex
{
  public:
    RecursiveMutex()
    {
        pthread_mutexattr_t mta;
        int rc = pthread_mutexattr_init(&mta);
        rc = pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&mutex, &mta);
        pthread_mutexattr_destroy(&mta);
    }

    ~RecursiveMutex()
    {
        pthread_mutex_destroy(&mutex);
    }

    int Lock()
    {
        return pthread_mutex_lock(&mutex);
    }

    int TryLock()
    {
        return pthread_mutex_trylock(&mutex);
    }

    int UnLock()
    {
        return pthread_mutex_unlock(&mutex);
    }

    pthread_mutex_t &get_pthread_mutex() const
    {
        return mutex;
    }

  protected:
    mutable pthread_mutex_t mutex;
};

extern void unlock_glock(void *pArg);
template <class T> class TScopedLock
{
  public:
    explicit TScopedLock(T &lock, char x = '0') : lock_(lock)
    {
#ifndef ANDROID_OS_DEBUG
        __self = pthread_self();
        __handler.__routine = unlock_glock;
        __handler.__arg = (void *)&lock_.get_pthread_mutex();
        __handler.__next = __self->__cleanup_stack;
        __self->__cleanup_stack = &__handler;
#else
        __pthread_cleanup_push(&__cleanup, (unlock_glock), ((void *)&lock_.get_pthread_mutex()));
#endif
        lock_.Lock();
#if LOCK_DEBUG
        mFlag = x;
        if (mFlag != '0')
            printf("TScopedLock  %c", mFlag);
#endif
    }
    ~TScopedLock()
    {
        lock_.UnLock();
#ifndef ANDROID_OS_DEBUG
        __self->__cleanup_stack = __handler.__next;
#else
        __pthread_cleanup_pop(&__cleanup, (0));
#endif
#if LOCK_DEBUG
        if (mFlag != '0')
            printf("~TScopedLock  %c", mFlag);
#endif
    }

  private:
#if LOCK_DEBUG
    char mFlag;
#endif
#ifndef ANDROID_OS_DEBUG
    pthread_t __self;
    struct __darwin_pthread_handler_rec __handler;
#else
    __pthread_cleanup_t __cleanup;
#endif
    T &lock_;
};

class ScopedMutexLock
{
  public:
    ScopedMutexLock(MutexLock &lock) : mLock(lock)
    {
        mLock.Lock();
    }
    ~ScopedMutexLock()
    {
        mLock.UnLock();
    }

  private:
    MutexLock &mLock;
};
static void GetDelayedTimeSpec(uint64_t delayed_misc, struct timespec &ts)
{
    // clock_gettime(CLOCK_REALTIME,&ts);

    timeval now;
    gettimeofday(&now, NULL);

    ts.tv_sec = now.tv_sec;
    ts.tv_nsec = now.tv_usec;

    ts.tv_sec += delayed_misc / 1000;
    long cur_misc = ts.tv_nsec / 1000000;
    long tmp_misc = cur_misc + delayed_misc % 1000;
    ts.tv_sec += tmp_misc / 1000;
    ts.tv_nsec = (tmp_misc % 1000) * 1000000;
}

class ConditionLock
{
  public:
    ConditionLock()
    {
        pthread_cond_init(&cond_, NULL);
    }
    ~ConditionLock()
    {
        pthread_cond_destroy(&cond_);
    }

    int Signal()
    {
        return pthread_cond_signal(&cond_);
    }
    int BroadCast()
    {
        return pthread_cond_broadcast(&cond_);
    }

    int Wait(MutexLock &mutex, int64_t misc)
    {
        int iret = -1;
        if (misc <= 0)
        {
            iret = pthread_cond_wait(&cond_, &mutex.get_pthread_mutex());
            return iret;
        }

        struct timespec ts;
        GetDelayedTimeSpec(misc, ts);
        iret = pthread_cond_timedwait(&cond_, &mutex.get_pthread_mutex(), &ts);
        return iret;
    }

  private:
    pthread_cond_t cond_;
};

class WaitObject
{
  public:
    WaitObject()
    {
        bsignaled_ = false;
    }

  public:
    int TimedWait(int64_t timeoutms = -1, char tag = '0')
    {
        ScopedMutexLock tmplock(mutex_);
#if LOCK_DEBUG
        mTag = tag;
        if (mTag != '0')
        {
            printf("WaitObject wait %c", mTag);
        }
#endif
        if (bsignaled_)
            return 0;
        return cond_.Wait(mutex_, timeoutms);
    }
    int Signal()
    {
        ScopedMutexLock tmplock(mutex_);
#if LOCK_DEBUG
        if (mTag != '0')
        {
            printf("WaitObject signal %c", mTag);
        }
#endif
        bsignaled_ = true;
        return cond_.Signal();
    }
    int Broadcast()
    {
        {
            ScopedMutexLock tmplock(mutex_);
            bsignaled_ = true;
        }
        return cond_.BroadCast();
    }
    pthread_mutex_t &get_pthread_mutex()
    {
        return mutex_.get_pthread_mutex();
    }

  private:
#if LOCK_DEBUG
    char mTag;
#endif
    MutexLock mutex_;
    ConditionLock cond_;
    volatile bool bsignaled_;
};

typedef std::shared_ptr<WaitObject> WaitObjectPtr;
#endif

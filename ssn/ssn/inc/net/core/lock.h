//
//  lock.h
//  ssn
//
//  Created by lingminjun on 14-8-19.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__lock__
#define __ssn__lock__

#include <pthread.h>
#include <sys/time.h>
#include <memory> //C11
//#include <tr1/memory>//C99

namespace ssn
{
class mutexlock
{
  public:
    mutexlock()
    {
        pthread_mutex_init(&_mutex, NULL);
    }
    ~mutexlock()
    {
        pthread_mutex_destroy(&_mutex);
    }
    int lock()
    {
        return pthread_mutex_lock(&_mutex);
    }
    int unlock()
    {
        return pthread_mutex_unlock(&_mutex);
    }
    pthread_mutex_t &get_pthread_mutex()
    {
        return _mutex;
    }

  private:
    pthread_mutex_t _mutex;
};

class recursivelock
{
  public:
    recursivelock()
    {
        pthread_mutexattr_t mta;
        int rc = pthread_mutexattr_init(&mta);
        rc = pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_mutex, &mta);
        pthread_mutexattr_destroy(&mta);
    }

    ~recursivelock()
    {
        pthread_mutex_destroy(&_mutex);
    }

    int lock()
    {
        return pthread_mutex_lock(&_mutex);
    }

    int trylock()
    {
        return pthread_mutex_trylock(&_mutex);
    }

    int unlock()
    {
        return pthread_mutex_unlock(&_mutex);
    }

    pthread_mutex_t &get_pthread_mutex() const
    {
        return _mutex;
    }

  protected:
    mutable pthread_mutex_t _mutex;
};

extern void delay_time_spec(const uint64_t &delay_misc, struct timespec &ts);
class conditionlock
{
  public:
    conditionlock()
    {
        pthread_cond_init(&_cond, NULL);
    }
    ~conditionlock()
    {
        pthread_cond_destroy(&_cond);
    }

    int signal()
    {
        return pthread_cond_signal(&_cond);
    }
    int broadcast()
    {
        return pthread_cond_broadcast(&_cond);
    }

    int wait(mutexlock &mutex, int64_t misc)
    {
        int iret = -1;
        if (misc <= 0)
        {
            iret = pthread_cond_wait(&_cond, &mutex.get_pthread_mutex());
            return iret;
        }

        struct timespec ts;
        delay_time_spec(misc, ts);
        iret = pthread_cond_timedwait(&_cond, &mutex.get_pthread_mutex(), &ts);
        return iret;
    }

  private:
    pthread_cond_t _cond;
};

extern void unlock_glock(void *pArg);

template <class T> class scopedlock
{
  public:
    explicit scopedlock(T &lock) : _lock(lock)
    {
#ifndef ANDROID_OS_DEBUG
        _thread = pthread_self();
        _handler.__routine = unlock_glock;
        _handler.__arg = (void *)&_lock.get_pthread_mutex();
        _handler.__next = _thread->__cleanup_stack;
        _thread->__cleanup_stack = &_handler;
#else
        __pthread_cleanup_push(&_cleanup, (unlock_glock), ((void *)&_lock.get_pthread_mutex()));
#endif
        _lock.lock();
    }
    ~scopedlock()
    {
        _lock.unlock();
#ifndef ANDROID_OS_DEBUG
        _thread->__cleanup_stack = _handler.__next;
#else
        __pthread_cleanup_pop(&_cleanup, (0));
#endif
    }

  private:
#ifndef ANDROID_OS_DEBUG
    pthread_t _thread;
    struct __darwin_pthread_handler_rec _handler;
#else
    __pthread_cleanup_t _cleanup;
#endif
    T &_lock;
};

class waitobject
{
  public:
    waitobject()
    {
        _signaled = false;
    }

  public:
    int wait(int64_t timeoutms = -1)
    {
        scopedlock<mutexlock> tmplock(_mutex);
        if (_signaled)
        {
            return 0;
        }
        return _cond.wait(_mutex, timeoutms);
    }
    int signal()
    {
        scopedlock<mutexlock> tmplock(_mutex);
        _signaled = true;
        return _cond.signal();
    }
    int broadcast()
    {
        {
            scopedlock<mutexlock> tmplock(_mutex);
            _signaled = true;
        }
        return _cond.broadcast();
    }
    pthread_mutex_t &get_pthread_mutex()
    {
        return _mutex.get_pthread_mutex();
    }

  private:
    mutexlock _mutex;
    conditionlock _cond;
    volatile bool _signaled;
};

// typedef std::tr1::shared_ptr<waitobject> waitobject_ptr;
typedef std::shared_ptr<waitobject> waitobject_ptr;
}

#endif /* defined(__ssn__lock__) */

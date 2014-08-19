#ifndef __SAFEQUEUE_H
#define __SAFEQUEUE_H

#include <errno.h>
#include <pthread.h>
#include <queue>
#include <unistd.h>

template <class T>
class SafeQueue 
{
public:
	SafeQueue(); 
	~SafeQueue(); 
	bool IsEmpty() const; 
	uint64_t Size() const; 
	bool Put(const T& value,bool bForce=false); 
    void PutFront(const T& value);
	bool Get(T& t);
	bool Get(int timeoutms,T& t);//ms
    void SetQueueMax(uint64_t qmax){
        mMaxSize_=qmax;
    }
    void Clear(){
        pthread_mutex_lock(&write_mutex);
        inQueue.clear();
        pthread_mutex_unlock(&write_mutex);
    }
private:
    std::deque<T> inQueue;
	pthread_mutex_t write_mutex;
	pthread_cond_t more;
    uint64_t size_, mMaxSize_;
};

template <class T>
SafeQueue<T>::SafeQueue()
{
    size_ =0;
    mMaxSize_=10000000;
	pthread_mutex_init(&write_mutex, NULL);
	pthread_cond_init(&more, NULL);
}

template <class T>
SafeQueue<T>::~SafeQueue()
{
    pthread_cond_destroy(&more);
	pthread_mutex_destroy(&write_mutex);
}

template <class T>
bool SafeQueue<T>::IsEmpty() const
{
	return size_==0;
}

template <class T>
uint64_t SafeQueue<T>::Size() const
{
    return size_;
}
template <class T>
void SafeQueue<T>::PutFront(const T& value)
{
	pthread_mutex_lock(&write_mutex);
    size_++;
	inQueue.push_front(value);
	pthread_cond_signal(&more);
	pthread_mutex_unlock(&write_mutex);
    return ;
    
}
template <class T>
bool SafeQueue<T>::Put(const T& value,bool bForce)
{
	pthread_mutex_lock(&write_mutex);
    if(false==bForce)
    {
        if(size_>=mMaxSize_)
        {
	        pthread_mutex_unlock(&write_mutex);
            return false;
        }
    }
    size_++;
	inQueue.push_back(value);
	pthread_cond_signal(&more);
	pthread_mutex_unlock(&write_mutex);
    return true;
}

template <class T>
bool SafeQueue<T>::Get(T& retT)
{
	pthread_mutex_lock(&write_mutex);
	while(inQueue.empty())
	{
		pthread_cond_wait(&more, &write_mutex);
	}
	retT=inQueue.front();
    inQueue.pop_front();
    size_--;
	pthread_mutex_unlock(&write_mutex);
	return true;
}

template <class T>
bool SafeQueue<T>::Get(int tmms,T& retT)
{
	struct timeval now;
    struct timespec timeout;
    struct timezone tz;
    int retcode=0;
    gettimeofday(&now,&tz);
    int sec = tmms/ 1000;
    int nano = (tmms- sec*1000)*1000000;
    timeout.tv_sec = now.tv_sec + tmms/1000;
    timeout.tv_nsec = now.tv_usec * 1000 + nano;

    pthread_mutex_lock(&write_mutex);
	while(inQueue.empty() && retcode != ETIMEDOUT)
	{
		retcode = pthread_cond_timedwait(&more, &write_mutex, &timeout);
	}
	if(ETIMEDOUT == retcode)
	{
		pthread_mutex_unlock(&write_mutex);
		return false;	
	}
	retT=inQueue.front();
    inQueue.pop_front();
    size_--;
	pthread_mutex_unlock(&write_mutex);
	return true;
};


#endif 

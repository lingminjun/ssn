//
//  SSNSeqGen.m
//  ssn
//
//  Created by lingminjun on 15/3/15.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNSeqGen.h"
#import <pthread.h>

@interface SSNSeqGen () {
    pthread_mutex_t _mutex;
    NSUInteger _seq_seek;
}
@property (nonatomic) NSUInteger cycleSize;
@end

@implementation SSNSeqGen

- (instancetype)init {
    return [self initWithCycleSize:SSNSeqGenDefaultCycleSize];
}

- (instancetype)initWithCycleSize:(NSUInteger)size {
    self = [super init];
    if (self) {
        _cycleSize = size;
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutex);
}

- (NSUInteger)seed {
    NSUInteger seed = 0;
    pthread_mutex_lock(&_mutex);
    seed = _seq_seek;
    pthread_mutex_unlock(&_mutex);
    return seed;
}

- (NSUInteger)seq {
    NSUInteger seq = 0;
    pthread_mutex_lock(&_mutex);
    if (_seq_seek == _cycleSize) {//最大
        _seq_seek = 1;
    }
    else {
        _seq_seek++;
    }
    seq = _seq_seek;
    pthread_mutex_unlock(&_mutex);
    return seq;
}

@end

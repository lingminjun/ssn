//
//  SSNSafeDictionary.m
//  ssn
//
//  Created by lingminjun on 14-11-6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNSafeDictionary.h"
#import <pthread.h>

@interface SSNSafeDictionary ()
{
    NSMutableDictionary *_dic;
    pthread_rwlock_t _rwlock;
    NSCache *_cache;//for FastEnumeration cache
}

@end

#define	ssn_read_lock \
int err = pthread_rwlock_rdlock(&_rwlock);\
if (EDEADLK == err)\
{\
[NSException raise:@"SSNSafeDictionary" format: @"failed to dead read lock rwlock!"];\
}\
else if (err != 0)\
{\
[NSException raise:@"SSNSafeDictionary" format: @"failed to read lock rwlock!"];\
}\

#define	ssn_write_lock \
int err = pthread_rwlock_wrlock(&_rwlock);\
if (EDEADLK == err)\
{\
[NSException raise:@"SSNSafeDictionary" format: @"failed to dead write lock rwlock!"];\
}\
else if (err != 0)\
{\
[NSException raise:@"SSNSafeDictionary" format: @"failed to write lock rwlock!"];\
}\

#define	ssn_unlock  \
if (0 != pthread_rwlock_unlock(&_rwlock))\
{\
[NSException raise:@"SSNSafeDictionary" format: @"failed to unlock rwlock"];\
}\

@implementation SSNSafeDictionary

#pragma mark initializer
- (instancetype)init {
    self = [super init];
    if (self) {
        _dic = [[NSMutableDictionary alloc] init];
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}
- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self) {
        _dic = [[NSMutableDictionary alloc] initWithCapacity:numItems];
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}
- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    self = [super init];
    if (self) {
        _dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary];//not lock at initializer
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)dealloc {
    pthread_rwlock_destroy(&_rwlock);
}

#pragma mark key value cache
- (NSUInteger)count {
    ssn_read_lock
    NSUInteger count = [_dic count];
    ssn_unlock
    return count;
}


- (id)objectForKey:(id)aKey {
    ssn_read_lock
    id object = [_dic objectForKey:aKey];
    ssn_unlock
    return object;
}

- (NSEnumerator *)keyEnumerator {
    //need copy dic
    return [[self dictionary] keyEnumerator];
}


- (NSArray *)allKeys {
    ssn_read_lock
    NSArray *allKeys = [_dic allKeys];
    ssn_unlock
    return allKeys;
}


- (NSArray *)allKeysForObject:(id)anObject {
    ssn_read_lock
    NSArray *allKeys = [_dic allKeysForObject:anObject];
    ssn_unlock
    return allKeys;
}


- (NSArray *)allValues {
    ssn_read_lock
    NSArray *allValues = [_dic allValues];
    ssn_unlock
    return allValues;
}


- (NSEnumerator *)objectEnumerator {
    //need copy dic
    return [[self dictionary] objectEnumerator];
}


- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker {
    ssn_read_lock
    NSArray *objects = [_dic objectsForKeys:keys notFoundMarker:marker];
    ssn_unlock
    return objects;
}


- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator {
    //need copy dic
    return [[self dictionary] keysSortedByValueUsingSelector:comparator];
}


- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}


- (void)removeObjectForKey:(id)aKey {
    ssn_write_lock
    [_dic removeObjectForKey:aKey];
    ssn_unlock
}
- (id)objectRemoveForKey:(id)aKey {
    id obj = nil;
    ssn_write_lock
    obj = [_dic objectForKey:aKey];
    [_dic removeObjectForKey:aKey];
    ssn_unlock
    return obj;
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    ssn_write_lock
    [_dic setObject:anObject forKey:aKey];
    ssn_unlock
}


- (void)removeAllObjects {
    ssn_write_lock
    [_dic removeAllObjects];
    ssn_unlock
}


- (void)removeObjectsForKeys:(NSArray *)keyArray {
    ssn_write_lock
    [_dic removeObjectsForKeys:keyArray];
    ssn_unlock
}


- (void)setDictionary:(NSDictionary *)otherDictionary {
    ssn_write_lock
    [_dic setDictionary:otherDictionary];
    ssn_unlock
}


- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    [self setObject:obj forKey:key];
}


- (NSDictionary *)dictionary {
    ssn_read_lock
    NSDictionary *dic =[NSDictionary dictionaryWithDictionary:_dic];
    ssn_unlock
    return dic;
}

#pragma mark enumerate
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    [_dic enumerateKeysAndObjectsUsingBlock:block];
}


- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    [_dic enumerateKeysAndObjectsWithOptions:opts usingBlock:block];
}


#pragma mark filter
- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate {
    ssn_read_lock
    NSSet *set =[_dic keysOfEntriesPassingTest:predicate];
    ssn_unlock
    return set;
}


- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate {
    ssn_read_lock
    NSSet *set =[_dic keysOfEntriesWithOptions:opts passingTest:predicate];
    ssn_unlock
    return set;
}


#pragma mark factory
+ (instancetype)dictionary {
    return [[[self class] alloc] init];
}


+ (instancetype)dictionaryWithCapacity:(NSUInteger)numItems {
    return [[[self class] alloc] initWithCapacity:numItems];
}


+ (instancetype)dictionaryWithDictionary:(NSDictionary *)otherDictionary {
    return [[[self class] alloc] initWithDictionary:otherDictionary];
}

#pragma mark NSFastEnumeration
//并不安全，for语句无法易用[self dictionary]实例，遍历将属于真空状态
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {

    state->mutationsPtr = (unsigned long *)&state->mutationsPtr;

    NSString *cache_key = [NSString stringWithFormat:@"%p",state];
    NSMutableArray *objs = [_cache objectForKey:cache_key];
    if (!objs) {
        objs = [[NSMutableArray alloc] init];
        [_cache setObject:objs forKey:cache_key];
    }
    
    [objs removeAllObjects];//释放上一批缓存数据
    
    ssn_read_lock
    
    NSUInteger dic_count = [_dic count];
    
    NSUInteger count = 0;
    if (dic_count <= state->state) //数组在遍历过程中发生改变
    {
        //if (arr_count > state->state) { NSLog(@"SSNSafeArray:%p在遍历过程中发生了改变！",self); }
        [_cache removeObjectForKey:cache_key];//将遍历过程临时引用的对象释放掉
        NSLog(@"释放所有缓存引用对象");
    }
    else
    {
        count = MIN(len, dic_count - state->state);
        
        if (count % 2 != 0)//必须是两倍
        {
            [[NSException exceptionWithName:@"SSNSafeDictionary" reason:@"Enumerating error!" userInfo:nil] raise];
        }
        else
        {
            //此种实现方案遍历字典非常浪费
            id __unsafe_unretained *keys = (id __unsafe_unretained *)malloc(dic_count * sizeof(id __unsafe_unretained));
            
            [_dic getObjects:NULL andKeys:keys];//
            
            for (unsigned long i = 0, p = state->state; i < count; i++, p++) {
                buffer[i] = keys[p];
                
                [objs addObject:keys[p]];//强引用 临时保持住对象
            }
            
            state->state += count;
            
            free(keys);
        }
    }
    
    state->itemsPtr = buffer;
    
    ssn_unlock
    
    return count;
}


#pragma mark KVC
- (id)valueForKey:(NSString *)key {
    ssn_read_lock
    id obj =[_dic valueForKey:key];
    ssn_unlock
    return obj;
}


- (void)setValue:(id)value forKey:(NSString *)key {
    ssn_write_lock
    [_dic setValue:value forKey:key];
    ssn_unlock
}


@end

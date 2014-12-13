//
//  SSNSafeArray.m
//  ssn
//
//  Created by lingminjun on 14-11-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNSafeArray.h"
#import <pthread.h>

@interface SSNSafeArray ()
{
    NSMutableArray *_arr;
    pthread_rwlock_t _rwlock;
    NSCache *_cache;//for FastEnumeration cache
}

@end

#define	ssn_read_lock \
int err = pthread_rwlock_rdlock(&_rwlock);\
if (EDEADLK == err)\
{\
[NSException raise:@"SSNSafeArray" format: @"failed to dead read lock rwlock!"];\
}\
else if (err != 0)\
{\
[NSException raise:@"SSNSafeArray" format: @"failed to read lock rwlock!"];\
}\

#define	ssn_write_lock \
int err = pthread_rwlock_wrlock(&_rwlock);\
if (EDEADLK == err)\
{\
[NSException raise:@"SSNSafeArray" format: @"failed to dead write lock rwlock!"];\
}\
else if (err != 0)\
{\
[NSException raise:@"SSNSafeArray" format: @"failed to write lock rwlock!"];\
}\

#define	ssn_unlock  \
if (0 != pthread_rwlock_unlock(&_rwlock))\
{\
[NSException raise:@"SSNSafeArray" format: @"failed to unlock rwlock"];\
}\



@implementation SSNSafeArray

#pragma mark initializer
- (instancetype)init {
    self = [super init];
    if (self) {
        _arr = [[NSMutableArray alloc] init];
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}


- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self) {
        _arr = [[NSMutableArray alloc] initWithCapacity:numItems];
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}


- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _arr = [[NSMutableArray alloc] initWithArray:array];//not lock at initializer
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)dealloc {
    pthread_rwlock_destroy(&_rwlock);
}

#pragma mark objects operation
- (NSUInteger)count {
    ssn_read_lock
    NSUInteger count = [_arr count];
    ssn_unlock
    return count;
}
- (id)objectAtIndex:(NSUInteger)index {
    ssn_read_lock
    id object = [_arr objectAtIndex:index];
    ssn_unlock
    return object;
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    ssn_read_lock
    NSString *string = [_arr componentsJoinedByString:separator];
    ssn_unlock
    return string;
}


- (BOOL)containsObject:(id)anObject {
    ssn_read_lock
    BOOL contained = [_arr containsObject:anObject];
    ssn_unlock
    return contained;
}


- (NSUInteger)indexOfObject:(id)anObject {
    ssn_read_lock
    NSUInteger index = [_arr indexOfObject:anObject];
    ssn_unlock
    return index;
}


- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
    ssn_read_lock
    NSUInteger index = [_arr indexOfObject:anObject inRange:range];
    ssn_unlock
    return index;
}


- (id)firstObject {
    ssn_read_lock
    id object = [_arr firstObject];
    ssn_unlock
    return object;
}


- (id)lastObject {
    ssn_read_lock
    id object = [_arr lastObject];
    ssn_unlock
    return object;
}


- (NSEnumerator *)objectEnumerator {
    //need copy
    return [[self array] objectEnumerator];
}


- (NSEnumerator *)reverseObjectEnumerator {
    //need copy
    return [[self array] reverseObjectEnumerator];
}


- (NSArray *)subarrayWithRange:(NSRange)range {
    ssn_read_lock
    NSArray *array = [_arr subarrayWithRange:range];
    ssn_unlock
    return array;
}


- (void)makeObjectsPerformSelector:(SEL)aSelector {
    //need copy
    [[self array] makeObjectsPerformSelector:aSelector];
}


- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    //need copy
    [[self array] makeObjectsPerformSelector:aSelector withObject:argument];
}


- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
    ssn_read_lock
    NSArray *array = [_arr objectsAtIndexes:indexes];
    ssn_unlock
    return array;
}


- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}


- (void)addObject:(id)anObject {
    ssn_write_lock
    [_arr addObject:anObject];
    ssn_unlock
}


- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    ssn_write_lock
    [_arr insertObject:anObject atIndex:index];
    ssn_unlock
}


- (void)removeLastObject {
    ssn_write_lock
    [_arr removeLastObject];
    ssn_unlock
}


- (void)removeObjectAtIndex:(NSUInteger)index {
    ssn_write_lock
    [_arr removeObjectAtIndex:index];
    ssn_unlock
}

- (id)objectRemoveAtIndex:(NSUInteger)index {
    id obj = nil;
    ssn_write_lock
    obj = [_arr objectAtIndex:index];
    [_arr removeObjectAtIndex:index];
    ssn_unlock
    return obj;
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    ssn_write_lock
    [_arr replaceObjectAtIndex:index withObject:anObject];
    ssn_unlock
}


- (void)addObjectsFromArray:(NSArray *)otherArray {
    ssn_write_lock
    [_arr addObjectsFromArray:otherArray];
    ssn_unlock
}


- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    ssn_write_lock
    [_arr exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    ssn_unlock
}


- (void)removeAllObjects {
    ssn_write_lock
    [_arr removeAllObjects];
    ssn_unlock
}


- (void)removeObject:(id)anObject inRange:(NSRange)range {
    ssn_write_lock
    [_arr removeObject:anObject inRange:range];
    ssn_unlock
}


- (void)removeObject:(id)anObject {
    ssn_write_lock
    [_arr removeObject:anObject];
    ssn_unlock
}


- (void)removeObjectsInArray:(NSArray *)otherArray {
    ssn_write_lock
    [_arr removeObjectsInArray:otherArray];
    ssn_unlock
}


- (void)removeObjectsInRange:(NSRange)range {
    ssn_write_lock
    [_arr removeObjectsInRange:range];
    ssn_unlock
}


- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
    ssn_write_lock
    [_arr replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];
    ssn_unlock
}


- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    ssn_write_lock
    [_arr replaceObjectsInRange:range withObjectsFromArray:otherArray];
    ssn_unlock
}


- (void)setArray:(NSArray *)otherArray {
    ssn_write_lock
    [_arr setArray:otherArray];
    ssn_unlock
}


- (NSArray *)array {
    ssn_read_lock
    NSArray *array = [NSArray arrayWithArray:_arr];
    ssn_unlock
    return array;
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    ssn_write_lock
    [_arr insertObjects:objects atIndexes:indexes];
    ssn_unlock
}


- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    ssn_write_lock
    [_arr removeObjectsAtIndexes:indexes];
    ssn_unlock
}


- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    ssn_write_lock
    [_arr replaceObjectsAtIndexes:indexes withObjects:objects];
    ssn_unlock
}


- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    ssn_write_lock
    [_arr setObject:obj atIndexedSubscript:idx];
    ssn_unlock
}


- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context {
    ssn_write_lock
    [_arr sortUsingFunction:compare context:context];
    ssn_unlock
}


- (void)sortUsingSelector:(SEL)comparator {
    ssn_write_lock
    [_arr sortUsingSelector:comparator];
    ssn_unlock
}


- (void)sortUsingComparator:(NSComparator)cmptr {
    ssn_write_lock
    [_arr sortUsingComparator:cmptr];
    ssn_unlock
}


- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr {
    ssn_write_lock
    [_arr sortWithOptions:opts usingComparator:cmptr];
    ssn_unlock
}

#pragma mark enumerate
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    [_arr enumerateObjectsUsingBlock:block];
}


- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    [_arr enumerateObjectsWithOptions:opts usingBlock:block];
}


- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    [_arr enumerateObjectsAtIndexes:s options:opts usingBlock:block];
}


#pragma mark filter
- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    ssn_read_lock
    NSIndexSet *set = [_arr indexesOfObjectsPassingTest:predicate];
    ssn_unlock
    return set;
}


- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    ssn_read_lock
    NSIndexSet *set = [_arr indexesOfObjectsWithOptions:opts passingTest:predicate];
    ssn_unlock
    return set;
}


- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    ssn_read_lock
    NSIndexSet *set = [_arr indexesOfObjectsAtIndexes:s options:opts passingTest:predicate];
    ssn_unlock
    return set;
}


#pragma mark factory
+ (instancetype)array {
    return [[[self class] alloc] init];
}


+ (instancetype)arrayWithCapacity:(NSUInteger)numItems {
    return [[[self class] alloc] initWithCapacity:numItems];
}


+ (instancetype)arrayWithArray:(NSArray *)array {
    return [[[self class] alloc] initWithArray:array];
}


#pragma mark expand api
- (BOOL)addObjectDoesNotContain:(id)anObject {
    ssn_write_lock
    BOOL notContain = ![_arr containsObject:anObject];
    if (notContain) {
        [_arr addObject:anObject];
    }
    ssn_unlock
    return notContain;
}


#pragma mark NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    
    state->mutationsPtr = (unsigned long *)&state->mutationsPtr;
    
    NSString *cache_key = [NSString stringWithFormat:@"%p",state];
    NSMutableArray *objs = [_cache objectForKey:cache_key];
    if (!objs) {
        objs = [[NSMutableArray alloc] init];
        [_cache setObject:objs forKey:cache_key];
    }
    
    [objs removeAllObjects];//释放上一批数据
    
    ssn_read_lock
    
    unsigned long arr_count = [_arr count];
    
    NSUInteger count = 0;
    if (arr_count <= state->state) //数组在遍历过程中发生改变
    {
        //if (arr_count > state->state) { NSLog(@"SSNSafeArray:%p在遍历过程中发生了改变！",self); }
        [_cache removeObjectForKey:cache_key];//将遍历过程临时引用的对象释放掉
        NSLog(@"释放所有缓存引用对象");
    }
    else
    {
        count = MIN(len, arr_count - state->state);
        
        id __unsafe_unretained *values = (id __unsafe_unretained *)malloc(count * sizeof(id __unsafe_unretained));
        
        NSRange range = NSMakeRange(state->state, count);
        [_arr getObjects:values range:range];
        
        for (unsigned long i = 0; i < count; i++)
        {
            buffer[i] = values[i];
            
            [objs addObject:values[i]];//保证遍历过程不被释放，需要强引用对象
        }
        
        state->state += count;
        
        free(values);
    }
    
    state->itemsPtr = buffer;
    
    ssn_unlock
    
    return count;
}

#pragma mark KVC
- (id)valueForKey:(NSString *)key {
    ssn_read_lock
    id obj =[_arr valueForKey:key];
    ssn_unlock
    return obj;
}


- (void)setValue:(id)value forKey:(NSString *)key {
    ssn_write_lock
    [_arr setValue:value forKey:key];
    ssn_unlock
}


@end

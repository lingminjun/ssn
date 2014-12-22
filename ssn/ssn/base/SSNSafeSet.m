//
//  SSNSafeSet.m
//  ssn
//
//  Created by lingminjun on 14-11-8.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNSafeSet.h"
#import <pthread.h>

@interface SSNSafeSet()
{
    NSMutableSet *_set;
    pthread_rwlock_t _rwlock;
    NSCache *_cache;//for FastEnumeration cache
}

@end

#define	ssn_read_lock \
int err = pthread_rwlock_rdlock(&_rwlock);\
if (EDEADLK == err)\
{\
[NSException raise:@"SSNSafeSet" format: @"failed to dead read lock rwlock!"];\
}\
else if (err != 0)\
{\
[NSException raise:@"SSNSafeSet" format: @"failed to read lock rwlock!"];\
}\

#define	ssn_write_lock \
int err = pthread_rwlock_wrlock(&_rwlock);\
if (EDEADLK == err)\
{\
[NSException raise:@"SSNSafeSet" format: @"failed to dead write lock rwlock!"];\
}\
else if (err != 0)\
{\
[NSException raise:@"SSNSafeSet" format: @"failed to write lock rwlock!"];\
}\

#define	ssn_unlock  \
if (0 != pthread_rwlock_unlock(&_rwlock))\
{\
[NSException raise:@"SSNSafeSet" format: @"failed to unlock rwlock"];\
}\

@implementation SSNSafeSet

#pragma mark initializer
- (instancetype)init {
    self = [super init];
    if (self) {
        _set = [[NSMutableSet alloc] init];
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}


- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self) {
        _set = [[NSMutableSet alloc] initWithCapacity:numItems];
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}


- (instancetype)initWithSet:(NSSet *)set {
    self = [super init];
    if (self) {
        _set = [[NSMutableSet alloc] initWithSet:set];
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}


- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _set = [[NSMutableSet alloc] initWithArray:array];
        pthread_rwlock_init(&_rwlock, NULL);
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)dealloc {
    pthread_rwlock_destroy(&_rwlock);
}


#pragma mark factory
+ (instancetype)set {
    return [[[self class] alloc] init];
}


+ (instancetype)setWithCapacity:(NSUInteger)numItems {
    return [[[self class] alloc] initWithCapacity:numItems];
}


+ (instancetype)setWithSet:(NSSet *)set {
    return [[[self class] alloc] initWithSet:set];
}


+ (instancetype)setWithArray:(NSArray *)array {
    return [[[self class] alloc] initWithArray:array];
}


#pragma mark cache
- (NSUInteger)count {
    ssn_read_lock
    NSUInteger count = [_set count];
    ssn_unlock
    return count;
}


- (id)member:(id)object {
    ssn_read_lock
    id member = [_set member:object];
    ssn_unlock
    return member;
}


- (NSEnumerator *)objectEnumerator {
    //need copy set
    return [[self set] objectEnumerator];
}


- (NSArray *)allObjects {
    ssn_read_lock
    NSArray *objs = [_set allObjects];
    ssn_unlock
    return objs;
}


- (id)anyObject {
    ssn_read_lock
    id obj = [_set anyObject];
    ssn_unlock
    return obj;
}


- (BOOL)containsObject:(id)anObject {
    ssn_read_lock
    BOOL contained = [_set containsObject:anObject];
    ssn_unlock
    return contained;
}


- (BOOL)intersectsSet:(NSSet *)otherSet {
    ssn_read_lock
    BOOL result = [_set intersectsSet:otherSet];
    ssn_unlock
    return result;
}


- (BOOL)isEqualToSet:(NSSet *)otherSet {
    ssn_read_lock
    BOOL result = [_set isEqualToSet:otherSet];
    ssn_unlock
    return result;
}


- (BOOL)isSubsetOfSet:(NSSet *)otherSet {
    ssn_read_lock
    BOOL result = [_set isSubsetOfSet:otherSet];
    ssn_unlock
    return result;
}


- (void)makeObjectsPerformSelector:(SEL)aSelector {
    [[self set] makeObjectsPerformSelector:aSelector];
}


- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    [[self set] makeObjectsPerformSelector:aSelector withObject:argument];
}

- (void)addObject:(id)object {
    ssn_write_lock
    [_set addObject:object];
    ssn_unlock
}


- (void)removeObject:(id)object {
    ssn_write_lock
    [_set removeObject:object];
    ssn_unlock
}


- (void)addObjectsFromArray:(NSArray *)array {
    ssn_write_lock
    [_set addObjectsFromArray:array];
    ssn_unlock
}


- (void)intersectSet:(NSSet *)otherSet {
    ssn_write_lock
    [_set intersectSet:otherSet];
    ssn_unlock
}


- (void)minusSet:(NSSet *)otherSet {
    ssn_write_lock
    [_set minusSet:otherSet];
    ssn_unlock
}


- (void)removeAllObjects {
    ssn_write_lock
    [_set removeAllObjects];
    ssn_unlock
}


- (void)unionSet:(NSSet *)otherSet {
    ssn_write_lock
    [_set unionSet:otherSet];
    ssn_unlock
}


- (void)setSet:(NSSet *)otherSet {
    ssn_write_lock
    [_set setSet:otherSet];
    ssn_unlock
}


#pragma mark enumerate
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block {
    [_set enumerateObjectsUsingBlock:block];
}


- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, BOOL *stop))block {
    [_set enumerateObjectsWithOptions:opts usingBlock:block];
}

#pragma mark filter
- (NSSet *)objectsPassingTest:(BOOL (^)(id obj, BOOL *stop))predicate {
    ssn_read_lock
    NSSet *set = [_set objectsPassingTest:predicate];
    ssn_unlock
    return set;
}


- (NSSet *)objectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, BOOL *stop))predicate {
    ssn_read_lock
    NSSet *set = [_set objectsWithOptions:opts passingTest:predicate];
    ssn_unlock
    return set;
}


#pragma mark expand api
/**
 * copy the set
 */
- (NSSet *)set {
    ssn_read_lock
    NSSet *set = [[NSSet alloc] initWithSet:_set];
    ssn_unlock
    return set;
}

/**
 *  添加集合中不包含对象
 *  如果你有类似下面的逻辑：
 *  if (NO == [set containsObject:obj]) {
 *      [set addObject:obj]
 *  }
 *  又需要确保加入到set中的元素不会重复，建议你使用-addObjectDoesNotContain:方法替换，此操作是原子行为，但是性能有所降低
 *
 *  @param  anObject，可能要添加的对象
 *  @return 返回yes表示成功加入对象，返回no表示早已包含此对象
 */
- (BOOL)addObjectDoesNotContain:(id)anObject {
    ssn_write_lock
    BOOL notContain = ![_set containsObject:anObject];
    if (notContain) {
        [_set addObject:anObject];
    }
    ssn_unlock
    return notContain;
}


#pragma mark FastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    
    NSString *cache_key = [NSString stringWithFormat:@"%p",state];
    NSMutableArray *objs = [_cache objectForKey:cache_key];
    if (!objs) {
        objs = [[NSMutableArray alloc] init];
        [_cache setObject:objs forKey:cache_key];
    }
    
    [objs removeAllObjects];//释放上一批缓存数据
    
    ssn_read_lock
    
    unsigned long set_count = [_set count];
    
    NSUInteger count = 0;
    if (set_count <= state->state) //数组在遍历过程中发生改变
    {
        //if (set_count > state->state) { NSLog(@"SSNSafeSet:%p在遍历过程中发生了改变！",self); }
        [_cache removeObjectForKey:cache_key];//将遍历过程临时引用的对象释放掉
        NSLog(@"释放所有缓存引用对象");
    }
    else
    {
        //直接使用系统本身的方式取值，肯能抛出遍历时改变异常，暂时没有更好的实现
        count = [_set countByEnumeratingWithState:state objects:buffer count:len];
        
        state->mutationsPtr = (unsigned long *)&state->mutationsPtr;//不然系统检查出改变

        //安全起见，将数据临时缓存主
        for (unsigned long i = 0; i < count; i++)
        {
            [objs addObject:buffer[i]];//保证遍历过程不被释放，需要强引用对象
        }
    }
    
    ssn_unlock
    
    return count;

}


#pragma mark KVC
- (id)valueForKey:(NSString *)key {
    ssn_read_lock
    id obj =[_set valueForKey:key];
    ssn_unlock
    return obj;
}


- (void)setValue:(id)value forKey:(NSString *)key {
    ssn_write_lock
    [_set setValue:value forKey:key];
    ssn_unlock
}

@end

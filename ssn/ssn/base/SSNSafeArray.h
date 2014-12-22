//
//  SSNSafeArray.h
//  ssn
//
//  Created by lingminjun on 14-11-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  线程安全的数组，当你的数组需要在多个线程中读写时建议使用
 *  快速枚举for(id obj in array)同样线程安全
 */
@interface SSNSafeArray : NSObject <NSFastEnumeration>

#pragma mark initializer
- (instancetype)init;
- (instancetype)initWithCapacity:(NSUInteger)numItems;
- (instancetype)initWithArray:(NSArray *)array;

#pragma mark objects operation
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

- (NSString *)componentsJoinedByString:(NSString *)separator;

- (BOOL)containsObject:(id)anObject;

- (NSUInteger)indexOfObject:(id)anObject;
- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range;

- (id)firstObject;
- (id)lastObject;
- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)reverseObjectEnumerator;

- (NSArray *)subarrayWithRange:(NSRange)range;

- (void)makeObjectsPerformSelector:(SEL)aSelector;
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument;

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (id)objectRemoveAtIndex:(NSUInteger)index;//返回删除的对象
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)removeAllObjects;
- (void)removeObject:(id)anObject inRange:(NSRange)range;
- (void)removeObject:(id)anObject;

- (void)removeObjectsInArray:(NSArray *)otherArray;
- (void)removeObjectsInRange:(NSRange)range;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray;
- (void)setArray:(NSArray *)otherArray;

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects;

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;
- (void)sortUsingSelector:(SEL)comparator;
- (void)sortUsingComparator:(NSComparator)cmptr;
- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;

#pragma mark enumerate
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

#pragma mark filter
- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

#pragma mark factory
+ (instancetype)array;
+ (instancetype)arrayWithCapacity:(NSUInteger)numItems;
+ (instancetype)arrayWithArray:(NSArray *)array;


#pragma mark expand api
/**
 * copy new array
 */
- (NSArray *)array;

/**
 *  添加数组中不包含对象
 *  如果你有类似下面的逻辑：
 *  if (NO == [array containsObject:obj]) {
 *      [array addObject:obj]
 *  }
 *  又需要确保加入到array中的元素不会重复，建议你使用-addObjectDoesNotContain:方法替换，此操作是原子行为，但是性能有所降低
 *
 *  @param  anObject，可能要添加的对象
 *  @return 返回yes表示成功加入对象，返回no表示早已包含此对象
 */
- (BOOL)addObjectDoesNotContain:(id)anObject;

@end

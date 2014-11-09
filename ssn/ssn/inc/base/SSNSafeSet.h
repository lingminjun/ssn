//
//  SSNSafeSet.h
//  ssn
//
//  Created by lingminjun on 14-11-8.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  线程安全的集合
 */
@interface SSNSafeSet : NSObject <NSFastEnumeration>

#pragma mark initializer
- (instancetype)init;
- (instancetype)initWithCapacity:(NSUInteger)numItems;
- (instancetype)initWithSet:(NSSet *)set;
- (instancetype)initWithArray:(NSArray *)array;

#pragma mark factory
+ (instancetype)set;
+ (instancetype)setWithCapacity:(NSUInteger)numItems;
+ (instancetype)setWithSet:(NSSet *)set;
+ (instancetype)setWithArray:(NSArray *)array;


#pragma mark cache
- (NSUInteger)count;
- (id)member:(id)object;
- (NSEnumerator *)objectEnumerator;


- (NSArray *)allObjects;
- (id)anyObject;
- (BOOL)containsObject:(id)anObject;

- (BOOL)intersectsSet:(NSSet *)otherSet;
- (BOOL)isEqualToSet:(NSSet *)otherSet;
- (BOOL)isSubsetOfSet:(NSSet *)otherSet;

- (void)makeObjectsPerformSelector:(SEL)aSelector;
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument;

- (void)addObject:(id)object;
- (void)removeObject:(id)object;

- (void)addObjectsFromArray:(NSArray *)array;
- (void)intersectSet:(NSSet *)otherSet;
- (void)minusSet:(NSSet *)otherSet;
- (void)removeAllObjects;
- (void)unionSet:(NSSet *)otherSet;

- (void)setSet:(NSSet *)otherSet;

#pragma mark enumerate
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, BOOL *stop))block;

#pragma mark filter
- (NSSet *)objectsPassingTest:(BOOL (^)(id obj, BOOL *stop))predicate;
- (NSSet *)objectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, BOOL *stop))predicate;

#pragma mark expand api
/**
 * copy the set
 */
- (NSSet *)set;

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
- (BOOL)addObjectDoesNotContain:(id)anObject;

@end

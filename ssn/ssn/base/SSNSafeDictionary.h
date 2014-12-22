//
//  SSNSafeDictionary.h
//  ssn
//
//  Created by lingminjun on 14-11-6.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  线程安全的字典，当你的字典需要在多个线程中读写时建议使用
 *  线程安全字典仅提供内存操作需要，若需要存储，请调用-dictionary和-setDictionary:进行转换
 *  快速枚举for(id key in dictionary)同样线程安全，注意：字典的快速枚举只遍历keys
 */
@interface SSNSafeDictionary : NSObject <NSFastEnumeration>

#pragma mark initializer
- (instancetype)init;
- (instancetype)initWithCapacity:(NSUInteger)numItems;
- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary;

#pragma mark key value cache
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;

- (NSArray *)allKeys;
- (NSArray *)allKeysForObject:(id)anObject;
- (NSArray *)allValues;

- (NSEnumerator *)objectEnumerator;
- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker;

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator;

- (id)objectForKeyedSubscript:(id)key;

- (void)removeObjectForKey:(id)aKey;
- (id)objectRemoveForKey:(id)aKey;//删除对象并返回
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;

- (void)removeAllObjects;
- (void)removeObjectsForKeys:(NSArray *)keyArray;
- (void)setDictionary:(NSDictionary *)otherDictionary;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

#pragma mark enumerate
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;
- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block;

#pragma mark filter
- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate;
- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate;

#pragma mark factory
+ (instancetype)dictionary;
+ (instancetype)dictionaryWithCapacity:(NSUInteger)numItems;
+ (instancetype)dictionaryWithDictionary:(NSDictionary *)otherDictionary;

#pragma mark expand api
/**
 * copy to dictionary
 */
- (NSDictionary *)dictionary;

@end

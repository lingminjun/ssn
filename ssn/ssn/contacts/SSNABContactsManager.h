//
//  SSNABContactsManager.h
//  ssn
//
//  Created by lingminjun on 15/5/30.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABRecord.h>
#import "SSNABPerson.h"
#import "SSNABRecord.h"
#import "SSNDBTable.h"

/**
 *  本地通讯录监听
 */
@interface SSNABContactsManager : NSObject

/**
 *  唯一实例
 *
 *  @return 返回唯一实例
 */
+ (SSNABContactsManager *)manager;

/**
 *  访问是否授权,第一次请不要用这个函数,因为无法感知正在授权
 *
 *  @return 返回本地通讯录是否授权
 */
- (BOOL)isGrantedAccessABAddressBook;

/**
 *  是否开启服务
 *
 *  @return 开启服务
 */
- (BOOL)isOpenService;

/**
 *  开启服务
 *
 *  @return 同步开启，等的用户决定
 */
- (void)openService;

/**
 *  关闭服务
 */
- (void)closeService;

/**
 *  返回本地联系人数据库
 *
 *  @return 数据库表实例
 */
- (SSNDBTable *)ABPersonTable;

/**
 *  获取所有本地联系人，必须有号码的
 *
 *  @return 返回SSNABPerson结果集
 */
- (NSArray *)allPersons;

/**
 *  查询相关联系人（名字，拼音或者号码）
 *
 *  @param searchText 查询字符串
 *  @param results    SSNABPerson结果
 */
- (void)searchPersonsWithSearchText:(NSString *)searchText results:(void (^)(NSArray *results))results;

/**
 *  获取联系人
 *
 *  @param key 主键
 *
 *  @return 返回匹配的联系人
 */
- (SSNABPerson *)personWithKey:(NSString *)key;

/**
 *  获取联系人
 *
 *  @param mobile 手机号，号码将被调整，去掉国家码
 *
 *  @return 返回匹配的联系人
 */
- (SSNABPerson *)personWithMobile:(NSString *)mobile;

/**
 *  返回关联本地联系人
 *
 *  @param recordID 本地联系人id
 *
 *  @return 一个或者多个SSNABPerson
 */
- (NSArray *)personsWithABRecordID:(ABRecordID)recordID;

/**
 *  本地通讯录数据
 *
 *  @param recordID 本地联系人id
 *
 *  @return 本地通讯录数据
 */
- (SSNABRecord *)ABRecordWithABRecordID:(ABRecordID)recordID;

@end

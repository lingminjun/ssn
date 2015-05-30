//
//  SSNABContactsManager.m
//  ssn
//
//  Created by lingminjun on 15/5/30.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNABContactsManager.h"
#import "SSNDBPool.h"
#import "SSNDBTable+Factory.h"
#import "NSString+SSN.h"
#import "NSString+SSNPinyin.h"
#import "SSNABRecord.h"
#import "SSNRigidCache.h"

NSString *const SSNDBABRecordScope = @"abbook";

NSString *const SSNEmptyName       = @"无名字";

@interface SSNABContactsManager () {
    dispatch_queue_t _gcdQueue;
    ABAddressBookRef _addressBook;
}

@property (nonatomic,readwrite) ABAddressBookRef addressBook;

@property (nonatomic,strong) SSNDB *db;
@property (nonatomic,strong) SSNDBTable *table;

//@property (nonatomic) BOOL isGrantedAccessABAddressBook;
@property (nonatomic) BOOL isOpenService;

@end

@implementation SSNABContactsManager

//监听本地通讯录的变化，实时修改数据库变化
static void addressBookExternalChangeCallback (ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    [[SSNABContactsManager manager] addressBookChangeNotifyWith:addressBook inf:info];
}

- (void)setAddressBook:(ABAddressBookRef)addressBook {
    if (addressBook == _addressBook) {
        return ;
    }
    
    if (addressBook) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookExternalChangeCallback, NULL);
        });
        CFRetain(addressBook);
    }
    
    if (_addressBook) {
        ABAddressBookRef tem_addressBook = _addressBook;
        dispatch_async(dispatch_get_main_queue(), ^{
            ABAddressBookUnregisterExternalChangeCallback(tem_addressBook, addressBookExternalChangeCallback, NULL);
            CFRelease(tem_addressBook);
        });
    }
    _addressBook = addressBook;
}

- (id)init {
    self = [super init];
    if (self) {
        _gcdQueue = dispatch_queue_create("local.contacts.queue", NULL);
        
        _db = [[SSNDBPool shareInstance] dbWithScope:SSNDBABRecordScope];
        _table = [SSNDBTable tableWithDB:_db name:NSStringFromClass([SSNABPerson class]) templateName:nil];
    }
    return self;
}

- (void)dealloc {
    self.addressBook = nil;
}

+ (SSNABContactsManager *)manager {
    static SSNABContactsManager *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[SSNABContactsManager alloc] init];
    });
    return share;
}

#pragma mark 号码管理

- (void)addressBookChangeNotifyWith:(ABAddressBookRef)addressBook inf:(CFDictionaryRef)info {
    if (_addressBook == addressBook) {
        SEL selector = @selector(delayResponseAddressBookChange);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
        [self performSelector:selector withObject:self afterDelay:0.1 inModes:@[NSRunLoopCommonModes]];
    }
}

- (void)delayResponseAddressBookChange {
    if (!self.isGrantedAccessABAddressBook) {
        return ;
    }
    
    if (self.addressBook == nil) {
        return ;
    }
    
    //暂不穿越线程,直接主线程改了
    __weak typeof(self) w_self = self;
    dispatch_async(_gcdQueue, ^{
        __strong typeof(w_self) self = w_self;
        [self updateDatasFromABAddressBook];
    });
}

/*
- (LWSectionInfo *)sectionWithKey:(NSString *)key
                            title:(NSString *)title
                        sortIndex:(NSInteger)sortIndex {
    LWSectionInfo *section = [[LWSectionInfo alloc] init];
    section.sectionKey = key;
    section.sectionName = title;
    return LW_AUTORELEASE(section);
}

- (NSArray *)recordKeysOrderByPinyin {
    NSString *sql = [NSString stringWithFormat:@"SELECT key FROM %@ ORDER BY groupIndex,pinyin,localId ASC",[LWDBABRecord tableName]];
    NSArray *results = [LWDBABRecord findWithSql:sql
                                  withParameters:nil
                                          withDB:TheLWUserDatabase];
    
    NSArray *keys = [results valueForKey:@"key"];
    return keys;
}

- (NSArray *)groupListByGroupIndex {
    
    NSString *sql = [NSString stringWithFormat:@"SELECT groupIndex, COUNT(*) AS num FROM %@ GROUP BY groupIndex ORDER BY groupIndex ASC",[LWDBABRecord tableName]];
    NSArray *record = [TheLWUserDatabase executeSql:sql
                                     withParameters:nil
                                    withClassForRow:[NSMutableDictionary class]];
    return record;
}
 */

/*
- (void)asynLoadMobileRecordListComplete:(void(^)(NSArray *list))complete {
    if (!self.isOpenLocalContactService) {
        if (complete) {
            dispatch_async(self.gcdQueue, ^{
                complete(nil);
            });
        }
        return ;
    }
    
    __weak typeof(self) w_self = self;
    dispatch_async(self.gcdQueue, ^{
        if (!w_self) {
            return ;
        }
        __strong typeof(w_self) self = w_self;
        
        NSArray *keys = [self recordKeysOrderByPinyin];
        
        NSArray *groupIndexs = [self groupListByGroupIndex];
        
        LWSectionInfo *lwUserStrangerSection = nil;
        LWSectionInfo *lwUserFriendSection = nil;
        LWSectionInfo *localMobileSection = nil;
        
        NSInteger localIndex = 0;
        
        for (NSDictionary *item in groupIndexs) {
            LWDBABRecordGroupIndexType index = [[item objectForKey:@"groupIndex"] intValue];
            NSInteger num = [[item objectForKey:@"num"] intValue];
            
            if (localIndex + num > [keys count]) {//防止越界
                num = [keys count] - localIndex;
            }
            
            NSArray *recordKeys = [keys subarrayWithRange:NSMakeRange(localIndex, num)];
            // localIndex后移num位
            localIndex += num;
            
            if (index == RecordGroupLWStranger) {
                if (!lwUserStrangerSection) {
                    lwUserStrangerSection = [self sectionWithKey:LWUserStrangerSectionKey
                                                           title:@"在来往的人"
                                                       sortIndex:0];
                }
                
                [lwUserStrangerSection.objects setArray:recordKeys];
                
            }
            else if (index == RecordGroupNotLWUser) {
                if (!localMobileSection) {
                    localMobileSection = [self sectionWithKey:LWLocalABRecordSectionKey
                                                        title:@"本地名片"
                                                    sortIndex:1];
                }
                [localMobileSection.objects setArray:recordKeys];
                
            }
            else {
                if (!lwUserFriendSection) {
                    lwUserFriendSection = [self sectionWithKey:LWUserFriendSectionKey
                                                         title:@"好友"
                                                     sortIndex:2];
                }
                [lwUserFriendSection.objects setArray:recordKeys];
            }
        }
        
        NSMutableArray *sections = [NSMutableArray arrayWithCapacity:0];
        if (lwUserStrangerSection) {
            [sections addObject:lwUserStrangerSection];
        }
        
        if (localMobileSection) {
            [sections addObject:localMobileSection];
        }
        
        if (lwUserFriendSection) {
            [sections addObject:lwUserFriendSection];
        }
        
        if (complete) {
            complete(sections);
        }
    });
}
*/

- (BOOL)isGrantedAccessABAddressBook {//
    ABAuthorizationStatus abStatus = ABAddressBookGetAuthorizationStatus();
    if (kABAuthorizationStatusAuthorized == abStatus) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)synAuthoriseAccessABAddressBook {
    //已经授权并取得了本地通讯录
    if (self.addressBook) {
        return YES;
    }
    
    //ios6以上处理
    BOOL authorized = NO;
    
    ABAddressBookRef temAddressBook = nil;
    
    ABAuthorizationStatus abStatus = ABAddressBookGetAuthorizationStatus();
    if (kABAuthorizationStatusNotDetermined == abStatus) {
        
        temAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        __block BOOL accessGranted = NO;
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(temAddressBook, ^(bool granted, CFErrorRef error) {
                                                     accessGranted = granted;
                                                     dispatch_semaphore_signal(sema);
                                                 });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        if (accessGranted) {
            authorized = YES;
        }
        else {
            if (temAddressBook) {
                CFRelease(temAddressBook);
                temAddressBook = NULL;
            }
        }
    }
    else if (kABAuthorizationStatusAuthorized == abStatus) {
        temAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        authorized = YES;
        
    } else {
        authorized = NO;
    }
    
    if (authorized && temAddressBook) {
       self.addressBook = temAddressBook;
    }
    
    if (temAddressBook) {
        CFRelease(temAddressBook);
    }
    
    return authorized;
}

//主要为查询提供接口
//- (NSArray *)filerLocalMoibleRecordKeysWithSearchString:(NSString *)searchString notInLW:(BOOL)notInLW {
//    if (!self.isOpenLocalContactService) {
//        return nil;
//    }
//    
//    if (self.addressBook == nil) {
//        return nil;
//    }
//    
//    NSString *condition = [[@"%" stringByAppendingString:searchString] stringByAppendingString:@"%"];
//    
//    NSString *sql = nil;
//    
//    if (notInLW) {
//        sql = [NSString stringWithFormat:@"SELECT key FROM %@ WHERE (lwUID IS NULL OR lwUID = '') AND (name like ? OR pinyin like ? OR phoneNumber like ?)",[LWDBABRecord tableName]];
//    }
//    else {
//        sql = [NSString stringWithFormat:@"SELECT key FROM %@ WHERE (name like ? OR pinyin like ? OR phoneNumber like ?)",[LWDBABRecord tableName]];
//    }
//    
//    NSArray *results = [LWDBABRecord findWithSql:sql
//                                  withParameters:@[condition,condition,condition]
//                                          withDB:TheLWUserDatabase];
//    
//    
//    
//    NSArray *keys = [results valueForKey:@"key"];
//    
//    //新方案
//    LWSectionInfo *searchSection = [[LWSectionInfo alloc] init];
//    searchSection.sectionKey = LWSearchRecordsSectionKey;
//    searchSection.sectionName = @"搜索结果";
//    if (keys) {
//        [searchSection.objects setArray:keys];
//    }
//    
//    NSArray *result = [NSArray arrayWithObject:searchSection];
//    
//    //LW_RELEASE(searchSection);
//    
//    return result;
//}
//
//- (void)lwfriendContactSyncNotify:(NSString *)nofity {
//    [self uploadInLwLocalRecords];
//}

//- (void)uploadInLwLocalRecords  //更新在来往中的人的排序字段
//{
//    NSMutableArray *updateRecords = [NSMutableArray arrayWithCapacity:10];
//    NSArray *keys = [self recordKeysISLWUser];
//    
//    for (NSString *key in keys) {
//        
//        LWDBABRecord *rd = [self recordWithForKey:key];
//        
//        if ([TheDBPersonServices isFriendWithUID:rd.lwUID]) {
//            rd.groupIndex = RecordGroupLWFriend;
//            rd.isLWFriend = YES;
//        }
//        else {
//            rd.groupIndex = RecordGroupLWStranger;
//            rd.isLWFriend = NO;
//        }
//        
//        if (rd) {
//            [updateRecords addObject:rd];
//        }
//    }
//    
//    //更新db
//    [self saveUpdateRecords:updateRecords deleteKeys:nil];
//    
//    //发出通知
//    if ([NSThread isMainThread]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:LWLocalMobileListChangeNotify object:nil];
//    }
//    else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:LWLocalMobileListChangeNotify object:nil];
//        });
//    }
//}

//- (void)lwfriendContactChangeNotify:(NSNotification *)notify {
//    if (![self isOpenService]) {//还没有开启通讯录服务
//        return ;
//    }
//    
//    NSSet *set = [notify.userInfo objectForKey:LWDBChangePersonsKey];
//    
//    NSMutableArray *updateRecords = [NSMutableArray arrayWithCapacity:10];
//    
//    for (NSString *uid in [set allObjects]) {
//        NSArray *keys = [self recordKeysWithLWUserId:uid];
//        
//        for (NSString *key in keys) {
//            
//            LWDBABRecord *rd = [self recordWithForKey:key];
//            
//            if ([TheDBPersonServices isFriendWithUID:uid]) {
//                rd.groupIndex = RecordGroupLWFriend;
//                rd.isLWFriend = YES;
//            }
//            else {
//                rd.groupIndex = RecordGroupLWStranger;
//                rd.isLWFriend = NO;
//            }
//            
//            if (rd) {
//                [updateRecords addObject:rd];
//            }
//        }
//    }
//    //更新db
//    [self saveUpdateRecords:updateRecords deleteKeys:nil];
//    
//    //发出通知
//    if ([NSThread isMainThread]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:LWLocalMobileListChangeNotify object:nil];
//    }
//    else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:LWLocalMobileListChangeNotify object:nil];
//        });
//    }
//}

#pragma mark 服务开启控制
- (void)saveUpdateRecords:(NSArray *)upRecords deleteKeys:(NSArray *)delKeys {
    
    [_table upinsertObjects:upRecords];
    
    if (delKeys) {
        NSString *delKeysString = [delKeys componentsJoinedByString:@"','"];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM SSNABPerson WHERE key in ('%@')",delKeysString];
        [_db executeSql:sql];
    }
}


- (NSArray *)loadAllRecordKeys {
    NSString *sql = @"SELECT key FROM SSNABPerson";
    NSArray *results = [_db objects:nil sql:sql,nil];
    NSArray *keys = [results valueForKey:@"key"];
    return keys;
}

- (void)updateDatasFromABAddressBook {
    
    if (!self.addressBook) {
        return ;
    }
    else {
        ABAddressBookRevert(self.addressBook);
    }
    
    CFArrayRef thePeople = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    if (!thePeople) {
        return ;
    }
    
    NSMutableSet *set = [NSMutableSet setWithCapacity:1];//记录本次存在的数据
    NSMutableDictionary *newRecords = [NSMutableDictionary dictionaryWithCapacity:1];
    
    NSInteger count = CFArrayGetCount(thePeople);
    for (CFIndex i = 0; i < count; i++) { @autoreleasepool {
        ABRecordRef record = (ABRecordRef)CFArrayGetValueAtIndex(thePeople, i);
        ABRecordID recordID = ABRecordGetRecordID(record);
        
        SSNABRecord *contact = [SSNABRecord contactWithRecord:record];
        if (!contact) {
            continue ;
        }
        
        NSDate *motify = [contact modificationDate];
        int64_t modifyT = [motify timeIntervalSince1970];
        
        NSString *name = [contact compositeName];
        if ([name length] == 0) {
            name = SSNEmptyName;
        }
        
        NSArray *phoneNumbers = [contact phoneArray];
        
        for (NSString *phone in phoneNumbers) { @autoreleasepool {
            
            NSString *mobile = [phone ssn_trimPhoneNumber];
            
            //号码不存在的，过滤掉
            if ([mobile length] == 0) {//没有号码不显示
                continue ;
            }
            
            NSString *phoneCRC = [mobile ssn_crc64];
            if ([phoneCRC length] == 0) {
                continue ;
            }
            
            NSString *key = [self keyWithCrc64:phoneCRC recordID:recordID];
            if ([set containsObject:key]) {//已经存在不需要
                continue ;
            }
            
            [set addObject:key];//
            
            //取得对象
            SSNABPerson *record = [self personWithKey:key];
            if (record && record.modifyAt == modifyT) {//时间戳没有变化直接过
                record.mobile = mobile;
                continue ;
            }
            
            //新增数据
            if (!record) {
                record = [[SSNABPerson alloc] init];
                record.key = key;
                record.recordID = recordID;
                record.mobile = mobile;
            }
            
            //将修改字段记录下来
            [newRecords setObject:record forKey:key];
            
            //更新时间戳
            record.modifyAt = modifyT;
            
            //将名字更新一下
            record.name = name;
        }}
        
    }}
    CFRelease(thePeople);
    
    //过滤已经删除的数据
    NSArray *keys = [self loadAllRecordKeys];
    NSMutableArray *delKeys = [NSMutableArray array];
    if (keys) {
        [delKeys setArray:keys];
    }
    [delKeys removeObjectsInArray:[set allObjects]];//去掉已经存在的
    
    //存储下数据
    [self saveUpdateRecords:[newRecords allValues] deleteKeys:delKeys];
}

- (void)openService {
    
    if (_isOpenService && self.addressBook) {//没有加载过
        return ;
    }
    
    _isOpenService = YES;
    //第一授权成功,需要加载数据,最好在异步线程中
    __weak typeof(self) w_self = self;
    dispatch_async(_gcdQueue, ^{ __strong typeof(w_self) self = w_self;
        
        BOOL granted = [self synAuthoriseAccessABAddressBook];
        if (!granted) {
            return ;
        }
        
        //本地通讯录数据加载
        [self updateDatasFromABAddressBook];
    });
}

- (void)closeService {
    _isOpenService = NO;
    self.addressBook = nil;
}

/**
 *  返回本地联系人数据库
 *
 *  @return 数据库表实例
 */
- (SSNDBTable *)ABPersonTable {
    return _table;
}

/**
 *  获取所有本地联系人，必须有号码的
 *
 *  @return 返回SSNABPerson结果集
 */
- (NSArray *)allPersons {
    return [_table objectsWithClass:[SSNABPerson class] forConditions:nil];
}

/**
 *  查询相关联系人（名字，拼音或者号码）
 *
 *  @param searchText 查询字符串
 *  @param results    SSNABPerson结果
 */
- (void)searchPersonsWithSearchText:(NSString *)searchText results:(void (^)(NSArray *results))results {
    dispatch_async(_gcdQueue, ^{
        NSString *text = [searchText ssn_trimWhitespace];
        
        NSString *sql = nil;
        if ([text length] == 0) {
            sql = @"SELECT * FROM SSNABPerson";
        }
        else {
            sql = [NSString stringWithFormat:@"SELECT * FROM SSNABPerson WHERE mobile like '%%%@%%' OR name like '%%%@%%' OR pinyin like '%%%@%%'",text,text,text];
        }
        
        NSArray *array = [_db objects:[SSNABPerson class] sql:sql,nil];
        
        if (results) {
            results(array);
        }
    });
}

/**
 *  获取联系人
 *
 *  @param key 主键
 *
 *  @return 返回匹配的联系人
 */
- (SSNABPerson *)personWithKey:(NSString *)key {
    if ([key length] == 0) {
        return 0;
    }
    
    NSArray *array = [_table objectsWithClass:[SSNABPerson class] forConditions:@{@"key":key}];
    return [array firstObject];
}

/**
 *  获取联系人
 *
 *  @param mobile 手机号，号码将被调整，去掉国家码
 *
 *  @return 返回匹配的联系人
 */
- (SSNABPerson *)personWithMobile:(NSString *)mobile {
    NSString *text = [mobile ssn_trimPhoneNumber];
    if ([text length] == 0) {
        return nil;
    }
    
    NSArray *array = [_table objectsWithClass:[SSNABPerson class] forConditions:@{@"mobile":text}];
    return [array firstObject];
}

/**
 *  返回关联本地联系人
 *
 *  @param recordID 本地联系人id
 *
 *  @return 一个或者多个SSNABPerson
 */
- (NSArray *)personsWithABRecordID:(ABRecordID)recordID {
    if (recordID == 0) {
        return nil;
    }
    
    return [_table objectsWithClass:[SSNABPerson class] forConditions:@{@"recordID":@(recordID)}];
}

/**
 *  本地通讯录数据
 *
 *  @param recordID 本地联系人id
 *
 *  @return 本地通讯录数据
 */
- (SSNABRecord *)ABRecordWithABRecordID:(ABRecordID)recordID {
    if (recordID == 0) {
        return nil;
    }
    
    if (!self.addressBook) {
        return nil;
    }
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(self.addressBook, recordID);
    if (recordRef) {
        return [SSNABRecord contactWithRecord:recordRef];
    }
    
    return nil;
}

#pragma mark 其他接口支持
- (NSString *)keyWithCrc64:(NSString *)crc64 recordID:(ABRecordID)recordID {
    return [NSString stringWithUTF8Format:"%s-%d",[crc64 UTF8String],recordID];
}


- (ABRecordRef)abrecordWithRecordID:(ABRecordID)recordID {
    if (!self.addressBook) {
        return NULL;
    }
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(self.addressBook, recordID);
    return recordRef;
}

#pragma mark 本地通讯录接口
//- (NSArray *)allABRecords {
//    if (!self.addressBook) {
//        return [NSArray array];
//    }
//    return CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(self.addressBook));
//}
//
//- (NSArray *)abrecordsWithSearchText:(NSString *)text {
//    if (!self.addressBook) {
//        return [NSArray array];
//    }
//    if ([text length]) {
//        return CFBridgingRelease(ABAddressBookCopyPeopleWithName(self.addressBook,(__bridge CFStringRef)(text)));
//    }
//    else {
//        return CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(self.addressBook));
//    }
//}


@end

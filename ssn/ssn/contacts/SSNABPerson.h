//
//  SSNABPerson.h
//  ssn
//
//  Created by lingminjun on 15/5/30.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/ABRecord.h>
#import "SSNDBFetch.h"

@interface SSNABPerson : NSObject<SSNDBFetchObject>

@property (nonatomic,copy) NSString *key;   //主键

@property (nonatomic,copy) NSString *mobile;//号码
@property (nonatomic,copy) NSString *name;  //名字
@property (nonatomic,copy) NSString *pinyin;//searchPinyin，支持多音字
@property (nonatomic) char firstSpell;      //首拼字母

@property (nonatomic) ABRecordID recordID; //对应本地联系人属性
@property (nonatomic) int64_t modifyAt;     //本地修改时间

@property (nonatomic) long option;          //拓展标记位
@property (nonatomic,copy) NSString *ext;   //拓展字段，带索引

@end

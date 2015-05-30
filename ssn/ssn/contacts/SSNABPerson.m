//
//  SSNABPerson.m
//  ssn
//
//  Created by lingminjun on 15/5/30.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNABPerson.h"
#import "NSObject+SSN.h"
#import "NSString+SSNPinyin.h"

@implementation SSNABPerson

@synthesize ssn_dbfetch_rowid = _ssn_dbfetch_rowid;


- (NSUInteger)hash {
    return self.ssn_dbfetch_rowid;
}

- (BOOL)isEqual:(SSNABPerson *)object {
    if (![object isKindOfClass:[SSNABPerson class]]) {
        return NO;
    }
    return self.ssn_dbfetch_rowid == object.ssn_dbfetch_rowid;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self ssn_copy];
}


- (void)setName:(NSString *)name {
    _pinyin = [name ssn_searchPinyinString];
    if ([_pinyin length] > 0) {
        unichar c = [_pinyin characterAtIndex:0];
        if (c >= 'a' && c <= 'z') {
            _firstSpell = c - ('a' - 'A');
        }
        else if (c >= 'A' && c <= 'Z') {
            _firstSpell = c;
        }
        else {
            _firstSpell = '#';
        }
    }
    else {
        _firstSpell = '#';
    }
    _name = [name copy];
}

@end

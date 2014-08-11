//
//  TestModel.m
//  ssn
//
//  Created by lingminjun on 14-5-9.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "TestModel.h"
#import "ssndb1.h"

@implementation TestModel

@ssnimpIntPrimary(type);
@ssnimpTextPrimary(uid);

@ssnimpObj(name);

@ssnimpInt(age);
@ssnimpInt(sex);
@ssnimpFloat(hight);

+ (SSNModelPropertType)typeForKey:(NSString *)key {
    NSString *tp = [self valueTypeForKey:key];
    if ([tp isEqualToString:@"@"]) {
        return SSNModelPropertText;
    }
    else if ([tp isEqualToString:@"i"]) {
        return SSNModelPropertInteger;
    }
    else if ([tp isEqualToString:@"f"]) {
        return SSNModelPropertFloat;
    }
    return SSNModelPropertText;
}


+ (NSArray *)dataBase:(SSNDataBase *)database columnsForTemplateName:(NSString *)templateName databaseVersion:(NSUInteger)version {
    NSMutableArray *cls = [NSMutableArray arrayWithCapacity:5];
    
    NSArray *pks = [self primaryKeys];
    
    for (NSString *key in [self valuesKeys]) {
        SSNTableColumnInfo *info = [SSNTableColumnInfo columnWithName:key
                                                                 type:[self typeForKey:key]
                                                              keyType:[pks containsObject:key]?SSNModelPropertPrimaryKey:SSNModelPropertNormalKey
                                                            indexType:SSNModelPropertNotIndex
                                                              default:@""
                                                              mapping:@""];
        [cls addObject:info];
    }
    return cls;
}

@end

//
//  SSNDBTableManager.h
//  ssn
//
//  Created by lingminjun on 14-5-23.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNDBTableManager : NSObject

/*
 XML方式 实现table 版本管理
 xml定义参考
 <root>
    <tb>TestPerson</tb>
    <its>
        <vs value = 1/>
        <cl name = 'contactid' type = 1, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
        <cl name = 'name' type = 3, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
        <cl name = 'age' type = 1, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
    </its>
    <its>
        <vs value = 2/>
        <cl name = 'contactid' type = 1, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
        <cl name = 'name' type = 3, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
        <cl name = 'age' type = 1, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
    </its>
 </root>
 */

+ (NSDictionary *)loadDBTableFromXmlFile:(NSString *)path;


/*
 JSON方式 实现table 版本管理
 json文件定义
 {
    "tb":"TestPerson",
    "its":[{
            "vs":1,
            "cl":[{"name":"contactid","type":1,"keyType":0,"defaultValue":"","indexType":0,"mapping":""},
                    {"name":"name","type":3,"keyType":0,"defaultValue":"","indexType":0,"mapping":""},
                    {"name":"age","type":1,"keyType":0,"defaultValue":"","indexType":0,"mapping":""}
                    ]
        },
        {
            "vs":2,
            "cl":[{"name":"contactid","type":1,"keyType":0,"defaultValue":"","indexType":0,"mapping":""},
                    {"name":"name","type":3,"keyType":0,"defaultValue":"","indexType":0,"mapping":""},
                    {"name":"age","type":1,"keyType":0,"defaultValue":"","indexType":0,"mapping":""}
                    ]
        }
        ]
 }
 */
+ (NSDictionary *)loadDBTableFromJsonFile:(NSString *)path;

@end

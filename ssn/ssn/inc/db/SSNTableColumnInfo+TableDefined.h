//
//  SSNTableColumnInfo+TableDefined.h
//  ssn
//
//  Created by lingminjun on 14-4-14.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDataBase.h"

@interface SSNTableColumnInfo (TableDefined)

/*返回每个版本对应表定义，
 xml定义样式
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
+ (NSDictionary *)loadTableColumnsFromXmlFile:(NSString *)path;

@end

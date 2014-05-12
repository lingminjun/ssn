//
//  SSNTableColumnInfo+TableDefined.m
//  ssn
//
//  Created by lingminjun on 14-4-14.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNTableColumnInfo+TableDefined.h"

@implementation SSNTableColumnInfo (TableDefined)

/*返回每个版本对应表定义，
 xml定义样式
 <root>
     <tb>TestPerson</tb>
     <its>
         <vs value = 1/>
         <cl name = 'contactid' type = 0, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
         <cl name = 'name' type = 3, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
         <cl name = 'age' type = 0, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
     </its>
     <its>
         <vs value = 2/>
         <cl name = 'contactid' type = 0, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
         <cl name = 'name' type = 3, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
         <cl name = 'age' type = 0, keyType = 0, defaultValue = '' indexType = 0 mapping = ''/>
     </its>
 </root>
 */

typedef void (^XMLParserBlockType)(NSXMLParser *parser, NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict);

static XMLParserBlockType xlmParserDidStartElement  = nil;
static XMLParserBlockType xlmParserDidEndElement    = nil;
//static

+ (NSDictionary *)loadTableColumnsFromXmlFile:(NSString *)path {
    if ([path length] == 0) {
        return nil;
    }
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    // 初始化
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    //必须线性执行
    @synchronized (self) {
    
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        __block NSString *version = nil;
        __block NSMutableArray *cls = nil;
        
        xlmParserDidStartElement = ^(NSXMLParser *parser, NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict) {
            if ([elementName isEqualToString:@"its"]) {
                cls  = [NSMutableArray arrayWithCapacity:1];
            }
            else if ([elementName isEqualToString:@"vs"]) {//版本
                version = [NSString stringWithFormat:@"%ld",[[attributeDict objectForKey:@"value"] integerValue]];
            }
            else if ([elementName isEqualToString:@"cl"]) {//列
                SSNTableColumnInfo *info = [SSNTableColumnInfo columnWithName:[attributeDict objectForKey:@"name"]
                                                                       type:(SSNModelPropertType)[[attributeDict objectForKey:@"type"] integerValue]
                                                                    keyType:(SSNModelPropertKeyType)[[attributeDict objectForKey:@"keyType"] integerValue]
                                                                  indexType:(SSNModelPropertIndexType)[[attributeDict objectForKey:@"indexType"] integerValue]
                                                                    default:[attributeDict objectForKey:@"defaultValue"]
                                                                    mapping:[attributeDict objectForKey:@"mapping"]];
                [cls addObject:info];
            }
        };
        
        xlmParserDidEndElement = ^(NSXMLParser *parser, NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict) {
            if ([elementName isEqualToString:@"its"]) {
                if ([version length] && [cls count]) {
                    [dic setObject:cls forKey:version];
                }
                version = nil;
                cls = nil;
            }
        };
        
        // 代理
        xmlParser.delegate = (id  <NSXMLParserDelegate>)self;
        
        // 开始解析
        [xmlParser parse];
        
        xlmParserDidStartElement = nil;
        xlmParserDidEndElement = nil;
        
        return dic;
    }
    
}

+ (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (xlmParserDidStartElement) {
        xlmParserDidStartElement(parser,elementName,namespaceURI,qName,attributeDict);
    }
}

+ (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (xlmParserDidEndElement) {
        xlmParserDidEndElement(parser,elementName,namespaceURI,qName,nil);
    }
}

@end

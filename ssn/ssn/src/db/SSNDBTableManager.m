//
//  SSNDBTableManager.m
//  ssn
//
//  Created by lingminjun on 14-5-23.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBTableManager.h"
#import "SSNDataBase.h"

typedef void (^XMLParserBlockType)(NSXMLParser *parser, NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict);

@interface SSNDBTableManager () <NSXMLParserDelegate> {
    
    //XML方式解析实现
    XMLParserBlockType xlmParserDidStartElement;
    XMLParserBlockType xlmParserDidEndElement;
}

@end


@implementation SSNDBTableManager

#pragma - mark xml格式文件 管理表版本
- (NSDictionary *)loadDBTableFromXmlParser:(NSXMLParser *)xmlParser {
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
    xmlParser.delegate = self;
    
    // 开始解析
    [xmlParser parse];
    
    return dic;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (xlmParserDidStartElement) {
        xlmParserDidStartElement(parser,elementName,namespaceURI,qName,attributeDict);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (xlmParserDidEndElement) {
        xlmParserDidEndElement(parser,elementName,namespaceURI,qName,nil);
    }
}

+ (NSDictionary *)loadDBTableFromXmlFile:(NSString *)path {
    if ([path length] == 0) {
        return nil;
    }
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    if ([data length] == 0) {
        return nil;
    }
    
    // 初始化
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    SSNDBTableManager *manager = [[SSNDBTableManager alloc] init];
    
    return [manager loadDBTableFromXmlParser:xmlParser];
}

#pragma - mark json 方式定义 数据表支持
+ (NSDictionary *)loadDBTableFromJsonFile:(NSString *)path {
    
    if ([path length] == 0) {
        return nil;
    }
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    if ([data length] == 0) {
        return nil;
    }
    
    //IOS5自带解析类NSJSONSerialization从data中解析出数据放到字典中
    NSDictionary *temDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    NSMutableDictionary *rslt = [NSMutableDictionary dictionaryWithCapacity:1];
    for (NSDictionary* its in [temDic objectForKey:@"its"]) {
        NSString *vs = [its objectForKey:@"vs"];
        NSArray *cls = [its objectForKey:@"cl"];
        
        NSMutableArray *tcls = [NSMutableArray arrayWithCapacity:[cls count]];
        
        for (NSDictionary *cl in cls) {
            SSNTableColumnInfo *info = [SSNTableColumnInfo columnWithName:[cl objectForKey:@"name"]
                                                                     type:(SSNModelPropertType)[[cl objectForKey:@"type"] integerValue]
                                                                  keyType:(SSNModelPropertKeyType)[[cl objectForKey:@"keyType"] integerValue]
                                                                indexType:(SSNModelPropertIndexType)[[cl objectForKey:@"indexType"] integerValue]
                                                                  default:[cl objectForKey:@"defaultValue"]
                                                                  mapping:[cl objectForKey:@"mapping"]];
            [tcls addObject:info];
        }
        
        if ([vs length] && [tcls count]) {
            [rslt setObject:tcls forKey:vs];
        }
    }
    
    return rslt;
}

@end

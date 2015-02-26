//
//  SSNVMSectionInfo.h
//  ssn
//
//  Created by lingminjun on 15/2/23.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SSN_VM_SECTION_INFO_DEFAULT_HEIGHT (20)

/**
 *  table section 的 view model
 */
@interface SSNVMSectionInfo : NSObject

/**
 *  id，isEqaul将比较idendify
 */
@property (nonatomic,copy) NSString *identify;

/**
 *  title
 */
@property (nonatomic,copy) NSString *title;

/**
 *  高度，默认值是20
 */
@property (nonatomic) CGFloat height;

/**
 *  其他参数存储
 */
@property (nonatomic,strong,readonly) NSMutableDictionary *userInfo;

/**
 *  元素个数
 */
@property (nonatomic,strong,readonly) NSMutableArray *objects;

/**
 *  元素个数
 *
 *  @return 元素个数
 */
- (NSUInteger)count;

/**
 *  返回元素，如果越界将返回nil
 *
 *  @param index 元素所处位置
 *
 *  @return 元素
 */
- (id)objectAtIndex:(NSUInteger)index;

/**
 *  工程方法
 *
 *  @param identify id，根据需要来设置
 *  @param title    标题，显示的标题
 *
 *  @return section info 实例
 */
+ (instancetype)sectionInfoWithIdentify:(NSString *)identify title:(NSString *)title;
@end

//
//  SSNVMSectionInfo.h
//  ssn
//
//  Created by lingminjun on 15/2/23.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SSN_VM_SECTION_INFO_DEFAULT_HEIGHT (20)

/**
 *  table section 的 view model
 */
@interface SSNVMSectionInfo : NSObject<NSCopying>

/**
 *  id，isEqaul将比较idendify
 */
@property (nonatomic,copy,readonly) NSString *identify;

/**
 *  title
 */
@property (nonatomic,copy) NSString *headerTitle;

/**
 *  是否影藏header，默认显示
 */
@property (nonatomic) BOOL hiddenHeader;

/**
 *  高度，默认值是20
 */
@property (nonatomic) CGFloat headerHeight;

/**
 *  用于显示的view
 */
@property (nonatomic,strong) UIView *customHeaderView;

/**
 *  title
 */
@property (nonatomic,copy) NSString *footerTitle;

/**
 *  是否影藏footer，默认隐藏
 */
@property (nonatomic) BOOL hiddenFooter;

/**
 *  高度，默认值是20
 */
@property (nonatomic) CGFloat footerHeight;

/**
 *  用于显示的view
 */
@property (nonatomic,strong) UIView *customFooterView;

/**
 *  排序键，默认值为0
 */
@property (nonatomic) NSInteger sortIndex;

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
 *  返回元素所在位置，如果结果集中没找到返回NSNotFound
 *
 *  @param object 元素
 *
 *  @return 位置
 */
- (NSUInteger)indexOfObject:(id)object;

/**
 *  用于排序需要，默认比较sortIndex，可以重载完成更多需求
 *
 *  @param info 下一个section info
 *
 *  @return 大小关系
 */
- (NSComparisonResult)compare:(SSNVMSectionInfo *)info;

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

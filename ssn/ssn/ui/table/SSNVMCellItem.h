//
//  SSNVMCellItem.h
//  ssn
//
//  Created by lingminjun on 15/2/23.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SSN_VM_CELL_ITEM_DEFAULT_HEIGHT (44)

@protocol SSNVMCellProtocol;

/**
 *  cell model协议（给定view model概念）
 */
@protocol SSNCellModel <NSObject>
@end

/**
 *  table view cell view model
 */
@interface SSNVMCellItem : NSObject<SSNCellModel>

/**
 *  id，isEqaul将比较idendify
 */
@property (nonatomic,copy) NSString *identify;

/**
 *  业务对象，如果支持copy，请尽量采用copy方式
 */
@property (nonatomic,strong/*copy*/) id object;

/**
 *  用于存储业务其他需要的值
 */
@property (nonatomic,strong,readonly) NSMutableDictionary *userInfo;

#pragma mark UITableViewCell 配置支持
/**
 *  cell 高度
 */
@property (nonatomic) CGFloat height;

/**
 *  对应得cell 类型
 */
@property (nonatomic,strong) Class<SSNVMCellProtocol> cellClass;

/**
 *  用于UITableView dequeueReusableCellWithIdentifier:方法，方便cell重用，默认用SSNVMCellItem类名字
 */
@property (nonatomic,copy) NSString *cellIdentify;

@end

/**
 *  cell重置协议
 */
@protocol SSNVMCellProtocol <NSObject>

/**
 *  配置cell
 *
 *  @param model     用view model配置cell
 *  @param indexPath 数据位置
 *  @param tableView 所在的tableView
 */
- (void)ssn_configureCellWithModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;

@end

@interface UITableViewCell (SSNVMCellProtocol)

/**
 *  do noting
 *
 *  @param model     用view model配置cell
 *  @param indexPath 数据位置
 *  @param tableView 所在的tableView
 */
- (void)ssn_configureCellWithModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;

@end

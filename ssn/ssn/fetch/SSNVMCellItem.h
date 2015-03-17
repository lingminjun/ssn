//
//  SSNVMCellItem.h
//  ssn
//
//  Created by lingminjun on 15/2/23.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SSN_VM_CELL_ITEM_DEFAULT_HEIGHT (44)

@protocol SSNVMCellProtocol;

/**
 *  cell model协议（给定view model概念）
 */
@protocol SSNCellModel <NSObject>

/**
 *  元素的hash值
 */
@property (readonly) NSUInteger hash;

/**
 *  数据
 *
 *  @param model 另一个数据
 *
 *  @return 返回是否相等
 */
- (BOOL)isEqual:(id<SSNCellModel>)model;

/**
 *  对应的cell 类型
 */
@property (nonatomic,strong,readonly) Class<SSNVMCellProtocol> cellClass;

/**
 *  对应的cell nib 文件名
 */
@property (nonatomic,copy,readonly) NSString *cellNibName;

/**
 *  用于UITableView dequeueReusableCellWithIdentifier:方法，方便cell重用，默认用SSNVMCellItem类名字
 */
@property (nonatomic,copy,readonly) NSString *cellIdentify;

/**
 *  行高
 */
@property (nonatomic,readonly) CGFloat cellHeight;

/**
 *  是否被禁用选择
 */
@property (nonatomic,readonly) BOOL isDisabledSelect;

/**
 *  是否滑动删除，且删除文案配置，若返回nil表示不支持删除
 */
@property (nonatomic,copy,readonly) NSString *cellDeleteConfirmationButtonTitle;

/**
 *  用于分组的key
 */
@property (nonatomic,copy,readonly) NSString *cellSectionIdentify;

@optional
/**
 *  具备排序能力，请实现view model排序规则
 *
 *  实例代码
 
//排序实现
- (NSComparisonResult)ssn_compare:(SSNVMCellItem *)model {
    if (self == model) {
        return NSOrderedSame;
    }
    
    if (![model isKindOfClass:[SSNVMCellItem class]]) {
        return NSOrderedAscending;
    }
    
    return [self.identify compare:model.identify];
}

 *
 *  @param model 另一个数据
 *
 *  @return 返回大小关系
 */
- (NSComparisonResult)ssn_compare:(id<SSNCellModel>)model;
@end

/**
 *  协议弱化
 */
@interface NSObject (SSNCellModel)<SSNCellModel>

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
@property (nonatomic) CGFloat cellHeight;

/**
 *  是否被禁用选择
 */
@property (nonatomic,getter=isDisabledSelect) BOOL disabledSelect;

/**
 *  是否滑动删除，且删除文案配置，若返回nil表示不支持删除
 */
@property (nonatomic,copy) NSString *cellDeleteConfirmationButtonTitle;

/**
 *  对应得cell 类型
 */
@property (nonatomic,strong) Class<SSNVMCellProtocol> cellClass;

/**
 *  对应的cell nib 文件名
 */
@property (nonatomic,copy) NSString *cellNibName;


/**
 *  用于UITableView dequeueReusableCellWithIdentifier:方法，方便cell重用，默认用SSNVMCellItem类名字
 */
@property (nonatomic,copy) NSString *cellIdentify;

/**
 *  用于分组需要，默认返回nil
 */
@property (nonatomic,copy) NSString *cellSectionIdentify;

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

/**
 *  呈现cell的viewController，若cell没有被呈现到界面，或者没有直接或者间接呈现于viewController中，此接口将返回nil
 *
 *  @return 返回呈现cell的控制器
 */
- (UIViewController *)ssn_presentingViewController;


/**
 *  配置cell的cellModel，若此时cell不在界面，此方法将返回nil
 *
 *  @return cellModel
 */
- (id<SSNCellModel>)ssn_cellModel;

@end

@interface UITableViewCell (SSNVMCellProtocol)

/**
 *  do nothing
 *
 *  @param model     用view model配置cell
 *  @param indexPath 数据位置
 *  @param tableView 所在的tableView
 */
- (void)ssn_configureCellWithModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;

/**
 *  呈现cell的viewController，若cell没有被呈现到界面，或者没有直接或者间接呈现于viewController中，此接口将返回nil (此方法必须实时获取)
 *
 *  @return 返回呈现cell的控制器
 */
- (UIViewController *)ssn_presentingViewController;

/**
 *  配置cell的cellModel，若此时cell不在界面，此方法将返回nil (此方法必须实时获取)
 *
 *  @return cellModel
 */
@property (nonatomic,weak) id<SSNCellModel> ssn_cellModel;

@end

//
//  UIViewController+SSNTableViewEasyConfigure.h
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNVMCellItem.h"
#import "SSNVMSectionInfo.h"
#import "UITableView+SSNPullRefresh.h"
#import "SSNListFetchController.h"

@protocol SSNTableViewConfiguratorDelegate;

/**
 *  给出一种默认的实现，让控制器变得更佳简介易用
 */
@interface SSNTableViewConfigurator : NSObject<UITableViewDelegate,UITableViewDataSource,SSNPullRefreshDelegate,
SSNListFetchControllerDelegate,SSNListFetchControllerDataSource>

/**
 *  委托
 */
@property (nonatomic,weak) id<SSNTableViewConfiguratorDelegate> delegate;

/**
 *  默认ssn_listFetchController的委托是控制器本身
 *  数据源的委托还未指定
 */
@property (nonatomic,strong,readonly) SSNListFetchController *listFetchController;

/**
 *  结果呈现的table，此ui应该由ui来把持
 */
@property (nonatomic,weak) UITableView *tableView;

/**
 *  自动检查loadMore功能，不需要你处理tableView.ssn_loadMoreEnabled属性，自动检查是否有更多
 */
@property (nonatomic) BOOL isAutoEnabledLoadMore;

/**
 *  请务必调用此方法配置你的Configurator
 *
 *  @param tableView 需要设置的table
 *  @param grouping  listFetchController的类型定义
 */
- (void)configureWithTableView:(UITableView *)tableView groupingFetchController:(BOOL)grouping;

@end

/**
 *  table view 配置器 委托定义
 */
@protocol SSNTableViewConfiguratorDelegate <NSObject>

@required
/**
 *  当某行数据选中委托
 *
 *  @param configurator 配置器
 *  @param tableView    所作用的表
 *  @param model        所选对象
 *  @param indexPath    选择数据的位置
 */
- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator tableView:(UITableView *)tableView didSelectModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath;

@optional
/**
 *  删除动作回调
 *
 *  @param configurator 配置器
 *  @param tableView    所作用的表
 *  @param editingStyle 编辑类型
 *  @param indexPath    选择数据的位置
 */
- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  重新加载数据委托
 *  注意：在加载完数据后请务必调用completion通知controller来反馈结果集变化
 *
 *  @param configurator 配置器
 *  @param controller 当前fetch controller
 *  @param offset     起始值，第一次默认为0，后面为count大小
 *  @param limit      结果大小限制，为0时一般表示不限制，根据使用者需要定义
 *  @param userInfo   其他参数
 *  @param completion 回调结果 results中存放原始数据集，finished表示此次加载是否正常完结，若错误则需要设置为NO
 */
- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator controller:(SSNListFetchController *)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion;

@optional
/**
 *  对原始数据加工，转换成view model，若不实现此方法，则直接采用原始数据
 *
 *  @param configurator 配置器
 *  @param controller 当前fetch controller
 *  @param results    原始数据集
 *
 *  @return 返回加工后的数据集 @see SSNCellModel
 */
- (NSArray *)ssn_configurator:(SSNTableViewConfigurator *)configurator controller:(SSNListFetchController *)controller constructObjectsFromResults:(NSArray *)results;

@end

/**
 *  对简易行的tableView结果集委托有一套默认实现，方便使用者使用
 *  UITableViewDataSource仅仅实现必要委托
 */
@interface UIViewController (SSNTableViewEasyConfigure) <SSNTableViewConfiguratorDelegate>

/**
 *  table配置器
 */
@property (nonatomic,strong,readonly) SSNTableViewConfigurator *ssn_tableViewConfigurator;


@end

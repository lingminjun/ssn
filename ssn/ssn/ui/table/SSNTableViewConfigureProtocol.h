//
//  SSNTableViewConfigureProtocol.h
//  ssn
//
//  Created by lingminjun on 15/3/3.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNVMCellItem.h"
#import "SSNVMSectionInfo.h"
#import "UITableView+SSNPullRefresh.h"
#import "SSNFetchControllerPrototol.h"

@protocol SSNTableViewConfiguratorDelegate,SSNTableViewConfigurator,SSNCellModel;

/**
 *  将table configurator单独定义下，表明必要接口
 */
@protocol SSNTableViewConfigurator <NSObject,UITableViewDelegate,UITableViewDataSource,SSNPullRefreshDelegate>
/**
 *  委托
 */
@property (nonatomic,weak) id<SSNTableViewConfiguratorDelegate> delegate;

/**
 *  结果呈现的table，此ui应该由ui来把持
 */
@property (nonatomic,weak) UITableView *tableView;

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
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath;

@optional
/**
 *  删除动作回调
 *
 *  @param configurator 配置器
 *  @param tableView    所作用的表
 *  @param editingStyle 编辑类型
 *  @param indexPath    选择数据的位置
 */
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;


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
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion;

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
- (NSArray *)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller constructObjectsFromResults:(NSArray *)results;

@end


//
//  SSNListFetchController.h
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNFetchControllerPrototol.h"

#define SSN_LIST_FETCH_CONTROLLER_DEFAULT_LIMIT (20)

FOUNDATION_EXTERN NSString *const SSNFetchDefaultSectionIdentify;

@protocol SSNListFetchControllerDelegate,SSNListFetchControllerDataSource,SSNCellModel;
@class SSNSectionModel;


/**
 *  简单的列表结果集管理控制器
 *  注意：此简单结果集管理器只能在主线程中使用
 */
@interface SSNListFetchController : NSObject<SSNFetchControllerPrototol>

/**
 *  刷新委托
 */
@property (nonatomic, weak) id<SSNListFetchControllerDelegate> delegate;

/**
 *  数据源委托
 */
@property (nonatomic, weak) id<SSNListFetchControllerDataSource> dataSource;

/**
 *  正在刷新数据
 */
@property (nonatomic,readonly) BOOL isLoading;

/**
 *  是否还有更多
 */
@property (nonatomic,readonly) BOOL hasMore;

/**
 *  是否需要强制排序，如果设置为yes，你需要结合实现SSNCellModel协议 -ssn_compare: 方法告知排序规则
 */
@property (nonatomic) BOOL isMandatorySorting;


/**
 *  是否分组展示，也就是有多个section的意思
 */
@property (nonatomic,readonly) BOOL isGrouping;


/**
 *  每次拉取数据大小，默认为20，设置为零时一般表示不限制大小，请在reload接口调用前设置
 */
@property (nonatomic) NSUInteger limit;

/**
 *  初始化fetch
 *
 *  @param grouping 是否分组
 *
 *  @return 返回当前实例
 */
- (instancetype)initWithGrouping:(BOOL)grouping;

/**
 *  更新所有数据，默认offset被重置为0，正在加载时忽略调用，数据加载是一个异步过程
 */
- (void)loadData;

/**
 *  加载更多数据，hasMore为NO时忽略调用，正在加载时忽略调用，数据加载是一个异步过程
 */
- (void)loadMoreData;

#pragma mark object manager
/**
 *  section个数
 *
 *  @return section个数
 */
- (NSUInteger)sectionCount;

/**
 *  所有数据集大小
 *
 *  @return 所有数据集大小
 */
- (NSUInteger)objectsCount;

/**
 *  所有sections，返回的数据是不可以修改的，即使修改也不会有任何作用
 *
 *  @return 返回所有sections
 */
- (NSArray *)sections;

/**
 *  所有sections的 identify
 *
 *  @return 返回所有identfiers
 */
- (NSArray *)sectionIdentifiers;

/**
 *  返回所有当前数据 返回 SSNCellModel @see SSNCellModel
 *
 *  @return 返回所有当前数据
 */
- (NSArray *)objects;

/**
 *  返回section info
 *
 *  @param index 所在位置
 *
 *  @return 返回section
 */
- (SSNSectionModel *)sectionAtIndex:(NSUInteger)section;

/**
 *  返回section info
 *
 *  @param identify section identify
 *
 *  @return 返回section
 */
- (SSNSectionModel *)sectionWithSectionIdentify:(NSString *)identify;

/**
 *  返回section所在位置
 *
 *  @param section
 *
 *  @return 位置，如果结果集中没找到返回NSNotFound
 */
- (NSUInteger)indexWithSection:(SSNSectionModel *)section;

/**
 *  返回section
 *
 *  @param identify section唯一标示
 *
 *  @return 获取section
 */
- (NSUInteger)indexWithSectionIdentify:(NSString *)identify;

/**
 *  返回数据
 *
 *  @param indexPath 位置
 *
 *  @return 数据
 */
- (id<SSNCellModel>)objectAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  获取数据位置，如果结果集中没找到返回NSNotFound
 *
 *  @param object 数据
 *
 *  @return 位置
 */
- (NSIndexPath *)indexPathOfObject:(id<SSNCellModel>)object;//

#pragma mark 数据集局部改变通知接口
/**
 *  新增数据
 *
 *  @param data       新增的数据
 *  @param indexPath   indexPath插入data
 */
- (void)insertData:(id<SSNCellModel>)data atIndexPath:(NSIndexPath *)indexPath;

/**
 *  新增数据
 *
 *  @param datas       新增的数据
 *  @param indexPath   indexPath插入datas
 */
- (void)insertDatas:(NSArray *)datas atIndexPath:(NSIndexPath *)indexPath;

/**
 *  末尾新增数据
 *
 *  @param datas       新增的数据
 */
- (void)appendDatas:(NSArray *)datas;

/**
 *  删除数据
 *
 *  @param data       删除数据
 */
- (void)deleteData:(id<SSNCellModel>)data;

/**
 *  删除对应位置的数据
 *
 *  @param indexPath NSIndexPath数据所在位置
 */
- (void)deleteDataAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  删除对应位置的数据
 *
 *  @param indexPaths NSIndexPaths数据所在位置
 */
- (void)deleteDatasAtIndexPaths:(NSArray *)indexPaths;

/**
 *  更新位置的数据
 *
 *  @param datas      更新的数据
 *  @param indexPath 位置信息必须与与更新数据保持一致
 */
- (void)updateData:(id<SSNCellModel>)data atIndexPath:(NSIndexPath *)indexPath;

/**
 *  更新位置的数据
 *
 *  @param datas      更新的数据
 *  @param indexPaths 位置信息必须与与更新数据保持一致
 */
- (void)updateDatas:(NSArray *)datas atIndexPaths:(NSArray *)indexPaths;

#pragma mark 工厂方法
/**
 *  工厂方法
 *
 *  @param delegate   事件委托
 *  @param dataSource 数据源委托
 *  @param isGrouping 是否为分组
 *
 *  @return SSNListFetchController
 */
+ (instancetype)fetchControllerWithDelegate:(id<SSNListFetchControllerDelegate>)delegate dataSource:(id<SSNListFetchControllerDataSource>)dataSource isGrouping:(BOOL)isGrouping;
@end


/**
 * 结果集改变委托
 */
@protocol SSNListFetchControllerDelegate <NSObject>

/**
 *  数据修改委托
 */
typedef NS_ENUM(NSUInteger, SSNListFetchedChangeType){
    /**
     *  数据插入
     */
    SSNListFetchedChangeInsert = 1,
    /**
     *  数据更新
     */
    SSNListFetchedChangeDelete = 2,
    /**
     *  数据移动
     */
    SSNListFetchedChangeMove = 3,
    /**
     *  数据更新
     */
    SSNListFetchedChangeUpdate = 4
};

/**
//实例代码
- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeSection:(SSNSectionModel *)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(SSNListFetchedChangeType)type {
    switch(type) {
        case SSNListFetchedChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case SSNListFetchedChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:break;
    }
}

- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeObject:(id<SSNCellModel>)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(SSNListFetchedChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (controller != self.listFetchController) {
        return ;
    }
    
    switch (type) {
        case SSNListFetchedChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeMove:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeUpdate:
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell ssn_configureCellWithModel:object atIndexPath:indexPath inTableView:self.tableView];
        }
            break;
        default:
            break;
    }
}

- (void)ssnlist_controllerWillChange:(SSNListFetchController *)controller {
    [self.tableView beginUpdates];
}

- (void)ssnlist_controllerDidChange:(SSNListFetchController *)controller {
    [self.tableView endUpdates];
}
*/
@required
- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeSection:(SSNSectionModel *)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(SSNListFetchedChangeType)type;

- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeObject:(id<SSNCellModel>)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(SSNListFetchedChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

- (void)ssnlist_controllerWillChange:(SSNListFetchController *)controller;


- (void)ssnlist_controllerDidChange:(SSNListFetchController *)controller;

@end


/**
 *  数据源委托申明
 */
@protocol SSNListFetchControllerDataSource <NSObject>

@required
/**
 *  重新加载数据委托
 *  注意：在加载完数据后请务必调用completion通知controller来反馈结果集变化
 *
 *  @param controller 当前fetch controller
 *  @param offset     起始值，第一次默认为0，后面为count大小
 *  @param limit      结果大小限制，为0时一般表示不限制，根据使用者需要定义
 *  @param userInfo   其他参数
 *  @param completion 回调结果 results中存放原始数据集，finished表示此次加载是否正常完结，若错误则需要设置为NO
 */
- (void)ssnlist_controller:(SSNListFetchController *)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion;


@optional
/**
 *  grouping 结果集，当系统已经构造好了一个空的section时回调通知，你可以在这里配置section，
 *
 *  @param controller 当前fetch controller
 *  @param section    section
 *  @param identify   section的唯一标示
 */
- (void)ssnlist_controller:(SSNListFetchController *)controller sectionDidLoad:(SSNSectionModel *)section sectionIdntify:(NSString *)identify;

@end

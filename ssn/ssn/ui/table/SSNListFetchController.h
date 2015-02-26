//
//  SSNListFetchController.h
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SSN_LIST_FETCH_CONTROLLER_DEFAULT_LIMIT (20)

@protocol SSNListFetchControllerDelegate,SSNListFetchControllerDataSource,SSNCellModel;

/**
 *  简单的列表结果集管理控制器
 *  注意：此简单结果集管理器只能在主线程中使用
 */
@interface SSNListFetchController : NSObject

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
 *  每次拉取数据大小，默认为20，设置为零时一般表示不限制大小，请在reload接口调用前设置
 */
@property (nonatomic) NSUInteger limit;

/**
 *  更新所有数据，默认offset被重置为0，正在加载时忽略调用
 */
- (void)loadData;

/**
 *  加载更多数据，hasMore为NO时忽略调用，正在加载时忽略调用
 *  等价与
 */
- (void)loadMoreData;

#pragma mark object manager
- (NSUInteger)count;//数据集大小

- (NSArray *)objects;//返回所有当前数据 @see SSNCellModel

- (id<SSNCellModel>)objectAtIndex:(NSUInteger)index;//小于count，否则出现越界异常

- (NSUInteger)indexOfObject:(id<SSNCellModel>)object;//如果结果集中没找到返回NSNotFound

#pragma mark 数据集局部改变通知接口
/**
 *  新增源数据
 *
 *  @param data  新增原始数据
 *  @param index index位置，若大于count，则插入到最后
 */
- (void)insertData:(id)data atIndex:(NSUInteger)index;

/**
 *  删除对应位置的数据
 *
 *  @param indexs 数据所在位置
 */
- (void)deleteObjectsAtIndexs:(NSIndexSet *)indexs;

/**
 *  更新对应位置数据的原始数据
 *
 *  @param data  原始数据
 *  @param index 位置
 */
- (void)updateData:(id)data atIndex:(NSUInteger)index;


/**
 *  批量新增源数据
 *
 *  @param datas 所有需要添加的原始数据
 *  @param index index位置，若大于count，则插入到最后
 */
- (void)insertDatas:(NSArray *)datas atIndex:(NSUInteger)index;

#pragma mark 工厂方法
/**
 *  工厂方法
 *
 *  @param delegate   事件委托
 *  @param dataSource 数据源委托
 *
 *  @return SSNListFetchController
 */
+ (instancetype)fetchControllerWithDelegate:(id<SSNListFetchControllerDelegate>)delegate dataSource:(id<SSNListFetchControllerDataSource>)dataSource;
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
- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeObject:(id<SSNCellModel>)object atIndex:(NSUInteger)index forChangeType:(SSNListFetchedChangeType)type newIndex:(NSUInteger)newIndex {
    
    switch (type) {
        case SSNListFetchedChangeInsert:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeDelete:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeMove:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNListFetchedChangeUpdate:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            UITableViewCell *cell = [self.ssn_resultsTableView cellForRowAtIndexPath:indexPath];
            [cell ssn_configureCellWithModel:object atIndexPath:indexPath inTableView:self.ssn_resultsTableView];
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
- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeObject:(id<SSNCellModel>)object atIndex:(NSUInteger)index forChangeType:(SSNListFetchedChangeType)type newIndex:(NSUInteger)newIndex;


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
 *  对原始数据加工，转换成view model，若不实现此方法，则直接采用原始数据
 *
 *  @param controller 当前fetch controller
 *  @param results    原始数据集
 *
 *  @return 返回加工后的数据集 @see SSNCellModel
 */
- (NSArray *)ssnlist_controller:(SSNListFetchController *)controller constructObjectsFromResults:(NSArray *)results;

@end

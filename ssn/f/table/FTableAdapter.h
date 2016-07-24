//
//  FTableAdapter.h
//  ssn
//
//  Created by lingminjun on 16/7/17.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FTableCell,FTableCellModel,FTableCellProtected,FTableAdapterDelegate;

/**
 *  UITableView适配器，更好的使用table view，也可以成为结果集管理器
 *  仅仅支持一级table展示，若要支持section展示，请在FTableCellModel中标示
 */
@interface FTableAdapter : NSObject

- (instancetype)init;
- (instancetype)initWithSectionStyle:(BOOL)supportSection;

@property (nonatomic, readonly) BOOL supportSection;
@property (nonatomic, strong) UITableView *tableView;//所作用的table view
@property (nonatomic, weak) id<FTableAdapterDelegate> delegate;//回调



- (void)refreash;//刷新界面，也就是通知table更新

- (NSUInteger)count;//数据个数

- (NSArray<id<FTableCellModel> > *)models;//获取所有数据
- (id<FTableCellModel>)modelAtIndex:(NSUInteger)index;//获取对应位置数据
- (NSUInteger)indexOfModel:(id<FTableCellModel>)model;//返回model对应的位置

- (void)setModels:(NSArray<id<FTableCellModel> > *)models;//设置数据源
- (void)appendModels:(NSArray<id<FTableCellModel> > *)models;//尾部增加数据源
- (void)appendModel:(id<FTableCellModel>)model;//尾部增加数据

- (void)insertModel:(id<FTableCellModel>)model atIndex:(NSUInteger)index;//在对应的位置插入数据
- (void)insertModels:(NSArray<id<FTableCellModel> > *)models atIndex:(NSUInteger)index;//在对应位置插入数据集

- (void)updateModel:(id<FTableCellModel>)model atIndex:(NSUInteger)index;//更新对应位置的数据
- (void)updateModelsAtIndexs:(NSIndexSet *)indexs;//更新对应位置的数据
- (void)updateModelsInRange:(NSRange)range;//更新对应位置的数据

- (void)deleteModel:(id<FTableCellModel>)model;//删除对应的数据
- (void)deleteModelAtIndex:(NSUInteger)index;//删除对应位置的数据
- (void)deleteModelsInRange:(NSRange)range;//删除对应位置的批量数据

@property (nonatomic) UITableViewRowAnimation animation;//当table发生变化时动画配置，默认UITableViewRowAnimationFade

@end

/**
 *  cell展示协议
 */
@protocol FTableCell <NSObject>

/**
 *  cell 展示回到
 *
 *  @param cellModel 数据源
 *  @param indexPath 当前table位置
 *  @param tableView 显示的table
 */
- (void)ftable_display:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView;

/**
 *  最后展示的数据
 *
 *  @return 最后展示的cellModel
 */
- (id<FTableCellModel>)ftable_cellModel;

@end

@protocol FTableCellProtected <FTableCell>
- (void)ftable_onDisplay:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView;
@end

/**
 *  支持FTableCell，弱协议支持
 */
@interface UITableViewCell (FTableCell) <FTableCellProtected>
@end

/**
 *  支持FTableCell，弱协议支持
 */
@interface UITableViewHeaderFooterView (FTableCell) <FTableCellProtected>
@end


/**
 *  要用FTableAdapter管理table，必须使用FTableCellModel来适配cell
 */
@protocol FTableCellModel <NSObject>
@optional
/**
 *  用于展示的cell xib文件名返回，cell会复用
 *
 *  @return 返回可复用的cell xib文件名
 */
- (NSString *)ftable_displayCellNibName;

/**
 *  用于展示的cell类型返回，cell会复用，若设置了nibName，则cell将从nib加载，此方法将不再起作用
 *
 *  @return 返回可复用的cell类型
 */
- (Class<FTableCellProtected>)ftable_displayCellClass;

/**
 *  返回cell需要展示的高度
 *
 *  @return 返回高度，若返回0，则采用tableView默认高度
 */
- (NSUInteger)ftable_cellHeight;

/**
 *  是否能够被删除，且删除title，返回nil表示不可删除
 *
 *  @return 删除title
 */
- (NSString *)ftable_cellDeleteConfirmationButtonTitle;

/**
 *  当前是section header，将会悬乎到顶部，注意若为header，呈现的View不能是UITableViewCell类型，请用UITableViewHeaderFooterView类型
 *  否则发生错误“No index path for table cell being reused”，
 *
 *  @return 是否为section header，请返回既定值，否则容易发生错误
 */
- (BOOL)ftable_isSectionHeader;

@end


/**
 *  委托协议
 */
@protocol FTableAdapterDelegate <NSObject>

@optional
/**
 *  选中某个cell回调
 *
 *  @param adapter   适配器
 *  @param tableView 对应的表
 *  @param model     选中的数据
 *  @param index     位置
 */
- (void)ftable_adapter:(FTableAdapter *)adapter tableView:(UITableView *)tableView didSelectModel:(id<FTableCellModel>)model atIndex:(NSUInteger)index;

@optional
/**
 *  删除动作回调
 *
 *  @param adapter      配置器
 *  @param tableView    所作用的表
 *  @param editingStyle 编辑类型
 *  @param index        选择数据的位置
 */
- (void)ftable_adapter:(FTableAdapter *)adapter tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndex:(NSUInteger)index;
@end


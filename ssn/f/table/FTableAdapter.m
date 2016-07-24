//
//  FTableAdapter.m
//  ssn
//
//  Created by lingminjun on 16/7/17.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import "FTableAdapter.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

/**
 *  数据修改委托
 */
typedef NS_ENUM(NSUInteger, FTableChangeType){
    /**
     *  数据插入
     */
    FTableChangeInsert = 1,
    /**
     *  数据删除
     */
    FTableChangeDelete = 2,
    /**
     *  数据移动
     */
    FTableChangeMove = 3,
    /**
     *  数据更新
     */
    FTableChangeUpdate = 4
};

static char *ftable_cell_model_key = NULL;

@implementation UITableViewCell (FTableCell)
- (void)ftable_display:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView {}

- (void)ftable_setCellModel:(id<FTableCellModel>)cellModel {
    objc_setAssociatedObject(self, &(ftable_cell_model_key),cellModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<FTableCellModel>)ftable_cellModel {
    return objc_getAssociatedObject(self, &(ftable_cell_model_key));
}

- (void)ftable_onDisplay:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView {
    //防止嵌套调用ftable_display方法
    
    //提前替换掉cell model
    [self ftable_setCellModel:cellModel];
    
    //调用展示函数
    @try {
        [self ftable_display:cellModel atIndexPath:indexPath inTable:tableView];
    } @catch (NSException *exception) {
        NSLog(@"0x0:%@",exception);
    } @finally {
        //
    }
    
    //最后防止数据被串改回来
    [self ftable_setCellModel:cellModel];
}

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}
@end

@implementation UITableViewHeaderFooterView (FTableCell)
- (void)ftable_display:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView {}

- (void)ftable_setCellModel:(id<FTableCellModel>)cellModel {
    objc_setAssociatedObject(self, &(ftable_cell_model_key),cellModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<FTableCellModel>)ftable_cellModel {
    return objc_getAssociatedObject(self, &(ftable_cell_model_key));
}

- (void)ftable_onDisplay:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView {
    //防止嵌套调用ftable_display方法
    
    //提前替换掉cell model
    [self ftable_setCellModel:cellModel];
    
    //调用展示函数
    @try {
        [self ftable_display:cellModel atIndexPath:indexPath inTable:tableView];
    } @catch (NSException *exception) {
        NSLog(@"0x1:%@",exception);
    } @finally {
        //
    }
    
    //最后防止数据被串改回来
    [self ftable_setCellModel:cellModel];
}
@end

@interface FTableSectionNode : NSObject
@property (nonatomic,strong) id<FTableCellModel> model;
@property (nonatomic,strong) NSMutableArray<id<FTableCellModel>> *objs;
@property (nonatomic) NSInteger index;//起始位置
+ (instancetype)node;
+ (instancetype)nodeWithModel:(id<FTableCellModel>)model atIndex:(NSInteger)index;
@end
@implementation FTableSectionNode
- (instancetype)init {
    self = [super init];
    if (self) {
        _objs = [[NSMutableArray alloc] init];
        _index = -1;
    }
    return self;
}
+ (instancetype)node {
    return [[[self class] alloc] init];
}
+ (instancetype)nodeWithModel:(id<FTableCellModel>)model atIndex:(NSInteger)index {
    FTableSectionNode *node = [[[self class] alloc] init];
    node.model = model;
    node.index = index;
    return node;
}
@end


@interface FTableAdapter () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray<id<FTableCellModel>> *objs;//数据源
@property (nonatomic,strong) NSMutableArray<FTableSectionNode *> *scns;//若是以分组来展示

@property (nonatomic) BOOL supportSection;//支持section说明，主要是性能考虑，以此标签表示
@property (nonatomic) BOOL operating;//操作中表示

//section支持
- (FTableSectionNode *)sectionNodeOfIndex:(NSUInteger)index;//取index所在的section
- (FTableSectionNode *)sectionNodeOfSection:(NSUInteger)section;//取section位置的sectionNode
- (NSUInteger)sectionOfIndex:(NSUInteger)index;//取index所在的section位置

- (NSUInteger)indexOfIndexPath:(NSIndexPath *)indexPath;
- (id<FTableCellModel>)modelOfIndexPath:(NSIndexPath *)indexPath;
- (id<FTableCellModel>)modelAtSection:(NSUInteger)section;

- (BOOL)checkIsSectionCellModel:(id<FTableCellModel>)cellModel;

@end

@implementation FTableAdapter

- (instancetype)init {
    return [self initWithSectionStyle:NO];
}

- (instancetype)initWithSectionStyle:(BOOL)supportSection {
    self = [super init];
    if (self) {
        _objs = [[NSMutableArray alloc] init];
        _scns = [[NSMutableArray alloc] init];
        _supportSection = supportSection;
        _animation = UITableViewRowAnimationFade;
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView {
    if (_tableView == tableView) {
        return;
    }
    
    if (_tableView != nil) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
    tableView.delegate = self;
    tableView.dataSource = self;
    
    _tableView = tableView;
    [_tableView reloadData];
}

- (void)refreash {[_tableView reloadData];}

- (NSUInteger)count {
    if (_supportSection) {
        FTableSectionNode *node = [_scns lastObject];
        if (node == nil) {
            return 0;
        }
        return node.index + 1 + [node.objs count];
    } else {
        return [_objs count];
    }
}

- (NSArray<id<FTableCellModel> > *)models {
    if (_supportSection) {
        NSMutableArray *array = [NSMutableArray array];
        [_scns enumerateObjectsUsingBlock:^(FTableSectionNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.model) {
                [array addObject:obj.model];
            }
            
            [obj.objs enumerateObjectsUsingBlock:^(id<FTableCellModel>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [array addObject:obj];
            }];
        }];
        return array;
    } else {
        return [NSArray arrayWithArray:_objs];
    }
}

- (id<FTableCellModel>)modelAtIndex:(NSUInteger)index {
    if (_supportSection) {
        if (index > [self count]) {
            return nil;
        }
        FTableSectionNode *node = [self sectionNodeOfIndex:index];
        if (node.index == index) {
            return node.model;
        } else {
            NSInteger idx = ((NSInteger)index - node.index - 1);//涉及到位置计算
            if (idx >= 0 && idx < [node.objs count]) {
                return [node.objs objectAtIndex:idx];
            }
            return nil;
        }
    } else {
        if (index >= [_objs count]) {
            return nil;
        }
        return [_objs objectAtIndex:index];
    }
}

- (NSUInteger)indexOfModel:(id<FTableCellModel>)model {
    if (model == nil) {
        return NSNotFound;
    }
    if (_supportSection) {
        for (NSInteger idx = 0; idx < [_scns count]; idx++) {
            FTableSectionNode *node = [_scns objectAtIndex:0];
            if ([model isEqual:node.model]) {
                return node.index;
            }
            
            if ([node.objs count] > 0) {
                NSUInteger i = [node.objs indexOfObject:model];
                if (i != NSNotFound) {
                    return i;
                }
            }
        }
        return NSNotFound;
    } else {
        return [_objs indexOfObject:model];
    }
}

- (void)setModels:(NSArray<id<FTableCellModel> > *)models {
    if (models != nil) {
        //遍历section
        if (_supportSection) {
            [_scns removeAllObjects];
            FTableSectionNode *lastNode = nil;
            for (NSUInteger idx = 0; idx < [models count]; idx++) {
                id<FTableCellModel> obj = [models objectAtIndex:idx];
                
                if ([self checkIsSectionCellModel:obj]) {
                    lastNode = [FTableSectionNode nodeWithModel:obj atIndex:idx];
                    [_scns addObject:lastNode];
                    continue;
                }
                
                if (lastNode == nil && idx == 0) {
                    lastNode = [FTableSectionNode nodeWithModel:nil atIndex:-1];
                    [_scns addObject:lastNode];
                }
                
                if (lastNode != nil) {
                    [lastNode.objs addObject:obj];
                }
            }
        } else {
             [_objs setArray:models];
        }
        
        //需要改进
        [_tableView reloadData];
        
        _operating = NO;
    }
}

- (void)appendModels:(NSArray<id<FTableCellModel> > *)models {
    if (models == nil || [models count] == 0) {
        return;
    }
    
    [self insertDatas:models atIndex:[self count]];
}

- (void)appendModel:(id<FTableCellModel>)model {
    if (model == nil) {
        return;
    }
    
    [self insertDatas:@[model] atIndex:[self count]];
}

- (void)insertModel:(id<FTableCellModel>)model atIndex:(NSUInteger)index {
    if (model == nil) {
        return;
    }
    
    NSUInteger idx = index;
    if (index >= [self count]) {
        idx = [self count];
    }
    
    [self insertDatas:@[model] atIndex:idx];
}

- (void)insertModels:(NSArray<id<FTableCellModel> > *)models atIndex:(NSUInteger)index {
    if (models == nil || [models count] == 0) {
        return;
    }
    
    NSUInteger idx = index;
    if (index >= [self count]) {
        idx = [self count];
    }
    
    [self insertDatas:models atIndex:idx];
}

/**
 *  更新对应位置的数据
 *
 *  @param model 可以传入空
 *  @param index 对应位置数据更新
 */
- (void)updateModel:(id<FTableCellModel>)model atIndex:(NSUInteger)index {
    if (index >= [self count]) {
        return;
    }
    
    id<FTableCellModel> md = model;
    if (md == nil) {
        md = [self modelAtIndex:index];
    }
    
    [self updateDatas:@[md] atIndexs:[NSIndexSet indexSetWithIndex:index]];
}

- (void)updateModelsAtIndexs:(NSIndexSet *)indexs {
    if ([indexs count] == 0) {
        return;
    }
    @autoreleasepool {
        NSMutableArray *objs = [NSMutableArray array];
        NSMutableIndexSet *idxs = [NSMutableIndexSet indexSet];
        NSUInteger count = [self count];
        
        NSUInteger idx = [indexs firstIndex];
        while (idx != NSNotFound) {
            if (idx >= count) {
                break;//无需继续遍历，超出边界
            } else {
                [idxs addIndex:idx];
                id<FTableCellModel> md = [self modelAtIndex:idx];
                [objs addObject:md];
            }
            idx = [indexs indexGreaterThanIndex:idx];//升序
        }
        [self updateDatas:objs atIndexs:idxs];
    }
}
- (void)updateModelsInRange:(NSRange)range {
    if (range.length == 0 || range.location >= [self count]) {
        return;
    }
    @autoreleasepool {
        NSMutableArray *objs = [NSMutableArray array];
        NSMutableIndexSet *idxs = [NSMutableIndexSet indexSet];
        NSUInteger count = [self count];
        for (NSUInteger idx = 0; idx < range.length; idx++) {
            if ((idx + range.location) >= count) {
                break;//无需继续遍历，超出边界
            }
            [idxs addIndex:(idx + range.location)];
            id<FTableCellModel> md = [self modelAtIndex:(idx + range.location)];
            [objs addObject:md];
        }
        
        [self updateDatas:objs atIndexs:idxs];
    }
}

- (void)deleteModel:(id<FTableCellModel>)model {
    NSUInteger idx = [self indexOfModel:model];
    
    if (idx >= [self count]) {
        return;
    }
    
    [self deleteDatasAtIndexs:[NSIndexSet indexSetWithIndex:idx]];
}

- (void)deleteModelAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        return;
    }
    
    [self deleteDatasAtIndexs:[NSIndexSet indexSetWithIndex:index]];
}

- (void)deleteModelsInRange:(NSRange)range {
    if (range.location >= [self count] || range.length == 0) {
        return;
    }
    
    NSUInteger count = [self count];
    NSMutableIndexSet *idxs = [NSMutableIndexSet indexSet];
    for (NSUInteger idx = 0; idx < range.length; idx++) {
        NSUInteger t_idx = (idx + range.location);
        if (t_idx >= count) {
            break;
        }
        [idxs addIndex:t_idx];
    }
    
    [self deleteDatasAtIndexs:idxs];
}

- (void)deleteModelsAtIndexs:(NSIndexSet *)indexs {
    NSMutableIndexSet *idxs = [NSMutableIndexSet indexSet];
    NSUInteger count = [self count];
    
    NSUInteger idx = [indexs firstIndex];
    while (idx != NSNotFound) {
        if (idx >= count) {
            break;//无需继续遍历，超出边界
        } else {
            [idxs addIndex:idx];
        }
        
        idx = [indexs indexGreaterThanIndex:idx];//升序
    }
    
    [self deleteDatasAtIndexs:idxs];
}

//////////////////////////////////////////////////////////////////////////////////
// 具体实现
//////////////////////////////////////////////////////////////////////////////////
/**
 *  新增数据
 *
 *  @param indexPaths  对应的位置新增，实际位置并不取决于它
 */
- (void)insertDatas:(NSArray<id<FTableCellModel> > *)datas atIndex:(NSUInteger)index {
    
    if ([datas count] == 0) {
        return ;
    }

    if (_operating) {
        NSLog(@"fetctController:%p 忽略插入！说明此时数据源并没有稳定",self);
        return ;
    }
    _operating = YES;
  
    [self ftable_dataWillChange];
    
    if (_supportSection) {
        
        //1、寻找被插入的section
        FTableSectionNode *first_change_node = [self sectionNodeOfIndex:index];
        
        //2、没找到，则表明源数据还是空的情况，那么就先构建一个，调用插入
        NSUInteger first_change_section = 0;
        if (first_change_node == nil) {
            NSLog(@"第一次插入第一个Section");
            first_change_node = [FTableSectionNode nodeWithModel:nil atIndex:-1];
            [_scns addObject:first_change_node];
            [self ftable_dataDidChangeSection:first_change_node.model atIndex:0 forChangeType:FTableChangeInsert];
        } else {
            first_change_section = [_scns indexOfObject:first_change_node];
        }
        
        //3、找到section内插入点，并记录下插入点后面的对象
        NSUInteger section_insert_begin = first_change_section;
        NSRange back_models_range = NSMakeRange(0, 0);
        NSArray<id<FTableCellModel>> * back_models = nil;
        BOOL back_models_need_delete = NO;
        if (index == first_change_node.index) {//显然，正好是section节点上，说明插入位置是前一个section
            if (first_change_section > 0) {
                first_change_section -= 1;
                first_change_node = [_scns objectAtIndex:first_change_section];
            }
            NSLog(@"插入的位置真好是当前节点上%ld",index);
        } else if ((NSInteger)index > first_change_node.index && index < (first_change_node.index + 1 + [first_change_node.objs count])) {
            section_insert_begin += 1;//插入点在first_change_section后面
            
            NSUInteger loc = (NSInteger)index - (first_change_node.index + 1);
            NSUInteger len = [first_change_node.objs count] - loc;
            back_models_range = NSMakeRange(loc, len);
            back_models = [first_change_node.objs subarrayWithRange:back_models_range];
            back_models_need_delete = YES;
        } else {//说明是尾追
            section_insert_begin += 1;
            NSLog(@"插入的位置说明是尾追%ld",index);
        }
        
        //4、开始遍历插入数据源
        FTableSectionNode *lastNode = first_change_node;
        NSUInteger current_section = first_change_section;
        for (NSUInteger idx = 0; idx < [datas count]; idx++) {
            id<FTableCellModel> obj = [datas objectAtIndex:idx];
            
            //5、遍历中出现有section的情况，看看是不是第一个位置，第一个位置就直接替换，其他位置则插入
            if ([self checkIsSectionCellModel:obj]) {
                current_section = section_insert_begin;//记住当前section位置
                //第一个位置正好是空缺的时
                if (lastNode.model == nil && (index + idx) == 0) {
                    lastNode.model = obj;
                    lastNode.index = 0;
                    //多调用一次update，应该没啥事
                    [self ftable_dataDidChangeSection:lastNode.model atIndex:0 forChangeType:FTableChangeInsert];
                } else {//不是第一个，则在insert_begin位置上插入一个section即可
                    lastNode = [FTableSectionNode nodeWithModel:obj atIndex:(index + idx)];
                    [_scns insertObject:lastNode atIndex:section_insert_begin];//插在其后面即可
                    [self ftable_dataDidChangeSection:lastNode.model atIndex:section_insert_begin forChangeType:FTableChangeInsert];
                }
                section_insert_begin++;//后面在遇到section，插入位置往后移
                
                //因为插入了section，此时原来若存在插入点后的对象，统统需要从first_change_node中移除
                if (back_models_need_delete && back_models_range.length > 0) {
                    
                    //section 提示刷新一下在操作数据
                    [self ftable_dataDidChangeSection:first_change_node.model atIndex:first_change_section forChangeType:FTableChangeUpdate];
                    for (NSUInteger i = back_models_range.location; i < back_models_range.location + back_models_range.length; i++) {
                        id<FTableCellModel> obj = [first_change_node.objs objectAtIndex:i];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:first_change_section];
                        [self ftable_dataDidChangeObject:obj atIndexPath:indexPath forChangeType:FTableChangeDelete newIndexPath:nil];
                    }
                    
                    [first_change_node.objs removeObjectsInRange:back_models_range];//删掉全部数据
                    
                    //清理
                    back_models_need_delete = NO;
//                    back_models_range.length = 0;
//                    back_models_range.location = 0;
                }
                continue;
            }
            
            //通过位置取section
            if (lastNode == nil) {
                NSLog(@"次数不应该走进来，若走进来需要debug看看");
            }
            
            //6、将数据插入到当前section中
            NSInteger row = (NSInteger)(index + idx) - lastNode.index - 1;
            [lastNode.objs insertObject:obj atIndex:row];
            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:row inSection:current_section];
            [self ftable_dataDidChangeObject:obj atIndexPath:newIndex forChangeType:FTableChangeInsert newIndexPath:newIndex];
        }
        
        //7、之前截断的model插入到最后
        if (lastNode != nil && lastNode != first_change_node && [back_models count] > 0) {
            for (NSUInteger i = 0; i < [back_models count]; i++) {
                id<FTableCellModel> obj = [back_models objectAtIndex:i];
                NSInteger row = [lastNode.objs count];
                [lastNode.objs addObject:obj];
                NSIndexPath *newIndex = [NSIndexPath indexPathForRow:row inSection:current_section];
                [self ftable_dataDidChangeObject:obj atIndexPath:newIndex forChangeType:FTableChangeInsert newIndexPath:newIndex];
            }
        }
        
        //8、更新后面所有的section node的index
        for (NSInteger i = current_section + 1; i < [_scns count]; i++) {
            FTableSectionNode *node = [_scns objectAtIndex:i];
            node.index += [datas count];
        }
       
    } else {
        [datas enumerateObjectsUsingBlock:^(id<FTableCellModel> model, NSUInteger idx, BOOL * stop) {
            [_objs insertObject:model atIndex:(index + idx)];
            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:(index + idx) inSection:0];
            [self ftable_dataDidChangeObject:model atIndexPath:newIndex forChangeType:FTableChangeInsert newIndexPath:newIndex];
        }];
    }
    
    [self ftable_dataDidChange];
    
    _operating = NO;
}

/**
 *  删除对应位置的数据
 *
 *  @param indexPaths NSIndexPaths数据所在位置
 */
- (void)deleteDatasAtIndexs:(NSIndexSet *)indexs {
    if ([indexs count] == 0) {
        return ;
    }
    
    if (_operating) {
        NSLog(@"fetctController:%p 忽略删除！说明此时数据源并没有稳定",self);
        return ;
    }
    _operating = YES;
    
    [self ftable_dataWillChange];
    
    if (_supportSection) {
        NSUInteger idx = [indexs lastIndex];
        while (idx != NSNotFound) {
            //取当前要修改的section
            FTableSectionNode *node = [self sectionNodeOfIndex:idx];
            NSInteger section = [_scns indexOfObject:node];
            
            //之前此处是一个节点，直接删除节点
            if (node.index == idx) {
                if (idx == 0) {//如果开始是第一个节点，则删除其数据
                    node.model = nil;
                    node.index = -1;
                    
                    [self ftable_dataDidChangeSection:node.model atIndex:section forChangeType:FTableChangeUpdate];
                } else {
                    
                    if (section == 0) {
                        NSLog(@"异常流check,此时不应该进入此分支，检查上面的逻辑");
                    }
                    
                    //删除老的section
                    [self ftable_dataDidChangeSection:node.model atIndex:section forChangeType:FTableChangeDelete];
                    
                    //将数据转移
                    FTableSectionNode *pre_node = [_scns objectAtIndex:section - 1];
                    [self ftable_dataDidChangeSection:pre_node.model atIndex:section - 1 forChangeType:FTableChangeUpdate];
                    
                    [node.objs enumerateObjectsUsingBlock:^(id<FTableCellModel>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSUInteger count = [pre_node.objs count];
                        [pre_node.objs addObject:obj];
                        NSIndexPath *newIndex = [NSIndexPath indexPathForRow:count inSection:section - 1];
                        [self ftable_dataDidChangeObject:obj atIndexPath:newIndex forChangeType:FTableChangeInsert newIndexPath:newIndex];
                    }];
                }
            }
            //查找节点修改点
            else if ((NSInteger)idx > node.index && idx < (node.index + 1 + [node.objs count])) {
                NSUInteger del_idx = (NSInteger)idx - (node.index + 1);
                //非常简单，直接删除即可
                [self ftable_dataDidChangeSection:node.model atIndex:section forChangeType:FTableChangeUpdate];
                id<FTableCellModel> del_model = [node.objs objectAtIndex:del_idx];
                
                NSIndexPath *path = [NSIndexPath indexPathForRow:del_idx inSection:section];
                [self ftable_dataDidChangeObject:del_model atIndexPath:path forChangeType:FTableChangeDelete newIndexPath:nil];
                [node.objs removeObjectAtIndex:del_idx];
                
                //接下来修改后面section的值
                for (NSUInteger s_idx = section + 1; s_idx < [_scns count]; s_idx++) {
                    FTableSectionNode *node = [_scns objectAtIndex:s_idx];
                    node.index -= 1;
                }
            }
            else {
                NSLog(@"删除不应该进入到此逻辑，检查前面条件限制%ld",idx);
            }
        
            
            
            
            idx = [indexs indexLessThanIndex:idx];//从大到小删比较安全
        }
    } else {

        NSUInteger idx = [indexs lastIndex];
        while (idx != NSNotFound) {
            id<FTableCellModel> obj = [_objs objectAtIndex:idx];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [self ftable_dataDidChangeObject:obj atIndexPath:indexPath forChangeType:FTableChangeDelete newIndexPath:nil];
            
            idx = [indexs indexLessThanIndex:idx];//从大到小删比较安全
        }
        
        [_objs removeObjectsAtIndexes:indexs];
        
    }
    
    [self ftable_dataDidChange];
    
    _operating = NO;
}


/**
 *  更新位置的数据，如果对应位置数据没有确实有变化，可能重新排序
 *
 *  @param indexPaths 位置
 */
- (void)updateDatas:(NSArray<id<FTableCellModel> > *)datas atIndexs:(NSIndexSet *)indexs {
    
    if ([indexs count] != [datas count] || [indexs count] == 0) {
        return ;
    }
    
    if (_operating) {
        NSLog(@"fetctController:%p 更新！说明此时数据源并没有稳定",self);
        return ;
    }
    _operating = YES;
    
    
    [self ftable_dataWillChange];
    
    if (_supportSection) {
        NSUInteger idx = [indexs firstIndex];
        NSUInteger d_idx = 0;
        while (idx != NSNotFound) {
            
            //取出新数据
            id<FTableCellModel> new_model = [datas objectAtIndex:d_idx];
            
            //取到修改的section
            FTableSectionNode *node = [self sectionNodeOfIndex:idx];
            NSInteger section = [_scns indexOfObject:node];
            
            //如果节点正好是model，那就直接替换
            if (node.index == (NSInteger)idx) {
                //还要看看新数据是否为section
                if ([self checkIsSectionCellModel:new_model]) {
                    node.model = new_model;
                    [self ftable_dataDidChangeSection:new_model atIndex:section forChangeType:FTableChangeUpdate];
                } else {//从不同节点变成section，比较麻烦
                    
                    if (idx == 0) {//如果是第一个，也比较好办
                        node.model = nil;
                        node.index = -1;
                        [self ftable_dataDidChangeSection:nil atIndex:0 forChangeType:FTableChangeUpdate];
                        
                        //插入第一个元素
                        [node.objs insertObject:new_model atIndex:0];
                        NSIndexPath *newIndex = [NSIndexPath indexPathForRow:idx inSection:0];
                        [self ftable_dataDidChangeObject:new_model atIndexPath:newIndex forChangeType:FTableChangeInsert newIndexPath:newIndex];
                        
                    } else {//不是第一个，需要拆除原来section，并把数据给上一个section
                        if (section == 0) {
                            NSLog(@"错误逻辑校验，此时section不应该为0");
                        }
                        //删除原sction
                        [self ftable_dataDidChangeSection:node.model atIndex:section forChangeType:FTableChangeDelete];
                        [_scns removeObjectAtIndex:section];
                        
                        //前一个更新
                        FTableSectionNode *pre_node = [_scns objectAtIndex:section - 1];
                        [self ftable_dataDidChangeSection:pre_node.model atIndex:(section - 1) forChangeType:FTableChangeUpdate];
                        
                        //前一个开始插入数据
                        NSInteger row = [pre_node.objs count];
                        [pre_node.objs addObject:new_model];
                        NSIndexPath *newIndex = [NSIndexPath indexPathForRow:row inSection:(section - 1)];
                        [self ftable_dataDidChangeObject:new_model atIndexPath:newIndex forChangeType:FTableChangeInsert newIndexPath:newIndex];
                        
                        row += 1;
                        [node.objs enumerateObjectsUsingBlock:^(id<FTableCellModel>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [pre_node.objs addObject:obj];
                            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:(row + idx) inSection:(section - 1)];
                            [self ftable_dataDidChangeObject:new_model atIndexPath:newIndex forChangeType:FTableChangeInsert newIndexPath:newIndex];
                        }];
                    }
                }
            }
            //查找节点修改点
            else if ((NSInteger)idx > node.index && idx < (node.index + 1 + [node.objs count])) {
                NSUInteger loc = (NSInteger)idx - (node.index + 1);
                NSUInteger len = [node.objs count] - loc;
                NSRange back_models_range = NSMakeRange(loc, len);
                NSArray<id<FTableCellModel>> * back_models = [node.objs subarrayWithRange:back_models_range];
                
                //若更新成节点了，此时则需要将数据分割
                if ([self checkIsSectionCellModel:new_model]) {
                    //检查一下是不是第一个
                    if (idx == 0) {
                        if (node.index != -1) {
                            NSLog(@"异常流check,不应该进入，此时只可能是-1");
                        }
                        
                        node.model = new_model;
                        node.index = 0;
                        
                        //删除原来位置的对象
                        id<FTableCellModel> oldObj = [node.objs objectAtIndex:0];
                        [node.objs removeObjectAtIndex:0];
                        NSIndexPath *newIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self ftable_dataDidChangeObject:oldObj atIndexPath:newIndex forChangeType:FTableChangeDelete newIndexPath:nil];
                        
                        //删完数据在更新，否则没意义
                        [self ftable_dataDidChangeSection:new_model atIndex:0 forChangeType:FTableChangeUpdate];
                    } else {
                        [self ftable_dataDidChangeSection:node.model atIndex:section forChangeType:FTableChangeUpdate];
                        
                        //删除剩余部分
                        for (NSUInteger i = back_models_range.location; i < back_models_range.location + back_models_range.length; i++) {
                            id<FTableCellModel> obj = [node.objs objectAtIndex:i];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
                            [self ftable_dataDidChangeObject:obj atIndexPath:indexPath forChangeType:FTableChangeDelete newIndexPath:nil];
                        }
                        
                        [node.objs removeObjectsInRange:back_models_range];//删掉全部数据
                        
                        //插入新的section
                        FTableSectionNode *new_node = [FTableSectionNode nodeWithModel:new_model atIndex:idx];
                        [_scns insertObject:new_node atIndex:section + 1];
                        [self ftable_dataDidChangeSection:new_node.model atIndex:section + 1 forChangeType:FTableChangeInsert];
                        
                        //删掉第一位
                        for (NSInteger i = 1; i < [back_models count]; i++) {
                            id<FTableCellModel> obj = [back_models objectAtIndex:i];
                            [new_node.objs addObject:obj];
                            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:(i-1) inSection:section + 1];
                            [self ftable_dataDidChangeObject:obj atIndexPath:newIndex forChangeType:FTableChangeInsert newIndexPath:newIndex];
                        }
                    }
                } else {
                    [self ftable_dataDidChangeSection:node.model atIndex:section forChangeType:FTableChangeUpdate];
                    
                    [node.objs replaceObjectAtIndex:loc withObject:new_model];
                    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:loc inSection:section];
                    [self ftable_dataDidChangeObject:new_model atIndexPath:newIndex forChangeType:FTableChangeUpdate newIndexPath:newIndex];
                }
            } else {//
                NSLog(@"更新不应该进入到此逻辑，检查前面条件限制%ld",idx);
            }
            
            //下一个，从小到大遍历
            idx = [indexs indexGreaterThanIndex:idx];
            d_idx++;
        }

    } else {
        NSUInteger idx = [indexs firstIndex];
        NSUInteger d_idx = 0;
        while (idx != NSNotFound) {
            id<FTableCellModel> model = [datas objectAtIndex:d_idx];
            [_objs replaceObjectAtIndex:idx withObject:model];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [self ftable_dataDidChangeObject:model atIndexPath:indexPath forChangeType:FTableChangeUpdate newIndexPath:indexPath];
            
            //下一个，从小到大遍历
            idx = [indexs indexGreaterThanIndex:idx];
            d_idx++;
        }
    }
    
    [self ftable_dataDidChange];
    
    _operating = NO;
}

//////////////////////////////////////////////////////////////////////////
- (void)ftable_dataDidChangeSection:(id<FTableCellModel>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(FTableChangeType)type {
    if (_tableView == nil) {
        return ;
    }
    
    switch(type) {
        case FTableChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"%p section FTableChangeInsert %ld",self,sectionIndex);
            break;
            
        case FTableChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"%p section FTableChangeDelete %ld",self,sectionIndex);
            break;
        case FTableChangeUpdate:
            NSLog(@"%p section FTableChangeUpdate %ld",self,sectionIndex);
            break;
        default:break;
    }
}

- (void)ftable_dataDidChangeObject:(id<FTableCellModel>)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(FTableChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (_tableView == nil) {
        return ;
    }
    
    switch (type) {
        case FTableChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:self.animation];
            NSLog(@"%p row FTableChangeInsert (%ld,%ld)",self,indexPath.section,indexPath.row);
        }
            break;
        case FTableChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.animation];
            NSLog(@"%p row FTableChangeDelete (%ld,%ld)",self,indexPath.section,indexPath.row);
        }
            break;
        case FTableChangeMove:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.animation];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.animation];
        }
            break;
        case FTableChangeUpdate:
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell ftable_onDisplay:object atIndexPath:indexPath inTable:self.tableView];
            NSLog(@"%p row FTableChangeUpdate (%ld,%ld)",self,indexPath.section,indexPath.row);
        }
            break;
        default:
            break;
    }
}

- (void)ftable_dataWillChange {
    [self.tableView beginUpdates];
}

- (void)ftable_dataDidChange {
    [self.tableView endUpdates];
}

//////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.tableView) {
        return 0;
    }
    
    if (_supportSection) {
        return [_scns count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return 0;
    }
    
    if (_supportSection) {
        FTableSectionNode *node = [self sectionNodeOfSection:section];
        return [node.objs count];
    }
    
    return [_objs count];
}

- (id<FTableCellProtected>)loadCellWithTableView:(UITableView *)tableView cellModel:(id<FTableCellModel>)cellModel {
    
    BOOL isSectionHeader = false;
    if ([cellModel respondsToSelector:@selector(ftable_isSectionHeader)]) {
        isSectionHeader = [cellModel ftable_isSectionHeader];
    }
    
    //优先从nib加载
    NSString *nibName = nil;
    Class clazz = nil;
    if ([cellModel respondsToSelector:@selector(ftable_displayCellNibName)] > 0) {
        nibName = [cellModel ftable_displayCellNibName];
    }
    if ([cellModel respondsToSelector:@selector(ftable_displayCellClass)]) {
        clazz = [cellModel ftable_displayCellClass];
    }
    
    
    NSString *cellId = @"ftablecell";
    if ([nibName length] > 0) {
        if (isSectionHeader) {
            cellId = [NSString stringWithFormat:@"ftable-section-nib-%@",nibName];
        } else {
            cellId = [NSString stringWithFormat:@"ftable-nib%@",nibName];
        }
    } else if (clazz) {
        if (isSectionHeader) {
            cellId = [NSString stringWithFormat:@"ftable-section-cls-%@",NSStringFromClass(clazz)];
        } else {
            cellId = [NSString stringWithFormat:@"ftable-cls-%@",NSStringFromClass(clazz)];
        }
    }
    
    //先取复用队列
    id<FTableCellProtected> cell = nil;
    if (isSectionHeader) {//投机取巧，实际UITableViewHeaderFooterView包含接口UITableViewCell都包含
        cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellId];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    
    if (cell) {
        return cell;
    }
    
    
    if ([nibName length] > 0) {
        NSArray *views =  [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
        cell = [views objectAtIndex:0];
    }
    if (cell) {
        return cell;
    }
    
    //自己创建
    if (clazz) {
        cell = [[clazz alloc] initWithReuseIdentifier:@"cell"];
    }
    if (cell) {
        NSAssert([cell conformsToProtocol:@protocol(FTableCellProtected)], @"请确保FTableModel用于展示view遵循FTableCellProtected协议");
        return cell;
    }
    
    //默认返回
    if (!isSectionHeader) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    id<FTableCellModel> model = [self modelOfIndexPath:indexPath];
    
    id<FTableCellProtected> cell = [self loadCellWithTableView:tableView cellModel:model];
    
    [cell ftable_onDisplay:model atIndexPath:indexPath inTable:tableView];
    
    return (UITableViewCell *)cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return 44;
    }
    
    id<FTableCellModel> model = [self modelOfIndexPath:indexPath];
    CGFloat height = 44.0f;
    if ([model respondsToSelector:@selector(ftable_cellHeight)]) {
        height = [model ftable_cellHeight];
    }
    
    if (height <= 0) {
        height = tableView.rowHeight == 0 ? 44 : tableView.rowHeight;
    }
    return height;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return UITableViewCellEditingStyleNone;
    }
    
    //仅仅支持删除
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ftable_adapter:tableView:commitEditingStyle:forRowAtIndex:)]) {
        @try {
            [self.delegate ftable_adapter:self tableView:tableView commitEditingStyle:editingStyle forRowAtIndex:[self indexOfIndexPath:indexPath]];
        } @catch (NSException *exception) {
            NSLog(@"0x2:%@",exception);
        } @finally {
            //
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return nil;
    }
    
    id<FTableCellModel> model = [self modelOfIndexPath:indexPath];
    if ([model respondsToSelector:@selector(ftable_cellDeleteConfirmationButtonTitle)]) {
        return [model ftable_cellDeleteConfirmationButtonTitle];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return NO;
    }
    
    id<FTableCellModel> model = [self modelOfIndexPath:indexPath];
    if ([model respondsToSelector:@selector(ftable_cellDeleteConfirmationButtonTitle)]) {
        return [model ftable_cellDeleteConfirmationButtonTitle] > 0;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<FTableCellModel> model = [self modelOfIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(ftable_adapter:tableView:didSelectModel:atIndex:)]) {
        @try {
            [self.delegate ftable_adapter:self tableView:tableView didSelectModel:model atIndex:[self indexOfIndexPath:indexPath]];
            NSLog(@"did selected (%@,%@)",@(indexPath.section),@(indexPath.row));
        } @catch (NSException *exception) {
            NSLog(@"0x3:%@",exception);
        } @finally {
            //
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
// section header 支持
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)checkIsSectionCellModel:(id<FTableCellModel>)cellModel {
    if (!_supportSection) {
        return NO;
    }
    
    BOOL isSection = false;
    if ([cellModel respondsToSelector:@selector(ftable_isSectionHeader)]) {
        isSection = [cellModel ftable_isSectionHeader];
    }
    return isSection;
}

- (FTableSectionNode *)sectionNodeOfIndex:(NSUInteger)index {
    if (!_supportSection) {
        return nil;
    }
    for (NSUInteger idx = 0; idx < [_scns count]; idx++) {
        FTableSectionNode *node = [_scns objectAtIndex:idx];
        if ((NSInteger)index >= node.index && (NSInteger)index < (node.index + 1 + [node.objs count])) {
            return node;
        }
    }
    return [_scns lastObject];
}

- (FTableSectionNode *)sectionNodeOfSection:(NSUInteger)section {
    if (!_supportSection) {
        return nil;
    }
    if (section >= [_scns count]) {
        return nil;
    }
    return [_scns objectAtIndex:section];
}

- (NSUInteger)sectionOfIndex:(NSUInteger)index {
    if (!_supportSection) {
        return 0;
    }
    NSUInteger idx = 0;
    for (; idx < [_scns count]; idx++) {
        FTableSectionNode *node = [_scns objectAtIndex:idx];
        if ((NSInteger)index >= node.index && index < (node.index + 1 + [node.objs count])) {
            return idx;
        }
    }
    return idx > 0 ? idx - 1 : idx;//最后一个
}

- (NSUInteger)indexOfIndexPath:(NSIndexPath *)indexPath {
    if (!_supportSection) {
        if (indexPath.section != 0) {
            return NSNotFound;
        }
        return indexPath.row;
    }
    
    if (indexPath.section < 0 || indexPath.section >= [_scns count]) {
        return NSNotFound;
    }
    
    FTableSectionNode *node = [_scns objectAtIndex:indexPath.section];
    return node.index + 1 + indexPath.row;
}

- (id<FTableCellModel>)modelOfIndexPath:(NSIndexPath *)indexPath {
    if (!_supportSection) {
        if (indexPath.section != 0) {
            return nil;
        }
        if (indexPath.row < 0 || indexPath.row >= [_objs count]) {
            return nil;
        }
        return [_objs objectAtIndex:indexPath.row];
    }
    
    if (indexPath.section < 0 || indexPath.section >= [_scns count]) {
        return nil;
    }
    
    FTableSectionNode *node = [_scns objectAtIndex:indexPath.section];
    if (indexPath.row < 0 || indexPath.row >= [node.objs count]) {
        return nil;
    }
    return [node.objs objectAtIndex:indexPath.row];
}

- (id<FTableCellModel>)modelAtSection:(NSUInteger)section {
    if (!_supportSection) {
        return nil;
    }
    
    if ([_scns count] == 0) {
        return nil;
    }
    
    if (section >= [_scns count]) {
        return nil;
    }
    
    return [[_scns objectAtIndex:section] model];
}


//////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return 0.0f;
    }
    
    if (!_supportSection) {
        return 0.0f;
    }
    
    id<FTableCellModel> model = [self modelAtSection:section];
    CGFloat height = 0.0f;
    if ([model respondsToSelector:@selector(ftable_cellHeight)]) {
        height = [model ftable_cellHeight];
    }
    
    if (height <= 0) {
        height = tableView.sectionHeaderHeight;
    }
    return height;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //- (nullable __kindof UITableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifier:(NSString *)identifier NS_AVAILABLE_IOS(6_0);  // like dequeueReusableCellWithIdentifier:, but for headers/footers
    if (tableView != self.tableView) {
        return nil;
    }
    
    if (!_supportSection) {
        return nil;
    }
    
    id<FTableCellModel> model = [self modelAtSection:section];
    
    id<FTableCellProtected> cell = [self loadCellWithTableView:tableView cellModel:model];
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:-1 inSection:section];
    [cell ftable_onDisplay:model atIndexPath:index inTable:tableView];
    
//    [(UITableViewHeaderFooterView *)cell setFrame:CGRectZero];
    
    return (UITableViewHeaderFooterView *)cell;
}

@end

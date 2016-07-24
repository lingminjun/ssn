//
//  DMTableAdapterController.m
//  ssn
//
//  Created by lingminjun on 16/7/18.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import "DMTableAdapterController.h"
#import "FTableAdapter.h"

@interface DMAdapterCell : UITableViewCell
@end

@interface DMAdapterCellModel : NSObject <FTableCellModel>
@property (nonatomic,strong) NSString *name;
@end

@implementation DMAdapterCellModel

- (Class<FTableCellProtected>)ftable_displayCellClass {
    return [DMAdapterCell class];
}

- (NSUInteger)ftable_cellHeight {
    return 60;
}

- (NSString *)ftable_cellDeleteConfirmationButtonTitle {
    return @"删删";
}

@end

@implementation DMAdapterCell

- (void)ftable_display:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView {
    self.textLabel.text = [(DMAdapterCellModel *)cellModel name];
}

@end

@interface DMAdapterSectionCell : UITableViewHeaderFooterView
@end

@interface DMAdapterSectionModel : NSObject <FTableCellModel>
@property (nonatomic,strong) NSString *name;
@end

@implementation DMAdapterSectionCell

- (void)ftable_display:(id<FTableCellModel>)cellModel atIndexPath:(NSIndexPath *)indexPath inTable:(UITableView *)tableView {
    self.textLabel.text = [(DMAdapterSectionModel *)cellModel name];
}

@end

@implementation DMAdapterSectionModel

- (BOOL)ftable_isSectionHeader {
    return YES;
}

- (Class<FTableCellProtected>)ftable_displayCellClass {
    return [DMAdapterSectionCell class];
}

- (NSUInteger)ftable_cellHeight {
    return 40;
}

@end


@interface DMTableAdapterController () <FTableAdapterDelegate>

@end


@implementation DMTableAdapterController {
    FTableAdapter *_dataper;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试Adapter";
    
    _dataper = [[FTableAdapter alloc] initWithSectionStyle:YES];
    
    for (int i = 0; i < 5; i++) {
        DMAdapterCellModel *model = [[DMAdapterCellModel alloc] init];
        model.name = [NSString stringWithFormat:@"test %d",i];
        [_dataper appendModel:model];
    }
    
    _dataper.tableView = self.tableView;
    _dataper.delegate = self;
    _dataper.animation = UITableViewRowAnimationNone;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DMAdapterSectionModel *model = [[DMAdapterSectionModel alloc] init];
        model.name = @"test section1";
        [_dataper insertModel:model atIndex:3];
        for (int i = 0; i < 5; i++) {
            DMAdapterCellModel *model = [[DMAdapterCellModel alloc] init];
            model.name = [NSString stringWithFormat:@"test 2%d",i];
            [_dataper insertModel:model atIndex:3];
        }
        
        for (int i = 0; i < 5; i++) {
            DMAdapterCellModel *model = [[DMAdapterCellModel alloc] init];
            model.name = [NSString stringWithFormat:@"utest 2%d",i];
            [_dataper insertModel:model atIndex:9];
        }
        
        for (int i = 0; i < 5; i++) {
            DMAdapterCellModel *model = [[DMAdapterCellModel alloc] init];
            model.name = [NSString stringWithFormat:@"test 22%d",i];
            [_dataper appendModel:model];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DMAdapterSectionModel *model = [[DMAdapterSectionModel alloc] init];
        model.name = @"test section2";
        [_dataper appendModel:model];
        for (int i = 0; i < 10; i++) {
            DMAdapterCellModel *model = [[DMAdapterCellModel alloc] init];
            model.name = [NSString stringWithFormat:@"test 3%d",i];
            [_dataper appendModel:model];
        }
    });
}

- (void)ftable_adapter:(FTableAdapter *)adapter tableView:(UITableView *)tableView didSelectModel:(id<FTableCellModel>)model atIndex:(NSUInteger)index {
    DMAdapterCellModel *cellModel = (DMAdapterCellModel *)model;
    if ([cellModel.name hasPrefix:@"test 2"]) {
        [_dataper deleteModel:cellModel];
    } else if ([cellModel.name hasPrefix:@"test 3"]) {
        DMAdapterCellModel *model = [[DMAdapterCellModel alloc] init];
        model.name = [NSString stringWithFormat:@"test 2%ld",index];
        [_dataper insertModel:model atIndex:(index - 5)];
    } else if ([cellModel.name hasPrefix:@"utest 21"]) {
        
        DMAdapterSectionModel *model = [[DMAdapterSectionModel alloc] init];
        model.name = [NSString stringWithFormat:@"update section first"];
        [_dataper updateModel:model atIndex:0];
    } else if ([cellModel.name hasPrefix:@"utest 2"]) {
        
        if ([[_dataper modelAtIndex:index - 1] isKindOfClass:[DMAdapterSectionModel class]]) {
            DMAdapterCellModel *model = [[DMAdapterCellModel alloc] init];
            model.name = [NSString stringWithFormat:@"update cell test 2%ld",index - 1];
            [_dataper updateModel:model atIndex:index - 1];
            
        } else {
            
            DMAdapterSectionModel *model = [[DMAdapterSectionModel alloc] init];
            model.name = [NSString stringWithFormat:@"update section test 2%ld",index];
            [_dataper updateModel:model atIndex:index];
        }
    } else if ([cellModel.name hasPrefix:@"update section test"]) {
        DMAdapterCellModel *model = [[DMAdapterCellModel alloc] init];
        model.name = [NSString stringWithFormat:@"update cell test 2%ld",index];
        [_dataper updateModel:model atIndex:index];
    }

    
}

- (void)ftable_adapter:(FTableAdapter *)adapter tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndex:(NSUInteger)index {
    [_dataper deleteModelAtIndex:index];
}

@end

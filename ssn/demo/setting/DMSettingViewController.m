//
//  DMSettingViewController.m
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMSettingViewController.h"
#import "SSNRouter.h"
#import "SSNToast.h"
#import "SSNListFetchController.h"
#import "UIViewController+SSNTableViewEasyConfigure.h"
#import "DMSettingCellItem.h"
#import "DMSectionCellItem.h"

@interface DMSettingViewController ()<SSNTableViewConfiguratorDelegate> {
    NSInteger flag;
}

@end

@implementation DMSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Setting";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];

    self.tableView.ssn_pullRefreshEnabled = YES;
    self.ssn_tableViewConfigurator.tableView = self.tableView;
//    self.ssn_tableViewConfigurator.isAutoEnabledLoadMore = NO;
//    self.ssn_tableViewConfigurator.listFetchController.isMandatorySorting = NO;
    
    flag = 0;
    
    //开始加载数据
    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (void)logout {
    [SSNToast showTarget:self progressLoadingAtGoldenSection:@"正在注销。。。"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self ssn_router] openURL:[NSURL URLWithString:@"app://login"]];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    static int i = 0;
    i++;
    flag = i;
    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 2;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellId = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
//    }
//    if (indexPath.row == 0) {
//        cell.textLabel.text = @"UIDic";
//    }
//    else {
//        cell.textLabel.text = @"UILayout";
//    }
//
//    return cell;
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    if (indexPath.row == 0) {
//        [self openRelativePath:@"../uidic" query:nil];
//    }
//    else {
//        [self openRelativePath:@"../layout" query:nil];
//    }
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath
*)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator controller:(SSNListFetchController *)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    NSMutableArray *ary = [NSMutableArray array];
    if (flag % 2 == 0) {
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UIDic"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"xxxxxxxx"]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"========="]];
        [ary addObject:[DMSectionCellItem item]];
        
        [ary addObject:[DMSettingCellItem itemWithTitle:@"===ddd==="]];
        [ary addObject:[DMSectionCellItem item]];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion(ary,[ary count],nil,YES);
    });
}

- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator tableView:(UITableView *)tableView didSelectModel:(DMSettingCellItem *)model atIndexPath:(NSIndexPath *)indexPath {
    if ([model.title isEqualToString:@"UIDic"]) {
        [self openRelativePath:@"../uidic" query:nil];
    }
    else if ([model.title isEqualToString:@"UILayout"]) {
        [self openRelativePath:@"../layout" query:nil];
    }
    else if ([model.title isEqualToString:@"xxxxxxxx"]) {
        [self.ssn_tableViewConfigurator.listFetchController updateDatasAtIndexPaths:@[indexPath] withContext:nil];
    }
    else if ([model.title isEqualToString:@"========="]) {
        [self.ssn_tableViewConfigurator.listFetchController insertDatasAtIndexPaths:@[indexPath] withContext:nil];
    }
    else {
        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        [self.ssn_tableViewConfigurator.listFetchController deleteDatasAtIndexPaths:@[indexPath,nextPath] withContext:nil];
    }
}

- (id<SSNCellModel>)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller insertDataWithIndexPath:(NSIndexPath *)indexPath context:(void *)context {
    return nil;
}

- (id<SSNCellModel>)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller updateDataWithOriginalData:(id<SSNCellModel>)model indexPath:(NSIndexPath *)indexPath context:(void *)context {
    DMSettingCellItem *item = (DMSettingCellItem *)model;
    if ([item.title isEqualToString:@"xxxxxxxx"]) {
        item.title = @"xxx===xxxx";
    }
    else {
        item.title = @"xxxxxxxx";
    }
    return item;
}

- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    [self.ssn_tableViewConfigurator.listFetchController deleteDatasAtIndexPaths:@[indexPath,nextPath] withContext:nil];
    
}
@end

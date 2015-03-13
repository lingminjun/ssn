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

@interface DMSettingViewController ()<SSNTableViewConfiguratorDelegate>

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
    self.ssn_tableViewConfigurator.isAutoEnabledLoadMore = YES;
    self.ssn_tableViewConfigurator.listFetchController.isMandatorySorting = NO;
    
    //开始加载数据
    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (void)logout {
    [SSNToast showTarget:self progressLoadingAtGoldenSection:@"正在注销。。。"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self ssn_router] openURL:[NSURL URLWithString:@"app://login"]];
    });
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
    static int i = 0;
    if (i%2 == 0) {
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
    }
    i++;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    else {
        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        [self.ssn_tableViewConfigurator.listFetchController deleteDatasAtIndexPaths:@[indexPath,nextPath]];
    }
}
@end

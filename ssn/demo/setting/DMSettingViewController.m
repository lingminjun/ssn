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
#import "SSNScrollEdgeView.h"
#import "SSNDefaultPullRefreshView.h"
#import "SSNDefaultLoadMoreView.h"
#import "SSNNavigationBarAnimator.h"
#import "SSNSafeKVO.h"
#import "DMSettingViewController+TOne.h"
#import "SSNBriefRSA.h"
#import "ssninteger.h"

@interface TTSameName : NSObject

@end

@implementation TTSameName


@end


@interface DMSettingViewController ()<SSNTableViewConfiguratorDelegate,SSNNavigationBarAnimatorDelegate> {
    NSInteger flag;
    SSNNavigationBarAnimator *animator;
    dispatch_queue_t  queue;
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
    
    [self test_function_one];
    
    flag = 0;

    self.title = @"Setting";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];

    self.tableView.ssn_pullRefreshEnabled = YES;//下拉刷新
//    self.tableView.ssn_loadMoreEnabled = YES;//上提更多
    
    self.ssn_tableViewConfigurator.tableView = self.tableView;
    
//    self.ssn_tableViewConfigurator.isAutoEnabledLoadMore = YES;//自动控制是否还有更多
    
    animator = [[SSNNavigationBarAnimator alloc] init];
    [animator setTargetView:self.tableView];
    animator.delegate = self;
    
    //开始加载数据
    [self.ssn_tableViewConfigurator.listFetchController loadData];
    
//    queue = dispatch_queue_create("ddddd", DISPATCH_QUEUE_SERIAL);
//    NSLog(@"pppppp,%p",[NSThread currentThread]);
//
//    dispatch_async(queue, ^{
//        NSLog(@"=======,%p",[NSThread currentThread]);
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            NSLog(@"xxxxxxxx,%p",[NSThread currentThread]);
//        });
//    });
    
    
//    [self.tableView ssn_addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSLog(@"%@ : %@",object,keyPath);
}

- (void)animator:(SSNNavigationBarAnimator *)animator didSetNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden) {
        self.tableView.ssn_headerPullRefreshView.startOffset = 20;
    }
    else {
        self.tableView.ssn_headerPullRefreshView.startOffset = 64;
    }
}

- (void)logout {
    [SSNToast showTarget:self progressLoadingAtGoldenSection:@"正在注销。。。"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self ssn_router] openURL:[NSURL URLWithString:@"app://login"]];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    animator.enabled = YES;
    
//    static int i = 0;
//    i++;
//    flag = i;
//    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    animator.enabled = NO;
    
    
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
    
    
    flag++;
    
    //测试模仿 发起异步请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *ary = [NSMutableArray array];
        
        {//显示cell构造
            [ary addObject:[DMSettingCellItem itemWithTitle:@"UIDic"]];
            [ary addObject:[DMSectionCellItem item]];
            
            [ary addObject:[DMSettingCellItem itemWithTitle:@"brief_rsa"]];
            [ary addObject:[DMSectionCellItem item]];
            
            [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
            [ary addObject:[DMSectionCellItem item]];
            
            [ary addObject:[DMSettingCellItem itemWithTitle:@"UILayout"]];
            [ary addObject:[DMSectionCellItem item]];
            
            [ary addObject:[DMSettingCellItem itemWithTitle:@"testAdpater"]];
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
            
            [ary addObject:[DMSettingCellItem itemWithTitle:@"=========0"]];
            [ary addObject:[DMSectionCellItem item]];
            
            [ary addObject:[DMSettingCellItem itemWithTitle:@"===ddd==="]];
            [ary addObject:[DMSectionCellItem item]];
        }
        completion(ary,flag!=3,nil,YES);
    });
}

- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator tableView:(UITableView *)tableView didSelectModel:(DMSettingCellItem *)model atIndexPath:(NSIndexPath *)indexPath {
    if ([model.title isEqualToString:@"UIDic"]) {
        [self openRelativePath:@"../uidic" query:nil];
    }
    else if ([model.title isEqualToString:@"UILayout"]) {
        [self openRelativePath:@"../layout" query:nil];
    }
    else if ([model.title isEqualToString:@"brief_rsa"]) {
        //
        [self briefTesting];
    }
    else if ([model.title isEqualToString:@"xxxxxxxx"]) {
        DMSettingCellItem *item = (DMSettingCellItem *)model;
        if ([item.title isEqualToString:@"xxxxxxxx"]) {
            item.title = @"xxx===xxxx";
        }
        else {
            item.title = @"xxxxxxxx";
        }
        [self.ssn_tableViewConfigurator.listFetchController updateData:model atIndexPath:indexPath];
    }
    else if ([model.title isEqualToString:@"========="]) {
        DMSettingCellItem *item = [DMSettingCellItem itemWithTitle:@"insert"];
        [self.ssn_tableViewConfigurator.listFetchController insertDatas:@[item,[DMSectionCellItem item]] atIndexPath:indexPath];
    }
    else if ([model.title isEqualToString:@"=========0"]) {
        DMSettingCellItem *item = [DMSettingCellItem itemWithTitle:@"insert"];
        [self.ssn_tableViewConfigurator.listFetchController insertData:item atIndexPath:indexPath];
    }
    else if ([model.title isEqualToString:@"testAdpater"]) {
        [self openRelativePath:@"../adapter" query:nil];
    }
    else {
        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        [self.ssn_tableViewConfigurator.listFetchController deleteDatasAtIndexPaths:@[indexPath,nextPath]];
    }
}

- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    [self.ssn_tableViewConfigurator.listFetchController deleteDatasAtIndexPaths:@[indexPath,nextPath]];
    
}

- (void)briefTesting {
    //9,223,372,036,854,775,807
    //rsa pub key:(n,e) = (826758626753975959,65537) = Yjc5M2M5NzM2YTkxNjk3KzEwMDAx
    //rsa pri key:(n,d) = (826758626753975959,52983600480739073) = Yjc5M2M5NzM2YTkxNjk3K2JjM2M0ZGNkOTM1ZjAx
    
    
    {
        NSString *msg = @"www.fengqu.com";
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        NSString *sign = [SSNBriefRSA sign:@"Yjc5M2M5NzM2YTkxNjk3K2JjM2M0ZGNkOTM1ZjAx" data:data];
        NSLog(@"%@",sign);
        if ([SSNBriefRSA verify:@"Yjc5M2M5NzM2YTkxNjk3KzEwMDAx" sign:sign data:data]) {
            NSLog(@"verify true");
        }
    }
    {
        NSString *msg = @"肖信波 杨世亮";
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        NSString *sign = [SSNBriefRSA sign:@"Yjc5M2M5NzM2YTkxNjk3K2JjM2M0ZGNkOTM1ZjAx" data:data];
        NSLog(@"%@",sign);
        if ([SSNBriefRSA verify:@"Yjc5M2M5NzM2YTkxNjk3KzEwMDAx" sign:sign data:data]) {
            NSLog(@"verify true");
        }
    }
    {
        NSString *msg = @"打算大家送大礼斯柯达dhjkasakda哈佛爱的大声道啊";
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        NSString *sign = [SSNBriefRSA sign:@"Yjc5M2M5NzM2YTkxNjk3K2JjM2M0ZGNkOTM1ZjAx" data:data];
        NSLog(@"%@",sign);
        if ([SSNBriefRSA verify:@"Yjc5M2M5NzM2YTkxNjk3KzEwMDAx" sign:sign data:data]) {
            NSLog(@"verify true");
        }
    }
//    {
//        int64_t ll = -54343214504323ll;
//        SSNBInteger lv;
//        ssn_long_to_bigInt(ll, &lv);
//        ssn_bigint_print(&lv);
//        char dl[64];
//        int len = ssn_bigint_transform_in_bytes(&lv, dl);
//        NSLog(@"len %d",len);
//        SSNBInteger lvv;
//        ssn_bigint_transform_from_bytes(dl, &lvv, len);
//        int64_t kvv = ssn_bigint_to_long(&lvv);
//        ssn_bigint_print(&lvv);
//        NSLog(@"kvv %lld",kvv);
//        if (ll == kvv) {
//            NSLog(@"最后相等======%lld",kvv);
//        }
//    }
    
    {
        int64_t ll = -144343214504323l;//-144343214504323
        SSNBInteger lv;
        ssn_long_to_bigInt(ll, &lv);
//        ssn_bigint_print(&lv);
        char dl[64];
        int len = ssn_bigint_transform_in_bytes(&lv, dl, 64);
        NSLog(@"len %d",len);
//        SSNBInteger lvv;
//        ssn_bigint_transform_from_bytes(dl, &lvv, len);
//        int64_t kvv = ssn_bigint_to_long(&lvv);
//        ssn_bigint_print(&lvv);
        for (int ii = 0; ii < len; ii++) {
            printf("%d,",dl[ii]);
        }
        printf("\n");
        NSData *sign = [NSData dataWithBytes:dl length:len];
        NSLog(@"%@",[sign base64EncodedStringWithOptions:0]);
    }
//    {
//        char chs[1024];
//        for (int i = 1; i <= 9; i++) {
//            for (int j = 1; j <= 9; j++) {
//                memset(chs, 0x00, 1024);
//                chs[0] = '0' + i;
//                chs[1] = '0' + j;
//                strcat(chs, "4343214504323");
//                int64_t dddll = strtoll(chs, NULL, 10);
//                {
//                    int64_t ll = -dddll;
//                    SSNBInteger lv;
//                    ssn_long_to_bigInt(ll, &lv);
//                    //                ssn_bigint_print(&lv);
//                    char dl[64];
//                    int len = ssn_bigint_transform_in_bytes(&lv, dl, 64);
////                                    NSLog(@"len %d",len);
//                    
//                    SSNBInteger lvv;
//                    ssn_bigint_transform_from_bytes(dl, &lvv, len);
//                    
//                    int64_t kvv = ssn_bigint_to_long(&lvv);
//                    
////                    for (int ii = 0; ii < len; ii++) {
////                        printf("%d,",dl[ii]);
////                    }
////                    printf("\n");
//
//                    NSData *sign = [NSData dataWithBytes:dl length:len];
//                    NSLog(@"%@ === %lld == %lld",[sign base64EncodedStringWithOptions:0],ll,kvv);
//                }{
//                     int64_t ll = dddll;
//                    SSNBInteger lv;
//                    ssn_long_to_bigInt(ll, &lv);
//                    //                ssn_bigint_print(&lv);
//                    char dl[64];
//                    int len = ssn_bigint_transform_in_bytes(&lv, dl, 64);
////                                    NSLog(@"len %d",len);
//                    
//                    SSNBInteger lvv;
//                    ssn_bigint_transform_from_bytes(dl, &lvv, len);
//                    int64_t kvv = ssn_bigint_to_long(&lvv);
//                    
////                    for (int ii = 0; ii < len; ii++) {
////                        printf("%d,",dl[ii]);
////                    }
////                    printf("\n");
//
//                    NSData *sign = [NSData dataWithBytes:dl length:len];
//                    NSLog(@"%@ === %lld == %lld",[sign base64EncodedStringWithOptions:0],ll,kvv);
//                }
//            }
//        }
//    }
}
@end

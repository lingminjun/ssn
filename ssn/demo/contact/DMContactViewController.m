//
//  DMContactViewController.m
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMContactViewController.h"

#import "SSNRouter.h"
#import "DMPerson.h"
#import "DMPersonExt.h"
#import "DMSession.h"
#import "DMSignEngine.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "SSNDBFetchController.h"
#import "SSNDBFetch.h"
#import "SSNDBPool.h"
#import "SSNDBTable+Factory.h"

#import "SSNKVOBound.h"
#import "SSNDBBound.h"

#import "UITableView+SSNPullRefresh.h"
#import "UIViewController+SSNTableViewDBConfigure.h"

#import "DMPersonCell.h"


//#import "DMProfileViewController.h"

@interface DMContactViewController ()<SSNDBFetchControllerDelegate,ABPeoplePickerNavigationControllerDelegate>

//@property SSNDBFetchController *fetchController;

@end

@implementation DMContactViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
//        [_fetchController setDelegate:self];
        
    }
    return self;
}

- (SSNDBFetchController *)loadDBFetchController {
    // Custom initialization
    SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
    
    //表生成下
    [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPerson class]) templateName:nil];
    [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPersonExt class]) templateName:nil];
    
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"mobile" ascending:YES];
    
    //非级联测试
    //SSNDBFetch *fetch = [SSNDBFetch fetchWithEntity:[DMPerson class] sortDescriptors:@[ sort1, sort2 ] predicate:nil offset:1 limit:4 fromTable:NSStringFromClass([DMPerson class])];
    
    //级联测试
    SSNDBCascadeFetch *fetch = [SSNDBCascadeFetch fetchWithEntity:[DMPersonVM class] sortDescriptors:@[ sort1, sort2 ] predicate:nil offset:0 limit:0 fromTable:NSStringFromClass([DMPerson class])];
    
    [fetch setQueryColumnDescriptors:@[
                                       @"uid",
                                       @"name",
                                       @"avatar",
                                       @"mobile",
                                       @"DMPersonExt.brief AS brief",
                                       @"DMPersonExt.address AS address"
                                       ]];
    
    [fetch addCascadedTable:NSStringFromClass([DMPersonExt class]) joinedColumn:@"uid" to:@"uid"];
    
    return [SSNDBFetchController fetchControllerWithDB:db fetch:fetch];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
    SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPerson class]) templateName:nil];
    NSString *sql = [NSString stringWithFormat:@"select count(*) AS count from %@",tb.name];
    
    [self ssn_boundTable:tb forSQL:sql tieField:@"title" map:^id(SSNDBTable *table, NSString *sql, NSArray *changed_new_values) {
        NSArray *sums = [changed_new_values valueForKey:@"count"];
        NSNumber *first = [sums firstObject];
        if (first) {
            return [NSString stringWithFormat:@"Contact(%@)",first];
        }
        else {
            return @"Contact(0)";
        }
    }];
    

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addPerson:)];
    
    self.ssn_tableViewDBConfigurator.tableView = self.tableView;
    self.ssn_tableViewDBConfigurator.dbFetchController = [self loadDBFetchController];
    
    //开始加载数据
    [self.ssn_tableViewDBConfigurator.dbFetchController performFetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}



- (void)addPerson:(id)sender {
    ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
    ppnc.peoplePickerDelegate = self;
    ppnc.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    [self presentViewController:ppnc animated:YES completion:nil];
}

- (NSString *)compositeNameWithRecord:(ABRecordRef)record
{
    NSString *reslut = nil;
    CFStringRef name = ABRecordCopyCompositeName(record);
    if (name) {
        reslut = [NSString stringWithString:(__bridge NSString *)name];
        CFRelease(name);
    }
    
    if ([reslut length] == 0) {
        reslut = @"无名字";
    }
    
    return reslut;
}

- (NSString *)tidyPhoneNumber:(NSString *)number {
    
    //return [NSString stringWithString:self];
    
    NSMutableString *countryCode = [NSMutableString string];
    NSMutableString *mobile = [NSMutableString string];
    
    NSInteger index = 0;
    NSInteger length = [number length];
    
    BOOL mayBeCountryCode = NO;
    if ([number hasPrefix:@"+"]) {
        mayBeCountryCode = YES;
        index = 1;
    }
    else if ([number hasPrefix:@"00"]) {
        mayBeCountryCode = YES;
        index = 2;
    }
    
    if (mayBeCountryCode) {//考虑计算国家吗，最长国家码7位
        
        [countryCode appendString:@"+"];
        
        const NSInteger max_cc_length = 7;//国家码最长
        
        NSInteger max_cc_location = index + max_cc_length + 1;//检查到国家码最长后一位，如果仍然没有分割符，就不算国家码
        
        for (; index < max_cc_location && index < length; index++) {
            
            unichar c = [number characterAtIndex:index];
            
            if ((c >= '0' && c <= '9')//数字
                || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')//字母也支持，
                || (c == '#' || c == '*')//“#”号也支持
                ) {
                NSString *charString = [NSString stringWithFormat:@"%c",c];
                [countryCode appendString:charString];
                [mobile appendString:charString];
            }
            else {//遇到非法字符，可以终止
                break ;
            }
        }
        
        if ([countryCode length] > 1 && [countryCode length] <= max_cc_length + 1) {//前面有个加号
            [mobile setString:@"-"];//增加减号连接符
        }
        else {
            //保留其加号
            [countryCode setString:@"+"];
        }
    }
    
    for (; index < length; index++) {
        
        unichar c = [number characterAtIndex:index];
        
        //合法字符
        if ((c >= '0' && c <= '9')//数字
            || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')//字母也支持，
            || (c == '#' || c == '*')//“#”号也支持
            ) {
            NSString *charString = [NSString stringWithFormat:@"%c",c];
            [mobile appendString:charString];
        }
        else {//遇到非法字符，可以终止
            continue ;
        }
    }
    
    if ([mobile isEqualToString:@"-"]) {//说明后面并没有找到多余号码
        [mobile setString:@""];
    }
    
    return [NSString stringWithFormat:@"%@%@",countryCode,mobile];
}


- (NSArray *)phoneNumbersWithRecord:(ABRecordRef)record
{
    NSArray *results = nil;
    CFTypeRef theProperty = ABRecordCopyValue(record, kABPersonPhoneProperty);
    if (theProperty) {
        CFArrayRef items = ABMultiValueCopyArrayOfAllValues(theProperty);
        if (items) {
            results = [NSArray arrayWithArray:(__bridge NSArray *)items];
            CFRelease(items);
        }
        CFRelease(theProperty);
    }
    return results;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *name = [self compositeNameWithRecord:person];
    NSArray *mobiles = [self phoneNumbersWithRecord:person];
    
    SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
    SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPerson class]) templateName:nil];
    
    SSNDBTable *tbext = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPersonExt class]) templateName:nil];
    
    NSMutableArray *list = [NSMutableArray array];
    for (NSString *phone in mobiles) {
        NSString *mobile = [self tidyPhoneNumber:phone];
        if ([mobile length] == 0) {
            continue ;
        }
//        DMPerson *pn = [[DMPerson alloc] init];
//        pn.uid = mobile;
//        pn.mobile = mobile;
//        pn.name = name;
//        [list addObject:pn];
        
        DMPersonVM *pn = [[DMPersonVM alloc] init];
        pn.uid = mobile;
        pn.mobile = mobile;
        pn.name = name;
        static int i = 0;
        i++;
        pn.brief = [NSString stringWithFormat:@"%03i,%@",i,mobile];
        [list addObject:pn];
    }
    
    [tb upinsertObjects:list];
    [tbext upinsertObjects:list];
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

#pragma mark - fetch countroller delegate
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath {
    DMPerson *person = (DMPerson *)model;
    [self openRelativePath:@"../profile" query:@{@"uid":person.uid,@"person":person}];
}


// Override to support editing the table view.
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        DMPersonVM *person = [self.ssn_tableViewDBConfigurator.dbFetchController objectAtIndex:indexPath.row];
        
        SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
        SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPerson class]) templateName:nil];
        SSNDBTable *tbext = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPersonExt class]) templateName:nil];
        
        [tbext deleteObject:person];
        [tb deleteObject:person];
        
    }
    
}

@end

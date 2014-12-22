//
//  DMContactViewController.m
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMContactViewController.h"

#import "DMPerson.h"
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

@interface DMContactViewController ()<SSNDBFetchControllerDelegate,ABPeoplePickerNavigationControllerDelegate>

@property SSNDBFetchController *fetchController;

@end

@implementation DMContactViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
        SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
        SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPerson class]) templateName:nil];
        
        NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"mobile" ascending:YES];
        
        SSNDBFetch *fetch = [SSNDBFetch fetchWithEntity:[DMPerson class] sortDescriptors:@[ sort1, sort2 ] predicate:nil offset:0 limit:0];
        
        _fetchController = [SSNDBFetchController fetchControllerWithDB:db table:tb fetch:fetch];
        
        //_fetchController.
        
        [_fetchController setDelegate:self];
        
    }
    return self;
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
    
    
    self.tableView.rowHeight = 60;
    
    [_fetchController performFetch];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addPerson:)];
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
    [tb update];
    
    NSMutableArray *list = [NSMutableArray array];
    for (NSString *phone in mobiles) {
        NSString *mobile = [self tidyPhoneNumber:phone];
        if ([mobile length] == 0) {
            continue ;
        }
        DMPerson *pn = [[DMPerson alloc] init];
        pn.uid = mobile;
        pn.mobile = mobile;
        pn.name = name;
        [list addObject:pn];
    }
    
    [tb upinsertObjects:list];
    //[tb inreplaceObjects:list];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_fetchController count];
}

- (void)configureCell:(UITableViewCell *)cell person:(DMPerson *)person atIndexPath:(NSIndexPath *)indexPath {
    
    [cell.imageView ssn_boundObject:person forField:@"avatar" tieField:@"image" filter:nil map:^id(id obj, NSString *field, id changed_new_value) {
        if (changed_new_value) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:changed_new_value]];
            if (data) {
                return [UIImage imageWithData:data];
            }
        }
        return [UIImage imageNamed:@"dm_default_avatar"];
    }];
    
    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = person.mobile;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    [self configureCell:cell person:[_fetchController objectAtIndex:indexPath.row] atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DMPerson *person = [_fetchController objectAtIndex:indexPath.row];
    [self openRelativePath:@"../profile" query:@{@"uid":person.uid,@"person":person}];
    //[self openRelativePath:@"../profile" query:@{@"uid":person.uid}];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        DMPerson *person = [_fetchController objectAtIndex:indexPath.row];
        
        SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
        SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPerson class]) templateName:nil];
        [tb deleteObject:person];
    }
    
}


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

#pragma mark ssndb fetch delegate
- (void)ssndb_controller:(SSNDBFetchController *)controller didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(SSNDBFetchedChangeType)type newIndex:(NSUInteger)newIndex {
    
    switch (type) {
        case SSNDBFetchedChangeInsert:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNDBFetchedChangeDelete:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNDBFetchedChangeMove:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SSNDBFetchedChangeUpdate:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:cell person:(DMPerson *)object atIndexPath:indexPath];
        }
            break;
        default:
            break;
    }
    
}

- (void)ssndb_controllerWillChange:(SSNDBFetchController *)controller {
    [self.tableView beginUpdates];
}

- (void)ssndb_controllerDidChange:(SSNDBFetchController *)controller {
    [self.tableView endUpdates];
}

@end

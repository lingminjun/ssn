//
//  DMSessionViewController.m
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMSessionViewController.h"
#import "DMSignEngine.h"
#import "DMSession.h"

#import "SSNDBFetchController.h"
#import "SSNDBFetch.h"
#import "SSNDBPool.h"
#import "SSNDBTable+Factory.h"


@interface DMSessionViewController ()<SSNDBFetchControllerDelegate>

@property SSNDBFetchController *fetchController;

@end

@implementation DMSessionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
        SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMSession class]) templateName:nil];
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"modifiedAt" ascending:NO];
        
        SSNDBFetch *fetch = [SSNDBFetch fetchWithEntity:[DMSession class] sortDescriptors:@[ sort ] predicate:nil offset:0 limit:0];
        
        _fetchController = [SSNDBFetchController fetchControllerWithDB:db table:tb fetch:fetch];
        [_fetchController setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Session";
    
    self.tableView.rowHeight = 60;
    
    [_fetchController performFetch];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_fetchController count];
}

- (void)configureCell:(UITableViewCell *)cell session:(DMSession *)session atIndexPath:(NSIndexPath *)indexPath {
    
    //cell.imageView.image =
    cell.imageView.image = [UIImage imageNamed:@"dm_default_avatar"];
    
    cell.textLabel.text = session.title;
    
    cell.detailTextLabel.text = session.content;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }

    // Configure the cell...
    [self configureCell:cell session:[_fetchController objectAtIndex:indexPath.row] atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DMSession *session = [_fetchController objectAtIndex:indexPath.row];
    [self openRelativePath:@"../chat" query:@{@"sid":session.sid}];
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
        DMSession *session = [_fetchController objectAtIndex:indexPath.row];
        
        SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
        SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMSession class]) templateName:nil];
        [tb deleteObject:session];
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
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:cell session:(DMSession *)object atIndexPath:indexPath];
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

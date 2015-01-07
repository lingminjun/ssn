//
//  DMUIDicViewController.m
//  ssn
//
//  Created by lingminjun on 15/1/7.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "DMUIDicViewController.h"
#import "SSNRouter.h"

@implementation DMUIDicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"UIDic";
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
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"UIDic";
    }
    else {
        cell.textLabel.text = @"UILayout";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self openRelativePath:@"../uidic" query:nil];
    }
    else {
        [self openRelativePath:@"../layout" query:nil];
    }
}

@end

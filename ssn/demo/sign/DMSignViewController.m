//
//  DMSignViewController.m
//  ssn
//
//  Created by lingminjun on 14-8-11.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMSignViewController.h"
#import "DMSignEngine.h"
#import "SSNToast.h"

@interface DMSignViewController ()

@end

@implementation DMSignViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"登录";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(doneAction:)];
    
    UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, 200, 44)];
    text.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:text];
    [text becomeFirstResponder];
}

- (void)doneAction:(id)sender
{
    [SSNToast showTarget:self progressLoadingAtGoldenSection:@"正在登录。。。"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DMSignEngine sharedInstance].loginId = @"18758014247";
        [self.ssn_router openURL:[NSURL URLWithString:@"app://default"]];
    });
}

- (void)testButtonAction:(id)sender {
    NSLog(@">>>>>>>>>>>>>>>>>>");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"===========================");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

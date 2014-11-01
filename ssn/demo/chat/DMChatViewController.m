//
//  DMChatViewController.m
//  ssn
//
//  Created by lingminjun on 14-11-1.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMChatViewController.h"

@interface DMChatViewController ()

@property (nonatomic,strong) NSString *nickname;

@end

@implementation DMChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"聊天(%@)",self.nickname];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人资料"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(doneAction:)];
}

- (void)doneAction:(id)sender
{
    //父控制器打开profile
    [self openRelativePath:@"../profile" query:@{@"nickname":self.nickname}];
    
    //直接响应当前目录
    //[self noticeRelativePath:@"." query:@{@"nickname":self.nickname}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark SSNPage
//是否可以响应，默认返回NO，已存在界面如果可以响应，将重新被打开
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    NSString *nickname = [query objectForKey:@"nickname"];
    return [nickname isEqualToString:self.nickname];
}

//当ssn_canRespondURL:query:返回YES后，openURL将调用此方法，如果一个页面第一次被创建，也会被询问调用此方法
- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.nickname = [query objectForKey:@"nickname"];
}

//当ssn_canRespondURL:query:返回YES后，noticeURL将调用此方法，
- (void)ssn_handleNoticeURL:(NSURL *)url query:(NSDictionary *)query {
    self.nickname = [query objectForKey:@"nickname"];
    self.title = [NSString stringWithFormat:@"聊天(%@)",self.nickname];
}


@end

//
//  DMChatViewController.m
//  ssn
//
//  Created by lingminjun on 14-11-1.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMChatViewController.h"
#import "DMSignEngine.h"
#import "DMSession.h"
#import "DMPerson.h"

#import "SSNDBPool.h"
#import "SSNDBTable+Factory.h"

@interface DMChatViewController ()

@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) DMSession *session;

@end

@implementation DMChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.session.title;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人资料"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(doneAction:)];
}

- (void)doneAction:(id)sender
{
    //父控制器打开profile
    NSArray *uids = [self.session memberUids];
    NSString *uid = nil;
    for (NSString *str in uids) {
        if (![str isEqualToString:[DMSignEngine sharedInstance].loginId]) {
            uid = str;
            break ;
        }
    }
    [self openRelativePath:@"../profile" query:@{@"uid":uid}];
    
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
    NSString *sid = [query objectForKey:@"sid"];
    return [sid isEqualToString:self.sid];
}

//当ssn_canRespondURL:query:返回YES后，openURL将调用此方法，如果一个页面第一次被创建，也会被询问调用此方法
- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.sid = [query objectForKey:@"sid"];
    self.session = [query objectForKey:@"session"];
    if (!_session) {
        SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
        SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMSession class]) templateName:nil];
        self.session =[[tb objectsWithClass:[DMSession class] forConditions:@{@"sid":self.sid}] firstObject];
    }
    self.title = self.session.title;
}

//当ssn_canRespondURL:query:返回YES后，noticeURL将调用此方法，
- (void)ssn_handleNoticeURL:(NSURL *)url query:(NSDictionary *)query {
}


@end

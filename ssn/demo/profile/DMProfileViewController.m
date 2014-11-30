//
//  DMProfileViewController.m
//  ssn
//
//  Created by lingminjun on 14-11-1.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "DMProfileViewController.h"
#import "DMSession.h"
#import "DMPerson.h"
#import "DMSignEngine.h"

#import "SSNDBPool.h"
#import "SSNDBTable+Factory.h"

@interface DMProfileViewController ()

@property (nonatomic,strong) DMPerson *person;

@end

@implementation DMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [NSString stringWithFormat:@"个人信息(%@)",self.person.name];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"聊天"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(doneAction:)];
}

- (void)doneAction:(id)sender
{
    DMPerson *selfPerson = [[DMSignEngine sharedInstance] selfProfile];
    DMSession *sn = [DMSession sessionWithSelf:selfPerson toPerson:self.person];
    
    SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
    SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMSession class]) templateName:nil];
    [tb upinsertObject:sn];
    
    [self.ssn_router openURL:[NSURL URLWithString:@"app://main/session_tab/chat"] query:@{@"sid":sn.sid}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSString *uid = [query objectForKey:@"uid"];
    return [uid isEqualToString:self.person.uid];
}

//当ssn_canRespondURL:query:返回YES后，openURL将调用此方法，如果一个页面第一次被创建，也会被询问调用此方法
- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.person = [query objectForKey:@"person"];
    if (!_person) {
        NSString *uid = [query objectForKey:@"uid"];
        
        SSNDB *db = [[SSNDBPool shareInstance] dbWithScope:[DMSignEngine sharedInstance].loginId];
        SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass([DMPerson class]) templateName:nil];
        self.person = [[tb objectsWithClass:[DMPerson class] forConditions:@{@"uid":uid}] firstObject];
    }
    self.title = [NSString stringWithFormat:@"个人信息(%@)",self.person.name];
}

//当ssn_canRespondURL:query:返回YES后，noticeURL将调用此方法，
- (void)ssn_handleNoticeURL:(NSURL *)url query:(NSDictionary *)query {
}

@end

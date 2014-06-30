//
//  ViewController.m
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "ViewController.h"
#import "ssndb.h"
#import "TestModel.h"
#import "ssnbase.h"


@interface ViewController ()
{
    SSNDataBase *sharedb;
    SSNModelManager *manager;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
   
    
    SSNDataBase *db = [[SSNDataBase alloc] initWithPath:@"test/db.sqlite" version:1];
    
    [db createTable:@"TestModel" withDelegate:[TestModel class]];
    
    manager = [[SSNModelManager alloc] initWithDataBase:db];
    
    
    
    //[TestModel setManager:self];
    
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //TestModel *m = [TestModel modelWithKeyPredicate:@"type = 0 AND uid = '3344422'"];
    
    TestModel *m = (TestModel *)[manager modelWithClass:[TestModel class] keyPredicate:@"type = 0 AND uid = '3344422'"];
    
    NSLog(@"%@",m);
    
    NSLog(@"%@",m.name);
    NSLog(@"%@",m.uid);
    NSLog(@"%ld",m.age);
    NSLog(@"%f",m.hight);
    
    m[@"name"] = @"dddddd";
    
    NSLog(@"%@",m);
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

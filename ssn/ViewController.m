//
//  ViewController.m
//  ssn
//
//  Created by lingminjun on 14-5-7.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    TestModel *m = [[TestModel alloc] init];
    m.name = @"lingminjun";
    m.uid = @"3344422";
    m.age = 56;
    m.hight = 16.5f;
    m.type = 0;
//    [m ssn_model_set_on_text:@"ddd"];
//    m.text = @"ttttt";
    NSLog(@"%@",m.name);
    NSLog(@"%@",m.uid);
    NSLog(@"%ld",m.age);
    NSLog(@"%f",m.hight);
    
    m.uid = @"6666666";
    
    NSLog(@"%p",[TestModel class]);
    NSLog(@"%@",[TestModel primaryKeys]);
    NSLog(@"%@",[TestModel valuesKeys]);
    
    NSLog(@"%@",[m keyPredicate]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

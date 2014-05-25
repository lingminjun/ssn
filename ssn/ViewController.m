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
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedb = [[SSNDataBase alloc] initWithPath:@"test/db.sqlite" version:1];
    [sharedb open];
    [sharedb createTable:@"TestModel" withDelegate:[TestModel class]];
    
    [TestModel setManager:self];
    
	// Do any additional setup after loading the view, typically from a nib.
    TestModel *m = [TestModel modelWithKeyPredicate:@"type = 0 AND uid = '3344422'"];
    
    
    
    m.name = @"lingminjun";
//    m.uid = @"3344422";
    m.age = 56;
    m.hight = 16.5f;
//    m.type = 0;
    m.sex = YES;
    
    [m updateToStore];
    
//    [m ssn_model_set_on_text:@"ddd"];
//    m.text = @"ttttt";
//    NSLog(@"%@",m.name);
//    NSLog(@"%@",m.uid);
//    NSLog(@"%ld",m.age);
//    NSLog(@"%f",m.hight);
//    
//    //m.uid = @"6666666";
//    
//    NSLog(@"%p",[TestModel class]);
//    NSLog(@"%@",[TestModel primaryKeys]);
//    NSLog(@"%@",[TestModel valuesKeys]);
//    
//    NSLog(@"%@",[m keyPredicate]);
    NSLog(@"%@",m);
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    TestModel *m = [TestModel modelWithKeyPredicate:@"type = 0 AND uid = '3344422'"];
    
//    m.uid = @"3344422";
//    m.type = 0;
    
    NSLog(@"%@",m);
    
    NSLog(@"%@",m.name);
    NSLog(@"%@",m.uid);
    NSLog(@"%ld",m.age);
    NSLog(@"%f",m.hight);
    
    NSLog(@"%@",m);
}


//加载某类型实例的数据，keyPredicate意味着是主键，所以只返回一个对象
- (NSDictionary *)model:(SSNModel *)model loadDatasWithPredicate:(NSString *)keyPredicate {
    NSArray *ary = [sharedb queryObjects:nil sql:[NSString stringWithFormat:@"SELECT * FROM TestModel WHERE %@",keyPredicate],nil];
    return [ary lastObject];
}

//更新实例，不包含主键，存储成功请返回YES，否则返回失败
- (BOOL)model:(SSNModel *)model updateDatas:(NSDictionary *)valueKeys forPredicate:(NSString *)keyPredicate {
    
    NSString *setValuesString = [NSString predicateStringKeyAndValues:valueKeys componentsJoinedByString:@","];
    
    [sharedb queryObjects:nil sql:[NSString stringWithFormat:@"UPDATE TestModel SET %@ WHERE %@",setValuesString,keyPredicate],nil];
    
    return YES;
}

//插入实例，如果数据库中已经存在，可以使用replace，也可以返回NO，表示插入失败，根据使用者需要
- (BOOL)model:(SSNModel *)model insertDatas:(NSDictionary *)valueKeys forPredicate:(NSString *)keyPredicate {
    
    NSString *keysString = [[valueKeys allKeys] componentsJoinedByString:@","];
    NSMutableArray *vs = [NSMutableArray array];
    for (NSInteger index = 0; index < [valueKeys count]; index ++) {
        [vs addObject:@"?"];
    }
    NSString *valueString = [vs componentsJoinedByString:@","];
    NSArray *values = [valueKeys objectsForKeys:[valueKeys allKeys] notFoundMarker:[NSNull null]];
    
    [sharedb queryObjects:nil sql:[NSString stringWithFormat:@"INSERT INTO TestModel (%@) VALUES (%@)",keysString,valueString] arguments:values];
    
    return YES;
}

//删除实例
- (BOOL)model:(SSNModel *)model deleteForPredicate:(NSString *)keyPredicate {
    [sharedb queryObjects:nil sql:[NSString stringWithFormat:@"DELETE FROM TestModel WHERE %@",keyPredicate]];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  DMLayoutViewController.m
//  ssn
//
//  Created by lingminjun on 15/1/3.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "DMLayoutViewController.h"
#import "SSNPanel.h"

#import "SSNUIEle.h"

@implementation DMLayoutViewController

- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Layout";
    {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, 84, 80, 280)];
        v.backgroundColor = [UIColor redColor];
        [self.view addSubview:v];
    }
    
    {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, 84, 80, 280)];
        v.backgroundColor = [UIColor blueColor];
        v.transform = CGAffineTransformMakeRotation(-M_PI_2);
        v.frame = CGRectMake(10, 84, 280, 80);
        [self.view addSubview:v];
        NSLog(@"%f,%f",v.frame.origin.x,v.frame.origin.y);
    }
    
    
//    NSString *str = [NSString stringWithUTF8String:nil];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 80, 300, 40)];
//    imageView.backgroundColor = [UIColor redColor];
//    imageView.image = [UIImage ssn_lineWithColor:[UIColor blackColor] orientation:UIInterfaceOrientationPortrait];
//    imageView.contentMode = UIViewContentModeCenter;
//    [self.view addSubview:imageView];

//    {
//        SSNUIFlowLayout *layout = [self.view ssn_flowLayout];
//        
//        layout.contentInset = UIEdgeInsetsMake(64, 100, 0, 100);
//        layout.rowHeight = 30;
//        layout.contentMode = SSNUIContentModeRight;
//        layout.spacing = 20;
//        
//        for (int i = 0; i<2; i++) {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
//            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
//            
//            [layout addSubview:view forKey:[NSString stringWithFormat:@"flow%i",i]];
//        }
//    }
//
//    {
//        SSNUIFlowLayout *layout = [self.view ssn_flowLayout];
//        
//        layout.contentInset = UIEdgeInsetsMake(154, 0, 0, 0);
//        layout.rowHeight = 30;
//        layout.spacing = 20;
//        layout.contentMode = SSNUIContentModeTopRight;
//        layout.isRowReverse = YES;
//        
//        for (int i = 0; i<20; i++) {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
//            
//            [layout addSubview:view forKey:[NSString stringWithFormat:@"flow2x%i",i]];
//        }
//    }
////
//    {
//        SSNUIFlowLayout *layout = [self.view ssn_flowLayout];
//        
//        layout.contentInset = UIEdgeInsetsMake(234, 0, 0, 0);
//        layout.rowHeight = 30;
//        layout.spacing = 10;
//        layout.contentMode = SSNUIContentModeCenter;
//        
//        for (int i = 0; i<19; i++) {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
//            [layout addSubview:view forKey:[NSString stringWithFormat:@"1x%i",i]];
//        }
//    }
//
//    {
//        SSNUIFlowLayout *layout = [self.view ssn_flowLayout];
//        
//        layout.contentInset = UIEdgeInsetsMake(334, 0, 0, 0);
//        layout.orientation = SSNUILayoutOrientationLandscapeLeft;
//        layout.rowHeight = 30;
//        layout.spacing = 10;
//        layout.contentMode = SSNUIContentModeTopLeft;
//        layout.isRowReverse = YES;
//        
//        for (int i = 0; i<20; i++) {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
//            [layout addSubview:view forKey:[NSString stringWithFormat:@"ux%i",i]];
//        }
//    }
    
   
//    {
////        SSNUITableLayout *layout = [self.view ssn_tableLayout];
////        
////        layout.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
////        layout.defaultRowHeight = 30;
////        layout.columnCount = 8;
////        layout.contentMode = SSNUIContentModeScaleToFill;
//        
//        for (int i = 0; i<19; i++) {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
//            view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//            [self.view ssn_addSubview:view forKey:[NSString stringWithFormat:@"t1x%i",i]];
//            //[layout addSubview:view forKey:[NSString stringWithFormat:@"t1x%i",i]];
//        }
//    }
    
//    {
//        UIView *testPanel1 = [[UIView alloc] initWithFrame:CGRectMake(10, 164, 180, 240)];
//        [self.view addSubview:testPanel1];
//        
//        SSNUITableLayout *layout = [testPanel1 ssn_tableLayout];
//        
//        layout.rowCount = 2;
//        layout.columnCount = 2;
//        layout.contentMode = SSNUIContentModeScaleToFill;
//        
//        for (int i = 0; i<4; i++) {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            if (i == 0) {
//                view.backgroundColor = [UIColor redColor];
//            }
//            else if (i == 1) {
//                view.backgroundColor = [UIColor yellowColor];
//            }
//            else if (i == 2) {
//                view.backgroundColor = [UIColor blueColor];
//            }
//            else {
//                view.backgroundColor = [UIColor greenColor];
//            }
//            view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//            [layout addSubview:view forKey:[NSString stringWithFormat:@"x%i",i]];
//        }
//        
//        SSNUITableLayout *layout2 = [testPanel1 ssn_tableLayout];
//        layout2.rowCount = 2;
//        layout2.columnCount = 2;
//        
//        UIView *icon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        icon.backgroundColor = [UIColor blackColor];
//        
//        SSNUITableCellInfo *cellInfo = [[SSNUITableCellInfo alloc] init];
//        cellInfo.contentInset = UIEdgeInsetsMake(0, 10, 10, 0);
//        cellInfo.contentMode = SSNUIContentModeBottomLeft;
//        
//        [layout2 insertSubview:icon atIndex:1 cellInfo:cellInfo forKey:@"icon"];
//    }
//    
//    {
//        UIView *testPanel1 = [[UIView alloc] initWithFrame:CGRectMake(198, 164, 120, 160)];
//        [self.view addSubview:testPanel1];
//        
//        SSNUITableLayout *layout = [testPanel1 ssn_tableLayout];
//        
//        layout.rowCount = 2;
//        layout.columnCount = 2;
//        layout.contentMode = SSNUIContentModeScaleToFill;
//        
//        for (int i = 0; i<4; i++) {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            if (i == 0) {
//                view.backgroundColor = [UIColor redColor];
//            }
//            else if (i == 1) {
//                view.backgroundColor = [UIColor yellowColor];
//            }
//            else if (i == 2) {
//                view.backgroundColor = [UIColor blueColor];
//            }
//            else {
//                view.backgroundColor = [UIColor greenColor];
//            }
//            view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//            [layout addSubview:view forKey:[NSString stringWithFormat:@"x%i",i]];
//        }
//        
//        SSNUITableLayout *layout2 = [testPanel1 ssn_tableLayout];
//        layout2.rowCount = 2;
//        layout2.columnCount = 2;
//        
//        UIView *icon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        icon.backgroundColor = [UIColor blackColor];
//        
//        SSNUITableCellInfo *cellInfo = [[SSNUITableCellInfo alloc] init];
//        cellInfo.contentInset = UIEdgeInsetsMake(0, 10, 10, 0);
//        cellInfo.contentMode = SSNUIContentModeBottomLeft;
//        
//        [layout2 insertSubview:icon atIndex:1 cellInfo:cellInfo forKey:@"icon"];
//    }
//    
//    
//    {
//        SSNUITableLayout *layout = [self.view ssn_tableLayout];
//        
//        layout.contentInset = UIEdgeInsetsMake(164, 0, 0, 0);
//        layout.defaultRowHeight = 30;
//        layout.columnCount = 8;
//        
//        for (int i = 0; i<19; i++) {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
//                        
//            SSNUITableCellInfo *cellInfo = [[SSNUITableCellInfo alloc] init];
//            cellInfo.contentMode = SSNUIContentModeCenter;
//            [layout insertSubview:view atIndex:i cellInfo:cellInfo forKey:[NSString stringWithFormat:@"tt1x%i",i]];
//        }
//    }
//    
//    
//    {
//        SSNUITableLayout *layout = [self.view ssn_tableLayout];
//        
//        layout.contentInset = UIEdgeInsetsMake(264, 0, 0, 0);
//        layout.defaultRowHeight = 30;
//        layout.columnCount = 8;
//        layout.orientation = SSNUILayoutOrientationLandscapeLeft;
//        layout.isRowReverse = YES;
//        
//        for (int i = 0; i<19; i++) {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
//            
//            SSNUITableCellInfo *cellInfo = [[SSNUITableCellInfo alloc] init];
//            cellInfo.contentMode = SSNUIContentModeCenter;
//            [layout insertSubview:view atIndex:i cellInfo:cellInfo forKey:[NSString stringWithFormat:@"txt1x%i",i]];
//        }
//    }
//    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)ssn_layoutDidLoad {
    SSNUITableLayout *layout = [self.view ssn_tableLayout];
    layout.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    layout.defaultRowHeight = 30;
    layout.columnCount = 8;
    layout.contentMode = SSNUIContentModeScaleToFill;
    for (int i = 0; i<19; i++) {
        [layout moveSubviewToIndex:i forKey:[NSString stringWithFormat:@"t1x%i",i]];
    }

}

@end

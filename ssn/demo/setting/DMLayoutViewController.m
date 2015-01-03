//
//  DMLayoutViewController.m
//  ssn
//
//  Created by lingminjun on 15/1/3.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "DMLayoutViewController.h"
#import "SSNPanel.h"

@implementation DMLayoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Layout";

    {
        SSNUIFlowLayout *layout = [self.view ssn_flowLayout];
        
        layout.contentInset = UIEdgeInsetsMake(64, 100, 0, 100);
        layout.rowHeight = 30;
        layout.contentMode = SSNUIContentModeRight;
        layout.spacing = 20;
        
        for (int i = 0; i<2; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
            
            [layout addSubview:view forKey:[NSString stringWithFormat:@"%i",i]];
        }
    }
    
    {
        SSNUIFlowLayout *layout = [self.view ssn_flowLayout];
        
        layout.contentInset = UIEdgeInsetsMake(154, 0, 0, 0);
        layout.rowHeight = 30;
        layout.spacing = 20;
        layout.contentMode = SSNUIContentModeTopRight;
        layout.isXReverse = YES;
        
        for (int i = 0; i<20; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
            
            [layout addSubview:view forKey:[NSString stringWithFormat:@"2x%i",i]];
        }
    }
//
    {
        SSNUIFlowLayout *layout = [self.view ssn_flowLayout];
        
        layout.contentInset = UIEdgeInsetsMake(234, 0, 0, 0);
        layout.rowHeight = 30;
        layout.spacing = 10;
        layout.contentMode = SSNUIContentModeCenter;
        
        for (int i = 0; i<19; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
            [layout addSubview:view forKey:[NSString stringWithFormat:@"1x%i",i]];
        }
    }
 
    {
        SSNUIFlowLayout *layout = [self.view ssn_flowLayout];
        
        layout.contentInset = UIEdgeInsetsMake(334, 0, 0, 0);
        layout.orientation = SSNUILayoutOrientationLandscapeLeft;
        layout.rowHeight = 30;
        layout.spacing = 10;
        layout.contentMode = SSNUIContentModeTopLeft;
        layout.isXReverse = YES;
        
        for (int i = 0; i<20; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            view.backgroundColor = [UIColor colorWithRed:0.380 + 0.008 * i green:0.267 + 0.05 * i blue:0.996 alpha:1.000];
            [layout addSubview:view forKey:[NSString stringWithFormat:@"ux%i",i]];
        }
    }
    
    

}

@end

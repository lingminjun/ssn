//
//  SSNCrashReport.m
//  ssn
//
//  Created by lingminjun on 15/1/21.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNCrashReport.h"
#import "NSFileManager+SSN.h"
#import <MessageUI/MessageUI.h>
#import "SSNUIEle.h"

NSString *ssn_crash_file_path( ) {
    NSString *path = [[NSFileManager ssn_fileManager] pathDocumentDirectoryWithPathComponents:@"ssncrash"];
    NSString *fileName = @"crash.txt";
    return [path stringByAppendingPathComponent:fileName];
}

void ssn_uncaught_exception_handler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *url = [NSString stringWithFormat:@"=============异常崩溃报告=============\nname:\n%@\nreason:\n%@\ntime:\n%@\ncallStackSymbols:\n%@",
                     name,reason,[NSDate date],[arr componentsJoinedByString:@"\n"]];
    
    NSString *filePath = ssn_crash_file_path();
    [url writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

static UIView *crash_report_view = nil;

@implementation SSNCrashReport

+ (void)launchExceptionHandler
{
    NSSetUncaughtExceptionHandler(&ssn_uncaught_exception_handler);
}

+ (BOOL)hasCrashLog {
    NSString *filePath = ssn_crash_file_path();
    return [[NSFileManager ssn_fileManager] fileExistsAtPath:filePath];
}

+ (void)reportCrash {
    NSString *filePath = ssn_crash_file_path();
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    if (![manager fileExistsAtPath:filePath]) {
        return ;
    }
    NSString *crash = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{//暂时这么处理，防止在非主线程
        
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 40)];
        text.backgroundColor = [UIColor clearColor];
        text.font = [UIFont systemFontOfSize:11];
        text.text = crash;
        text.textColor = [UIColor blackColor];
        text.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        text.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        text.editable = NO;
        UIView *panel = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        panel.backgroundColor = [UIColor whiteColor];
        [panel addSubview:text];
        
        UIButton *button = [UIButton ssn_buttonWithSize:CGSizeMake(60, 30)
                                                   font:nil
                                                  color:[UIColor whiteColor]
                                               selected:nil
                                               disabled:nil
                                              backgroud:[UIImage ssn_imageWithColor:[UIColor redColor] border:0 color:nil cornerRadius:2]
                                               selected:nil
                                               disabled:nil];
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        button.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height - 20);
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:button];
        
        if (crash_report_view) {
            [crash_report_view removeFromSuperview];
        }
        crash_report_view = panel;
        
        [[[UIApplication sharedApplication].windows firstObject] addSubview:panel];
        [[UIApplication sharedApplication] resignFirstResponder];
    });
    
}

+ (void)dissmiss {//表示处理完，将文件删除掉
    
    [crash_report_view removeFromSuperview];
    crash_report_view = nil;
    
    NSString *filePath = ssn_crash_file_path();
    NSFileManager *manager = [NSFileManager ssn_fileManager];
    [manager removeItemAtPath:filePath error:nil];
}

+ (NSUncaughtExceptionHandler*)getHandler
{
    return NSGetUncaughtExceptionHandler();
}


@end

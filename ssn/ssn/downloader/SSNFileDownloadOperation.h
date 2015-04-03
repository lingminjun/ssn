//
//  SSNFileDownloadOperation.h
//  ssn
//
//  Created by lingminjun on 15/4/2.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNFileDownloader.h"

/**
 *  文件下载操作
 */
@interface SSNFileDownloadOperation : NSOperation <SSNFileDownloaderCancelable>

/**
 * 请求
 */
@property (strong, nonatomic, readonly) NSURLRequest *request;

/**
 *  此次请求需要证书
 */
@property (nonatomic, strong) NSURLCredential *credential;

/**
 *  开启后台继续下载
 */
@property (nonatomic) BOOL continueDownloadInBackground;

/**
 *  返回请求
 *
 *  @param request        http请求
 *  @param progressBlock  进度回调
 *  @param completedBlock 过程回调
 *  @param cancelBlock    取消回调
 *
 *  @return 返回实例
 */
- (instancetype)initWithRequest:(NSURLRequest *)request progress:(SSNFileDownloaderProgressBlock)progressBlock completed:(SSNFileDownloaderCompletedBlock)completedBlock cancelled:(SSNFileDownloaderCancelBlock)cancelBlock;

@end
//
//  SSNFileDownloader.h
//  ssn
//
//  Created by lingminjun on 15/4/2.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const SSNStartDownloadNotification;//开始下载，主线程回调
FOUNDATION_EXTERN NSString *const SSNStopDownloadNotification;//下载结束，主线程回调
FOUNDATION_EXTERN NSString *const SSNDownloadURKey;//NSURL

/**
 *  下载过程回调
 *
 *  @param receivedSize 收到的大小
 *  @param expectedSize 最终文件大小
 */
typedef void(^SSNFileDownloaderProgressBlock)(NSUInteger receivedSize, NSUInteger expectedSize);
typedef void(^SSNFileDownloaderCompletedBlock)(NSData *data, NSError *error, BOOL finished);
typedef void(^SSNFileDownloaderCancelBlock)(void);


@protocol SSNFileDownloaderCancelable <NSObject>

- (void)cancel;

@end


/**
 *  文件下载数
 */
@interface SSNFileDownloader : NSObject


/**
 *  最大下载数，默认值2
 */
@property (nonatomic) NSUInteger maxConcurrentDownloadCount;

/**
 * 当前下载个数
 */
@property (nonatomic,readonly) NSUInteger downloadCount;

/**
 *  下载超时时间 默认为 15.0.
 */
@property (assign, nonatomic) NSTimeInterval timeout;


/**
 *  文件下载器，单例
 *
 *  @return 单例
 */
+ (SSNFileDownloader *)downloader;

/**
 * 设置请求证书的用户名
 */
@property (strong, nonatomic) NSString *username;

/**
 * 设置请求证书的密码
 */
@property (strong, nonatomic) NSString *password;


/**
 * Set a value for a HTTP header to be appended to each download HTTP request.
 *
 * @param value The value for the header field. Use `nil` value to remove the header.
 * @param field The name of the header field to set.
 */
/**
 *  主要用于修改http header accept 字段
 *  注意：此接口主要用于配置accept字段
 *  accept字段设置请参考 http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
 *
 *
 *  @param value header值
 *  @param field accept字段
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 * 返回header头字段
 *
 * @return 参会header中对应的字段值
 */
- (NSString *)valueForHTTPHeaderField:(NSString *)field;

/**
 *  下载文件
 *
 *  @param url            文件资源url
 *  @param progressBlock  进度回调
 *  @param completedBlock 完成回调
 *
 *  @return 可取消
 */
- (id<SSNFileDownloaderCancelable>)downloadFileWithURL:(NSURL *)url progress:(SSNFileDownloaderProgressBlock)progressBlock completed:(SSNFileDownloaderCompletedBlock)completedBlock;


/**
 *  同步下载文件
 *
 *  @param url           文件资源url
 *  @param progressBlock 进度回调
 *
 *  @return 返回下载的文件
 */
- (NSData *)downloadFileWithURL:(NSURL *)url progress:(SSNFileDownloaderProgressBlock)progressBlock;

@end

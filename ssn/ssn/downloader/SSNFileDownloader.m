//
//  SSNFileDownloader.m
//  ssn
//
//  Created by lingminjun on 15/4/2.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNFileDownloader.h"
#import "SSNFileDownloadOperation.h"
#import "NSThread+SSN.h"

NSString *const SSNStartDownloadNotification    = @"SSNStartDownloadNotification";//开始下载，主线程回调
NSString *const SSNStopDownloadNotification     = @"SSNStopDownloadNotification";//下载结束，主线程回调
NSString *const SSNDownloadURKey                = @"SSNDownloadURKey";//NSURL

NSString *const kProgressCallbackKey = @"progress";
NSString *const kCompletedCallbackKey = @"completed";

@interface SSNFileDownloader ()

@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@property (weak, nonatomic) NSOperation *lastAddedOperation;
@property (strong, nonatomic) NSMutableDictionary *URLCallbacks;
@property (strong, nonatomic) NSMutableDictionary *HTTPHeaders;

@property ( nonatomic) dispatch_queue_t barrierQueue;

@end

@implementation SSNFileDownloader

+ (SSNFileDownloader *)downloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
//        _executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 2;
        _URLCallbacks = [[NSMutableDictionary alloc] initWithCapacity:1];
        _HTTPHeaders = [NSMutableDictionary dictionaryWithObject:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forKey:@"Accept"];
        _barrierQueue = dispatch_queue_create("com.ssn.fileDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _timeout = 15.0;
    }
    return self;
}

- (void)dealloc {
    [self.downloadQueue cancelAllOperations];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (value) {
        self.HTTPHeaders[field] = value;
    }
    else {
        [self.HTTPHeaders removeObjectForKey:field];
    }
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return self.HTTPHeaders[field];
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads {
    _downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}

- (NSUInteger)currentDownloadCount {
    return _downloadQueue.operationCount;
}

- (NSInteger)maxConcurrentDownloads {
    return _downloadQueue.maxConcurrentOperationCount;
}

- (id<SSNFileDownloaderCancelable>)downloadFileWithURL:(NSURL *)url progress:(SSNFileDownloaderProgressBlock)progressBlock completed:(SSNFileDownloaderCompletedBlock)completedBlock {
    
    __block SSNFileDownloadOperation *operation;
    __weak __typeof__ (self) wself = self;
    
    dispatch_block_t block = ^{
        NSTimeInterval timeoutInterval = wself.timeout;
        if (timeoutInterval == 0.0) {
            timeoutInterval = 120.0;
        }
        
        //请求request构建
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeoutInterval];
        
        request.HTTPShouldHandleCookies = YES;
        request.HTTPShouldUsePipelining = YES;
        request.allHTTPHeaderFields = wself.HTTPHeaders;
        
        void (^progress)(NSUInteger receivedSize, NSUInteger expectedSize) = ^(NSUInteger receivedSize, NSUInteger expectedSize) {
            __strong __typeof (wself) sself = wself;
            if (!sself) return;
            NSArray *callbacksForURL = [sself callbacksForURL:url];
            for (NSDictionary *callbacks in callbacksForURL) {
                SSNFileDownloaderProgressBlock callback = callbacks[kProgressCallbackKey];
                if (callback) callback(receivedSize, expectedSize);
            }
        };
        
        void (^completed)(NSData *data, NSError *error, BOOL finished) = ^(NSData *data, NSError *error, BOOL finished) {
            __strong __typeof (wself) sself = wself;
            if (!sself) return;
            
            NSArray *callbacksForURL = [sself callbacksForURL:url];
            if (finished) {
                [sself removeCallbacksForURL:url];
            }
            for (NSDictionary *callbacks in callbacksForURL) {
                SSNFileDownloaderCompletedBlock callback = callbacks[kCompletedCallbackKey];
                if (callback) callback(data, error, finished);
            }
        };
        
        void (^cancel)(void) = ^{
            __strong __typeof (wself) sself = wself;
            if (!sself) return;
            [sself removeCallbacksForURL:url];
        };
        
        operation = [[SSNFileDownloadOperation alloc] initWithRequest:request progress:progress completed:completed cancelled:cancel];
        
        if (wself.username && wself.password) {
            operation.credential = [NSURLCredential credentialWithUser:wself.username password:wself.password persistence:NSURLCredentialPersistenceForSession];
        }
        
        [wself.downloadQueue addOperation:operation];
    };
    
    [self addProgressCallback:progressBlock andCompletedBlock:completedBlock forURL:url createCallback:block];
    
    return operation;
}

/**
 *  同步下载文件
 *
 *  @param url           文件资源url
 *  @param progressBlock 进度回调
 *
 *  @return 返回下载的文件
 */
- (NSData *)downloadFileWithURL:(NSURL *)url progress:(SSNFileDownloaderProgressBlock)progressBlock {
    
    __block BOOL finish = NO;//不需要加锁，单次修改，反复check
    __block NSData *result = nil;
    
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRetain(runloop);
    
    SSNFileDownloaderCompletedBlock completed = ^(NSData *data, NSError *error, BOOL finished) {
        
        if (finished && [data length]) {
            result = data;
        }
        
        finish = YES;
        
        CFRunLoopStop(runloop);
        CFRelease(runloop);
    };
    
    [self downloadFileWithURL:url progress:progressBlock completed:completed];//completed必须回调，否则runloop泄漏
    
    [NSThread ssn_runloopBlockUntilCondition:^SSNBreak{ return finish; } atSpellTime:120];
    
    return result;
}


- (void)addProgressCallback:(SSNFileDownloaderProgressBlock)progressBlock andCompletedBlock:(SSNFileDownloaderCompletedBlock)completedBlock forURL:(NSURL *)url createCallback:(SSNFileDownloaderCancelBlock)createCallback {
    // The URL will be used as the key to the callbacks dictionary so it cannot be nil. If it is nil immediately call the completed block with no image or data.
    if (url == nil) {
        if (completedBlock != nil) {
            completedBlock(nil, nil, NO);
        }
        return;
    }
    
    dispatch_barrier_sync(self.barrierQueue, ^{
        BOOL first = NO;
        
        if (!self.URLCallbacks[url]) {
            self.URLCallbacks[url] = [[NSMutableArray alloc] initWithCapacity:1];
            first = YES;
        }
        
        // Handle single download of simultaneous download request for the same URL
        NSMutableArray *callbacksForURL = self.URLCallbacks[url];
        NSMutableDictionary *callbacks = [[NSMutableDictionary alloc] initWithCapacity:2];
        if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
        if (completedBlock) callbacks[kCompletedCallbackKey] = [completedBlock copy];
        [callbacksForURL addObject:callbacks];
        self.URLCallbacks[url] = callbacksForURL;
        
        if (first) {
            createCallback();
        }
    });
}

- (NSArray *)callbacksForURL:(NSURL *)url {
    __block NSArray *callbacksForURL;
    dispatch_sync(self.barrierQueue, ^{
        callbacksForURL = self.URLCallbacks[url];
    });
    return [callbacksForURL copy];
}

- (void)removeCallbacksForURL:(NSURL *)url {
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.URLCallbacks removeObjectForKey:url];
    });
}

@end

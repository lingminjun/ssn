//
//  SSNFileDownloadOperation.m
//  ssn
//
//  Created by lingminjun on 15/4/2.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "SSNFileDownloadOperation.h"
#import "NSObject+SSNBlock.h"


@interface SSNFileDownloadOperation () <NSURLConnectionDataDelegate>

@property (copy, nonatomic) SSNFileDownloaderProgressBlock progressBlock;
@property (copy, nonatomic) SSNFileDownloaderCompletedBlock completedBlock;
@property (copy, nonatomic) SSNFileDownloaderCancelBlock cancelBlock;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@property (assign, nonatomic) NSInteger expectedSize;
@property (strong, nonatomic) NSMutableData *fileData;

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, atomic) NSThread *thread;

#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
#endif

@end

@implementation SSNFileDownloadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithRequest:(NSURLRequest *)request progress:(SSNFileDownloaderProgressBlock)progressBlock completed:(SSNFileDownloaderCompletedBlock)completedBlock cancelled:(SSNFileDownloaderCancelBlock)cancelBlock {
    self = [super init];
    if (self) {
        _request = request;
        _progressBlock = [progressBlock copy];
        _completedBlock = [completedBlock copy];
        _cancelBlock = [cancelBlock copy];
        _executing = NO;
        _finished = NO;
        _expectedSize = 0;
    }
    return self;
}

- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        if (self.continueDownloadInBackground) {
            
            __weak __typeof__ (self) wself = self;
            self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                __strong __typeof (wself) sself = wself; if (!sself) { return ; }
                
                if (sself) {
                    [sself cancel];
                    
                    [[UIApplication sharedApplication] endBackgroundTask:sself.backgroundTaskId];
                    sself.backgroundTaskId = UIBackgroundTaskInvalid;
                }
            }];
        }
#endif
        
        self.executing = YES;
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
        self.thread = [NSThread currentThread];
    }
    
    [self.connection start];
    
    if (self.connection) {
        if (self.progressBlock) {
            self.progressBlock(0, NSURLResponseUnknownLength);
        }
        
        NSDictionary *info = @{SSNDownloadURKey:self.request.URL};
        __weak __typeof__ (self) wself = self;
        [self ssn_mainThreadAsyncBlock:^{ __strong __typeof (wself) sself = wself; if (!sself) { return ; }
            [[NSNotificationCenter defaultCenter] postNotificationName:SSNStartDownloadNotification object:sself userInfo:info];
        }];
        
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
            // Make sure to run the runloop in our background thread so it can process downloaded data
            // Note: we use a timeout to work around an issue with NSURLConnection cancel under iOS 5
            //       not waking up the runloop, leading to dead threads (see https://github.com/rs/SDWebImage/issues/466)
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, false);
        }
        else {
            CFRunLoopRun();
        }
        
        if (!self.isFinished) {
            [self.connection cancel];
            [self connection:self.connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:@{NSURLErrorFailingURLErrorKey : self.request.URL}]];
        }
    }
    else {
        if (self.completedBlock) {
            self.completedBlock(nil, [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Connection can't be initialized"}], YES);
        }
    }
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
#endif
}

- (void)cancel {
    @synchronized (self) {
        if (self.thread) {
            [self performSelector:@selector(cancelInternalAndStop) onThread:self.thread withObject:nil waitUntilDone:NO];
        }
        else {
            [self cancelInternal];
        }
    }
}

- (void)cancelInternalAndStop {
    if (self.isFinished) return;
    [self cancelInternal];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)cancelInternal {
    if (self.isFinished) return;
    [super cancel];
    if (self.cancelBlock) self.cancelBlock();
    
    if (self.connection) {
        [self.connection cancel];
        
        NSDictionary *info = @{SSNDownloadURKey:self.request.URL};
        __weak __typeof__ (self) wself = self;
        [self ssn_mainThreadAsyncBlock:^{ __strong __typeof (wself) sself = wself; if (!sself) { return ; }
            [[NSNotificationCenter defaultCenter] postNotificationName:SSNStopDownloadNotification object:sself userInfo:info];
        }];
        
        // As we cancelled the connection, its callback won't be called and thus won't
        // maintain the isFinished and isExecuting flags.
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }
    
    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    self.cancelBlock = nil;
    self.completedBlock = nil;
    self.progressBlock = nil;
    self.connection = nil;
    self.fileData = nil;
    self.thread = nil;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (![response respondsToSelector:@selector(statusCode)] || [((NSHTTPURLResponse *)response) statusCode] < 400) {
        NSUInteger expected = response.expectedContentLength > 0 ? (NSUInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
        if (self.progressBlock) {
            self.progressBlock(0, expected);
        }
        
        self.fileData = [[NSMutableData alloc] initWithCapacity:expected];
    }
    else {
        [self.connection cancel];
        
        NSDictionary *info = @{SSNDownloadURKey:self.request.URL};
        __weak __typeof__ (self) wself = self;
        [self ssn_mainThreadAsyncBlock:^{ __strong __typeof (wself) sself = wself; if (!sself) { return ; }
            [[NSNotificationCenter defaultCenter] postNotificationName:SSNStopDownloadNotification object:nil userInfo:info];
        }];
        
        if (self.completedBlock) {
            self.completedBlock(nil, [NSError errorWithDomain:NSURLErrorDomain code:[((NSHTTPURLResponse *)response) statusCode] userInfo:nil], YES);
        }
        CFRunLoopStop(CFRunLoopGetCurrent());
        [self done];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.fileData appendData:data];
    
    if (self.progressBlock) {
        self.progressBlock(self.fileData.length, self.expectedSize);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    SSNFileDownloaderCompletedBlock completionBlock = self.completedBlock;
    
    @synchronized(self) {
        
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.thread = nil;
        self.connection = nil;
        
        NSDictionary *info = @{SSNDownloadURKey:self.request.URL};
        __weak __typeof__ (self) wself = self;
        [self ssn_mainThreadAsyncBlock:^{ __strong __typeof (wself) sself = wself; if (!sself) { return ; }
            [[NSNotificationCenter defaultCenter] postNotificationName:SSNStopDownloadNotification object:nil userInfo:info];
        }];
        
    }
    
    if (completionBlock)
    {
        completionBlock(self.fileData, nil, YES);
    }
    
    self.completionBlock = nil;
    [self done];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    CFRunLoopStop(CFRunLoopGetCurrent());
    
    NSDictionary *info = @{SSNDownloadURKey:self.request.URL};
    __weak __typeof__ (self) wself = self;
    [self ssn_mainThreadAsyncBlock:^{ __strong __typeof (wself) sself = wself; if (!sself) { return ; }
        [[NSNotificationCenter defaultCenter] postNotificationName:SSNStopDownloadNotification object:nil userInfo:info];
    }];
    
    if (self.completedBlock) {
        self.completedBlock(nil, error, YES);
    }
    
    [self done];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        // Prevents caching of responses
        return nil;
    }
    else {
        return cachedResponse;
    }
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection __unused *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    } else {
        if ([challenge previousFailureCount] == 0) {
            if (self.credential) {
                [[challenge sender] useCredential:self.credential forAuthenticationChallenge:challenge];
            } else {
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        } else {
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
}

@end

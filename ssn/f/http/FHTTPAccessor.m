//
//  FHTTPAccessor.m
//  ssn
//
//  Created by lingminjun on 16/9/2.
//  Copyright © 2016年 lingminjun. All rights reserved.
//

#import "FHTTPAccessor.h"

@interface FHTTPAccessor () <NSURLSessionDelegate>
@property (nonatomic,strong) NSURLSession *session;
@end

@implementation FHTTPAccessor

//- (instancetype)init {
//    return [self initWithSessionConfiguration:nil];
//}
//
//- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
//    self = [super init];
//    if (!self) {
//        return nil;
//    }
//    
//    if (!configuration) {
//        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    }
//    
//    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
//    operationQueue.maxConcurrentOperationCount = 4;
//    
//    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:operationQueue];
//    
//    self.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    self.securityPolicy = [AFSecurityPolicy defaultPolicy];
//    
//#if !TARGET_OS_WATCH
//    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
//#endif
//    
//    self.mutableTaskDelegatesKeyedByTaskIdentifier = [[NSMutableDictionary alloc] init];
//    
//    self.lock = [[NSLock alloc] init];
//    self.lock.name = AFURLSessionManagerLockName;
//    
//    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
//        for (NSURLSessionDataTask *task in dataTasks) {
//            [self addDelegateForDataTask:task uploadProgress:nil downloadProgress:nil completionHandler:nil];
//        }
//        
//        for (NSURLSessionUploadTask *uploadTask in uploadTasks) {
//            [self addDelegateForUploadTask:uploadTask progress:nil completionHandler:nil];
//        }
//        
//        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
//            [self addDelegateForDownloadTask:downloadTask progress:nil destination:nil completionHandler:nil];
//        }
//    }];
//    
//    return self;
//}
//
//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//#pragma mark -
//
//- (NSString *)taskDescriptionForSessionTasks {
//    return [NSString stringWithFormat:@"%p", self];
//}
//
//- (void)taskDidResume:(NSNotification *)notification {
//    NSURLSessionTask *task = notification.object;
//    if ([task respondsToSelector:@selector(taskDescription)]) {
//        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidResumeNotification object:task];
//            });
//        }
//    }
//}
//
//- (void)taskDidSuspend:(NSNotification *)notification {
//    NSURLSessionTask *task = notification.object;
//    if ([task respondsToSelector:@selector(taskDescription)]) {
//        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidSuspendNotification object:task];
//            });
//        }
//    }
//}
//
//#pragma mark -
//
//- (AFURLSessionManagerTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
//    NSParameterAssert(task);
//    
//    AFURLSessionManagerTaskDelegate *delegate = nil;
//    [self.lock lock];
//    delegate = self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)];
//    [self.lock unlock];
//    
//    return delegate;
//}
//
//- (void)setDelegate:(AFURLSessionManagerTaskDelegate *)delegate
//            forTask:(NSURLSessionTask *)task
//{
//    NSParameterAssert(task);
//    NSParameterAssert(delegate);
//    
//    [self.lock lock];
//    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = delegate;
//    [delegate setupProgressForTask:task];
//    [self addNotificationObserverForTask:task];
//    [self.lock unlock];
//}
//
//- (void)addDelegateForDataTask:(NSURLSessionDataTask *)dataTask
//                uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
//              downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
//             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
//{
//    AFURLSessionManagerTaskDelegate *delegate = [[AFURLSessionManagerTaskDelegate alloc] init];
//    delegate.manager = self;
//    delegate.completionHandler = completionHandler;
//    
//    dataTask.taskDescription = self.taskDescriptionForSessionTasks;
//    [self setDelegate:delegate forTask:dataTask];
//    
//    delegate.uploadProgressBlock = uploadProgressBlock;
//    delegate.downloadProgressBlock = downloadProgressBlock;
//}
//
//- (void)addDelegateForUploadTask:(NSURLSessionUploadTask *)uploadTask
//                        progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
//               completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
//{
//    AFURLSessionManagerTaskDelegate *delegate = [[AFURLSessionManagerTaskDelegate alloc] init];
//    delegate.manager = self;
//    delegate.completionHandler = completionHandler;
//    
//    uploadTask.taskDescription = self.taskDescriptionForSessionTasks;
//    
//    [self setDelegate:delegate forTask:uploadTask];
//    
//    delegate.uploadProgressBlock = uploadProgressBlock;
//}
//
//- (void)addDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
//                          progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
//                       destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
//                 completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
//{
//    AFURLSessionManagerTaskDelegate *delegate = [[AFURLSessionManagerTaskDelegate alloc] init];
//    delegate.manager = self;
//    delegate.completionHandler = completionHandler;
//    
//    if (destination) {
//        delegate.downloadTaskDidFinishDownloading = ^NSURL * (NSURLSession * __unused session, NSURLSessionDownloadTask *task, NSURL *location) {
//            return destination(location, task.response);
//        };
//    }
//    
//    downloadTask.taskDescription = self.taskDescriptionForSessionTasks;
//    
//    [self setDelegate:delegate forTask:downloadTask];
//    
//    delegate.downloadProgressBlock = downloadProgressBlock;
//}
//
//- (void)removeDelegateForTask:(NSURLSessionTask *)task {
//    NSParameterAssert(task);
//    
//    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
//    [self.lock lock];
//    [delegate cleanUpProgressForTask:task];
//    [self removeNotificationObserverForTask:task];
//    [self.mutableTaskDelegatesKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
//    [self.lock unlock];
//}
//
//#pragma mark -
//
//- (NSArray *)tasksForKeyPath:(NSString *)keyPath {
//    __block NSArray *tasks = nil;
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
//        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
//            tasks = dataTasks;
//        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
//            tasks = uploadTasks;
//        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
//            tasks = downloadTasks;
//        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
//            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
//        }
//        
//        dispatch_semaphore_signal(semaphore);
//    }];
//    
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    
//    return tasks;
//}
//
//- (NSArray *)tasks {
//    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
//}
//
//- (NSArray *)dataTasks {
//    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
//}
//
//- (NSArray *)uploadTasks {
//    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
//}
//
//- (NSArray *)downloadTasks {
//    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
//}
//
//#pragma mark -
//
//- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (cancelPendingTasks) {
//            [self.session invalidateAndCancel];
//        } else {
//            [self.session finishTasksAndInvalidate];
//        }
//    });
//}
//
//#pragma mark -
//
//- (void)setResponseSerializer:(id <AFURLResponseSerialization>)responseSerializer {
//    NSParameterAssert(responseSerializer);
//    
//    _responseSerializer = responseSerializer;
//}
//
//#pragma mark -
//- (void)addNotificationObserverForTask:(NSURLSessionTask *)task {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidResume:) name:AFNSURLSessionTaskDidResumeNotification object:task];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidSuspend:) name:AFNSURLSessionTaskDidSuspendNotification object:task];
//}
//
//- (void)removeNotificationObserverForTask:(NSURLSessionTask *)task {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNSURLSessionTaskDidSuspendNotification object:task];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNSURLSessionTaskDidResumeNotification object:task];
//}
//
//#pragma mark -
//
//- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
//                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
//{
//    return [self dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
//}
//
//- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
//                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
//                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
//                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {
//    
//    __block NSURLSessionDataTask *dataTask = nil;
//    url_session_manager_create_task_safely(^{
//        dataTask = [self.session dataTaskWithRequest:request];
//    });
//    
//    [self addDelegateForDataTask:dataTask uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:completionHandler];
//    
//    return dataTask;
//}
//
//#pragma mark -
//
//- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
//                                         fromFile:(NSURL *)fileURL
//                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
//                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
//{
//    __block NSURLSessionUploadTask *uploadTask = nil;
//    url_session_manager_create_task_safely(^{
//        uploadTask = [self.session uploadTaskWithRequest:request fromFile:fileURL];
//    });
//    
//    if (!uploadTask && self.attemptsToRecreateUploadTasksForBackgroundSessions && self.session.configuration.identifier) {
//        for (NSUInteger attempts = 0; !uploadTask && attempts < AFMaximumNumberOfAttemptsToRecreateBackgroundSessionUploadTask; attempts++) {
//            uploadTask = [self.session uploadTaskWithRequest:request fromFile:fileURL];
//        }
//    }
//    
//    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];
//    
//    return uploadTask;
//}
//
//- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
//                                         fromData:(NSData *)bodyData
//                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
//                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
//{
//    __block NSURLSessionUploadTask *uploadTask = nil;
//    url_session_manager_create_task_safely(^{
//        uploadTask = [self.session uploadTaskWithRequest:request fromData:bodyData];
//    });
//    
//    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];
//    
//    return uploadTask;
//}
//
//- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
//                                                 progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
//                                        completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
//{
//    __block NSURLSessionUploadTask *uploadTask = nil;
//    url_session_manager_create_task_safely(^{
//        uploadTask = [self.session uploadTaskWithStreamedRequest:request];
//    });
//    
//    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];
//    
//    return uploadTask;
//}
//
//#pragma mark -
//
//- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
//                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
//                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
//                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
//{
//    __block NSURLSessionDownloadTask *downloadTask = nil;
//    url_session_manager_create_task_safely(^{
//        downloadTask = [self.session downloadTaskWithRequest:request];
//    });
//    
//    [self addDelegateForDownloadTask:downloadTask progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
//    
//    return downloadTask;
//}
//
//- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
//                                                progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
//                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
//                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
//{
//    __block NSURLSessionDownloadTask *downloadTask = nil;
//    url_session_manager_create_task_safely(^{
//        downloadTask = [self.session downloadTaskWithResumeData:resumeData];
//    });
//    
//    [self addDelegateForDownloadTask:downloadTask progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
//    
//    return downloadTask;
//}
//
//#pragma mark -
//- (NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task {
//    return [[self delegateForTask:task] uploadProgress];
//}
//
//- (NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task {
//    return [[self delegateForTask:task] downloadProgress];
//}
//
//#pragma mark -
//
//- (void)setSessionDidBecomeInvalidBlock:(void (^)(NSURLSession *session, NSError *error))block {
//    self.sessionDidBecomeInvalid = block;
//}
//
//- (void)setSessionDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential))block {
//    self.sessionDidReceiveAuthenticationChallenge = block;
//}
//
//- (void)setDidFinishEventsForBackgroundURLSessionBlock:(void (^)(NSURLSession *session))block {
//    self.didFinishEventsForBackgroundURLSession = block;
//}
//
//#pragma mark -
//
//- (void)setTaskNeedNewBodyStreamBlock:(NSInputStream * (^)(NSURLSession *session, NSURLSessionTask *task))block {
//    self.taskNeedNewBodyStream = block;
//}
//
//- (void)setTaskWillPerformHTTPRedirectionBlock:(NSURLRequest * (^)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request))block {
//    self.taskWillPerformHTTPRedirection = block;
//}
//
//- (void)setTaskDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential))block {
//    self.taskDidReceiveAuthenticationChallenge = block;
//}
//
//- (void)setTaskDidSendBodyDataBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block {
//    self.taskDidSendBodyData = block;
//}
//
//- (void)setTaskDidCompleteBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, NSError *error))block {
//    self.taskDidComplete = block;
//}
//
//#pragma mark -
//
//- (void)setDataTaskDidReceiveResponseBlock:(NSURLSessionResponseDisposition (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response))block {
//    self.dataTaskDidReceiveResponse = block;
//}
//
//- (void)setDataTaskDidBecomeDownloadTaskBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))block {
//    self.dataTaskDidBecomeDownloadTask = block;
//}
//
//- (void)setDataTaskDidReceiveDataBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))block {
//    self.dataTaskDidReceiveData = block;
//}
//
//- (void)setDataTaskWillCacheResponseBlock:(NSCachedURLResponse * (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse))block {
//    self.dataTaskWillCacheResponse = block;
//}
//
//#pragma mark -
//
//- (void)setDownloadTaskDidFinishDownloadingBlock:(NSURL * (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block {
//    self.downloadTaskDidFinishDownloading = block;
//}
//
//- (void)setDownloadTaskDidWriteDataBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block {
//    self.downloadTaskDidWriteData = block;
//}
//
//- (void)setDownloadTaskDidResumeBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes))block {
//    self.downloadTaskDidResume = block;
//}
//
//#pragma mark - NSObject
//
//- (NSString *)description {
//    return [NSString stringWithFormat:@"<%@: %p, session: %@, operationQueue: %@>", NSStringFromClass([self class]), self, self.session, self.operationQueue];
//}
//
//- (BOOL)respondsToSelector:(SEL)selector {
//    if (selector == @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)) {
//        return self.taskWillPerformHTTPRedirection != nil;
//    } else if (selector == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
//        return self.dataTaskDidReceiveResponse != nil;
//    } else if (selector == @selector(URLSession:dataTask:willCacheResponse:completionHandler:)) {
//        return self.dataTaskWillCacheResponse != nil;
//    } else if (selector == @selector(URLSessionDidFinishEventsForBackgroundURLSession:)) {
//        return self.didFinishEventsForBackgroundURLSession != nil;
//    }
//    
//    return [[self class] instancesRespondToSelector:selector];
//}
//
//#pragma mark - NSURLSessionDelegate
//
//- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
//{
//    NSLog(@"FHTTPAccessor session did become invalid! \n %@", error);
//}
//
//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge 
//completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
//{
//    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//    __block NSURLCredential *credential = nil;
//    
//    if (self.sessionDidReceiveAuthenticationChallenge) {
//        disposition = self.sessionDidReceiveAuthenticationChallenge(session, challenge, &credential);
//    } else {
//        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//            if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
//                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//                if (credential) {
//                    disposition = NSURLSessionAuthChallengeUseCredential;
//                } else {
//                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//                }
//            } else {
//                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
//            }
//        } else {
//            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//        }
//    }
//    
//    if (completionHandler) {
//        completionHandler(disposition, credential);
//    }
//}
//
//#pragma mark - NSURLSessionTaskDelegate
//
//- (void)URLSession:(NSURLSession *)session
//              task:(NSURLSessionTask *)task
//willPerformHTTPRedirection:(NSHTTPURLResponse *)response
//        newRequest:(NSURLRequest *)request
// completionHandler:(void (^)(NSURLRequest *))completionHandler
//{
//    NSURLRequest *redirectRequest = request;
//    
//    if (self.taskWillPerformHTTPRedirection) {
//        redirectRequest = self.taskWillPerformHTTPRedirection(session, task, response, request);
//    }
//    
//    if (completionHandler) {
//        completionHandler(redirectRequest);
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session
//              task:(NSURLSessionTask *)task
//didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
//{
//    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//    __block NSURLCredential *credential = nil;
//    
//    if (self.taskDidReceiveAuthenticationChallenge) {
//        disposition = self.taskDidReceiveAuthenticationChallenge(session, task, challenge, &credential);
//    } else {
//        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//            if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
//                disposition = NSURLSessionAuthChallengeUseCredential;
//                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//            } else {
//                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
//            }
//        } else {
//            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//        }
//    }
//    
//    if (completionHandler) {
//        completionHandler(disposition, credential);
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session
//              task:(NSURLSessionTask *)task
// needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
//{
//    NSInputStream *inputStream = nil;
//    
//    if (self.taskNeedNewBodyStream) {
//        inputStream = self.taskNeedNewBodyStream(session, task);
//    } else if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
//        inputStream = [task.originalRequest.HTTPBodyStream copy];
//    }
//    
//    if (completionHandler) {
//        completionHandler(inputStream);
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session
//              task:(NSURLSessionTask *)task
//   didSendBodyData:(int64_t)bytesSent
//    totalBytesSent:(int64_t)totalBytesSent
//totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
//{
//    
//    int64_t totalUnitCount = totalBytesExpectedToSend;
//    if(totalUnitCount == NSURLSessionTransferSizeUnknown) {
//        NSString *contentLength = [task.originalRequest valueForHTTPHeaderField:@"Content-Length"];
//        if(contentLength) {
//            totalUnitCount = (int64_t) [contentLength longLongValue];
//        }
//    }
//    
//    if (self.taskDidSendBodyData) {
//        self.taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalUnitCount);
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session
//              task:(NSURLSessionTask *)task
//didCompleteWithError:(NSError *)error
//{
//    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
//    
//    // delegate may be nil when completing a task in the background
//    if (delegate) {
//        [delegate URLSession:session task:task didCompleteWithError:error];
//        
//        [self removeDelegateForTask:task];
//    }
//    
//    if (self.taskDidComplete) {
//        self.taskDidComplete(session, task, error);
//    }
//}
//
//#pragma mark - NSURLSessionDataDelegate
//
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
//didReceiveResponse:(NSURLResponse *)response
// completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
//{
//    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
//    
//    if (self.dataTaskDidReceiveResponse) {
//        disposition = self.dataTaskDidReceiveResponse(session, dataTask, response);
//    }
//    
//    if (completionHandler) {
//        completionHandler(disposition);
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
//didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
//{
//    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
//    if (delegate) {
//        [self removeDelegateForTask:dataTask];
//        [self setDelegate:delegate forTask:downloadTask];
//    }
//    
//    if (self.dataTaskDidBecomeDownloadTask) {
//        self.dataTaskDidBecomeDownloadTask(session, dataTask, downloadTask);
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
//    didReceiveData:(NSData *)data
//{
//    
//    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
//    [delegate URLSession:session dataTask:dataTask didReceiveData:data];
//    
//    if (self.dataTaskDidReceiveData) {
//        self.dataTaskDidReceiveData(session, dataTask, data);
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
// willCacheResponse:(NSCachedURLResponse *)proposedResponse
// completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
//{
//    NSCachedURLResponse *cachedResponse = proposedResponse;
//    
//    if (self.dataTaskWillCacheResponse) {
//        cachedResponse = self.dataTaskWillCacheResponse(session, dataTask, proposedResponse);
//    }
//    
//    if (completionHandler) {
//        completionHandler(cachedResponse);
//    }
//}
//
//- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
//    if (self.didFinishEventsForBackgroundURLSession) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.didFinishEventsForBackgroundURLSession(session);
//        });
//    }
//}
//
//#pragma mark - NSURLSessionDownloadDelegate
//
//- (void)URLSession:(NSURLSession *)session
//      downloadTask:(NSURLSessionDownloadTask *)downloadTask
//didFinishDownloadingToURL:(NSURL *)location
//{
//    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
//    if (self.downloadTaskDidFinishDownloading) {
//        NSURL *fileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
//        if (fileURL) {
//            delegate.downloadFileURL = fileURL;
//            NSError *error = nil;
//            [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error];
//            if (error) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:error.userInfo];
//            }
//            
//            return;
//        }
//    }
//    
//    if (delegate) {
//        [delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session
//      downloadTask:(NSURLSessionDownloadTask *)downloadTask
//      didWriteData:(int64_t)bytesWritten
// totalBytesWritten:(int64_t)totalBytesWritten
//totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
//{
//    if (self.downloadTaskDidWriteData) {
//        self.downloadTaskDidWriteData(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session
//      downloadTask:(NSURLSessionDownloadTask *)downloadTask
// didResumeAtOffset:(int64_t)fileOffset
//expectedTotalBytes:(int64_t)expectedTotalBytes
//{
//    if (self.downloadTaskDidResume) {
//        self.downloadTaskDidResume(session, downloadTask, fileOffset, expectedTotalBytes);
//    }
//}
//
//#pragma mark - NSSecureCoding
//
//+ (BOOL)supportsSecureCoding {
//    return YES;
//}
//
//- (instancetype)initWithCoder:(NSCoder *)decoder {
//    NSURLSessionConfiguration *configuration = [decoder decodeObjectOfClass:[NSURLSessionConfiguration class] forKey:@"sessionConfiguration"];
//    
//    self = [self initWithSessionConfiguration:configuration];
//    if (!self) {
//        return nil;
//    }
//    
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)coder {
//    [coder encodeObject:self.session.configuration forKey:@"sessionConfiguration"];
//}
//
//#pragma mark - NSCopying
//
//- (instancetype)copyWithZone:(NSZone *)zone {
//    return [[[self class] allocWithZone:zone] initWithSessionConfiguration:self.session.configuration];
//}

@end

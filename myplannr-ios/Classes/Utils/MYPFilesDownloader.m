//
//  MYPFilesDownloader.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 13/11/2016.
//
//

#import "MYPFilesDownloader.h"
#import "MYPFileUtils.h"
#import "MYPConstants.h"

static CGFloat const kRequestTimeoutInterval = 90.0f;

@interface MYPFilesDownloader ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableDictionary<NSURL*, NSURL*> *downloadedFiles; // network url, local url

@end

@implementation MYPFilesDownloader

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downloadedFiles = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public methods

- (void)downloadFilesAtURLs:(NSArray<NSURL *> *)urls completion:(MultipleFilesDownloadCompletionHandler)handler {
    const NSInteger count = urls.count;
    __block NSInteger requestsCompleted = 0;
    NSMutableArray *errorsArray = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSURL *documentURL in urls) {
            
            void (^taskHandler)(NSURL*, NSURLResponse*, NSError *) =
            ^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error)
            {
                requestsCompleted++;
                
                if (error) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    NSInteger code = httpResponse.statusCode;
                    NSLog(@"downloadTaskWithRequest:downloadTaskWithRequest: - %@ (statusCode=%lu)", error, (long) code);
                    [errorsArray addObject:error];
                } else {
                    /* Open the downloaded file for reading */
                    NSError *readError = nil;
                    [NSFileHandle fileHandleForReadingFromURL:location error:&readError];
                    if (readError) {
                        NSLog(@"[NSFileHandle fileHandleForReadingFromURL:error:] - %@", readError);
                        [errorsArray addObject:readError];
                        [MYPFileUtils removeFilesAtURLs:@[location] error:nil];
                    } else {
                        /* Move the file outside of /tmp directory */
                        NSURL *docsDir = [MYPFileUtils downloadedDocumentsDirectory];
                        NSURL *newLocation = [NSURL URLWithString:documentURL.lastPathComponent relativeToURL:docsDir];
                       
                        // remove any previously existing file with this name
                        if ([[NSFileManager defaultManager] fileExistsAtPath:newLocation.path]) {
                            [MYPFileUtils removeFilesAtURLs:@[newLocation] error:nil];
                        }
                        
                        NSError *moveError = nil;
                        if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:newLocation error:&moveError]) {
                            NSLog(@"NSFileManager moveItemAtURL:toURL:error: - %@", moveError);
                            [MYPFileUtils removeFilesAtURLs:@[location, newLocation] error:nil];
                            [errorsArray addObject:moveError];
                        } else {
                            [self.downloadedFiles setObject:newLocation forKey:response.URL];
                        }
                    }
                }
                
                if (requestsCompleted == count) {
                    [self notifyHandler:handler urls:self.downloadedFiles.copy errors:errorsArray];
                    [self.downloadedFiles removeAllObjects];
                    self.session = nil;
                }
            };
            
            NSURLRequest *request = [NSURLRequest requestWithURL:documentURL];
            NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request
                                                                 completionHandler:taskHandler];
            [task resume];
        }
    });
}

- (void)downloadFileAtURL:(NSURL *)url completion:(SingleFileDownloadCompletionHandler)handler {
    [self downloadFilesAtURLs:@[url] completion:^(NSDictionary *results, NSArray *errors) {
        if (errors.count > 0) {
            NSError *e = errors.firstObject;
            [self notifyHandler:handler url:nil error:e];
        } else {
            NSURL *url = results.allValues.firstObject;
            [self notifyHandler:handler url:url error:nil];
        }
    }];
}

- (void)cancelRequests {
    [self.session invalidateAndCancel];
    self.session = nil;
    
    if (self.downloadedFiles.count > 0) {
        [MYPFileUtils removeFilesAtURLs:self.downloadedFiles.allValues error:nil];
        [self.downloadedFiles removeAllObjects];
    }
}

#pragma mark - Private properties

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        configuration.timeoutIntervalForRequest = kRequestTimeoutInterval;
        self.session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _session;
}

#pragma mark - Private methods

- (void)notifyHandler:(SingleFileDownloadCompletionHandler)handler url:(NSURL *)url error:(NSError *)error {
    if (handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(url, error);
        });
    }
}

- (void)notifyHandler:(MultipleFilesDownloadCompletionHandler)handler
                 urls:(NSDictionary *)results
               errors:(NSArray *)errors
{
    if (handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(results, errors);
        });
    }
}

@end

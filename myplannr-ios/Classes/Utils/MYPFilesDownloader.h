//
//  MYPFilesDownloader.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 13/11/2016.
//
//

#import <Foundation/Foundation.h>

typedef void(^SingleFileDownloadCompletionHandler) (NSURL *fileURL, NSError *error);
typedef void(^MultipleFilesDownloadCompletionHandler) (NSDictionary<NSURL*, NSURL*> *results, NSArray *errors);

@interface MYPFilesDownloader : NSObject

- (void)downloadFilesAtURLs:(NSArray<NSURL *>*)urls completion:(MultipleFilesDownloadCompletionHandler)handler;

- (void)downloadFileAtURL:(NSURL *)url completion:(SingleFileDownloadCompletionHandler)handler;

- (void)cancelRequests;

@end

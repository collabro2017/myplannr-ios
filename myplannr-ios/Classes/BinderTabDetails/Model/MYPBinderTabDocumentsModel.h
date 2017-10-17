//
//  MYPBinderTabDocumentsModel.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 21/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "MYPConstants.h"
#import "MYPBinderTab.h"
#import "MYPDocument.h"
#import "FCCollectionModelDelegate.h"

@interface MYPBinderTabDocumentsModel : NSObject

@property (strong, nonatomic, readonly) MYPBinderTab *binderTab;
@property (assign, nonatomic, readonly) MYPAccessType accessType;
@property (assign, nonatomic, readonly) NSUInteger documentsCount;

@property (weak, nonatomic) id<FCCollectionModelDelegate> delegate;

- (instancetype)initWithTab:(MYPBinderTab *)tab accessType:(MYPAccessType)accessType;

- (void)uploadDocument:(NSData *)document
              filename:(NSString *)filename
              mimeType:(NSString *)mimeType
            completion:(void (^)(BOOL success, NSError *error))completion;

- (void)removeDocuments:(NSArray *)documents completion:(void (^)(BOOL success, NSArray *errors))completion;

- (void)downloadDocuments:(NSArray *)documents
               completion:(void (^)(NSArray<NSURL *> *fileURLs, NSArray *errors))completion;

- (void)cancelDownloadRequests;

@end

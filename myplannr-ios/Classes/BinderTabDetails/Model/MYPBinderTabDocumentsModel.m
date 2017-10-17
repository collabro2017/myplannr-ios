//
//  MYPBinderTabDocumentsModel.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 21/02/2017.
//
//

#import "MYPBinderTabDocumentsModel.h"
#import "MYPFilesDownloader.h"
#import "MYPService.h"
#import "MYPFileUtils.h"

@interface MYPBinderTabDocumentsModel ()

@property (strong, nonatomic, readwrite) MYPBinderTab *binderTab;
@property (assign, nonatomic, readwrite) MYPAccessType accessType;

@property (strong, nonatomic) MYPFilesDownloader *filesDownloader;

@property (strong, nonatomic, readonly) NSOrderedSet<MYPDocument *> *documents;

@end

@implementation MYPBinderTabDocumentsModel

- (instancetype)initWithTab:(MYPBinderTab *)tab accessType:(MYPAccessType)accessType {
    self = [super init];
    if (self) {
        self.binderTab = tab;
        self.accessType = accessType;
        self.filesDownloader = [[MYPFilesDownloader alloc] init];
    }
    return self;
}

#pragma mark - Public methods

- (void)uploadDocument:(NSData *)document
              filename:(NSString *)filename
              mimeType:(NSString *)mimeType
            completion:(void (^)(BOOL success, NSError *error))completion
{
    MYPService *service = [MYPService sharedInstance];
    [service uploadDocument:document
                   fileName:filename
                   mimeType:mimeType
                        tab:self.binderTab
                    handler:^(MYPDocument *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         if (error) {
             if (completion) {
                 completion(NO, error);
             }
             return;
         }
         
         [self.binderTab addDocumentsObject:object];
         [service saveManagedObjectContextToPersistentStore];
         
         SEL selector = @selector(model:didInsertItemsAtIndexPaths:);
         if ([self.delegate respondsToSelector:selector]) {
             NSInteger count = self.documentsCount;
             NSIndexPath *path = [NSIndexPath indexPathForItem:(count - 1) inSection:0];
             [self.delegate model:self didInsertItemsAtIndexPaths:@[path]];
         }
         
         if (completion) {
             completion(YES, nil);
         }
     }];
}

- (void)removeDocuments:(NSArray *)documents completion:(void (^)(BOOL, NSArray *))completion {
    NSMutableOrderedSet *documentsCopy = self.documents.mutableCopy;
    NSMutableArray *errors = [NSMutableArray array];
    __block NSInteger requestsHandled = 0;
    for (MYPDocument *doc in documents) {
        if (doc.isDownloaded) {
            NSURL *fileURL = doc.downloadedDocumentURL;
            [MYPFileUtils removeFilesAtURLs:@[fileURL] error:nil];
        }
        
        [[MYPService sharedInstance] deleteDocument:doc
                                            handler:^(NSData *responseData, NSInteger statusCode, NSError *error)
         {
             requestsHandled++;
             
             if (error) {
                 [errors addObject:error];
             } else {
                 SEL selector = @selector(model:didDeleteItemsAtIndexPaths:);
                 if ([self.delegate respondsToSelector:selector]) {
                     NSInteger idx = [documentsCopy indexOfObject:doc];
                     if (idx != NSNotFound) {
                         NSIndexPath *path = [NSIndexPath indexPathForItem:idx inSection:0];
                         [self.delegate model:self didDeleteItemsAtIndexPaths:@[path]];
                         [documentsCopy removeObjectAtIndex:idx];
                     }
                 }
             }
             
             if (requestsHandled == documents.count && completion) {
                 completion(errors.count == 0, errors);
             }
         }];
    }
}

- (void)downloadDocuments:(NSArray *)documents completion:(void (^)(NSArray<NSURL *>*, NSArray*))completion {
    NSMutableArray<NSURL *> *networkURLs = [NSMutableArray arrayWithCapacity:documents.count];
    for (MYPDocument *doc in documents) {
        NSURL *documentURL = [NSURL URLWithString:doc.storageUrl];
        [networkURLs addObject:documentURL];
    }
    
    [self.filesDownloader downloadFilesAtURLs:networkURLs
                                   completion:^(NSDictionary<NSURL*, NSURL*> *results, NSArray *errors)
     {
         for (NSURL *networkURL in results.allKeys) {
             for (MYPDocument *doc in documents) {
                 NSURL *u = [NSURL URLWithString:doc.storageUrl];
                 if ([u isEqual:networkURL]) {
                     NSURL *curLocalURL = doc.downloadedDocumentURL;
                     NSURL *downloadedFileURL = results[networkURL];
                     if (curLocalURL) {
                         NSLog(@"%s: document's 'downloadedFileRelativePath' is not empty (%@)", __PRETTY_FUNCTION__, doc);
                         if (![curLocalURL isEqual:downloadedFileURL]
                             && [[NSFileManager defaultManager] fileExistsAtPath:curLocalURL.path])
                         {
                             [MYPFileUtils removeFilesAtURLs:@[curLocalURL] error:nil];
                         }
                     }
                     
                     doc.downloadedDocumentRelativePath = downloadedFileURL.relativePath;
                 }
             }
         }
         [[MYPService sharedInstance] saveManagedObjectContextToPersistentStore];
         
         if (completion) {
             completion(results.allValues, errors);
         }
         return;
     }];
}

- (void)cancelDownloadRequests {
    [self.filesDownloader cancelRequests];
}

- (NSUInteger)documentsCount {
    return self.documents.count;
}

#pragma mark - Private methods

- (NSOrderedSet<MYPDocument *> *)documents {
    return self.binderTab.documents;
}

@end

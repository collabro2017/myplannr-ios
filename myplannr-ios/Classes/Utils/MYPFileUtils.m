//
//  MYPFileUtils.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 01/03/2017.
//
//

@import MobileCoreServices;

#import "MYPFileUtils.h"

@implementation MYPFileUtils

+ (NSURL *)downloadedDocumentsDirectory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSURL *> *urls = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheDir = urls.firstObject;
    NSURL *docDir = [cacheDir URLByAppendingPathComponent:@"downloaded_documents" isDirectory:YES];
    if (![fm fileExistsAtPath:docDir.path]) {
        NSError *error = nil;
        if (![fm createDirectoryAtURL:docDir withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"%s: failed to create directory - %@", __PRETTY_FUNCTION__, error);
            return nil;
        }
    }
    return docDir;
}

+ (void)removeFilesAtURLs:(NSArray<NSURL *> *)fileURLs error:(NSError * __autoreleasing *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSError *privateError = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSURL *url in fileURLs) {
        if (![fileManager removeItemAtURL:url error:&privateError]) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, privateError);
            if (error != NULL) {
                *error = privateError;
            }
            break;
        }
    }
}

+ (NSString *)mimeTypeForItemAtURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    
    NSString *extension = [url pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)extension,
                                                            NULL);
    NSString *mimeType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType));
    if (mimeType.length == 0) {
        NSLog(@"Failed to detect mimeType for URL=%@", url.path);
        mimeType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass (kUTTypeJPEG, kUTTagClassMIMEType));
    }
    
    return mimeType;
}

@end

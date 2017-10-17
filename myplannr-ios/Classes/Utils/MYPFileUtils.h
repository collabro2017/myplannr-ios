//
//  MYPFileUtils.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 01/03/2017.
//
//

#import <Foundation/Foundation.h>

@interface MYPFileUtils : NSObject

+ (NSURL *)downloadedDocumentsDirectory;

+ (void)removeFilesAtURLs:(NSArray<NSURL *>*)fileURLs error:(NSError **)error;

+ (NSString *)mimeTypeForItemAtURL:(NSURL *)url;

@end

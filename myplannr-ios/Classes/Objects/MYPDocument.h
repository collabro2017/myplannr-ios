//
//  MYPDocument.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/08/16.
//
//

#import "MYPServiceObject.h"

typedef NS_ENUM(NSInteger, MYPDocumentType) {
    MYPDocumentTypeImageJPEG = 1,
    MYPDocumentTypeImagePNG,
    MYPDocumentTypePDF,
    MYPDocumentTypeDOC,
    MYPDocumentTypeDOCX,
    MYPDocumentTypeXLS,
    MYPDocumentTypeXLSX
};

@class MYPBinderTab;

@interface MYPDocument : MYPServiceObject

@property (nonatomic, strong) NSNumber *documentId;
@property (nonatomic, copy) NSString *storagePreviewUrl;
@property (nonatomic, copy) NSString *storageUrl;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, strong) NSNumber *fileSize;
@property (nonatomic, strong) NSNumber *imgWidth;
@property (nonatomic, strong) NSNumber *imgHeight;
@property (nonatomic, strong) MYPBinderTab *binderTab;

@property (nonatomic, copy) NSString *downloadedDocumentRelativePath;

// Transient properties

@property (nonatomic, assign, readonly) MYPDocumentType documentType;
@property (nonatomic, assign, readonly) CFStringRef documentUTI;
@property (nonatomic, assign, readonly) BOOL isImage;
@property (nonatomic, assign, readonly) BOOL isDownloaded;

@property (nonatomic, strong, readonly) NSURL *downloadedDocumentURL; // scheme + path: file:///dir/subdir/xxx.jpg

@end

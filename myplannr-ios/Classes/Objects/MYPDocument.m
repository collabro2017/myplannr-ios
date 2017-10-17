//
//  MYPDocument.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/08/16.
//
//

#import "MYPDocument.h"
#import "MYPFileUtils.h"
#import "MYPConstants.h"

@interface MYPDocument ()

@property (nonatomic, assign, readwrite) MYPDocumentType documentType;

@end

@implementation MYPDocument

@dynamic documentId;
@dynamic storageUrl;
@dynamic storagePreviewUrl;
@dynamic contentType;
@dynamic fileSize;
@dynamic imgWidth;
@dynamic imgHeight;
@dynamic binderTab;
@dynamic downloadedDocumentRelativePath;

@synthesize documentType;

+ (RKEntityMapping *)responseMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKEntityMapping *objectMapping = [super responseMappingForManagedObjectStore:store];
    [objectMapping addAttributeMappingsFromDictionary:@{
                                                        @"id"                  : @"documentId",
                                                        @"storage_url"         : @"storageUrl",
                                                        @"storage_preview_url" : @"storagePreviewUrl",
                                                        @"content_type"        : @"contentType",
                                                        @"file_size"           : @"fileSize",
                                                        @"img_width"           : @"imgWidth",
                                                        @"img_height"          : @"imgHeight"
                                                        }];
    
    objectMapping.identificationAttributes = @[@"documentId"];
    
    return objectMapping;
}

#pragma mark - Public methods & properties

- (CFStringRef)documentUTI {
    CFStringRef uti = (UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                             (__bridge CFStringRef) self.contentType,
                                                             NULL));
    return uti;
}

- (BOOL)isImage {
    return (self.documentType == MYPDocumentTypeImagePNG || self.documentType == MYPDocumentTypeImageJPEG);
}

- (BOOL)isDownloaded {
    NSString *fullPath = self.downloadedDocumentURL.path;
    return (fullPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:fullPath]);
}

- (NSURL *)downloadedDocumentURL {
    NSString *relativePath = self.downloadedDocumentRelativePath;
    if (relativePath.length == 0) {
        return nil;
    }
    
    NSURL *docsDir = [MYPFileUtils downloadedDocumentsDirectory];
    return [NSURL URLWithString:relativePath relativeToURL:docsDir];
}

#pragma mark - NSManagedObject

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self updateDocumentType];
    [self observeContentTypeProperty];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self updateDocumentType];
    [self observeContentTypeProperty];
}

- (void)willTurnIntoFault {
    [self removeObserver:self forKeyPath:@"contentType"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"contentType"]) {
        NSString *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSString *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if ([oldValue isEqual:[NSNull null]] || ![newValue isEqualToString:oldValue]) {
            [self updateDocumentType];
        }
    }
}

#pragma mark - Private methods

- (void)observeContentTypeProperty {
    [self addObserver:self
           forKeyPath:@"contentType"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
              context:nil];
}

- (void)updateDocumentType {
    NSString *uti = (__bridge NSString *) self.documentUTI;
    MYPDocumentType type = MYPDocumentTypeImageJPEG;
    if ([uti isEqualToString:[MYPConstants kUTI_JPEG]]) type = MYPDocumentTypeImageJPEG;
    else if ([uti isEqualToString:[MYPConstants kUTI_PNG]])  type = MYPDocumentTypeImagePNG;
    else if ([uti isEqualToString:[MYPConstants kUTI_PDF]])  type = MYPDocumentTypePDF;
    else if ([uti isEqualToString:[MYPConstants kUTI_XLS]])  type = MYPDocumentTypeXLS;
    else if ([uti isEqualToString:[MYPConstants kUTI_XLSX]]) type = MYPDocumentTypeXLSX;
    else if ([uti isEqualToString:[MYPConstants kUTI_DOC]])  type = MYPDocumentTypeDOC;
    else if ([uti isEqualToString:[MYPConstants kUTI_DOCX]]) type = MYPDocumentTypeDOCX;
    self.documentType = type;
}

@end

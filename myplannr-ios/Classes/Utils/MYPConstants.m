//
//  MYPConstants.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 13/10/2016.
//
//

@import MobileCoreServices;

#import "MYPConstants.h"

static NSString * kUTI_JPEG = nil;
static NSString * kUTI_PNG = nil;
static NSString * kUTI_PDF = nil;
static NSString * kUTI_XLS = nil;
static NSString * kUTI_XLSX = nil;
static NSString * kUTI_DOC = nil;
static NSString * kUTI_DOCX = nil;

NSString * const kNewAlertNotification = @"kNewAlertNotification";
NSString * const kNewAlertNotificationContentKey = @"kNewAlertNotificationContentKey";
NSString * const kImportDocumentAtURLNotification = @"kImportDocumentAtURLNotification";
NSString * const kImportDocumentAtURLNotificationURLKey = @"kImportDocumentAtURLNotificationURLKey";
NSString * const kImportDocumentAtURLNotificationSourceAppKey = @"kImportDocumentAtURLNotificationSourceAppKey";

@implementation MYPConstants

+ (void)initialize {
    if (self == [MYPConstants self]) {
        kUTI_PNG = (__bridge NSString *) kUTTypePNG;
        kUTI_JPEG = (__bridge NSString *) kUTTypeJPEG;
        kUTI_PDF = (__bridge NSString *) kUTTypePDF;
        kUTI_XLS = (__bridge NSString *)(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                                               (__bridge CFStringRef) kMimeTypeXLS,
                                                                               NULL));
        kUTI_XLSX = (__bridge NSString *)(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                                                (__bridge CFStringRef) kMimeTypeXLSX,
                                                                                NULL));
        kUTI_DOC = (__bridge NSString *)(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                                                (__bridge CFStringRef) kMimeTypeDOC,
                                                                                NULL));
        kUTI_DOCX = (__bridge NSString *)(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                                               (__bridge CFStringRef) kMimeTypeDOCX,
                                                                               NULL));
    }
}

+ (NSArray<UIColor *> *)themeColors {
    NSArray *colors = @[
                        [UIColor myp_colorWithHexInt:0x43434E],
                        [UIColor myp_colorWithHexInt:0xFC3A30],
                        [UIColor myp_colorWithHexInt:0xFFCB00],
                        [UIColor myp_colorWithHexInt:0x4CD963],
                        [UIColor myp_colorWithHexInt:0x017AFF],
                        [UIColor myp_colorWithHexInt:0xBADDC7],
                        [UIColor myp_colorWithHexInt:0xABD0E2],
                        [UIColor myp_colorWithHexInt:0xFFD3C0],
                        [UIColor myp_colorWithHexInt:0xFFABAB],
                        [UIColor myp_colorWithHexInt:0xC1AEA7]
                        ];
    return colors;
}

#pragma mark - UTIs

+ (NSString *)kUTI_PNG {
    return kUTI_PNG;
}

+ (NSString *)kUTI_JPEG {
    return kUTI_JPEG;
}

+ (NSString *)kUTI_PDF {
    return kUTI_PDF;
}

+ (NSString *)kUTI_XLS {
    return kUTI_XLS;
}

+ (NSString *)kUTI_XLSX {
    return kUTI_XLSX;
}

+ (NSString *)kUTI_DOC {
    return kUTI_DOC;
}

+ (NSString *)kUTI_DOCX {
    return kUTI_DOCX;
}

@end

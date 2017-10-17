//
//  MYPConstants.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 13/10/2016.
//
//

#import <Foundation/Foundation.h>

#define kAppStoreLink @"https://itunes.apple.com/us/app/myplannr/id1156057111?ls=1&mt=8"

#define kTermsOfServicesLink @"https://myplannr.com/privacy_policy"

#define kServerDateFormat @"dd/MM/yyyy"
#define kServerDateTimeFormat @"yyyy-MM-dd'T'HH:mm:ssZ" 
#define kClientDateFormat @"MM/dd/yyyy"

#define kCardViewCornerRadius 8.0f
#define kRoundedButtonCornerRadiusBig 20.0f
#define kRoundedButtonCornerRadiusSmall 18.0f
#define kRoundedButtonBorderWidth 2.0f

#define kAvatarMaxSizeInPixels 250.0f

#define kCardBorderColor 0xDDDDDD

#define kJPEGDocumentsCompressionQuality 0.85f

#define kDocumentMaxSizeInMB 10.0f

#define kChatAvatarSize 32.0f

/* Mime types */

#define kMimeTypeXLS @"application/vnd.ms-excel"
#define kMimeTypeXLSX @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
#define kMimeTypeDOC @"application/msword"
#define kMimeTypeDOCX @"application/vnd.openxmlformats-officedocument.wordprocessingml.document"

/* Strings */

#define kAccessTypeReadOnlyString NSLocalizedString(@"Read-only", nil)
#define kAccessTypeFullAccessString NSLocalizedString(@"Full access", nil)

/* HTTP codes */

#define kHttpCode200OK 200
#define kHttpCode401Unauthorized 401
#define kHttpCode402PaymentRequired 402
#define kHttpCode403PermissionDenied 403
#define kHttpCode404NotFound 404
#define kHttpStatus422UnprocessableEntity 422

/* Notifications */

extern NSString * const kNewAlertNotification;
extern NSString * const kNewAlertNotificationContentKey;

extern NSString * const kImportDocumentAtURLNotification;
extern NSString * const kImportDocumentAtURLNotificationURLKey;
extern NSString * const kImportDocumentAtURLNotificationSourceAppKey;

typedef NS_ENUM(int16_t, MYPAccessType) {
    MYPAccessTypeFull = 1,
    MYPAccessTypeReadOnly = 2
};

@interface MYPConstants : NSObject

+ (NSArray<UIColor *> *)themeColors;

/* UTIs */
+ (NSString *) kUTI_JPEG;
+ (NSString *) kUTI_PNG;
+ (NSString *) kUTI_PDF;
+ (NSString *) kUTI_XLS;
+ (NSString *) kUTI_XLSX;
+ (NSString *) kUTI_DOC;
+ (NSString *) kUTI_DOCX;

@end

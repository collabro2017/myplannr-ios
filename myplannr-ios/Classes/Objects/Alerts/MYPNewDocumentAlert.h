//
//  MYPNewDocumentAlert.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPAlert.h"

@interface MYPNewDocumentAlert : MYPAlert

@property (strong, nonatomic, readonly) NSNumber *binderId;
@property (strong, nonatomic, readonly) NSNumber *tabId;
@property (strong, nonatomic, readonly) NSNumber *documentId;

- (instancetype)initWithAlertType:(MYPAlertType)type
                        alertText:(NSString *)alertText
                         binderId:(NSNumber *)binderId
                            tabId:(NSNumber *)tabId
                       documentId:(NSNumber *)docId;

@end

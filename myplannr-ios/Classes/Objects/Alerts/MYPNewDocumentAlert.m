//
//  MYPNewDocumentAlert.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPNewDocumentAlert.h"

@interface MYPNewDocumentAlert ()

@property (strong, nonatomic, readwrite) NSNumber *binderId;
@property (strong, nonatomic, readwrite) NSNumber *tabId;
@property (strong, nonatomic, readwrite) NSNumber *documentId;

@end

@implementation MYPNewDocumentAlert

- (instancetype)initWithAlertType:(MYPAlertType)type
                        alertText:(NSString *)alertText
                         binderId:(NSNumber *)binderId
                            tabId:(NSNumber *)tabId
                       documentId:(NSNumber *)docId
{
    self = [super initWithAlertType:type alertText:alertText];
    if (self) {
        self.binderId = binderId;
        self.tabId = tabId;
        self.documentId = docId;
    }
    return self;
}

@end

//
//  MYPAlertsFabric.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPAlertsFabric.h"
#import "MYPChatMessageAlert.h"
#import "MYPNewInviteAlert.h"
#import "MYPNewDocumentAlert.h"
#import "MYPBinderChangedAlert.h"
#import "MYPNewTabAlert.h"

NSString * const kAlertTypeChatMessage = @"alert_new_message";
NSString * const kAlertTypeNewInvite = @"alert_new_invite";
NSString * const kAlertTypeNewDocument = @"alert_new_doc";
NSString * const kAlertTypeBinderChanged = @"alert_edit_binder";
NSString * const kAlertTypeNewTab = @"alert_new_tab";

@implementation MYPAlertsFabric

+ (MYPAlert *)createAlertFromDictionary:(NSDictionary *)dict {
    NSString *type = dict[@"type"];
    NSDictionary *aps = dict[@"aps"];
    NSString *alertText = aps[@"alert"];
    NSAssert(type.length > 0, @"type is empty or nil");
    NSAssert(alertText.length > 0, @"alert is empty or nil");
    
    NSNumber *binderId = dict[@"binder_id"];
    NSNumber *userId = dict[@"user_id"];
    NSNumber *tabId = dict[@"tabId"];
    
    MYPAlert *alert = nil;
    if ([type isEqualToString:kAlertTypeChatMessage]) {
        MYPChatMessage *msg = [[MYPChatMessage alloc] initWithDictionary:dict];
        alert = [[MYPChatMessageAlert alloc] initWithAlertType:MYPAlertTypeChatMessage
                                                     alertText:alertText
                                                       message:msg];
    }
    else if ([type isEqualToString:kAlertTypeNewInvite]) {
        alert = [[MYPNewInviteAlert alloc] initWithAlertType:MYPAlertTypeNewInvite
                                                   alertText:alertText
                                                    binderId:binderId
                                                      userId:userId];
    }
    else if ([type isEqualToString:kAlertTypeNewDocument]) {
        NSNumber *docId = dict[@"document_id"];
        alert = [[MYPNewDocumentAlert alloc] initWithAlertType:MYPAlertTypeNewDocument
                                                     alertText:alertText
                                                      binderId:binderId
                                                         tabId:tabId
                                                    documentId:docId];
    }
    else if ([type isEqualToString:kAlertTypeBinderChanged]) {
        alert = [[MYPBinderChangedAlert alloc] initWithAlertType:MYPAlertTypeBinderChanged
                                                       alertText:alertText
                                                        binderId:binderId
                                                          userId:userId];
    }
    else if ([type isEqualToString:kAlertTypeNewTab]) {
        alert = [[MYPNewTabAlert alloc] initWithAlertType:MYPAlertTypeNewTab
                                                alertText:alertText
                                                 binderId:binderId
                                                    tabId:tabId];
    }
    else {
        NSLog(@"%s: unknown alert type - %@", __PRETTY_FUNCTION__, type);
    }
    
    return alert;
}

@end

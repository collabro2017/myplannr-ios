//
//  MYPAlertsFabric.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import <Foundation/Foundation.h>
#import "MYPAlert.h"

extern NSString * const kAlertTypeChatMessage;
extern NSString * const kAlertTypeNewInvite;
extern NSString * const kAlertTypeNewDocument;
extern NSString * const kAlertTypeBinderChanged;
extern NSString * const kAlertTypeNewTab;

@interface MYPAlertsFabric : NSObject

+ (MYPAlert *)createAlertFromDictionary:(NSDictionary *)dict;

@end

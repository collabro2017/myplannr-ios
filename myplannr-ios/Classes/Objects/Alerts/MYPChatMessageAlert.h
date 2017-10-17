//
//  MYPChatMessageAlert.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPAlert.h"
#import "MYPChatMessage.h"

@interface MYPChatMessageAlert : MYPAlert

@property (strong, nonatomic, readonly) MYPChatMessage *message;

- (instancetype)initWithAlertType:(MYPAlertType)type
                        alertText:(NSString *)alertText
                          message:(MYPChatMessage *)msg;

@end

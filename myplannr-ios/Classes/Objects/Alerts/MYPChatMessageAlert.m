//
//  MYPChatMessageAlert.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPChatMessageAlert.h"

@interface MYPChatMessageAlert ()

@property (strong, nonatomic, readwrite) MYPChatMessage *message;

@end

@implementation MYPChatMessageAlert

- (instancetype)initWithAlertType:(MYPAlertType)type
                        alertText:(NSString *)alertText
                          message:(MYPChatMessage *)msg
{
    self = [super initWithAlertType:type alertText:alertText];
    if (self) {
        self.message = msg;
    }
    return self;
}

@end

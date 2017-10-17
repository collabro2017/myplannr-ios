//
//  MYPNewInviteAlert.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPNewInviteAlert.h"

@interface MYPNewInviteAlert ()

@property (strong, nonatomic, readwrite) NSNumber *binderId;
@property (strong, nonatomic, readwrite) NSNumber *userId;

@end

@implementation MYPNewInviteAlert

- (instancetype)initWithAlertType:(MYPAlertType)type
                        alertText:(NSString *)alert
                         binderId:(NSNumber *)binderId
                           userId:(NSNumber *)userId
{
    self = [super initWithAlertType:type alertText:alert];
    if (self) {
        self.binderId = binderId;
        self.userId = userId;
    }
    return self;
}

@end

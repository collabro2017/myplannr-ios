//
//  MYPBinderChangedAlert.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPBinderChangedAlert.h"

@interface MYPBinderChangedAlert ()

@property (strong, nonatomic, readwrite) NSNumber *binderId;
@property (strong, nonatomic, readwrite) NSNumber *userId;

@end

@implementation MYPBinderChangedAlert

- (instancetype)initWithAlertType:(MYPAlertType)type
                        alertText:(NSString *)alertText
                         binderId:(NSNumber *)binderId
                           userId:(NSNumber *)userId
{
    self = [super initWithAlertType:type alertText:alertText];
    if (self) {
        self.binderId = binderId;
        self.userId = userId;
    }
    return self;
}

@end

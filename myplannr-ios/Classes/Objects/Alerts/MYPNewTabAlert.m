//
//  MYPNewTabAlert.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPNewTabAlert.h"

@interface MYPNewTabAlert ()

@property (strong, nonatomic, readwrite) NSNumber *binderId;
@property (strong, nonatomic, readwrite) NSNumber *tabId;

@end

@implementation MYPNewTabAlert

- (instancetype)initWithAlertType:(MYPAlertType)type
                               alertText:(NSString *)alert
                                binderId:(NSNumber *)binderId
                                   tabId:(NSNumber *)tabId
{
    self = [super initWithAlertType:type alertText:alert];
    if (self) {
        self.binderId = binderId;
        self.tabId = tabId;
    }
    return self;
}

@end

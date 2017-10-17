//
//  MYPAlert.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPAlert.h"

@interface MYPAlert ()

@property (strong, nonatomic, readwrite) NSString *alertText;
@property (assign, nonatomic, readwrite) MYPAlertType alertType;

@end

@implementation MYPAlert

- (instancetype)initWithAlertType:(MYPAlertType)type alertText:(NSString *)alertText {
    self = [super init];
    if (self) {
        self.alertType = type;
        self.alertText = alertText;
    }
    return self;
}

- (instancetype)init {
    return [self initWithAlertType:0 alertText:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type=%lu, alert_text=%@", (long)self.alertType, self.alertText];
}

@end

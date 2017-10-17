//
//  MYPBinderChangedAlert.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPAlert.h"

@interface MYPBinderChangedAlert : MYPAlert

@property (strong, nonatomic, readonly) NSNumber *binderId;
@property (strong, nonatomic, readonly) NSNumber *userId;

- (instancetype)initWithAlertType:(MYPAlertType)type
                        alertText:(NSString *)alertText
                         binderId:(NSNumber *)binderId
                           userId:(NSNumber *)userId;

@end

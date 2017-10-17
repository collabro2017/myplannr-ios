//
//  MYPNewTabAlert.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import "MYPAlert.h"

@interface MYPNewTabAlert : MYPAlert

@property (strong, nonatomic, readonly) NSNumber *binderId;
@property (strong, nonatomic, readonly) NSNumber *tabId;

- (instancetype)initWithAlertType:(MYPAlertType)type
                        alertText:(NSString *)alert
                         binderId:(NSNumber *)binderId
                            tabId:(NSNumber *)tabId;

@end

//
//  UIViewController+Alerts.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 08/01/2017.
//
//

#import <UIKit/UIKit.h>
#import "MYPAlert.h"

@interface UIViewController (Alerts)

- (void)subscribeForAlertNotifications;
- (void)unsubscribeForAlertNotifications;

- (void)handleAlert:(MYPAlert *)alert;

@end

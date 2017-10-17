//
//  MYPAlertsAwareViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 08/01/2017.
//
//

#import "MYPAlertsAwareViewController.h"

@implementation MYPAlertsAwareViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self subscribeForAlertNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self unsubscribeForAlertNotifications];
}

@end

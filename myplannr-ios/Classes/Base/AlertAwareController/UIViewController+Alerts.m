//
//  UIViewController+Alerts.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 08/01/2017.
//
//

#import "UIViewController+Alerts.h"
#import "MYPConstants.h"
#import "CRToast.h"

@implementation UIViewController (Alerts)

- (void)subscribeForAlertNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAlertNotification:)
                                                 name:kNewAlertNotification
                                               object:nil];
}

- (void)unsubscribeForAlertNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNewAlertNotification
                                                  object:nil];
}

- (void)handleAlert:(MYPAlert *)alert {
    NSString *title = NSLocalizedString(@"New Alert", nil);
    NSString *subtitle = alert.alertText;
    NSMutableDictionary *options = @{
                              kCRToastTextKey                         : title,
                              kCRToastSubtitleTextKey                 : subtitle,
                              kCRToastBackgroundColorKey              : [UIColor myp_colorWithHexInt:0x017AFF],
                              kCRToastNotificationTypeKey             : @(CRToastTypeNavigationBar),
                              kCRToastTextAlignmentKey                : @(NSTextAlignmentLeft),
                              kCRToastSubtitleTextAlignmentKey        : @(NSTextAlignmentLeft),
                              kCRToastImageAlignmentKey               : @(CRToastAccessoryViewAlignmentLeft),
                              kCRToastImageTintKey                    : [UIColor whiteColor],
                              kCRToastUnderStatusBarKey               : @(YES),
                              kCRToastAnimationInDirectionKey         : @(0),
                              kCRToastAnimationOutDirectionKey        : @(0),
                              kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover)
                              }.mutableCopy;
    
    if (alert.alertType == MYPAlertTypeChatMessage) {
        [options setObject:[UIImage imageNamed:@"IncomingMessage"] forKey:kCRToastImageKey];
    }
    
    [CRToastManager showNotificationWithOptions:options completionBlock:nil];
}

#pragma mark - Private methods

- (void)handleAlertNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    MYPAlert *alert = userInfo[kNewAlertNotificationContentKey];
    [self handleAlert:alert];
}

@end

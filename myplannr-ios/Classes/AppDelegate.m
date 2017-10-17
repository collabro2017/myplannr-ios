//
//  AppDelegate.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 02/08/16.
//
//

@import StoreKit;

#import <RestKit/RestKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "MYPStoreManager.h"
#import "MYPUserProfile.h"
#import "MYPService.h"
#import "MYPAlertsFabric.h"
#import "MYPConstants.h"
#import "MYPChatViewController.h"
#import "MYPBinderTabsViewController.h"
#import "MYPFileUtils.h"
#import "MYPChatMessageAlert.h"
#import "MYPBinder.h"

#warning проверить блоки на предмет необходимости _weak - http://stackoverflow.com/questions/20030873/always-pass-weak-reference-of-self-into-block-in-arc
#warning @throw -> NSAssert

/***** TODO LIST *****/

// 1. NSLog and production

// 2. App extensions (sharing)
// https://developer.apple.com/library/ios/documentation/General/Conceptual/ExtensibilityPG/index.html#//apple_ref/doc/uid/TP40014214-CH20-SW1
// http://stackoverflow.com/questions/28506219/how-to-get-listed-in-the-ios-8-system-wide-share-menu?noredirect=1#comment45332012_28506219

// 3. How to improve animation speed when leaving the Editing Mode (Binder Tabs, Manage Users)?
// How about putting animatable views into separate root view and calling [rootView layoufIfNeeded]
// instead of [cardContentView layoutIfNeeded] ?

// 4. Automatically logout users whenever they receive 401 error

/***** END TODO LIST *****/

@implementation AppDelegate {
    NSURL * _url;
    NSString * _sourceApp;
    MYPAlert * _lastAlert;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@, options: %@", NSStringFromSelector(_cmd), launchOptions);
    
    MYPUser *currentUser = [[MYPUserProfile sharedInstance] currentUser];
    if (currentUser) {
        [self.class startSessionWithUser:currentUser];
    }
    
    // Fabric
    [[Fabric sharedSDK] setDebug:NO];
    [Fabric with:@[[Crashlytics class]]];
    
    // RestKit
    // RKLogConfigureByName("*", RKLogLevelOff);
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelWarning);
   
    NSDictionary *notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        NSLog(@"%@ got a notification: %@", NSStringFromSelector(_cmd), notification);
    }
    
    // Customize SVProgressHUD
    [SVProgressHUD setFadeOutAnimationDuration:0.0f];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [self customizeAppearance];
    
    _url = nil;
    _sourceApp = nil;
    _lastAlert = nil;
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    NSLog(@"%@, url: %@, options: %@", NSStringFromSelector(_cmd), url, options);

    _url = url;
    _sourceApp = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[MYPService sharedInstance] saveManagedObjectContextToPersistentStore];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    // Reset icon badge counter
    application.applicationIconBadgeNumber = 0;
    
    if (_url) {
        [self importFileFromURL:_url sourceApp:_sourceApp];
        _url = nil;
        _sourceApp = nil;
    }
    
    if (_lastAlert) {
        [self displayAlert:_lastAlert];
        _lastAlert = nil;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[MYPStoreManager sharedInstance]];
}

#pragma mark - Notifications

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"%@:%@", NSStringFromSelector(_cmd), notificationSettings);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = deviceToken.description;
    token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Sending device token to the server: %@", token);
    
    [[MYPService sharedInstance] updatePushToken:token
                                         handler:^(NSData *responseData, NSInteger statusCode, NSError *error) {
                                             if (error) {
                                                 NSLog(@"Failed to upload push token to the server: %@", error);
                                             }
                                         }];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    UIApplicationState state = application.applicationState;
    NSLog(@"%@, userInfo: %@, state: %li", NSStringFromSelector(_cmd), userInfo, (long)state);
    _lastAlert = [MYPAlertsFabric createAlertFromDictionary:userInfo];
    if (state == UIApplicationStateActive) {
        NSDictionary *dict = @{ kNewAlertNotificationContentKey : _lastAlert };
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewAlertNotification
                                                            object:self
                                                          userInfo:dict];
        _lastAlert = nil; // the notification is handled, no need to keep any references to it
    } else if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1;
    }
    
    handler(UIBackgroundFetchResultNoData);
}

#pragma mark - Public Methods

+ (void)startSessionWithUser:(MYPUser *)user {
    FCSession *session = [FCSession sessionWithAuthToken:user.authToken];
    [MYPService provideSession:session];
    
    [self.class registerForRemoteNotifications];
}

+ (void)logoutWithCompletionBlock:(void (^)(void))block {
    [self.class unregisterForRemoteNotifications];
    
    [MYPService terminateSessionWithCompletionBlock:block];
    
    // Remove all files from the /Caches directory
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *docsDir = [MYPFileUtils downloadedDocumentsDirectory];
        NSError *error = nil;
        if (![fm removeItemAtPath:docsDir.path error:&error]) {
            NSLog(@"%s: failed to remove documents dir - %@", __PRETTY_FUNCTION__, error);
        }
    });
}

#pragma mark - Private Methods

+ (void)registerForRemoteNotifications {
#if !(TARGET_IPHONE_SIMULATOR)
    UIUserNotificationType types = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                         settingsForTypes:types
                                                                         categories:nil]];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

+ (void)unregisterForRemoteNotifications {
#if !(TARGET_IPHONE_SIMULATOR)
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
#endif
}

- (void)customizeAppearance {
    [UINavigationBar appearance].backgroundColor = [UIColor myp_defaultNavigationBarColor];
    [UINavigationBar appearance].tintColor = [UIColor myp_colorWithHexInt:0x43434E];
    [UIBarButtonItem appearance].tintColor = [UIColor myp_colorWithHexInt:0x43434E];
    [UINavigationBar appearance].titleTextAttributes = @{
                                                         NSForegroundColorAttributeName : [UIColor myp_colorWithHexInt:0x95989A]
                                                         };
}

- (void)importFileFromURL:(NSURL *)url sourceApp:(NSString *)sourceApp {
    NSLog(@"%s: url=%@, sourceApp=%@", __PRETTY_FUNCTION__, url.path, sourceApp);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{
                                   kImportDocumentAtURLNotificationURLKey       : url,
                                   kImportDocumentAtURLNotificationSourceAppKey : sourceApp
                                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:kImportDocumentAtURLNotification
                                                            object:self
                                                          userInfo:userInfo];
    });
}

- (void)displayAlert:(MYPAlert *)alert {
    MYPAlertType type = alert.alertType;
    if (type == MYPAlertTypeChatMessage) {
        MYPChatMessage *msg = ((MYPChatMessageAlert *)alert).message;
        [self presentChatViewControllerForMessage:msg];
    } else if (type == MYPAlertTypeNewInvite || type == MYPAlertTypeNewDocument || type == MYPAlertTypeBinderChanged) {
        NSNumber *binderId = [alert valueForKey:@"binderId"];
        [self displayBinderTabsForBinderWithId:binderId];
    } else {
        // do nothing
    }
}

- (void)presentChatViewControllerForMessage:(MYPChatMessage *)msg {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPChatStoryboard" bundle:[NSBundle mainBundle]];
    MYPChatViewController *chatVC = [storyboard instantiateInitialViewController];
    
    NSNumber *binderID = msg.binderId;
    chatVC.model = [[MYPChatModel alloc] initWithBinderID:binderID];
    chatVC.doneBarButtonHidden = NO;
    
    UINavigationController *chatNavVC = [[UINavigationController alloc] initWithRootViewController:chatVC];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.window.rootViewController presentViewController:chatNavVC animated:YES completion:nil];
    });
}

- (void)displayBinderTabsForBinderWithId:(NSNumber *)binderId {
    NSAssert(binderId && binderId.integerValue > 0, @"invalid binderId");
    
    NSFetchRequest *request = [MYPBinder fc_fetchRequest];
    request.fetchLimit = 1;
    request.returnsObjectsAsFaults = NO;
    request.predicate = [NSPredicate predicateWithFormat:@"binderId = %@", binderId];
    NSManagedObjectContext *ctx = [[MYPService sharedInstance] managedObjectContext];
    NSError *error = nil;
    NSArray *results = [ctx executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%s - %@", __PRETTY_FUNCTION__, error);
        return;
    }
    
    MYPBinder *binder = results.firstObject;
    if (binder) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPBinderTabsStoryboard" bundle:[NSBundle mainBundle]];
        UIViewController *tabsVC = [storyboard instantiateInitialViewController];
        if ([tabsVC respondsToSelector:NSSelectorFromString(@"setBinder:")]) {
            [tabsVC setValue:binder forKey:@"binder"];
        }
        if ([tabsVC respondsToSelector:NSSelectorFromString(@"setCancelBarButtonHidden:")]) {
            [tabsVC setValue:@(NO) forKey:@"cancelBarButtonHidden"];
        }
        
        UINavigationController *tabsNavVC = [[UINavigationController alloc] initWithRootViewController:tabsVC];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.window.rootViewController presentViewController:tabsNavVC animated:YES completion:nil];
        });
    }
}

@end

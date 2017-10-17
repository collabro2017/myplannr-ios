//
//  AppDelegate.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 02/08/16.
//
//

#import <UIKit/UIKit.h>

@class MYPUser;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (void)startSessionWithUser:(MYPUser *)user;
+ (void)logoutWithCompletionBlock:(void (^)(void))block;

@end


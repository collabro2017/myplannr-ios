//
//  MYPStartPageViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 16/09/16.
//
//

#import <UIKit/UIKit.h>

@interface MYPStartPageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIView *containerView;

- (void)showSignUpController;
- (void)showSignInController;
- (void)showRecoverPasswordController;
- (void)showCompleteRegistrationController;
- (void)showBindersListController;

@end

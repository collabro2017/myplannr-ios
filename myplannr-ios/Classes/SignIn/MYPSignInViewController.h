//
//  MYPSignInViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 15/09/16.
//
//

#import <UIKit/UIKit.h>

@class MYPUser;

@protocol MYPSignInViewControllerDelegate <NSObject>

@optional

- (void)signInController:(UIViewController *)controller didTapSignUpButton:(id)button;
- (void)signInController:(UIViewController *)controller didTapRecoverPasswordButton:(id)button;
- (void)signInController:(UIViewController *)controller didAuthorizeUser:(MYPUser *)user;

@end

@interface MYPSignInViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *emailPasswordContainerView;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (weak, nonatomic) IBOutlet UILabel *bottomBlockLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomBlockButton;

@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@property (weak, nonatomic) id<MYPSignInViewControllerDelegate> delegate;

@end

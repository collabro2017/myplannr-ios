//
//  MYPSignUpViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 02/08/16.
//
//

#import <UIKit/UIKit.h>

@class MYPUser;

@protocol MYPSignUpViewControllerDelegate <NSObject>

@optional

- (void)signUpController:(UIViewController *)controller didTapSignInButton:(id)button;
- (void)signUpController:(UIViewController *)controller didRegisterUser:(MYPUser *)user;

@end

@interface MYPSignUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *emailPasswordContainerView;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (weak, nonatomic) IBOutlet UILabel *bottomBlockLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomBlockButton;

@property (weak, nonatomic) id<MYPSignUpViewControllerDelegate> delegate;

@end


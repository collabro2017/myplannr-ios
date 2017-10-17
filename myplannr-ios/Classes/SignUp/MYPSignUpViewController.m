//
//  MYPSignUpViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 02/08/16.
//
//

#import "MYPSignUpViewController.h"
#import "MYPConstants.h"
#import "MYPUtils.h"
#import "MYPService.h"
#import "SVProgressHUD.h"

@interface MYPSignUpViewController () <UITextFieldDelegate>

@end

@implementation MYPSignUpViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signUpButton.layer.cornerRadius = kRoundedButtonCornerRadiusBig;
    self.bottomBlockButton.layer.cornerRadius = kRoundedButtonCornerRadiusSmall;
    self.bottomBlockButton.layer.borderWidth = kRoundedButtonBorderWidth;
    self.bottomBlockButton.layer.borderColor = [UIColor myp_colorWithHexInt:0xDDDDDD].CGColor;
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if ([self.emailTextField isFirstResponder]) [self.passwordTextField becomeFirstResponder];
    else if ([self.passwordTextField isFirstResponder]) [self.passwordTextField resignFirstResponder];
    return YES;
}

#pragma mark - Action handlers

- (IBAction)handleSignUpButtonClick:(id)sender {
    NSString *email = self.emailTextField.text;
    if (![email myp_isValidEmail]) {
        [MYPUtils shakeView:self.emailTextField];
        return;
    }
    
    NSString *password = self.passwordTextField.text;
    if (password.length == 0) {
        [MYPUtils shakeView:self.passwordTextField];
        return;
    }
    
    [SVProgressHUD show];
    [[MYPService sharedInstance] signUpWithEmail:email
                                        password:password
                                         handler:^(MYPUser *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         if (error) {
             [self processError:error statusCode:statusCode];
             return;
         }
         
         if ([self.delegate respondsToSelector:@selector(signUpController:didRegisterUser:)]) {
             [self.delegate signUpController:self didRegisterUser:object];
         }
     }];
}

- (IBAction)handleSignInButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(signUpController:didTapSignInButton:)]) {
        [self.delegate signUpController:self didTapSignInButton:sender];
    }
}

#pragma mark - Gesture Recognizers

- (IBAction)handleEmailLabelTap:(id)sender {
    if (!self.emailTextField.isFirstResponder) {
        [self.emailTextField becomeFirstResponder];
    }
}

- (IBAction)handlePasswordLabelTap:(id)sender {
    if (!self.passwordTextField.isFirstResponder) {
        [self.passwordTextField becomeFirstResponder];
    }
}

#pragma mark - Private methods

- (void)processError:(NSError *)error statusCode:(NSInteger)statusCode {
    NSString *errorStatus = NSLocalizedString(@"Unable to sign-up, please try again later.", nil);
    if (statusCode == kHttpStatus422UnprocessableEntity ) {
        // Unprocessable Entity
        NSString *errorMsg = error.userInfo[NSLocalizedRecoverySuggestionErrorKey];
        NSLog(@"Recovery suggestion: %@", errorMsg);
        errorStatus = NSLocalizedString(@"Unable to sign-up, please check your credentials.", nil);
    }
    
    [SVProgressHUD showErrorWithStatus:errorStatus];
}

@end

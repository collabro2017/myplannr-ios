//
//  MYPSignInViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 15/09/16.
//
//

#import "MYPSignInViewController.h"
#import "MYPConstants.h"
#import "MYPUtils.h"
#import "MYPService.h"
#import "SVProgressHUD.h"

@interface MYPSignInViewController () <UITextFieldDelegate>

@end

@implementation MYPSignInViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signInButton.layer.cornerRadius = kRoundedButtonCornerRadiusBig;
    self.bottomBlockButton.layer.cornerRadius = kRoundedButtonCornerRadiusSmall;
    self.bottomBlockButton.layer.borderColor = [UIColor myp_colorWithHexInt:0xDDDDDD].CGColor;
    self.bottomBlockButton.layer.borderWidth = kRoundedButtonBorderWidth;
    self.forgotPasswordButton.layer.cornerRadius = kRoundedButtonCornerRadiusBig;
    self.forgotPasswordButton.layer.borderColor = [UIColor myp_colorWithHexInt:0xDDDDDD].CGColor;
    self.forgotPasswordButton.layer.borderWidth = kRoundedButtonBorderWidth;
    
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

- (IBAction)handleSignInButtonClick:(id)sender {
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
    [[MYPService sharedInstance] signInWithEmail:email
                                        password:password
                                         handler:^(MYPUser *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         if (error) {
             [self processError:error statusCode:statusCode];
             return;
         }
         
         if ([self.delegate respondsToSelector:@selector(signInController:didAuthorizeUser:)]) {
             [self.delegate signInController:self didAuthorizeUser:object];
         }
     }];
}

- (IBAction)handleSignUpButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(signInController:didTapSignUpButton:)]) {
        [self.delegate signInController:self didTapSignUpButton:sender];
    }
}

- (IBAction)handleRecoverPasswordButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(signInController:didTapRecoverPasswordButton:)]) {
        [self.delegate signInController:self didTapRecoverPasswordButton:sender];
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
    NSString *errorStatus = NSLocalizedString(@"Unable to sign-in, please try again later.", nil);
    if (statusCode == kHttpCode404NotFound) {
        NSString *errorMsg = error.userInfo[NSLocalizedRecoverySuggestionErrorKey];
        NSLog(@"Recovery suggestion: %@", errorMsg);
        errorStatus = NSLocalizedString(@"Unable to sign-in, please check your credentials.", nil);
    }
    
    [SVProgressHUD showErrorWithStatus:errorStatus];
}

@end

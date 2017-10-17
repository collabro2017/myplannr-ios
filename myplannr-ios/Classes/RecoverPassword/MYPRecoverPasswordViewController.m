//
//  MYPRecoverPasswordViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 15/09/16.
//
//

#import "MYPRecoverPasswordViewController.h"
#import "MYPConstants.h"
#import "MYPUtils.h"
#import "MYPService.h"
#import "SVProgressHUD.h"

@interface MYPRecoverPasswordViewController () <UITextFieldDelegate>

@end

@implementation MYPRecoverPasswordViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recoverButton.layer.cornerRadius = kRoundedButtonCornerRadiusBig;
    self.cancelButton.layer.cornerRadius = kRoundedButtonCornerRadiusBig;
    self.cancelButton.layer.borderWidth = kRoundedButtonBorderWidth;
    self.cancelButton.layer.borderColor = [UIColor myp_colorWithHexInt:0xDDDDDD].CGColor;
    
    self.emailTextField.delegate = self;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self.emailTextField resignFirstResponder];
    return YES;
}

#pragma mark - Action handlers

- (IBAction)handleRecoverButtonClick:(id)sender {
    NSString *email = self.emailTextField.text;
    if (![email myp_isValidEmail]) {
        [MYPUtils shakeView:self.emailTextField];
        return;
    }
    
    [SVProgressHUD show];
    [[MYPService sharedInstance] recoverPassword:email handler:^(NSData *responseData, NSInteger statusCode, NSError *error) {
        [SVProgressHUD dismiss];
        
        if (error) {
            [self processError:error statusCode:statusCode];
            return;
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Email sent", nil)
                                                                                 message:NSLocalizedString(@"Please check your inbox.", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:(UIAlertActionStyleCancel)
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              if ([self.delegate respondsToSelector:@selector(recoverPasswordControllerShouldDismiss:)]) {
                                                                  [self.delegate recoverPasswordControllerShouldDismiss:self];
                                                              }
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (IBAction)handleCancelButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(recoverPasswordControllerShouldDismiss:)]) {
        [self.delegate recoverPasswordControllerShouldDismiss:self];
    }
}

#pragma mark - Gesture recognizers

- (IBAction)handleEmailLabelTap:(id)sender {
    if (!self.emailTextField.isFirstResponder) {
        [self.emailTextField becomeFirstResponder];
    }
}

#pragma mark - Private methods

- (void)processError:(NSError *)error statusCode:(NSInteger)statusCode {
    NSString *errorStatus = NSLocalizedString(@"Unable to send recovery link. Please try again later.", nil);
    if (statusCode == kHttpCode404NotFound) {
        NSString *errorMsg = error.userInfo[NSLocalizedRecoverySuggestionErrorKey];
        NSLog(@"Recovery suggestion: %@", errorMsg);
        errorStatus = NSLocalizedString(@"Unable to send recovery link: email not found.", nil);
    }
    
    [SVProgressHUD showErrorWithStatus:errorStatus];
}

@end

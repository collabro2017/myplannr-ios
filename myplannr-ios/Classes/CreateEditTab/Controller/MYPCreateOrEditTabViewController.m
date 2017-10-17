//
//  MYPCreateOrEditTabViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 12/10/2016.
//
//

#import "MYPCreateOrEditTabViewController.h"
#import "MYPUtils.h"
#import "MYPConstants.h"
#import "SVProgressHUD.h"

@interface MYPCreateOrEditTabViewController () <UITextFieldDelegate>

@property (assign, nonatomic) BOOL isEditingMode;

@end

@implementation MYPCreateOrEditTabViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isEditingMode = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isEditingMode) {
        self.navigationItem.title = NSLocalizedString(@"Edit Tab", nil);
        self.titleTextField.text = self.model.editingTab.title;
        self.colorCircleView.circleColor = self.model.editingTab.color;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self.titleTextField resignFirstResponder];
    return YES;
}

#pragma mark - MYPColorPickerViewControllerDelegate

- (void)colorPickerViewController:(UIViewController *)controller didPickColor:(UIColor *)color {
    self.colorCircleView.circleColor = color;
}

#pragma mark - Action handlers

- (IBAction)handleDoneBarButtonClick:(id)sender {
    NSString *title = self.titleTextField.text;
    if (title.length == 0) {
        [MYPUtils shakeView:self.titleTextField];
        return;
    }
    
    if (self.isEditingMode) {
        [self updateTab];
    } else {
        [self createTab];
    }
}

- (IBAction)handleCancelBarButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleTitleLabelTapGesture:(id)sender {
    if (!self.titleTextField.isFirstResponder) {
        [self.titleTextField becomeFirstResponder];
    }
}

- (IBAction)handleColorBlockTapGesture:(id)sender {
    NSBundle *bundle = [NSBundle mainBundle];
    UIStoryboard *storyborad = [UIStoryboard storyboardWithName:@"MYPColorPickerStoryboard" bundle:bundle];
    UINavigationController *navVC = [storyborad instantiateInitialViewController];
    UIViewController *vc = navVC.topViewController;
    if ([vc respondsToSelector:NSSelectorFromString(@"setDelegate:")]) {
        [vc setValue:self forKey:@"delegate"];
    }
    if ([vc respondsToSelector:NSSelectorFromString(@"setColor:")]) {
        UIColor *color = self.colorCircleView.circleColor;
        [vc setValue:color forKey:@"color"];
    }
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - Private Methods

- (BOOL)isEditingMode {
    return (self.model.editingTab != nil);
}

- (void)createTab {
    NSString *title = self.titleTextField.text;
    UIColor *color = self.colorCircleView.circleColor;
    [SVProgressHUD show];
    [self.model createTabWithTitle:title color:color completion:^(MYPBinderTab *tab, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         if (error) {
             NSNumber *statusCode = error.userInfo[FCHttpStatusKey];
             if (statusCode.integerValue == kHttpCode402PaymentRequired) {
                 [self showPaymentRequiredAlert];
             } else {
                 NSString *errorMsg = NSLocalizedString(@"Failed to create tab.", nil);
                 [SVProgressHUD showErrorWithStatus:errorMsg];
             }
             return;
         }
         
         [self dismissViewControllerAnimated:YES completion:nil];
         SEL selector = @selector(createOrEditTabViewController:didCreateTab:);
         if ([self.delegate respondsToSelector:selector]) {
             [self.delegate createOrEditTabViewController:self didCreateTab:tab];
         }
     }];
}

- (void)updateTab {
    NSString *title = self.titleTextField.text;
    UIColor *color = self.colorCircleView.circleColor;
    [SVProgressHUD show];
    [self.model updateTabWithTitle:title color:color completion:^(MYPBinderTab *tab, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         if (error) {
             NSString *errorMsg = NSLocalizedString(@"Failed to update tab.", nil);
             NSNumber *statusCode = error.userInfo[FCHttpStatusKey];
             if (statusCode.integerValue == kHttpCode403PermissionDenied) {
                 errorMsg = NSLocalizedString(@"You're not allowed to edit this tab.", nil);
             }
             [SVProgressHUD showErrorWithStatus:errorMsg];
             return;
         }
         
         [self dismissViewControllerAnimated:YES completion:nil];
         SEL selector = @selector(createOrEditTabViewController:didFinishEditingTab:);
         if ([self.delegate respondsToSelector:selector]) {
             [self.delegate createOrEditTabViewController:self didFinishEditingTab:tab];
         }
     }];
}

- (void)showPaymentRequiredAlert {
    NSString *title = NSLocalizedString(@"Unable to create Tab", nil);
    NSString *msg = NSLocalizedString(@"Please upgrade to get unlimited access.", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upgrade", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action)
                             {
                                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPGetUnlimitedAccessStoryboard"
                                                                                      bundle:[NSBundle mainBundle]];
                                 UIViewController *vc = [storyboard instantiateInitialViewController];
                                 [self presentViewController:vc animated:YES completion:nil];
                             }];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                      style:(UIAlertActionStyleCancel)
                                    handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end

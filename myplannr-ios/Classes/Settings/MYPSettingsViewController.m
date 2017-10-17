//
//  MYPSettingsViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 21/10/2016.
//
//

@import AVFoundation;

#import <SDWebImage/UIImageView+WebCache.h>
#import "MYPSettingsViewController.h"
#import "MYPDevicePropertiesUtils.h"
#import "MYPUserProfileCardView.h"
#import "MYPUserProfile.h"
#import "MYPDocumentPicker.h"
#import "MYPAvatarData.h"
#import "MYPService.h"
#import "MYPUser.h"
#import "MYPConstants.h"
#import "MYPStoreManager.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@interface MYPSettingsViewController () <UITextFieldDelegate,
                                         MYPUserProfileCardViewDelegate,
                                         MYPDocumentPickerDelegate>
{
    BOOL _isKeyboardVisible;
    BOOL _isSigningOut;
    NSString * _newAvatarUrl;
}

@property (nonatomic, strong) MYPDocumentPicker *documentPicker;

@end

@implementation MYPSettingsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        BOOL cropImages = !IS_IPAD;
        self.documentPicker = [[MYPDocumentPicker alloc] initWithViewController:self cropImages:cropImages];
        
        _isKeyboardVisible = NO;
        _isSigningOut = NO;
        _newAvatarUrl = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buySubscriptionButton.backgroundColor = [UIColor clearColor];
    self.buySubscriptionButton.layer.borderWidth = 1.0f;
    self.buySubscriptionButton.layer.borderColor = [UIColor myp_colorWithHexInt:0x4CD963].CGColor;
    [self.buySubscriptionButton setTitleColor:[UIColor myp_colorWithHexInt:0x4CD963]
                                     forState:UIControlStateNormal];
    
    self.restorePurchasesButton.backgroundColor = [UIColor clearColor];
    self.restorePurchasesButton.layer.borderWidth = 1.0f;
    self.restorePurchasesButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.restorePurchasesButton setTitleColor:[UIColor blackColor]
                                      forState:UIControlStateNormal];
    
    self.tellFriendsButton.backgroundColor = [UIColor clearColor];
    self.tellFriendsButton.layer.borderWidth = 1.0f;
    self.tellFriendsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.tellFriendsButton setTitleColor:[UIColor blackColor]
                                 forState:UIControlStateNormal];
    
    self.userProfileCardView.delegate = self;
    
    self.documentPicker.delegate = self;
    
    self.userProfileCardView.firstNameTextField.delegate = self;
    self.userProfileCardView.lastNameTextField.delegate = self;
    
    MYPUser *user = [MYPUserProfile sharedInstance].currentUser;
    
    self.userProfileCardView.firstNameTextField.text = user.firstName;
    self.userProfileCardView.lastNameTextField.text = user.lastName;
    
    NSString *avatarUrl = user.avatarUrl;
    UIImage *placeholder = [UIImage imageNamed:@"AvatarPlaceholder"];
    [self.userProfileCardView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]
                                                placeholderImage:placeholder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRefreshRequestCompletedNotification:)
                                                 name:kMYPStoreManagerRefreshRequestCompletedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRefreshRequestFailedNotification:)
                                                 name:kMYPStoreManagerRefreshRequestFailedNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat buyButtonHeight = CGRectGetHeight(self.buySubscriptionButton.bounds);
    self.buySubscriptionButton.layer.cornerRadius = (buyButtonHeight / 2);
    
    CGFloat restoreButtonHeight = CGRectGetHeight(self.restorePurchasesButton.bounds);
    self.restorePurchasesButton.layer.cornerRadius = (restoreButtonHeight / 2);
    
    CGFloat tellFriendsButtonHeight = CGRectGetHeight(self.tellFriendsButton.bounds);
    self.tellFriendsButton.layer.cornerRadius = (tellFriendsButtonHeight / 2);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Keyboard Show/Hide notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_isSigningOut == NO) {
        MYPUser *user = [MYPUserProfile sharedInstance].currentUser;
        NSString *oldFirstName = user.firstName;
        NSString *oldLastName = user.lastName;
        NSString *oldAvatarUrl = user.avatarUrl;
        NSString *newFirstName = self.userProfileCardView.firstNameTextField.text;
        NSString *newLastName = self.userProfileCardView.lastNameTextField.text;
        BOOL isAvatarChanged = (_newAvatarUrl != nil);
        if (![oldFirstName isEqualToString:newFirstName] || ![oldLastName isEqualToString:newLastName]
            || isAvatarChanged)
        {
            user.firstName = newFirstName;
            user.lastName = newLastName;
            if (isAvatarChanged) user.avatarUrl = _newAvatarUrl;
            [[MYPService sharedInstance] updateUser:user
                                             hander:^(MYPUser *object, NSData *responseData, NSInteger statusCode, NSError *error)
             {
                 if (error) {
                     // Revert changes
                     user.firstName = oldFirstName;
                     user.lastName = oldLastName;
                     user.avatarUrl = oldAvatarUrl;
                     [[MYPService sharedInstance] saveManagedObjectContextToPersistentStore];
                     
                     NSLog(@"Failed to update user: %@", error);
                 }
             }];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    UITextField *firstNameTextField = self.userProfileCardView.firstNameTextField;
    UITextField *lastNameTextField = self.userProfileCardView.lastNameTextField;
    if ([firstNameTextField isFirstResponder]) [lastNameTextField becomeFirstResponder];
    else if ([lastNameTextField isFirstResponder]) [lastNameTextField resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillHide:(NSNotification *) notification {
    [self makeInputViewTransitionWithDownDirection:YES notification:notification];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO notification:notification];
}

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    _isKeyboardVisible = !down;
    
    if (IS_IPHONE_4_OR_LESS) {
        [self.navigationController setNavigationBarHidden:_isKeyboardVisible animated:YES];
    }
}

#pragma mark - Notifications

- (void)handleRefreshRequestCompletedNotification:(NSNotification *)notification {
    NSString *successMsg = NSLocalizedString(@"Your purchases have been restored successfully.", nil);
    [SVProgressHUD showSuccessWithStatus:successMsg];
}

- (void)handleRefreshRequestFailedNotification:(NSNotification *)notification {
    NSString *errorMsg = NSLocalizedString(@"Failed to restore your past purchases. Please try again later.", nil);
    [SVProgressHUD showErrorWithStatus:errorMsg];
}

#pragma mark - MYPUserProfileCardViewDelegate

- (void)userProfileView:(MYPUserProfileCardView *)view didTapAvatarImageView:(UIImageView *)imageView {
    [self.documentPicker showPickImageAlert:imageView];
}

- (void)userProfileView:(MYPUserProfileCardView *)view didTapFirstNameLabel:(UILabel *)firstNameLabel {
    if (!self.userProfileCardView.firstNameTextField.isFirstResponder) {
        [self.userProfileCardView.firstNameTextField becomeFirstResponder];
    }
}

- (void)userProfileView:(MYPUserProfileCardView *)view didTapLastNameLabel:(UILabel *)firstNameLabel {
    if (!self.userProfileCardView.lastNameTextField.isFirstResponder) {
        [self.userProfileCardView.lastNameTextField becomeFirstResponder];
    }
}

#pragma mark - MYPDocumentPickerDelegate

- (void)documentPicker:(MYPDocumentPicker *)picker didPickImage:(UIImage *)image {
    CGRect boundingRect = CGRectMake(0.0f, 0.0f, kAvatarMaxSizeInPixels, kAvatarMaxSizeInPixels);
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(image.size, boundingRect);
    UIImage *scaledImage = [UIImage myp_imageWithImage:image scaledToSize:rect.size];
    self.userProfileCardView.avatarImageView.image = scaledImage;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationItem.hidesBackButton = YES;
    [SVProgressHUD show];
    [[MYPService sharedInstance] uploadUserAvatar:image
                                           hander:^(MYPAvatarData *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         self.navigationController.interactivePopGestureRecognizer.enabled = YES;
         self.navigationItem.hidesBackButton = NO;
         [SVProgressHUD dismiss];
         
         if (error) {
             NSString *errorMsg = NSLocalizedString(@"Unable to upload the image. Please try again later.", nil);
             [SVProgressHUD showErrorWithStatus:errorMsg];
             self.userProfileCardView.avatarImageView.image = nil;
             return;
         }
         
         self->_newAvatarUrl = object.uploadedURL;
     }];
}

#pragma mark - Action handlers

- (IBAction)handleBuySubscriptionButtonClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPGetUnlimitedAccessStoryboard"
                                                         bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)handleRestoreIAPsButtonClick:(id)sender {
    NSString *statusMsg = NSLocalizedString(@"Restoring your purchases...", nil);
    [SVProgressHUD showWithStatus:statusMsg];
    [[MYPStoreManager sharedInstance] refreshReceipt];
}

- (IBAction)handleTellFriendsButtonClick:(id)sender {
    NSString *string = NSLocalizedString(@"MyPlannr app on the App Store", nil);;
    NSURL *URL = [NSURL URLWithString:kAppStoreLink];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                                                                         applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeAssignToContact];
    activityViewController.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
    activityViewController.popoverPresentationController.sourceView = sender;
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:nil];
}

- (IBAction)handleLogOutButtonClick:(id)sender {
    NSString *title = NSLocalizedString(@"Log out of MyPlannr?", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Log Out", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self signOut];
                                                   }];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                      style:UIAlertActionStyleCancel
                                    handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)handleTermsOfServicesButtonClick:(id)sender {
    NSURL *url = [NSURL URLWithString:kTermsOfServicesLink];
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:url]) {
        [application openURL:url];
    }
}

#pragma mark - Private methods

- (void)signOut {
    _isSigningOut = YES;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Signing out...", nil)];
    [AppDelegate logoutWithCompletionBlock:^{
        [SVProgressHUD dismiss];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [storyboard instantiateInitialViewController];
        [self presentViewController:viewController animated:YES completion:^{
            [self.navigationController setViewControllers:@[] animated:NO];
        }];
    }];
}

@end

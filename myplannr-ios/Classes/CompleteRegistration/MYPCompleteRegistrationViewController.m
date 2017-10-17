//
//  MYPCompleteRegistrationViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 18/09/16.
//
//

@import AVFoundation;

#import "SVProgressHUD.h"
#import "MYPCompleteRegistrationViewController.h"
#import "MYPUserProfileCardView.h"
#import "MYPConstants.h"
#import "MYPUtils.h"
#import "MYPService.h"
#import "MYPUserProfile.h"
#import "MYPUser.h"
#import "MYPAvatarData.h"
#import "MYPDocumentPicker.h"
#import "MYPDevicePropertiesUtils.h"

@interface MYPCompleteRegistrationViewController () <UITextFieldDelegate,
                                                     MYPUserProfileCardViewDelegate,
                                                     MYPDocumentPickerDelegate>

@property (nonatomic, weak, readonly) UITextField *firstNameTextField;
@property (nonatomic, weak, readonly) UITextField *lastNameTextField;
@property (nonatomic, weak, readonly) UIImageView *avatarImageView;

@property (nonatomic, strong) MYPDocumentPicker *documentPicker;

@end

@implementation MYPCompleteRegistrationViewController {
    BOOL _isKeyboardVisible;
    NSString * _avatarUrl;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        BOOL cropImages = !IS_IPAD;
        self.documentPicker = [[MYPDocumentPicker alloc] initWithViewController:self cropImages:cropImages];
        
        _isKeyboardVisible = NO;
        _avatarUrl = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.doneButton.layer.cornerRadius = kRoundedButtonCornerRadiusBig;
    
    self.userProfileCardView.delegate = self;
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    
    self.documentPicker.delegate = self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.view.backgroundColor = [UIColor clearColor];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden {
    return _isKeyboardVisible;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if ([self.firstNameTextField isFirstResponder]) [self.lastNameTextField becomeFirstResponder];
    else if ([self.lastNameTextField isFirstResponder]) [self.lastNameTextField resignFirstResponder];
    return YES;
}

#pragma mark - MYPDocummentPickerDelegate

- (void)documentPicker:(MYPDocumentPicker *)picker didPickImage:(UIImage *)image {
    CGRect boundingRect = CGRectMake(0.0f, 0.0f, kAvatarMaxSizeInPixels, kAvatarMaxSizeInPixels);
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(image.size, boundingRect);
    UIImage *scaledImage = [UIImage myp_imageWithImage:image scaledToSize:rect.size];
    self.avatarImageView.image = scaledImage;
    
    self.doneButton.enabled = NO;
    [SVProgressHUD show];
    MYPService *service = [MYPService sharedInstance];
    [service uploadUserAvatar:image
                       hander:^(MYPAvatarData *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         self.doneButton.enabled = YES;
         [SVProgressHUD dismiss];
         
         if (error) {
             NSString *errorStatus = NSLocalizedString(@"Unable to upload your avatar. Please try again later", nil);
             [SVProgressHUD showErrorWithStatus:errorStatus];
             self.avatarImageView.image = [UIImage imageNamed:@"AvatarPlaceholder"];
             return;
         }
         
         self->_avatarUrl = object.uploadedURL;
     }];
}

#pragma mark - MYPUserProfileCardViewDelegate

- (void)userProfileView:(MYPUserProfileCardView *)view didTapAvatarImageView:(UIImageView *)imageView {
    [self.documentPicker showPickImageAlert:imageView];
}

- (void)userProfileView:(MYPUserProfileCardView *)view didTapFirstNameLabel:(UILabel *)firstNameLabel {
    if (!self.firstNameTextField.isFirstResponder) {
        [self.firstNameTextField becomeFirstResponder];
    }
}

- (void)userProfileView:(MYPUserProfileCardView *)view didTapLastNameLabel:(UILabel *)firstNameLabel {
    if (!self.lastNameTextField.isFirstResponder) {
        [self.lastNameTextField becomeFirstResponder];
    }
}

#pragma mark - Keyboard notifications

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
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - Action handlers

- (IBAction)handleDoneButtonClick:(id)sender {
    NSString *firstName = self.firstNameTextField.text;
    NSString *lastName = self.lastNameTextField.text;
    if (firstName.length == 0) {
        [MYPUtils shakeView:self.userProfileCardView.firstNameLabel];
        return;
    }
    if (lastName.length == 0) {
        [MYPUtils shakeView:self.userProfileCardView.lastNameLabel];
        return;
    }
    
    MYPUser *user = [MYPUserProfile sharedInstance].currentUser;
    
    NSString *oldFirstName = user.firstName;
    NSString *oldLastName = user.lastName;
    NSString *oldAvatarUrl = user.avatarUrl;
    
    user.firstName = firstName;
    user.lastName = lastName;
    user.avatarUrl = _avatarUrl;
    
    [SVProgressHUD show];
    [[MYPService sharedInstance] updateUser:user
                                     hander:^(id object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         if (error) {
             // Revert changes
             user.firstName = oldFirstName;
             user.lastName = oldLastName;
             user.avatarUrl = oldAvatarUrl;
             [[MYPService sharedInstance] saveManagedObjectContextToPersistentStore];
             
             NSString *errorStatus = NSLocalizedString(@"Unable to complete registration, please try again later", nil);
             [SVProgressHUD showErrorWithStatus:errorStatus];
             return;
         }
         
         if ([self.delegate respondsToSelector:@selector(completeRegistrationControllerDidFinishUserSetup:)]) {
             [self.delegate completeRegistrationControllerDidFinishUserSetup:self];
         }
     }];
}

#pragma mark - Properties

- (UITextField *)firstNameTextField {
    return self.userProfileCardView.firstNameTextField;
}

- (UITextField *)lastNameTextField {
    return self.userProfileCardView.lastNameTextField;
}

- (UIImageView *)avatarImageView {
    return self.userProfileCardView.avatarImageView;
}

@end

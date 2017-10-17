//
//  MYPInviteUsersViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 04/10/2016.
//
//

@import ContactsUI;

#import "MYPInviteUsersViewController.h"
#import "MYPNonManagedInvitedUser.h"
#import "MYPUtils.h"

@interface MYPInviteUsersViewController () <UITextFieldDelegate, CNContactPickerDelegate>

@property (assign, nonatomic) MYPAccessType accessType;
@property (strong, nonatomic) CNContact *contact;

@end

@implementation MYPInviteUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.accessType = MYPAccessTypeReadOnly;
}

#pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    self.contact = contact;
    
    NSString *email = [contact.emailAddresses firstObject].value;
    self.emailTextField.text = email;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

#pragma mark - Button Handlers & Gestures

- (IBAction)handleInviteBarButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inviteUsersController:didInviteUser:)]) {
        NSString *email = self.emailTextField.text;
        if (![email myp_isValidEmail]) {
            [MYPUtils shakeView:self.emailContainerView];
            return;
        }
        NSData *thumbnail = nil;
        if (self.contact.imageDataAvailable) {
            thumbnail = self.contact.imageData;
        }
        NSString *fullname = [CNContactFormatter stringFromContact:self.contact style:CNContactFormatterStyleFullName];
        MYPNonManagedInvitedUser *user = [MYPNonManagedInvitedUser invitedUserWithEmail:email
                                                                               fullName:fullname
                                                                             accessType:self.accessType
                                                                              thumbnail:thumbnail];
        [self.delegate inviteUsersController:self didInviteUser:user];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleEmailContainerTap:(id)sender {
    if (!self.emailTextField.isFirstResponder) {
        [self.emailTextField becomeFirstResponder];
    }
}

- (IBAction)handleAccessTypeContainerTap:(id)sender {
    NSString *title = NSLocalizedString(@"Select access type", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:kAccessTypeReadOnlyString
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       self.accessType = MYPAccessTypeReadOnly;
                                                   }];
    [alertController addAction:action];
    
    action = [UIAlertAction actionWithTitle:kAccessTypeFullAccessString
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        self.accessType = MYPAccessTypeFull;
                                    }];
    [alertController addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                      style:UIAlertActionStyleCancel
                                    handler:nil];
    [alertController addAction:action];
    
    UIView *view = ((UIGestureRecognizer *)sender).view;
    UIPopoverPresentationController *popoverController = alertController.popoverPresentationController;
    popoverController.sourceView = view;
    popoverController.sourceRect = view.bounds;
    
    [alertController view];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)handleAddFromContactsButton:(id)sender {
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    contactPicker.displayedPropertyKeys = @[CNContactEmailAddressesKey];
    contactPicker.predicateForEnablingContact = [NSPredicate predicateWithFormat:@"emailAddresses.@count > 0"];
    contactPicker.delegate = self;
    [self presentViewController:contactPicker animated:YES completion:nil];
}

#pragma mark - Public Methods & Properties

- (void)setAccessType:(MYPAccessType)accessType {
    _accessType = accessType;
    
    if (accessType == MYPAccessTypeReadOnly) self.accessTypeValueLabel.text = kAccessTypeReadOnlyString;
    else if (accessType == MYPAccessTypeFull) self.accessTypeValueLabel.text = kAccessTypeFullAccessString;
}

@end

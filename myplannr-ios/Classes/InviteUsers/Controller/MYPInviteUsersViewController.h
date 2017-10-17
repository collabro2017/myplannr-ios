//
//  MYPInviteUsersViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 04/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPAlertsAwareViewController.h"
#import "MYPConstants.h"

@class MYPNonManagedInvitedUser;

@protocol MYPInviteUsersViewControllerDelegate <NSObject>

@optional
- (void)inviteUsersController:(UIViewController *)controller didInviteUser:(MYPNonManagedInvitedUser *)user;

@end

@interface MYPInviteUsersViewController : MYPAlertsAwareViewController

@property (weak, nonatomic) IBOutlet UIView *emailContainerView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UIView *accessTypeContainerView;
@property (weak, nonatomic) IBOutlet UILabel *accessTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessTypeValueLabel;

@property (weak, nonatomic) id<MYPInviteUsersViewControllerDelegate> delegate;

@end

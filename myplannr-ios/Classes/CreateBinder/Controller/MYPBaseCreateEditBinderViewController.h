//
//  MYPBaseCreateEditBinderViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 15/02/2017.
//
//

#import <UIKit/UIKit.h>
#import "MYPCreateOrEditBinderView.h"
#import "MYPAlertsAwareViewController.h"
#import "MYPInvitedUserCollectionViewCell.h"

@interface MYPBaseCreateEditBinderViewController : MYPAlertsAwareViewController

/* UI */

@property (weak, nonatomic) MYPCreateOrEditBinderView *binderView;

/* Data */

@property (strong, nonatomic) NSSet *invitedUsers;

@property (strong, nonatomic, readonly) NSString *binderName;
@property (strong, nonatomic, readonly) UIColor *binderColor;
@property (strong, nonatomic, readonly) NSDate *eventdate;

- (BOOL)validateInput;
- (void)configureCell:(MYPInvitedUserCollectionViewCell *)cell withUser:(id)user;

@end

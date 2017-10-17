//
//  MYPSettingsViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 21/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPAlertsAwareViewController.h"

@class MYPUserProfileCardView;

@interface MYPSettingsViewController : MYPAlertsAwareViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property (weak, nonatomic) IBOutlet MYPUserProfileCardView *userProfileCardView;

@property (weak, nonatomic) IBOutlet UIView *secondCardContainerView;
@property (weak, nonatomic) IBOutlet UILabel *iapDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *restorePurchasesButton;
@property (weak, nonatomic) IBOutlet UIButton *buySubscriptionButton;
@property (weak, nonatomic) IBOutlet UILabel *tellFriendsHintLabel;
@property (weak, nonatomic) IBOutlet UIButton *tellFriendsButton;

@property (weak, nonatomic) IBOutlet UIView *signOutCardContainerView;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@property (weak, nonatomic) IBOutlet UIButton *termsOfServicesButton;

@end

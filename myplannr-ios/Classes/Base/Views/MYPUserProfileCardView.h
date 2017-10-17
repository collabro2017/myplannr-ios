//
//  MYPUserProfileCardView.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 18/09/16.
//
//

#import <UIKit/UIKit.h>
#import "FCNibView.h"

@class MYPUserProfileCardView;

@protocol MYPUserProfileCardViewDelegate <NSObject>

@optional
- (void)userProfileView:(MYPUserProfileCardView *)view didTapAvatarImageView:(UIImageView *)imageView;
- (void)userProfileView:(MYPUserProfileCardView *)view didTapFirstNameLabel:(UILabel *)firstNameLabel;
- (void)userProfileView:(MYPUserProfileCardView *)view didTapLastNameLabel:(UILabel *)lastNameLabel;

@end

IB_DESIGNABLE
@interface MYPUserProfileCardView : FCNibView

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UIView *cardContainerView;

@property (weak, nonatomic) IBOutlet UIView *firstNameContainerView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;

@property (weak, nonatomic) IBOutlet UIView *lastNameContainerView;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@property (weak, nonatomic) IBOutlet UIView *separator1;

@property (weak, nonatomic) id<MYPUserProfileCardViewDelegate> delegate;

@end

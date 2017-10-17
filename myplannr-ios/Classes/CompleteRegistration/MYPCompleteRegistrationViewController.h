//
//  MYPCompleteRegistrationViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 18/09/16.
//
//

#import <UIKit/UIKit.h>

@class MYPUserProfileCardView;

@protocol MYPCompleteRegistrationViewControllerDelegate <NSObject>

@optional

- (void)completeRegistrationControllerDidFinishUserSetup:(UIViewController *)controller;

@end

@interface MYPCompleteRegistrationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet MYPUserProfileCardView *userProfileCardView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) id<MYPCompleteRegistrationViewControllerDelegate> delegate;

@end

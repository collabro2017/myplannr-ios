//
//  MYPRecoverPasswordViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 15/09/16.
//
//

#import <UIKit/UIKit.h>

@protocol MYPRecoverPasswordViewControllerDelegate <NSObject>

@optional

- (void)recoverPasswordControllerShouldDismiss:(UIViewController *)controller;

@end

@interface MYPRecoverPasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@property (weak, nonatomic) IBOutlet UIView *emailContainerView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UIButton *recoverButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) id<MYPRecoverPasswordViewControllerDelegate> delegate;

@end

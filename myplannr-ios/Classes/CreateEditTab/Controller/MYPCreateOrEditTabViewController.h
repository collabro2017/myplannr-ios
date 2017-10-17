//
//  MYPCreateOrEditTabViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 12/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPAlertsAwareViewController.h"
#import "MYPColorPickerView.h"
#import "MYPCreateOrEditTabModel.h"

@protocol MYPCreateOrEditTabViewControllerDelegate <NSObject>

@optional
- (void)createOrEditTabViewController:(UIViewController *)controller didCreateTab:(MYPBinderTab *)tab;
- (void)createOrEditTabViewController:(UIViewController *)controller didFinishEditingTab:(MYPBinderTab *)tab;

@end

@interface MYPCreateOrEditTabViewController : MYPAlertsAwareViewController

/* Views */

@property (weak, nonatomic) IBOutlet UIView *cardContentView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) IBOutlet UILabel *colorLabel;
@property (weak, nonatomic) IBOutlet MYPCircleView *colorCircleView;

/* Data */

@property (weak, nonatomic) id<MYPCreateOrEditTabViewControllerDelegate> delegate;

@property (strong, nonatomic) MYPCreateOrEditTabModel *model;

@end

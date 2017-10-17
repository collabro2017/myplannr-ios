//
//  MYPCreateOrEditBinderView.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 15/02/2017.
//
//

#import <UIKit/UIKit.h>
#import "FCNibView.h"
#import "MYPColorPickerView.h"

@interface MYPCreateOrEditBinderView : FCNibView

@property (weak, nonatomic) IBOutlet UIView *stackViewContainerView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property (weak, nonatomic) IBOutlet UIView *nameContainerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UIView *dateContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UIView *colorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;
@property (weak, nonatomic) IBOutlet MYPCircleView *colorCircleView;
@property (weak, nonatomic) IBOutlet UIImageView *colorDisclosureIndicatorImageView;

@property (weak, nonatomic) IBOutlet UIView *usersContainerView;
@property (weak, nonatomic) IBOutlet UILabel *usersLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *usersCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *addUserLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *addUserRightButton;
@property (weak, nonatomic) IBOutlet UIButton *userSettingsButton;
@property (weak, nonatomic) IBOutlet UILabel *usersHintLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteBinderButton;

@end

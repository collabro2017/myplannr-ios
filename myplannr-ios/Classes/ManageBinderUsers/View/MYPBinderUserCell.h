//
//  MYPBinderUserCell.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 07/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPCardViewCell.h"
#import "MYPCheckbox.h"

@protocol MYPBinderUserCellDelegate <NSObject>

@optional

- (void)binderUserCell:(UITableViewCell *)cell didChangeCheckedState:(BOOL)checked;

@end

@interface MYPBinderUserCell : MYPCardViewCell

@property (weak, nonatomic) IBOutlet UIView *contentCardView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *accessTypeImageView;
@property (weak, nonatomic) IBOutlet MYPCheckbox *checkbox;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkboxWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkboxLeadingConstraint;


@property (assign, nonatomic, readonly) BOOL isChecked;

@property (weak, nonatomic) id<MYPBinderUserCellDelegate> checkedStateDelegate;

@end

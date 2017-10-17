//
//  MYPBinderTabCell.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPCardViewCell.h"
#import "MYPCheckbox.h"

@protocol MYPBinderTabCellDelegate <NSObject>

@optional

- (void)binderTabCellDidTapCard:(UITableViewCell *)cell;
- (void)binderTabCell:(UITableViewCell *)cell didChangeCheckedState:(BOOL)checked;

@end

@interface MYPBinderTabCell : MYPCardViewCell

@property (weak, nonatomic) IBOutlet UIView *contentCardView;
@property (weak, nonatomic) IBOutlet MYPCheckbox *checkbox;
@property (weak, nonatomic) IBOutlet UIView *tabColorView;
@property (weak, nonatomic) IBOutlet UILabel *tabNameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkboxWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkboxLeadingMarginConstraint;


@property (weak, nonatomic) id<MYPBinderTabCellDelegate> binderTabDelegate;

@end

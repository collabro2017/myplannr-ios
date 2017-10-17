//
//  MYPBinderCollectionViewCell.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 27/09/2016.
//
//

#import <UIKit/UIKit.h>

@class JSBadgeView;
@class MYPBinder;

@protocol MYPBinderCollectionViewCellDelegate <NSObject>

@optional
- (void)binderCollectionViewCell:(UICollectionViewCell *)cell didTapBinderButton:(UIButton *)button;
- (void)binderCollectionViewCell:(UICollectionViewCell *)cell didTapChatButton:(UIButton *)button;

@end

@interface MYPBinderCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *binderContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *ownerAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *binderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *binderButton;

@property (weak, nonatomic) IBOutlet UIButton *binderChatButton;
@property (strong, nonatomic) JSBadgeView *chatBadgeView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ownerNameLabelTopConstraint;

@property (assign, nonatomic) NSInteger unreadMessagesCount;

@property (weak, nonatomic) id<MYPBinderCollectionViewCellDelegate> delegate;

@end

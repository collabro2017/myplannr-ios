//
//  MYPUserProfileCardView.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 18/09/16.
//
//

#import "MYPUserProfileCardView.h"
#import "MYPConstants.h"

static CGFloat const kViewHeight = 184.0f;

@implementation MYPUserProfileCardView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 40.0f;
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.firstNameTextField.text = NSLocalizedString(@"text field", nil);
    self.lastNameTextField.text =  NSLocalizedString(@"text field", nil);
}

- (CGSize)intrinsicContentSize {
    CGFloat width = UIViewNoIntrinsicMetric;
    CGFloat height = kViewHeight;
    return CGSizeMake(width, height);
}

#pragma mark - Gesture Recognizers

- (IBAction)handleAvatarImageViewTap:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(userProfileView:didTapAvatarImageView:)]) {
        UIImageView *imageView = (UIImageView *)sender.view;
        [self.delegate userProfileView:self didTapAvatarImageView:imageView];
    }
}

- (IBAction)handleFirstNameLabelTap:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(userProfileView:didTapFirstNameLabel:)]) {
        UILabel *label = (UILabel *)sender.view;
        [self.delegate userProfileView:self didTapFirstNameLabel:label];
    }
}

- (IBAction)handleLastNameLabelTap:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(userProfileView:didTapLastNameLabel:)]) {
        UILabel *label = (UILabel *)sender.view;
        [self.delegate userProfileView:self didTapLastNameLabel:label];
    }
}

@end

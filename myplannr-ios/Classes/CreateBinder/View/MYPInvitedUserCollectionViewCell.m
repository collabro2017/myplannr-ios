//
//  MYPInvitedUserCollectionViewCell.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 05/10/2016.
//
//

#import "MYPInvitedUserCollectionViewCell.h"

@implementation MYPInvitedUserCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.clipsToBounds = YES;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.layer.borderWidth = 2.0f;
    self.avatarImageView.layer.cornerRadius = 24.0f;
}

@end

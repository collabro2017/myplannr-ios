//
//  MYPBinderCollectionViewCell.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 27/09/2016.
//
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MYPBinderCollectionViewCell.h"
#import "JSBadgeView.h"
#import "MYPBinder.h"

static CGFloat const kBinderCornerRadius = 8.0f;
static CGFloat const kBadgePositionAdjustmentX = -2.0f;
static CGFloat const kBadgePositionAdjustmentY = 5.0f;

@implementation MYPBinderCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.clipsToBounds = NO;
    self.layer.shadowOpacity = 0.2f;
    self.layer.shadowRadius = 5.0f;
    
    self.chatBadgeView = [[JSBadgeView alloc] initWithParentView:self.binderChatButton
                                                       alignment:(JSBadgeViewAlignmentTopRight)];
    self.chatBadgeView.badgePositionAdjustment = CGPointMake(kBadgePositionAdjustmentX, kBadgePositionAdjustmentY);
    [self setUnreadMessagesCount:0];
    
    self.binderContainerView.backgroundColor = [UIColor clearColor];
    
    self.ownerAvatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ownerAvatarImageView.layer.borderWidth = 2.0f;
    self.ownerAvatarImageView.layer.cornerRadius = 24.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.binderContainerView.bounds
                                                   byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(kBinderCornerRadius, kBinderCornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.binderContainerView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.binderContainerView.layer.mask = maskLayer;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.ownerAvatarImageView sd_cancelCurrentImageLoad];
    self.delegate = nil;
}

#pragma mark - Public Methods & Properties

- (void)setUnreadMessagesCount:(NSInteger)unreadMessagesCount {
    _unreadMessagesCount = unreadMessagesCount;
    self.chatBadgeView.badgeText = [NSString stringWithFormat:@"%li", (long)unreadMessagesCount];
    self.chatBadgeView.hidden = (unreadMessagesCount == 0);
}

#pragma mark - Button Handlers

- (IBAction)handleBinderButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(binderCollectionViewCell:didTapBinderButton:)]) {
        [self.delegate binderCollectionViewCell:self didTapBinderButton:sender];
    }
}

- (IBAction)handleChatButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(binderCollectionViewCell:didTapChatButton:)]) {
        [self.delegate binderCollectionViewCell:self didTapChatButton:sender];
    }
}

@end

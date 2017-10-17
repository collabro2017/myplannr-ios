//
//  MYPCardViewCell.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/10/2016.
//
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>

extern NSInteger const kUtilityButtonColor;
extern CGFloat const kUtilityButtonWidth;

extern NSInteger const kCardBorderColorHex;
extern NSInteger const kHighlightedColorHex;

@interface MYPCardViewCell : SWTableViewCell

@property (assign, nonatomic) UIRectCorner cardViewCorners;

@property (strong, nonatomic, readonly) UIView *cardView; // override in subclasses

@property (assign, nonatomic) BOOL shouldHighlightOnTap;

- (void)handleCardViewTapGesture; // override in subclasses (optionally)

@end

//
//  MYPCardView.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 05/10/2016.
//
//

#import "MYPCardView.h"
#import "MYPConstants.h"

@implementation MYPCardView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
    self.layer.borderColor = [UIColor myp_colorWithHexInt:kCardBorderColor].CGColor;
    self.layer.cornerRadius = kCardViewCornerRadius;
    self.clipsToBounds = YES;
}

@end

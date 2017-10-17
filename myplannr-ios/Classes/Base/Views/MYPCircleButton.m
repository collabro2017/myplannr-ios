//
//  MYPCircleButton.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 01/10/2016.
//
//

#import "MYPCircleButton.h"

static CGFloat const kButtonSize = 48.0f;

@implementation MYPCircleButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupButton];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupButton];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(kButtonSize, kButtonSize);
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:@"" forState:state];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor whiteColor]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = (CGRectGetWidth(self.bounds) / 2);
}

#pragma mark - Private Methods

- (void)setupButton {
    self.tintColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

@end

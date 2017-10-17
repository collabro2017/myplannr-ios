//
//  MYPCardViewCell.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/10/2016.
//
//

#import "MYPCardViewCell.h"
#import "MYPConstants.h"

static CGFloat const kCardViewLeftRightMargin = 24.0f;

static CGFloat const kTapHighlightAnimationDuration = 0.15f;

NSInteger const kCardBorderColorHex = kCardBorderColor;
NSInteger const kHighlightedColorHex = 0xEEEEEE;

NSInteger const kUtilityButtonColor = 0xF4F4F4;
CGFloat const kUtilityButtonWidth = 64.0f;

@implementation MYPCardViewCell {
    CGSize _cornerRadii;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self checkCardViewProperty];
    
    _cornerRadii = CGSizeMake(kCardViewCornerRadius, kCardViewCornerRadius);
    
    NSMutableArray *rightButtons = [NSMutableArray arrayWithCapacity:1];
    [rightButtons sw_addUtilityButtonWithColor:[UIColor myp_colorWithHexInt:(int)kUtilityButtonColor]
                                          icon:[UIImage imageNamed:@"DeleteCellButton"]];
    [self setRightUtilityButtons:rightButtons WithButtonWidth:kUtilityButtonWidth];
    
    SEL selector = @selector(handleCardViewTapGesture:);
    UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:selector];
    [self.cardView addGestureRecognizer:gestureRecognizer];
    
    self.cardView.layer.masksToBounds = NO;
}

#pragma mark - Public methods & Properties

- (void)setCardViewCorners:(UIRectCorner)cardViewCorners {
    [self checkCardViewProperty];
    
    /* Corners */
    CGSize cellSize = self.bounds.size;
    CGRect cardBounds = CGRectMake(0.0f,
                                   0.0f,
                                   (cellSize.width - kCardViewLeftRightMargin * 2),
                                   cellSize.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cardBounds
                                                   byRoundingCorners:cardViewCorners
                                                         cornerRadii:_cornerRadii];
    CAShapeLayer *maskLayer = (CAShapeLayer *)self.cardView.layer.mask;
    if (maskLayer == nil) {
        maskLayer = [CAShapeLayer layer];
        maskLayer.frame = cardBounds;
        maskLayer.masksToBounds = NO;
        self.cardView.layer.mask = maskLayer;
    }
    maskLayer.path = maskPath.CGPath;
    
    /* Border */
    NSArray *sublayers = self.cardView.layer.sublayers;
    CAShapeLayer *frameLayer = nil;
    for (CALayer *layer in sublayers) {
        if ([layer.name isEqualToString:@"border"]) {
            frameLayer = (CAShapeLayer *)layer;
            break;
        }
    }
    if (frameLayer == nil) {
        frameLayer = [CAShapeLayer layer];
        frameLayer.name = @"border";
        frameLayer.frame = cardBounds;
        frameLayer.strokeColor = [UIColor myp_colorWithHexInt:kCardBorderColorHex].CGColor;
        frameLayer.fillColor = nil;
        [self.cardView.layer addSublayer:frameLayer];
    }
    frameLayer.path = maskPath.CGPath;
}

- (void)handleCardViewTapGesture {
    if (self.shouldHighlightOnTap) {
        [UIView animateWithDuration:kTapHighlightAnimationDuration animations:^{
            self.cardView.backgroundColor = [UIColor myp_colorWithHexInt:(int)kHighlightedColorHex];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kTapHighlightAnimationDuration animations:^{
                self.cardView.backgroundColor = [UIColor whiteColor];
            }];
        }];
    }
}

- (BOOL)shouldHighlightOnTap {
    return self.isEditing;
}

#pragma mark - Action Handlers

- (void)handleCardViewTapGesture:(id)sender {
    [self handleCardViewTapGesture];
}

#pragma mark - Private methods

- (void)checkCardViewProperty {
    if (self.cardView == nil) {
        NSString *reason = @"You must override 'cardView' getter in your subclass and return non-nil value";
        @throw [NSException exceptionWithName:@"Illegal state"
                                       reason:reason
                                     userInfo:nil];
    }
}

@end

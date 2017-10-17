//
//  MYPTabTitleView.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 12/11/2016.
//
//

#import "MYPTabTitleView.h"

CGFloat const kColorViewHeight = 4.0f;
CGFloat const kColorViewMinWidth = 25.0f;
CGFloat const kColorViewCornerRadius = 2.0f;

@interface MYPTabTitleView ()

@property (strong, nonatomic, readwrite) UILabel *titleLabel;
@property (strong, nonatomic, readwrite) UIView *colorView;

@end

@implementation MYPTabTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        self.titleLabel.textColor = [UIColor myp_colorWithHexInt:0x95989A];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        self.colorView = [[UIView alloc] init];
        self.colorView.layer.cornerRadius = kColorViewCornerRadius;
        self.colorView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.colorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize titleLabelSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}];
    
    CGFloat colorViewBottomMargin = 6.0f;
    CGFloat colorViewWidth = (titleLabelSize.width > kColorViewMinWidth) ? titleLabelSize.width : kColorViewMinWidth;
    self.colorView.frame = CGRectMake((self.bounds.size.width - colorViewWidth) / 2,
                                      self.frame.size.height - kColorViewHeight - colorViewBottomMargin,
                                      colorViewWidth,
                                      kColorViewHeight);
    
    CGFloat titleLabelBottomMargin = 4.0f;
    self.titleLabel.frame = CGRectMake((self.bounds.size.width - titleLabelSize.width) / 2,
                                       self.colorView.frame.origin.y - titleLabelSize.height - titleLabelBottomMargin,
                                       titleLabelSize.width,
                                       titleLabelSize.height);
}

#pragma mark - Public methods & properties

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    
    [self setNeedsLayout];
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setColor:(UIColor *)color {
    self.colorView.backgroundColor = color;
}

- (UIColor *)color {
    return self.colorView.backgroundColor;
}

@end

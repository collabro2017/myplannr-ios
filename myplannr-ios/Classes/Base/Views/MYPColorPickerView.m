//
//  MYPColorPickerView.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 30/09/2016.
//
//

#import "MYPColorPickerView.h"

static NSArray *kDefaultColors = nil;

static CGFloat const kCircleViewDefaultSize = 16.0f;
static CGFloat const kCircleViewDefaultMargin = kCircleViewDefaultSize;
static CGFloat const kSelectedCircleViewScaleFactor = 1.3f;

static NSInteger const kDefaultCircleColor = 0xABD0E2;

@implementation MYPCircleView

- (instancetype)initWithColor:(UIColor *)color {
    self = [super init];
    if (self) {
        [self setupWithColor:color];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupWithColor:[UIColor myp_colorWithHexInt:kDefaultCircleColor]];
    }
    return self;
}

- (instancetype)init {
    return [self initWithColor:[UIColor myp_colorWithHexInt:kDefaultCircleColor]];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents(self.circleColor.CGColor));
    CGContextFillPath(ctx);
}

- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
    
    [self setNeedsDisplay];
}

#pragma mark - Private methods

- (void)setupWithColor:(UIColor *)color {
    self.circleColor = color;
    self.backgroundColor = [UIColor clearColor];
}

@end

@interface MYPColorPickerView ()

@property (nonatomic, strong) NSArray<UIColor*> *colors;

@end

@implementation MYPColorPickerView

+ (instancetype)colorPickerViewWithColors:(NSArray<UIColor *> *)colors {
    return [[self alloc] initWithColors:colors];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithColors:(NSArray<UIColor *> *)colors {
    self = [self initWithFrame:CGRectZero];
    self.colors = colors;
    return self;
}

- (void)addSubview:(UIView *)view {
    @throw [NSException exceptionWithName:@"Illegal call"
                                   reason:@"You must not add any subviews to the color picker view"
                                 userInfo:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGFloat xOffset = 0.0f;
    CGFloat yOffset = 0.0f;
    UIColor *selectedColor = (self.colors.count > 0) ? self.colors[self.selectedColorIndex] : nil;
    if (self.alignment == MYPColorPickerViewAlignmentRight) {
        xOffset = (bounds.size.width - self.circleItemSize - self.circleItemMargin);
        yOffset = self.circleItemMargin;
        for (MYPCircleView *subView in self.subviews) {
            BOOL newLine = (xOffset - self.circleItemSize - self.circleItemMargin) < 0;
            if (newLine) {
                xOffset = (bounds.size.width - self.circleItemSize - self.circleItemMargin);
                yOffset += self.circleItemSize + self.circleItemMargin;
            }
            subView.frame = CGRectMake(xOffset,
                                       yOffset,
                                       self.circleItemSize,
                                       self.circleItemSize);
            xOffset -= (self.circleItemSize + self.circleItemMargin);
            
            BOOL isSelected = [selectedColor isEqual:subView.circleColor];
            CGFloat size = isSelected ? self.circleItemSize * kSelectedCircleViewScaleFactor :  self.circleItemSize;
            [self animateBoundsChangeForView:subView newSize:CGSizeMake(size, size)];
        }
    } else if (self.alignment == MYPColorPickerViewAlignmentLeft) {
        xOffset = self.circleItemMargin;
        yOffset = self.circleItemMargin;
        for (MYPCircleView *subView in self.subviews) {
            BOOL newLine = (xOffset + self.circleItemSize + self.circleItemMargin) >= bounds.size.width;
            if (newLine) {
                xOffset = self.circleItemMargin;
                yOffset += self.circleItemSize + self.circleItemMargin;
            }
            subView.frame = CGRectMake(xOffset,
                                       yOffset,
                                       self.circleItemSize,
                                       self.circleItemSize);
            xOffset += (self.circleItemSize + self.circleItemMargin);
            
            BOOL isSelected = [selectedColor isEqual:subView.circleColor];
            CGFloat size = isSelected ? self.circleItemSize * kSelectedCircleViewScaleFactor :  self.circleItemSize;
            [self animateBoundsChangeForView:subView newSize:CGSizeMake(size, size)];
        }
    }
}

#pragma mark - Properties

- (void)setColors:(NSArray<UIColor *> *)colors {
    _colors = colors;
    
    NSArray *subviews = self.subviews;
    for (UIView *v in subviews) {
        [v removeFromSuperview];
    }
    
    [self setNeedsLayout];
}

- (void)setSelectedColorIndex:(NSInteger)selectedColorIndex {
    _selectedColorIndex = selectedColorIndex;
    
    [self setNeedsLayout];
}

- (UIColor *)selectedColor {
    return self.colors[self.selectedColorIndex];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    NSInteger index = [self.colors indexOfObject:selectedColor];
    if (index != NSNotFound) {
        [self setSelectedColorIndex:index];
    }
}

- (void)setCircleItemSize:(CGFloat)circleItemSize {
    _circleItemSize = circleItemSize;
    
    [self setNeedsLayout];
}

- (void)setCircleItemMargin:(CGFloat)circleItemMargin {
    _circleItemMargin = circleItemMargin;
    
    [self setNeedsLayout];
}

- (void)setAlignment:(MYPColorPickerViewAlignment)alignment {
    _alignment = alignment;
    
    [self setNeedsLayout];
}

#pragma mark - Gesture Recognizers

- (void)handleCircleViewClick:(id)sender {
    UIGestureRecognizer *gestureRecognizer = sender;
    MYPCircleView *targetView = (MYPCircleView *) gestureRecognizer.view;
    UIColor *color = targetView.circleColor;
    self.selectedColorIndex = [self.colors indexOfObject:color];
}

#pragma mark - Private Methods

- (void)setupView {
    self.clipsToBounds = YES;
    self.circleItemSize = kCircleViewDefaultSize;
    self.circleItemMargin = kCircleViewDefaultMargin;
    self.alignment = MYPColorPickerViewAlignmentRight;
    self.selectedColorIndex = 0;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kDefaultColors = @[
                           [UIColor myp_colorWithHexInt:0x43434E],
                           [UIColor myp_colorWithHexInt:0xFC3A30],
                           [UIColor myp_colorWithHexInt:0xFFCB00],
                           [UIColor myp_colorWithHexInt:0x4CD963],
                           [UIColor myp_colorWithHexInt:0x017AFF],
                           [UIColor myp_colorWithHexInt:0xBADDC7],
                           [UIColor myp_colorWithHexInt:0xABD0E2],
                           [UIColor myp_colorWithHexInt:0xFFD3C0],
                           [UIColor myp_colorWithHexInt:0xFFABAB],
                           [UIColor myp_colorWithHexInt:0xC1AEA7]
                           ];
    });
    
    if (self.colors.count == 0) {
        self.colors = [[NSArray alloc] initWithArray:kDefaultColors copyItems:YES];
    }
    
    for (UIColor *color in self.colors) {
        UIView *view = [[MYPCircleView alloc] initWithColor:color];
        view.clipsToBounds = YES;
        
        SEL selector = @selector(handleCircleViewClick:);
        UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:selector];
        [view addGestureRecognizer:gestureRecognizer];
        
        [super addSubview:view];
    }
}

- (void)animateBoundsChangeForView:(UIView *)view newSize:(CGSize)newSize {
#if !TARGET_INTERFACE_BUILDER
    [UIView animateWithDuration:0.2f animations:^{
        CGRect bounds = view.bounds;
        view.bounds = CGRectMake(bounds.origin.x, bounds.origin.y, newSize.width, newSize.height);
    }];
#endif
}

@end

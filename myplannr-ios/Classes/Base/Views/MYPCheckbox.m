//
//  MYPCheckbox.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 09/10/2016.
//
//

#import "MYPCheckbox.h"

CGFloat const kCheckbkoxViewSize = 26.0f;

@interface MYPCheckbox ()

@property (strong, nonatomic, readwrite) UIImageView *imageView;

@property (strong, nonatomic) UIImage *imageChecked;
@property (strong, nonatomic) UIImage *imageUnchecked;

@end

@implementation MYPCheckbox

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

- (CGSize)intrinsicContentSize {
    return CGSizeMake(kCheckbkoxViewSize, kCheckbkoxViewSize);
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    self.imageView.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark - Public Methods & Properties

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    
    [UIView transitionWithView:self
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = checked ? self.imageChecked : self.imageUnchecked;
                    }
                    completion:nil];
}

- (UIImage *)imageChecked {
    if (_imageChecked == nil) {
        _imageChecked = [UIImage imageNamed:@"CheckboxChecked"];
    }
    return _imageChecked;
}

- (UIImage *)imageUnchecked {
    if (_imageUnchecked == nil) {
        _imageUnchecked = [UIImage imageNamed:@"CheckboxUnchecked"];
    }
    return _imageUnchecked;
}

#pragma mark - Action Handlers

- (void)handleTapGesture:(id)sender {
    self.checked = !self.isChecked;
}

#pragma mark - Private Methods

- (void)setupView {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   kCheckbkoxViewSize,
                                                                   kCheckbkoxViewSize)];
    [self addSubview:self.imageView];
    
    self.backgroundColor = [UIColor clearColor];
    self.checked = NO;
    
    UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:gestureRecognizer];
    
    self.clipsToBounds = YES;
    self.imageView.clipsToBounds = YES;
}

@end

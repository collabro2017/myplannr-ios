//
//  FCNibView.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 19/02/2017.
//
//

#import "FCNibView.h"

@implementation FCNibView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setupView {    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSArray *views = [bundle loadNibNamed:NSStringFromClass([self class])
                                    owner:self
                                  options:nil];
    self.contentView = views[0];
    self.contentView.frame = self.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self addSubview:self.contentView];
}

@end

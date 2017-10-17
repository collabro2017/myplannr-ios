//
//  MYPBindersFlowLayout.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 27/09/2016.
//
//

#import "MYPBindersFlowLayout.h"
#import "MYPDevicePropertiesUtils.h"
#import <objc/message.h>

static CGFloat const kActiveDistance = 200.0f;

static CGFloat const kBinderCellWidthIphone4 = 160.0f;
static CGFloat const kBinderCellHeightIphone4 = 275.0f;

static CGFloat const kBinderCellWidthIphone5 = 190.0f;
static CGFloat const kBinderCellHeightIphone5 = 325.0f;

static CGFloat const kBinderCellWidthIphone6 = 205.0;
static CGFloat const kBinderCellHeightIphone6 = 350.0;

static CGFloat const kBinderCellWidthIphonePlus = 230;
static CGFloat const kBinderCellHeightIphonePlus = 390.0f;

static CGFloat const kBinderCellWidthIpad = 290.0f;
static CGFloat const kBinderCellHeightIpad = 485.0f;

static CGFloat const kInterItemMinDistanceIphone = 40.0f;
static CGFloat const kSelectedBinderYOffsetIhpone = 25.0f;

static CGFloat const kInterItemMinDistanceIpad = 50.0f;
static CGFloat const kSelectedBinderYOffsetIpad = 30.0f;

@implementation MYPBindersFlowLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.activeDistance = kActiveDistance;
        self.minimumLineSpacing = IS_IPHONE ? kInterItemMinDistanceIphone : kInterItemMinDistanceIpad;
        
        CGFloat width = 0;
        if (IS_IPHONE_4_OR_LESS) width = kBinderCellWidthIphone4;
        else if (IS_IPHONE_5)    width = kBinderCellWidthIphone5;
        else if (IS_IPHONE_6)    width = kBinderCellWidthIphone6;
        else if (IS_IPHONE_6P)   width = kBinderCellWidthIphonePlus;
        else if (IS_IPAD)        width = kBinderCellWidthIpad;
        else                     width = kBinderCellWidthIphone5;
        
        CGFloat height = 0;
        if (IS_IPHONE_4_OR_LESS) height = kBinderCellHeightIphone4;
        else if (IS_IPHONE_5)    height = kBinderCellHeightIphone5;
        else if (IS_IPHONE_6)    height = kBinderCellHeightIphone6;
        else if (IS_IPHONE_6P)   height = kBinderCellHeightIphonePlus;
        else if (IS_IPAD)        height = kBinderCellHeightIpad;
        else                     height = kBinderCellHeightIphone5;
        
        self.itemSize = CGSizeMake(width, height);
    }
    return self;
}

- (CATransform3D)transformationForActiveItem:(UICollectionViewLayoutAttributes *)attrs offsetFromCenter:(CGFloat)offset {
    CGFloat normalizedDistance = (offset / self.activeDistance);
    CGFloat yOffset = IS_IPHONE ? kSelectedBinderYOffsetIhpone : kSelectedBinderYOffsetIpad;
    CGFloat ty = (1 - ABS(normalizedDistance)) * -1.0f * yOffset;
    CATransform3D transform = CATransform3DMakeTranslation(0.0f, ty, 0.0f);
    return transform;
}

@end

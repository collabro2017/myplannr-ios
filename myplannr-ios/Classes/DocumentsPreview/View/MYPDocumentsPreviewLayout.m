//
//  MYPDocumentsPreviewLayout.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 20/10/2016.
//
//

#import "MYPDocumentsPreviewLayout.h"

static CGFloat const kDocumentCellSize = 65.0f;
static CGFloat const kActiveDistance = 50.0f;
static CGFloat const kInterItemMinDistance = 8.0f;
static CGFloat const kZoomFactor = 0.15f;
static CGFloat const kActivationTresholdDistance = 5.0f;

@implementation MYPDocumentsPreviewLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.itemSize = CGSizeMake(kDocumentCellSize, kDocumentCellSize);
        self.minimumLineSpacing = kInterItemMinDistance;
        self.activeDistance = kActiveDistance;
        self.activationTresholdDistance = kActivationTresholdDistance;
    }
    return self;
}

- (CATransform3D)transformationForActiveItem:(UICollectionViewLayoutAttributes *)attrs
                            offsetFromCenter:(CGFloat)offset {
    
    CGFloat normalizedDistance = (offset / self.activeDistance);
    CGFloat zoom = 1 + kZoomFactor * (1 - ABS(normalizedDistance));
    CATransform3D transform = CATransform3DMakeScale(zoom, zoom, 1.0);
    return transform;
}

@end

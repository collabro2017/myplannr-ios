//
//  MYPCenteredFlowLayout.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 20/10/2016.
//
//

#import <objc/message.h>
#import "MYPCenteredFlowLayout.h"

static CGFloat const kDefaultSectionInnsetTop = 0.0f;
static CGFloat const kDefaultSectionInnsetBottom = 0.0f;
static CGFloat const kDefaultActiveDistance = 50.0f;
static CGFloat const kDefaultActivationTresholdDistance = 0.0f;

@interface MYPCenteredFlowLayout () {
    BOOL _delegateSupportsCentering;
    BOOL _delegateSupportsDecentering;
}

@end

@implementation MYPCenteredFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupLayout];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLayout];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    SEL sel1 = @selector(collectionView:layout:didCenterItemAtIndexPath:);
    SEL sel2 = @selector(collectionView:layout:didDecenterItemAtIndexPath:);
    _delegateSupportsCentering = [self.collectionView.delegate respondsToSelector:sel1];
    _delegateSupportsDecentering = [self.collectionView.delegate respondsToSelector:sel2];
    
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat leftRightInset = (collectionViewWidth - self.itemSize.width) / 2;
    self.sectionInset = UIEdgeInsetsMake(self.topSectionInset,
                                         leftRightInset,
                                         self.bottomSectionInset,
                                         leftRightInset);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attrsArray = [super layoutAttributesForElementsInRect:rect];
    NSArray *attrsArrayCopy = [[NSArray alloc] initWithArray:attrsArray copyItems:YES];
    for (UICollectionViewLayoutAttributes *attrs in attrsArrayCopy) {
        if (attrs.representedElementCategory == UICollectionElementCategoryCell) {
            [self configurateCellLayoutAttributes:attrs];
        }
    }
    return attrsArrayCopy;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [super layoutAttributesForItemAtIndexPath:indexPath].copy;
    [self configurateCellLayoutAttributes:attrs];
    return attrs;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity {
    
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    CGRect targetRect = CGRectMake(proposedContentOffset.x,
                                   0.0f,
                                   self.collectionView.bounds.size.width,
                                   self.collectionView.bounds.size.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

- (CATransform3D)transformationForActiveItem:(UICollectionViewLayoutAttributes *)attrs
                            offsetFromCenter:(CGFloat)offset {
    
    CATransform3D transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
    return transform;
}

#pragma mark - Private methods

- (void)setupLayout {
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.bottomSectionInset = kDefaultSectionInnsetBottom;
    self.topSectionInset = kDefaultSectionInnsetTop;
    self.activeDistance = kDefaultActiveDistance;
    self.activationTresholdDistance = kDefaultActivationTresholdDistance;
    
    _delegateSupportsCentering = NO;
    _delegateSupportsDecentering = NO;
}

- (void)configurateCellLayoutAttributes:(UICollectionViewLayoutAttributes *)attrs {
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    if (CGRectIntersectsRect(attrs.frame, visibleRect)) {
        CGFloat distance = CGRectGetMidX(visibleRect) - attrs.center.x;
        if (ABS(distance) < self.activeDistance) {
            CATransform3D transform = [self transformationForActiveItem:attrs.copy
                                                       offsetFromCenter:distance];
            attrs.transform3D = transform;
            
            CGFloat normalizedDistance = distance / self.activeDistance;
            BOOL isCloseToCenter = (ABS(normalizedDistance) <= self.activationTresholdDistance);
            if (isCloseToCenter && _delegateSupportsCentering) {
                ((void (*)(id, SEL, id, id, id))objc_msgSend)(self.collectionView.delegate,
                                                              @selector(collectionView:layout:didCenterItemAtIndexPath:),
                                                              self.collectionView,
                                                              self,
                                                              attrs.indexPath);
            } else if (_delegateSupportsDecentering) {
                ((void (*)(id, SEL, id, id, id))objc_msgSend)(self.collectionView.delegate,
                                                              @selector(collectionView:layout:didDecenterItemAtIndexPath:),
                                                              self.collectionView,
                                                              self,
                                                              attrs.indexPath);
            }
        }
    }
}

@end

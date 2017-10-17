//
//  MYPInvitedUsersFlowLayout.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 05/10/2016.
//
//

#import "MYPInvitedUsersFlowLayout.h"

static CGFloat const kPreferredXOffset = 40.0f;

@interface MYPInvitedUsersFlowLayout ()

@property (nonatomic, assign) CGFloat xOffset;

@end

@implementation MYPInvitedUsersFlowLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.xOffset = kPreferredXOffset;
        
        self.collectionView.clipsToBounds = YES;
        self.minimumInteritemSpacing = 0.0f;
        self.minimumLineSpacing = 0.0f;
        self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.collectionView.bounds;
    gradientLayer.colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor];
    gradientLayer.startPoint = CGPointMake(0.75f, 1.0f);
    gradientLayer.endPoint = CGPointMake(1.0f, 1.0f);
    gradientLayer.cornerRadius = 8.0f;
    self.collectionView.layer.mask = gradientLayer;
    
    NSInteger itemsCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat itemWidth = self.itemSize.width;
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    CGFloat optimalContentWidth = itemWidth + ((itemsCount - 1) * (itemWidth - (itemWidth - self.xOffset)));
    if (optimalContentWidth > collectionViewWidth) {
        CGFloat dif = optimalContentWidth - collectionViewWidth;
        CGFloat adjustment = dif / itemsCount;
        self.xOffset -= adjustment;
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attrsArrayOriginal = [super layoutAttributesForElementsInRect:rect];
    NSArray *attrsArrayCopy = [[NSArray alloc] initWithArray:attrsArrayOriginal copyItems:YES];
    for (UICollectionViewLayoutAttributes *attrs in attrsArrayCopy) {
        if (attrs.representedElementCategory == UICollectionElementCategoryCell) {
            [self setupLayoutAttributes:attrs];
        }
    }
    return attrsArrayCopy;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [super layoutAttributesForItemAtIndexPath:indexPath].copy;
    [self setupLayoutAttributes:attrs];
    return attrs;
}

#pragma mark - Private Methods

- (void)setupLayoutAttributes:(UICollectionViewLayoutAttributes *)attrs {
    NSIndexPath *path = attrs.indexPath;
    CGFloat centerX = (attrs.size.width / 2) + (path.row * self.xOffset);
    CGFloat centerY = (attrs.size.height / 2);
    attrs.center = CGPointMake(centerX, centerY);
    attrs.zIndex = path.row;
}

@end

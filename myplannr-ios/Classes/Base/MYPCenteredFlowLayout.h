//
//  MYPCenteredFlowLayout.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 20/10/2016.
//
//

#import <UIKit/UIKit.h>

@protocol MYPCenteredFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@optional
- (void)collectionView:(UICollectionView *)collectionView
                layout:(UICollectionViewLayout *)collectionViewLayout
didCenterItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView
                layout:(UICollectionViewLayout *)collectionViewLayout
didDecenterItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface MYPCenteredFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat topSectionInset;
@property (nonatomic, assign) CGFloat bottomSectionInset;
@property (nonatomic, assign) CGFloat activeDistance;
@property (nonatomic, assign) CGFloat activationTresholdDistance;

- (CATransform3D)transformationForActiveItem:(UICollectionViewLayoutAttributes *)attrs
                            offsetFromCenter:(CGFloat)offset;

@end

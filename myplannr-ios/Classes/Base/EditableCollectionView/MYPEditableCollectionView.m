//
//  MYPEditableCollectionView.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 18/10/2016.
//
//

#import "MYPEditableCollectionView.h"
#import "MYPEditableCollectionViewCell.h"

@implementation MYPEditableCollectionView

- (void)setEditingModeEnabled:(BOOL)editingModeEnabled {
    _editingModeEnabled = editingModeEnabled;
    
    for (UICollectionViewCell *cell in self.visibleCells) {
        if ([cell isKindOfClass:[MYPEditableCollectionViewCell class]]) {
            ((MYPEditableCollectionViewCell *)cell).editing = editingModeEnabled;
        } else {
            NSLog(@"MYPEditableCollectionView: cells must extend MYPEditableCollectionViewCell class");
        }
    }
}

@end

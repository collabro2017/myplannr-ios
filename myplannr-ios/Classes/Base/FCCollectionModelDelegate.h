//
//  FCCollectionModelDelegate.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 17/02/2017.
//
//

#import <Foundation/Foundation.h>

@protocol FCCollectionModelDelegate <NSObject>

@optional
- (void)model:(id)model didInsertItemsAtIndexPaths:(NSArray<NSIndexPath*> *)paths;
- (void)model:(id)model didUpdateItemsAtIndexPaths:(NSArray<NSIndexPath*> *)paths;
- (void)model:(id)model didDeleteItemsAtIndexPaths:(NSArray<NSIndexPath*> *)paths;
- (void)model:(id)model didMoveItemFromIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath;

@end

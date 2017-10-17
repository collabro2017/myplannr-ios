//
//  MYPBindersListModel.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "MYPBinder.h"
#import "FCCollectionModelDelegate.h"

@interface MYPBindersListModel : NSObject

@property (nonatomic, strong, readonly) NSArray<MYPBinder *> *binders;
@property (nonatomic, strong, readonly) NSArray *bindersWithFullAccess;
@property (nonatomic, assign, readonly, getter=isLoadingBinders) BOOL loadingBinders;

@property (nonatomic, weak) id<FCCollectionModelDelegate> delegate;

- (void)loadBindersWithCompletionBlock:(void (^)(NSArray *results, BOOL fromLocalStorage, NSError *error))completion;

- (void)addBinder:(MYPBinder *)binder;
- (void)deleteBinder:(MYPBinder *)binder;
- (void)updateBinder:(MYPBinder *)binder;

@end

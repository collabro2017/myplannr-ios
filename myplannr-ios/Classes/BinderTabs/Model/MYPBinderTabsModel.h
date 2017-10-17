//
//  MYPBinderTabsModel.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 20/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "MYPBinder.h"
#import "MYPBinderTab.h"
#import "MYPService.h"
#import "FCCollectionModelDelegate.h"

@interface MYPBinderTabsModel : NSObject

@property (strong, nonatomic, readonly) MYPBinder *binder;
@property (strong, nonatomic, readonly) NSArray<MYPBinderTab *> *tabs;

@property (weak, nonatomic) id<FCCollectionModelDelegate> delegate;

- (instancetype)initWithBinder:(MYPBinder *)binder;

- (void)loadTabsWithCompletionBlock:(void (^)(NSArray *results, BOOL fromLocalStorage, NSError *error))completion;

- (void)addTab:(MYPBinderTab *)tab;

- (void)updateTab:(MYPBinderTab *)tab;

- (void)deleteTabs:(NSArray *)tabsToRemove completionBlock:(void (^)(BOOL success, NSArray *errors))completion;

@end

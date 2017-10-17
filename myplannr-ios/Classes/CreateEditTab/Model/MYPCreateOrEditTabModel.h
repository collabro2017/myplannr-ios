//
//  MYPCreateOrEditTabModel.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 20/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "MYPBinder.h"
#import "MYPBinderTab.h"
#import "MYPService.h"

@interface MYPCreateOrEditTabModel : NSObject

@property (strong, nonatomic, readonly) MYPBinder *binder;
@property (strong, nonatomic, readonly) MYPBinderTab *editingTab;

- (instancetype)initWithBinder:(MYPBinder *)binder;
- (instancetype)initWithBinder:(MYPBinder *)binder editingTab:(MYPBinderTab *)tab;

- (void)createTabWithTitle:(NSString *)title
                     color:(UIColor *)color
                completion:(void (^)(MYPBinderTab *tab, NSError* error))completion;

- (void)updateTabWithTitle:(NSString *)title
                     color:(UIColor *)color
                completion:(void (^)(MYPBinderTab *tab, NSError* error))completion;

@end

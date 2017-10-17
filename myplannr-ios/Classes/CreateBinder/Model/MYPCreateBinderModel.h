//
//  MYPCreateBinderModel.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 07/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "MYPBinder.h"
#import "MYPNonManagedInvitedUser.h"
#import "MYPService.h"

@interface MYPCreateBinderModel : NSObject

- (void)createBinderWithName:(NSString *)name
                       color:(UIColor *)color
                        date:(NSDate *)date
                       users:(NSSet<MYPNonManagedInvitedUser*> *)users
                  completion:(void (^)(MYPBinder *binder, NSError* error))completion;

@end

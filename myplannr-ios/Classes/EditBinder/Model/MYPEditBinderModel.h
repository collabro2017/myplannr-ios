//
//  MYPEditBinderModel.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/02/2017.
//
//

#import <Foundation/Foundation.h>

@class MYPBinder;

@interface MYPEditBinderModel : NSObject

@property (nonatomic, strong, readonly) MYPBinder *editingBinder;

- (instancetype)initWithBinder:(MYPBinder *)binder;

- (void)updateBinderWithName:(NSString *)name
                       color:(UIColor *)color
                   eventDate:(NSDate *)date
                  completion:(void (^)(BOOL success, NSError *error))completion;

- (void)updateInvitedUsers:(NSSet *)invitedUsers completion:(void (^)(BOOL success, NSArray *errors))completion;

- (void)deleteBinderWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end

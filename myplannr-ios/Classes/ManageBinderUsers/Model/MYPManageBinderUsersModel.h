//
//  MYPManageBinderUsersModel.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 17/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "FCCollectionModelDelegate.h"
#import "MYPConstants.h"

@interface MYPManageBinderUsersModel : NSObject

@property (strong, nonatomic, readonly) NSOrderedSet *binderUsers;

@property (weak, nonatomic) id<FCCollectionModelDelegate> delegate;

- (instancetype)initWithUsers:(NSOrderedSet *)users;

- (void)removeUsers:(NSArray *)usersToRemove;

- (MYPAccessType)accessTypeForUser:(id)user;
- (NSString *)emailForUser:(id)user;
- (NSString *)fullNameForUser:(id)user;
- (NSString *)avatarForUser:(id)user;
- (NSData *)thumbnailForUser:(id)user;

@end

//
//  MYPBinder.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 23/08/16.
//
//

#import "MYPServiceObject.h"
#import "MYPConstants.h"

@class MYPUser;
@class MYPInvitedUser;

@interface MYPBinder : MYPServiceObject

@property (nonatomic, strong) NSNumber *binderId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *colorString;
@property (nonatomic, strong) NSDate *eventDate;

@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, strong) MYPUser *owner;
@property (nonatomic, assign) MYPAccessType accessType;

@property (nonatomic, strong) NSSet<MYPInvitedUser *> *invitedUsers;

// Transient properties (not persisted to CoreData)

@property (nonatomic, strong) UIColor *color;

- (NSComparisonResult)compare:(MYPBinder *)otherObject;

@end

@interface MYPBinder (CoreDataAcessors)

- (void)addInvitedUsersObject:(MYPInvitedUser *)value;
- (void)removeInvitedUsersObject:(MYPInvitedUser *)value;
- (void)addInvitedUsers:(NSSet<MYPInvitedUser *> *)values;
- (void)removeInvitedUsers:(NSSet<MYPInvitedUser *> *)values;

@end

//
//  MYPInvitedUser.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 25/08/16.
//
//

#import "MYPServiceObject.h"
#import "MYPUserProtocol.h"
#import "MYPConstants.h"

@class MYPBinder;

@interface MYPInvitedUser : MYPServiceObject<MYPUserProtocol>

@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) MYPAccessType accessType;
@property (nonatomic, strong) MYPBinder *sharedBinder;
@property (nonatomic, strong) NSNumber *binderId;

@end

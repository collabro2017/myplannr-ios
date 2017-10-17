//
//  MYPUserProfile.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 09/09/16.
//
//

#import <Foundation/Foundation.h>
#import "MYPUser.h"

@interface MYPUserProfile : NSObject

@property (nonatomic, strong, readonly) MYPUser *currentUser;

@property (nonatomic, readonly, getter=isAuthorized) BOOL authorized;

+ (MYPUserProfile *)sharedInstance;

@end

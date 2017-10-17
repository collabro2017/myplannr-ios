//
//  MYPNonManagedInvitedUser.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 14/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "MYPConstants.h"

@interface MYPNonManagedInvitedUser : NSObject

@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, assign, readonly) MYPAccessType accessType;

@property (nonatomic, strong, readonly) NSString *fullName;
@property (nonatomic, strong, readonly) NSData *thumbnailImageData;

@property (nonatomic, assign, readonly) BOOL hasThumbnail;

+ (instancetype)invitedUserWithEmail:(NSString *)email
                            fullName:(NSString *)fullName
                          accessType:(MYPAccessType)accessType
                           thumbnail:(NSData *)thumbnail;

- (instancetype)initWithEmail:(NSString *)email
                     fullName:(NSString *)fullName
                   accessType:(MYPAccessType)accessType
                    thumbnail:(NSData *)thumbnail;

@end

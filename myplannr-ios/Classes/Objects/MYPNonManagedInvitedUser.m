//
//  MYPNonManagedInvitedUser.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 14/02/2017.
//
//

#import "MYPNonManagedInvitedUser.h"

@interface MYPNonManagedInvitedUser ()

@property (nonatomic, strong, readwrite) NSString *email;
@property (nonatomic, strong, readwrite) NSString *fullName;
@property (nonatomic, assign, readwrite) MYPAccessType accessType;
@property (nonatomic, strong, readwrite) NSData *thumbnailImageData;

@end

@implementation MYPNonManagedInvitedUser

+ (instancetype)invitedUserWithEmail:(NSString *)email
                            fullName:(NSString *)fullName
                          accessType:(MYPAccessType)accessType
                           thumbnail:(NSData *)thumbnail
{
    return [[self alloc] initWithEmail:email
                              fullName:fullName
                            accessType:accessType
                             thumbnail:thumbnail];
}

- (instancetype)initWithEmail:(NSString *)email
                     fullName:(NSString *)fullName
                   accessType:(MYPAccessType)accessType
                    thumbnail:(NSData *)thumbnail
{
    self = [super init];
    if (self) {
        self.email = email;
        self.fullName = fullName;
        self.accessType = accessType;
        self.thumbnailImageData = thumbnail;
    }
    return self;
}

- (BOOL)hasThumbnail {
    return self.thumbnailImageData.length > 0;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[MYPNonManagedInvitedUser class]]) {
        return NO;
    }
    
    MYPNonManagedInvitedUser *other = (object);
    return [self.email isEqualToString:other.email];
}

- (NSUInteger)hash {
    return self.email.hash;
}

@end

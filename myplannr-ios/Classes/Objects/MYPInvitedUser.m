//
//  MYPInvitedUser.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 25/08/16.
//
//

#import "MYPInvitedUser.h"
#import "MYPBinder.h"

@implementation MYPInvitedUser

@dynamic userId;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic avatarUrl;
@dynamic isActive;
@dynamic accessType;
@dynamic sharedBinder;
@dynamic binderId;

+ (RKEntityMapping *)responseMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKEntityMapping *mapping = [super responseMappingForManagedObjectStore:store];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"             : @"userId",
                                                  @"email"          : @"email",
                                                  @"first_name"     : @"firstName",
                                                  @"last_name"      : @"lastName",
                                                  @"avatar_url"     : @"avatarUrl",
                                                  @"is_active"      : @"isActive",
                                                  @"access_type_id" : @"accessType",
                                                  @"@parent.id"     : @"binderId"
                                                  }];
    
    mapping.identificationAttributes = @[@"userId", @"binderId"];
    
    return mapping;
}

+ (RKObjectMapping *)requestMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"userId"     : @"user_id",
                                                  @"email"      : @"email",
                                                  @"accessType" : @"access_type_id"
                                                  }];
    return mapping;
}

- (NSString *)fullName {
    NSString *fullName = @"";
    if (self.firstName.length > 0 && self.lastName.length > 0) {
        fullName = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
    return fullName;
}

@end

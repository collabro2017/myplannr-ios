//
//  MYPBinder.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 23/08/16.
//
//

#import "MYPBinder.h"
#import "MYPUser.h"
#import "MYPInvitedUser.h"
#import "MYPConstants.h"
#import "RKValueTransformer+Extenstions.h"

@implementation MYPBinder

@dynamic binderId;
@dynamic name;
@dynamic colorString;
@dynamic eventDate;
@dynamic isOwner;
@dynamic accessType;
@dynamic owner;
@dynamic invitedUsers;

@synthesize color = _color;

+ (RKEntityMapping *)responseMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKEntityMapping *mapping = [super responseMappingForManagedObjectStore:store];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"             : @"binderId",
                                                  @"name"           : @"name",
                                                  @"color"          : @"colorString",
                                                  @"is_owner"       : @"isOwner",
                                                  @"access_type_id" : @"accessType"
                                                  }];
    
    // Invited users
    RKEntityMapping *invitedUserMapping = [MYPInvitedUser responseMappingForManagedObjectStore:store];
    RKRelationshipMapping *usersMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"invited_users"
                                                                                      toKeyPath:@"invitedUsers"
                                                                                    withMapping:invitedUserMapping];
    [mapping addPropertyMapping:usersMapping];
    
    // Owner
    RKEntityMapping *userMapping = [MYPUser responseMappingForManagedObjectStore:store];
    RKRelationshipMapping *ownerMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"owner"
                                                                                      toKeyPath:@"owner"
                                                                                    withMapping:userMapping];
    [mapping addPropertyMapping:ownerMapping];
    
    // "event_date": NSString -> NSDate
    RKValueTransformer *dateTransformer = [RKValueTransformer myp_dateTransformerWithDateFormat:kServerDateFormat];
    RKAttributeMapping *dateMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"event_date"
                                                                            toKeyPath:@"eventDate"];
    dateMapping.valueTransformer = dateTransformer;
    [mapping addPropertyMapping:dateMapping];
    
    mapping.identificationAttributes = @[@"binderId"];
    
    return mapping;
}

+ (RKObjectMapping *)requestMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"name"        : @"name",
                                                  @"colorString" : @"color"
                                                  }];
    
    // Invited users
    RKObjectMapping *invitedUserMapping = [MYPInvitedUser requestMappingForManagedObjectStore:store];
    RKRelationshipMapping *usersMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"invitedUsers"
                                                                                      toKeyPath:@"invited_users"
                                                                                    withMapping:invitedUserMapping];
    [mapping addPropertyMapping:usersMapping];
    
    // "event_date": NSDate -> NSString
    RKValueTransformer *dateTransformer = [RKValueTransformer myp_inversedDateTransformerWithDateFormat:kServerDateFormat];
    RKAttributeMapping *dateMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"eventDate"
                                                                            toKeyPath:@"event_date"];
    dateMapping.valueTransformer = dateTransformer;
    dateMapping.propertyValueClass = [NSString class];
    [mapping addPropertyMapping:dateMapping];
    
    return mapping;
}

- (UIColor *)color {
    return [UIColor myp_colorWithHexString:self.colorString];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setColorString:[color myp_hexString]];
}

#pragma mark - Sorting

- (NSComparisonResult)compare:(MYPBinder *)otherObject {
    NSDate *d1 = self.eventDate;
    NSDate *d2 = otherObject.eventDate;
    return [d1 compare:d2];
}

@end

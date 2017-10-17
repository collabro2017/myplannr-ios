//
//  MYPUser.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 22/08/16.
//
//

#import "MYPUser.h"

@implementation MYPUser

@dynamic userId;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic authToken;
@dynamic avatarUrl;
@dynamic ownedBinders;

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
    
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
    self = [self initWithContext:context];
    if (self) {
        self.userId = dictionary[@"id"];
        self.email = dictionary[@"email"];
        self.firstName = dictionary[@"first_name"];
        self.lastName = dictionary[@"last_name"];
        self.avatarUrl = dictionary[@"avatar_url"];
        self.authToken = dictionary[@"auth_token"];
    }
    return self;
}

+ (RKEntityMapping *)responseMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKEntityMapping *objectMapping = [super responseMappingForManagedObjectStore:store];
    [objectMapping addAttributeMappingsFromDictionary:@{
                                                        @"id"         : @"userId",
                                                        @"email"      : @"email",
                                                        @"first_name" : @"firstName",
                                                        @"last_name"  : @"lastName",
                                                        @"avatar_url" : @"avatarUrl",
                                                        @"auth_token" : @"authToken"
                                                        }];
    
    objectMapping.identificationAttributes = @[@"userId"];
    
    return objectMapping;
}

+ (RKObjectMapping *)requestMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    return [[self responseMappingForManagedObjectStore:store] inverseMapping];
}

#pragma mark - Public methods & Properties

- (NSString *)fullName {
    NSString *fullName = @"";
    if (self.firstName.length > 0 && self.lastName.length > 0) {
        fullName = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
    return fullName;
}

@end

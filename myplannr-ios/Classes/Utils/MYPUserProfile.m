//
//  MYPUserProfile.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 09/09/16.
//
//

#import "MYPUserProfile.h"
#import "MYPService.h"

@implementation MYPUserProfile

+ (MYPUserProfile *)sharedInstance {
    static MYPUserProfile * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (MYPUser *)currentUser {
    NSError *error;
    NSManagedObjectContext *context = [MYPService sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [MYPUser fc_fetchRequest];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"authToken != nil"];
    fetchRequest.returnsObjectsAsFaults = NO;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    MYPUser *user = nil;
    if (error) {
        NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    } else if (results.count > 0) {
        user = results.firstObject;
        
        if (results.count > 1) {
            @throw [NSException exceptionWithName:@"Illegal CoreData state: MYPUser"
                                           reason:@"There is more than 1 user with (accessToken != nil) in the DB"
                                         userInfo:nil];
        }
    }
    
    return user;
}

- (BOOL)isAuthorized {
    return (self.currentUser != nil);
}

@end

//
//  MYPCreateBinderModel.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 07/02/2017.
//
//

#import "MYPCreateBinderModel.h"
#import "MYPInvitedUser.h"

@implementation MYPCreateBinderModel

#pragma mark - Public methods

- (void)createBinderWithName:(NSString *)name
                       color:(UIColor *)color
                        date:(NSDate *)date
                       users:(NSSet<MYPNonManagedInvitedUser*> *)users
                  completion:(void (^)(MYPBinder *binder, NSError* error))completion;
{
    NSManagedObjectContext *context = [MYPService sharedInstance].managedObjectContext;
    
    __block MYPBinder *binder = [[MYPBinder alloc] initWithContext:context];
    binder.name = name;
    binder.color = color;
    binder.eventDate = date;
    binder.isOwner = YES;
    
    NSMutableSet *managedUsers = [NSMutableSet setWithCapacity:users.count];
    MYPInvitedUser *invitedUser = nil;
    for (MYPNonManagedInvitedUser *usr in users) {
        invitedUser = [[MYPInvitedUser alloc] initWithContext:context];
        invitedUser.email = usr.email;
        invitedUser.accessType = usr.accessType;
        [managedUsers addObject:invitedUser];
    }
    binder.invitedUsers = managedUsers;
    
    [[MYPService sharedInstance] createBinder:binder
                                       hander:^(MYPBinder *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         if (error) {
             [context deleteObject:binder];
             [[MYPService sharedInstance] saveManagedObjectContextToPersistentStore];
             binder = nil;
             
             if (completion) {
                 completion(nil, error);
             }
             return;
         }
         
         if (completion) {
             completion(binder, nil);
         }
     }];
}

@end

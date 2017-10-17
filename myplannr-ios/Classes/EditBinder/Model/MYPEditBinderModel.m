//
//  MYPEditBinderModel.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/02/2017.
//
//

#import "MYPEditBinderModel.h"
#import "MYPService.h"
#import "MYPBinder.h"
#import "MYPInvitedUser.h"
#import "MYPBinderTab.h"
#import "MYPDocument.h"
#import "MYPNonManagedInvitedUser.h"
#import "MYPFileUtils.h"

@interface MYPEditBinderModel ()

@property (nonatomic, strong, readwrite) MYPBinder *editingBinder;

@end

@implementation MYPEditBinderModel

- (instancetype)initWithBinder:(MYPBinder *)binder {
    self = [super init];
    if (self) {
        self.editingBinder = binder;
    }
    return self;
}

#pragma mark - Public methods

- (void)updateBinderWithName:(NSString *)name
                       color:(UIColor *)color
                   eventDate:(NSDate *)date
                  completion:(void (^)(BOOL, NSError *))completion
{
    if (![self.editingBinder.name isEqualToString:name]) self.editingBinder.name = name;
    if (![self.editingBinder.color isEqual:color]) self.editingBinder.color = color;
    if (![self.editingBinder.eventDate isEqualToDate:date]) self.editingBinder.eventDate = date;
    
    if (!self.editingBinder.hasChanges) {
        if (completion) {
            completion(YES, nil);
        }
        return;
    }
    
    [[MYPService sharedInstance] updateBinder:self.editingBinder
                                       hander:^(id object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         NSError *updateError = nil;
         if (error) {
             NSString *errorMsg = NSLocalizedString(@"Failed to update the binder. Please try again later.", nil);
             if (statusCode == kHttpCode403PermissionDenied) {
                 errorMsg = NSLocalizedString(@"You're not allowed to edit this Binder.", nil);
             }
             updateError = [NSError errorWithUnderlyingError:error localizedDescription:errorMsg];
         }
         
         if (completion) {
             completion(error == nil, updateError);
         }
     }];
}

- (void)updateInvitedUsers:(NSSet *)invitedUsers completion:(void (^)(BOOL, NSArray *))completion {
    NSMutableSet<MYPInvitedUser*> *removedUsers = [NSMutableSet set];
    NSMutableSet<MYPInvitedUser*> *addedUsers = [NSMutableSet set];
    NSManagedObjectContext *context = [MYPService sharedInstance].managedObjectContext;
    
    for (MYPInvitedUser *user in self.editingBinder.invitedUsers) {
        if (![invitedUsers containsObject:user]) {
            [removedUsers addObject:user];
        }
    }
    
    for (id user in invitedUsers) {
        if ([user isKindOfClass:[MYPNonManagedInvitedUser class]]) {
            MYPInvitedUser *invitedUser = [[MYPInvitedUser alloc] initWithContext:context];
            invitedUser.email = [user valueForKey:@"email"];
            invitedUser.accessType = ((NSNumber *)[user valueForKey:@"accessType"]).integerValue;
            invitedUser.isActive = NO;
            invitedUser.binderId = self.editingBinder.binderId;
            [self.editingBinder addInvitedUsersObject:invitedUser];
            [addedUsers addObject:invitedUser];
        }
    }
    
    [self revokeAccessForUsers:removedUsers withCompletion:^(BOOL success, NSArray *errors)
     {
         if (!success) {
             [self deleteUsers:addedUsers fromContext:context];
             
             NSError *firstError = errors.firstObject;
             NSNumber *statusCode = firstError.userInfo[FCHttpStatusKey];
             NSString *revokeErrorMsg = NSLocalizedString(@"Failed to revoke access for selected users.", nil);
             if (statusCode.integerValue == kHttpCode403PermissionDenied) {
                 revokeErrorMsg = NSLocalizedString(@"You're not allowed to manage users in this binder.", nil);
             }
             if (completion) {
                 NSError *revokeError = [NSError errorWithUnderlyingError:firstError
                                                     localizedDescription:revokeErrorMsg];
                 completion(NO, @[revokeError]);
             }
             return;
         }
         
         [self inviteUsers:addedUsers withCompletion:^(BOOL success, NSArray *errors)
          {
              if (!success) {
                  [self deleteUsers:addedUsers fromContext:context];
                  
                  NSError *firstError = errors.firstObject;
                  NSNumber *statusCode = firstError.userInfo[FCHttpStatusKey];
                  NSString *inviteErrorMsg = NSLocalizedString(@"Failed to invite selected users to the binder.", ni);
                  if (statusCode.integerValue == kHttpCode403PermissionDenied) {
                      inviteErrorMsg = NSLocalizedString(@"You're not allowed to invite users to this binder.", nil);
                  }
                  if (completion) {
                      NSError *inviteError = [NSError errorWithUnderlyingError:firstError
                                                          localizedDescription:inviteErrorMsg];
                      completion(NO, @[inviteError]);
                  }
                  return;
              }
              
              if (completion) {
                  completion(YES, nil);
              }
          }];
     }];
}

- (void)deleteBinderWithCompletion:(void (^)(BOOL, NSError *))completion {
    MYPService *service = [MYPService sharedInstance];
    NSNumber *binderId = self.editingBinder.binderId; // read value while object still exists
    [service deleteBinder:self.editingBinder
                   hander:^(NSData *responseData, NSInteger statusCode, NSError *error)
     {
         NSError *deleteError = nil;
         if (error) {
             NSString *errorMsg = NSLocalizedString(@"Failed to remove the binder.", nil);
             if (statusCode == kHttpCode403PermissionDenied) {
                 errorMsg = NSLocalizedString(@"You're not allowed to remove this binder.", nil);
             }
             deleteError = [NSError errorWithUnderlyingError:error localizedDescription:errorMsg];
         } else {
             // Remove Binder Tabs since there is no strong relationship between Binders and Tabs
             // and they won't be removed automatically
             NSManagedObjectContext *ctx = service.managedObjectContext;
             NSFetchRequest *request = [MYPBinderTab fc_fetchRequest];
             request.predicate = [NSPredicate predicateWithFormat:@"binderId = %@", binderId];
             request.returnsObjectsAsFaults = YES;
             NSError *fetchError = nil;
             NSArray *results = [ctx executeFetchRequest:request error:&fetchError];
             if (!fetchError) {
                 for (MYPBinderTab *tab in results) {
                     NSOrderedSet *documents = tab.documents;
                     for (MYPDocument *doc in documents) {
                         if (doc.isDownloaded) {
                             NSURL *url = doc.downloadedDocumentURL;
                             [MYPFileUtils removeFilesAtURLs:@[url] error:nil];
                         }
                     }
                     
                     // documents will be removed automatically because of 'cascade' deletion rule
                     [ctx deleteObject:tab];
                 }
                 [service saveManagedObjectContextToPersistentStore];
             } else {
                 NSLog(@"%s: failed to execute fetch request - %@", __PRETTY_FUNCTION__, fetchError);
             }
         }
         
         if (completion) {
             completion(error == nil, deleteError);
         }
     }];
}

#pragma mark - Private methods

- (void)inviteUsers:(NSSet *)users withCompletion:(void (^_Nonnull)(BOOL success, NSArray *errors))completion
{
    if (users.count == 0) {
        completion(YES, nil);
        return;
    }
    
    __block NSInteger requestsHandled = 0;
    NSMutableArray *errors = [NSMutableArray array];
    NSArray *usersArray = users.allObjects;
    for (NSInteger i = 0, j = usersArray.count; i < j; i++) {
        MYPInvitedUser *u = usersArray[i];
        [[MYPService sharedInstance] inviteUser:u
                                       toBinder:self.editingBinder
                                        handler:^(MYPInvitedUser *object, NSData *responseData, NSInteger statusCode, NSError *error)
         {
             requestsHandled++;
             if (error) {
                 [errors addObject:error];
             }
             if (requestsHandled == j) {
                 completion(errors.count == 0, errors);
             }
         }];
    }
}

- (void)revokeAccessForUsers:(NSSet *)users withCompletion:(void (^_Nonnull)(BOOL success, NSArray *errors))completion
{
    if (users.count == 0) {
        completion(YES, nil);
        return;
    }
    
    __block NSInteger requestsHandled = 0;
    NSMutableArray *errors = [NSMutableArray array];
    NSArray *usersArray = users.allObjects;
    for (NSInteger i = 0, j = usersArray.count; i < j; i++) {
        MYPInvitedUser *u = usersArray[i];
        [[MYPService sharedInstance] revokeAccessForUser:u
                                                inBinder:self.editingBinder
                                                 handler:^(NSData *responseData, NSInteger statusCode, NSError *error)
         {
             requestsHandled++;
             if (error) {
                 [errors addObject:error];
             }
             if (requestsHandled == j) {
                 completion(errors.count == 0, errors);
             }
         }];
    }
}

- (void)deleteUsers:(NSSet<MYPInvitedUser *> *)set fromContext:(NSManagedObjectContext *)context {
    for (MYPInvitedUser *u in set) {
        [context deleteObject:u];
    }
    [[MYPService sharedInstance] saveManagedObjectContextToPersistentStore];
}

@end

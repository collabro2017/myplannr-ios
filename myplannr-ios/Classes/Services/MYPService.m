//
//  MYPService.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 22/08/16.
//
//

#import "MYPService.h"
#import "MYPUser.h"
#import "MYPInvitedUser.h"
#import "MYPAvatarData.h"
#import "MYPBinder.h"
#import "MYPBinderTab.h"
#import "MYPDocument.h"
#import "MYPChatMessage.h"
#import "MYPConstants.h"
#import "MYPUserProfile.h"

#if DEBUG
static NSString * const kBaseURL = @"https://myplannr.com/dev/api/v2";
#else
static NSString * const kBaseURL = @"https://myplannr.com/api/v2";
#endif

static NSString * const kUsersPath = @"users";
static NSString * const kAuthPath = @"authenticate";
static NSString * const kRecoverPasswordPath = @"recovery_password";
static NSString * const kUploadAvatarPath = @"avatar_upload";
static NSString * const kBindersPath = @"binders";
static NSString * const kInvitedUsersPath = @"invited_users";
static NSString * const kTabsPath = @"tabs";
static NSString * const kDocumentsPath = @"documents";
static NSString * const kMessagesPath = @"messages";
static NSString * const kDevicesPath = @"devices";
static NSString * const kReceiptDataPath = @"receipt_data";

@implementation MYPService

- (instancetype)init {
    self = [super init];
    if (self) {
        // Has no effect due to the following bug:
        // https://github.com/RestKit/RestKit/issues/1631
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = kServerDateFormat;
        [[RKValueTransformer defaultValueTransformer] insertValueTransformer:dateFormatter atIndex:0];
        
#ifdef DEBUG
        [self logDatabaseState];
#endif
    }
    return self;
}

#pragma mark - User methods

- (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
                handler:(ObjectRequestCompletionHandler)handler
{
    NSDictionary *params = @{
                             @"email" : email,
                             @"password" : password
                             };
    [self postObject:nil path:kUsersPath parameters:params handler:handler];
}

- (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
                handler:(ObjectRequestCompletionHandler)handler
{
    NSDictionary *params = @{
                             @"email" : email,
                             @"password" : password
                             };
    [self postObject:nil path:kAuthPath parameters:params handler:handler];
}

- (void)recoverPassword:(NSString *)email handler:(RequestCompletionHandler)handler
{
    NSDictionary *params = @{@"email" : email};
    [self getObjectsAtPath:kRecoverPasswordPath
                parameters:params
                   handler:^(id object, NSData *responseData, NSInteger statusCode, NSError *error) {
                       if (handler) {
                           handler(responseData, statusCode, error);
                       }
                   }];
}

- (void)uploadUserAvatar:(UIImage *)avatar hander:(ObjectRequestCompletionHandler)handler {
    [self postImageAsNonManagedRequest:avatar
                                  path:kUploadAvatarPath
                              partName:@"image_upload"
                              fileName:@"avatar.jpg"
                               handler:handler];
}

- (void)updateUser:(MYPUser *)user hander:(ObjectRequestCompletionHandler)handler {
    NSAssert(user.userId, @"MYPUser.userId is required field");
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", kUsersPath, user.userId];
    [self putObject:user
               path:path
         parameters:nil
            handler:handler];
}

#pragma mark - Binders

- (void)createBinder:(MYPBinder *)binder hander:(ObjectRequestCompletionHandler)handler {
    NSAssert(binder.name, @"MYPBinder.name is required field");
    NSAssert(binder.color, @"MYPBinder.color is required field");
    NSAssert(binder.eventDate, @"MYPBinder.eventDate is required field");
    
    [self postObject:binder
                path:kBindersPath
          parameters:nil
             handler:handler];
}

- (void)bindersWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:kBindersPath parameters:nil handler:handler];
}

- (void)updateBinder:(MYPBinder *)binder hander:(ObjectRequestCompletionHandler)handler {
    NSAssert(binder.binderId, @"MYPBinder.binderId is required field");
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", kBindersPath, binder.binderId];
    [self putObject:binder
               path:path
         parameters:nil
            handler:handler];
}

- (void)deleteBinder:(MYPBinder *)binder hander:(RequestCompletionHandler)handler {
    NSAssert(binder.binderId, @"MYPBinder.binderId is required field");
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", kBindersPath, binder.binderId];
    [self deleteObject:binder
                  path:path
            parameters:nil
               handler:^(id object, NSData *responseData, NSInteger statusCode, NSError *error) {
                   if (handler) {
                       handler(responseData, statusCode, error);
                   }
               }];
}

- (void)inviteUser:(MYPInvitedUser *)user
          toBinder:(MYPBinder *)binder
           handler:(ObjectRequestCompletionHandler)handler
{
    NSAssert(user.email, @"MYPInvitedUser.email is required field");
    NSAssert(user.accessType, @"MYPInvitedUser.accessType is required field");
    NSAssert(binder.binderId, @"MYPBinder.binderId is required field");
    
    NSString *path = [NSString stringWithFormat:@"%@?binder_id=%@", kInvitedUsersPath, binder.binderId];
    [self postObject:user
                path:path
          parameters:nil
             handler:handler];
}

- (void)updateAccessTypeForUser:(MYPInvitedUser *)user
                       inBinder:(MYPBinder *)binder
                        handler:(ObjectRequestCompletionHandler)handler
{
    NSAssert(user.userId, @"MYPInvitedUser.userId is required field");
    NSAssert(user.accessType, @"MYPInvitedUser.accessType is required field");
    NSAssert(binder.binderId, @"MYPBinder.binderId is required field");

    NSString *path = [NSString stringWithFormat:@"%@?binder_id=%@", kInvitedUsersPath, binder.binderId];
    [self putObject:user
               path:path
         parameters:nil
            handler:handler];
}

- (void)revokeAccessForUser:(MYPInvitedUser *)user
                   inBinder:(MYPBinder *)binder
                    handler:(RequestCompletionHandler)handler
{
    NSAssert(binder.binderId, @"MYPBinder.binderId is required field");
    NSAssert(user.userId, @"MYPInvitedUser.userId is required field");
    
    NSString *path = [NSString stringWithFormat:@"%@?binder_id=%@&user_id=%@", kInvitedUsersPath, binder.binderId,
                      user.userId];
    [self deleteObject:user
                  path:path
            parameters:nil
               handler:^(id object, NSData *responseData, NSInteger statusCode, NSError *error) {
                   if (handler) {
                       handler(responseData, statusCode, error);
                   }
               }];
}

#pragma mark - Tabs

- (void)createTab:(MYPBinderTab *)tab handler:(ObjectRequestCompletionHandler)handler {
    NSAssert(tab.binderId, @"MYPBinderTab.binderId is required field");
    NSAssert(tab.title, @"MYPBinderTab.title is required field");
    NSAssert(tab.color, @"MYPBinderTab.color is required field");

    [self postObject:tab
                path:kTabsPath
          parameters:nil
             handler:handler];
}

- (void)tabsForBinder:(MYPBinder *)binder handler:(ObjectRequestCompletionHandler)handler {
    NSAssert(binder.binderId, @"MYPBinder.binderId is required field");
    
    NSDictionary *params = @{@"binder_id" : binder.binderId};
    [self  getObjectsAtPath:kTabsPath parameters:params handler:handler];
}

- (void)updateTab:(MYPBinderTab *)tab handler:(ObjectRequestCompletionHandler)handler {
    NSAssert(tab.tabId, @"MYPBinderTab.tabId is required field");
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", kTabsPath, tab.tabId];
    [self  putObject:tab
                path:path
          parameters:nil
             handler:handler];
}

- (void)deleteTab:(MYPBinderTab *)tab handler:(RequestCompletionHandler)handler {
    NSAssert(tab.tabId, @"MYPBinderTab.tabId is required field");
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", kTabsPath, tab.tabId];
    [self  deleteObject:tab
                   path:path
             parameters:nil
                handler:^(id object, NSData *responseData, NSInteger statusCode, NSError *error) {
                    if (handler) {
                        handler(responseData, statusCode, error);
                    }
                }];
}

#pragma mark - Documents

- (void)uploadDocument:(NSData *)document
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
                   tab:(MYPBinderTab *)tab
               handler:(ObjectRequestCompletionHandler)handler
{
    NSAssert(document, @"document is required field");
    NSAssert(fileName, @"fileName is required field");
    NSAssert(mimeType, @"mimeType is required field");
    NSAssert(tab.tabId, @"MYPBinderTab.tabId is required field");
    
    NSString *path = [NSString stringWithFormat:@"%@?tab_id=%@", kDocumentsPath, tab.tabId];
    [self postDataAsManagedRequest:document
                              path:path
                          partName:@"file"
                          fileName:fileName
                          mimeType:mimeType
                           handler:handler];
}

- (void)deleteDocument:(MYPDocument *)document handler:(RequestCompletionHandler)handler {
    NSAssert(document.documentId, @"MYPDocument.documentId is required field");
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", kDocumentsPath, document.documentId];
    [self deleteObject:document
                  path:path
            parameters:nil
               handler:^(id object, NSData *responseData, NSInteger statusCode, NSError *error) {
                   if (handler) {
                       handler(responseData, statusCode, error);
                   }
               }];
}

#pragma mark - Chats & Messages

- (void)sendMessage:(MYPChatMessage *)message handler:(ObjectRequestCompletionHandler)handler {
    NSAssert(message.binderId, @"MYPChatMessage.binderId is required field");
    NSAssert(message.text, @"MYPChatMessage.text is required field");
    
    [self postObject:message
                path:kMessagesPath
          parameters:nil
             handler:handler];
}

- (void)messagesForBinderWithID:(NSNumber *)binderID
                         offset:(NSUInteger)offset
                          limit:(NSUInteger)limit
                        handler:(ObjectRequestCompletionHandler)handler
{
    NSAssert(binderID, @"binderID is required field");
    
    NSDictionary *params = @{
                             @"binder_id" : binderID,
                             @"limit"     : @(limit),
                             @"offset"    : @(offset)
                             };
    [self getObjectsAtPath:kMessagesPath parameters:params handler:handler];
}

#pragma mark - Push notifications

- (void)updatePushToken:(NSString *)token handler:(RequestCompletionHandler)handler {
    NSDictionary *params = @{
                             @"device_token" : token,
                             @"platform"     : @"ios"
                             };
    
    [self postObject:nil
                path:kDevicesPath
          parameters:params
             handler:^(id object, NSData *responseData, NSInteger statusCode, NSError *error) {
                 if (handler) {
                     handler(responseData, statusCode, error);
                 }
             }];
}

#pragma mark - IAPs and Subscriptions

- (void)validateReceipt:(NSData *)receiptData handler:(RequestCompletionHandler)handler {
    NSString *encReceipt = [receiptData base64EncodedStringWithOptions:0];
    NSDictionary *params = @{
                             @"binary_data" : encReceipt
                             };
    [self postObject:nil
                path:kReceiptDataPath
          parameters:params
             handler:^(id object, NSData *responseData, NSInteger statusCode, NSError *error)
    {
        if (handler) {
            handler(responseData, statusCode, error);
        }
    }];
}

#pragma mark - FCNetworkService

- (NSURL *)baseUrl {
    return [NSURL URLWithString:kBaseURL];
}

- (NSString *)modelFileName {
    return @"MyPlannrModel";
}

- (NSArray *)responseDescriptors {
    NSMutableArray *descriptors = [NSMutableArray array];
    
    RKManagedObjectStore *store = self.objectManager.managedObjectStore;
    RKObjectMapping *emptyMapping = [RKObjectMapping mappingForClass:[NSObject class]];
    
    // Sign-Up
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPUser responseMappingForManagedObjectStore:store]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kUsersPath
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 2)]];
    [descriptors addObject:responseDescriptor];
    
    // Login
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPUser responseMappingForManagedObjectStore:store]
                                                                      method:RKRequestMethodPOST
                                                                 pathPattern:kAuthPath
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [descriptors addObject:responseDescriptor];
    
    // Recover Password
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:emptyMapping
                                                                      method:RKRequestMethodGET
                                                                 pathPattern:kRecoverPasswordPath
                                                                     keyPath:nil
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [descriptors addObject:responseDescriptor];
    
    // Upload Avatar
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPAvatarData responseMapping]
                                                                      method:RKRequestMethodPOST
                                                                 pathPattern:kUploadAvatarPath
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Update User
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPUser responseMappingForManagedObjectStore:store]
                                                                      method:RKRequestMethodPUT
                                                                 pathPattern:[NSString stringWithFormat:@"%@/:id", kUsersPath]
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Get Binders
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPBinder responseMappingForManagedObjectStore:store]
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:kBindersPath
                                                                     keyPath:nil
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Update Binder
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPBinder responseMappingForManagedObjectStore:store]
                                                                      method:RKRequestMethodPUT
                                                                 pathPattern:[NSString stringWithFormat:@"%@/:id", kBindersPath]
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Revoke access
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:emptyMapping
                                                                      method:RKRequestMethodDELETE
                                                                 pathPattern:[NSString stringWithFormat:@"%@", kInvitedUsersPath]
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndex:204]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Invite User / Edit access type
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPInvitedUser responseMappingForManagedObjectStore:store]
                                                                      method:RKRequestMethodPOST | RKRequestMethodPUT
                                                                 pathPattern:[NSString stringWithFormat:@"%@", kInvitedUsersPath]
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 2)]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Create Tab / Get Tabs
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPBinderTab responseMappingForManagedObjectStore:store]
                                                                      method:RKRequestMethodPOST | RKRequestMethodGET
                                                                 pathPattern:kTabsPath
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 2)]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Update Tab
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPBinderTab responseMappingForManagedObjectStore:store]
                                                                      method:RKRequestMethodPUT
                                                                 pathPattern:[NSString stringWithFormat:@"%@/:id", kTabsPath]
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Upload Document
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPDocument responseMappingForManagedObjectStore:store]
                                                                      method:RKRequestMethodPOST
                                                                 pathPattern:kDocumentsPath
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndex:201]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Send Message / Get Messages
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MYPChatMessage responseMapping]
                                                                      method:RKRequestMethodPOST | RKRequestMethodGET
                                                                 pathPattern:kMessagesPath
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 2)]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    // Validate receipt
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSNull class]]
                                                                      method:RKRequestMethodPOST
                                                                 pathPattern:kReceiptDataPath
                                                                     keyPath:nil
                                                                 statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    return descriptors;
}

- (NSArray *)requestDescriptors {
    RKManagedObjectStore *store = self.objectManager.managedObjectStore;
    NSMutableArray *descriptors = [NSMutableArray array];
    
    // Update User
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[MYPUser requestMappingForManagedObjectStore:store]
                                                                                   objectClass:[MYPUser class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPUT];
    [descriptors addObject:requestDescriptor];
    
    // Create Binder / Update Binder
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[MYPBinder requestMappingForManagedObjectStore:store]
                                                              objectClass:[MYPBinder class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPOST | RKRequestMethodPUT];
    [descriptors addObject:requestDescriptor];
    
    // Invite User / Update access type / Revoke access
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[MYPInvitedUser requestMappingForManagedObjectStore:store]
                                                              objectClass:[MYPInvitedUser class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPOST | RKRequestMethodPUT | RKRequestMethodDELETE];
    [descriptors addObject:requestDescriptor];
    
    // Create Tab / Update Tab / Delete Tab
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[MYPBinderTab requestMappingForManagedObjectStore:store]
                                                              objectClass:[MYPBinderTab class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPOST | RKRequestMethodPUT | RKRequestMethodDELETE];
    [descriptors addObject:requestDescriptor];
    
    // Send Message
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[MYPChatMessage requestMapping]
                                                              objectClass:[MYPChatMessage class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPOST];
    [descriptors addObject:requestDescriptor];
    
    return descriptors;
}

#pragma mark - Private methods

- (void)logDatabaseState {
    NSLog(@"----- %s -----", __PRETTY_FUNCTION__);
    [self logCountForManagedObject:MYPBinder.class];
    [self logCountForManagedObject:MYPUser.class];
    [self logCountForManagedObject:MYPInvitedUser.class];
    [self logCountForManagedObject:MYPBinderTab.class];
    [self logCountForManagedObject:MYPDocument.class];
}

@end

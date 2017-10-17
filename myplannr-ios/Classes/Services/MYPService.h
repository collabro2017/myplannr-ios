//
//  MYPService.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 22/08/16.
//
//

#import "FCNetworkServiceBase.h"

@class MYPUser;
@class MYPBinder;
@class MYPInvitedUser;
@class MYPBinderTab;
@class MYPDocument;
@class MYPChatMessage;

@interface MYPService : FCNetworkServiceBase

/* User methods */

- (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
                handler:(ObjectRequestCompletionHandler)handler;

- (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
                handler:(ObjectRequestCompletionHandler)handler;

- (void)recoverPassword:(NSString *)email handler:(RequestCompletionHandler)handler;

- (void)uploadUserAvatar:(UIImage *)avatar hander:(ObjectRequestCompletionHandler)handler;

- (void)updateUser:(MYPUser *)user hander:(ObjectRequestCompletionHandler)handler;

/* Binders */

- (void)createBinder:(MYPBinder *)binder hander:(ObjectRequestCompletionHandler)handler;

- (void)bindersWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)updateBinder:(MYPBinder *)binder hander:(ObjectRequestCompletionHandler)handler;

- (void)deleteBinder:(MYPBinder *)binder hander:(RequestCompletionHandler)handler;

- (void)inviteUser:(MYPInvitedUser *)user
          toBinder:(MYPBinder *)binder
           handler:(ObjectRequestCompletionHandler)handler;

- (void)updateAccessTypeForUser:(MYPInvitedUser *)user
                       inBinder:(MYPBinder *)binder
                        handler:(ObjectRequestCompletionHandler)handler;

- (void)revokeAccessForUser:(MYPInvitedUser *)user
                   inBinder:(MYPBinder *)binder
                    handler:(RequestCompletionHandler)handler;

/* Tabs */

- (void)createTab:(MYPBinderTab *)tab handler:(ObjectRequestCompletionHandler)handler;

- (void)tabsForBinder:(MYPBinder *)binder handler:(ObjectRequestCompletionHandler)handler;

- (void)updateTab:(MYPBinderTab *)tab handler:(ObjectRequestCompletionHandler)handler;

- (void)deleteTab:(MYPBinderTab *)tab handler:(RequestCompletionHandler)handler;

/* Documents */

- (void)uploadDocument:(NSData *)document
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
                   tab:(MYPBinderTab *)tab
               handler:(ObjectRequestCompletionHandler)handler;

- (void)deleteDocument:(MYPDocument *)document handler:(RequestCompletionHandler)handler;

/* Chats & Messages */

- (void)sendMessage:(MYPChatMessage *)message handler:(ObjectRequestCompletionHandler)handler;

- (void)messagesForBinderWithID:(NSNumber *)binder
                         offset:(NSUInteger)limit
                          limit:(NSUInteger)offset
                        handler:(ObjectRequestCompletionHandler)handler;

/* Push notifications */

- (void)updatePushToken:(NSString *)token handler:(RequestCompletionHandler)handler;

/* IAPs and Subscriptions */

- (void)validateReceipt:(NSData *)receiptData handler:(RequestCompletionHandler)handler;

@end

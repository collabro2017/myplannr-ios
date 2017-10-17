//
//  MYPChatMessage.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 02/09/16.
//
//

#import <Foundation/Foundation.h>
#import "MYPServiceObject.h"
#import "MYPUser.h"
#import "JSQMessageData.h"
#import "FCObjectWithMapping.h"

@interface MYPChatMessage : NSObject<JSQMessageData, FCObjectWithMapping>

@property (nonatomic, strong, readonly) NSNumber *messageId;
@property (nonatomic, strong) NSNumber *binderId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) MYPUser *sender;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

- (instancetype)initWithText:(NSString *)text binderID:(NSNumber *)binderID currentUser:(MYPUser *)user; // outgoing messages

- (instancetype)initWithDictionary:(NSDictionary *)dictionary; // incoming messages (push notifications)

@end

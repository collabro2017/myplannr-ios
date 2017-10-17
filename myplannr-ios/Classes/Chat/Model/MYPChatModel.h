//
//  MYPChatModel.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/12/2016.
//
//

#import "JSQMessages.h"
#import "MYPChatMessage.h"

extern NSInteger const kMessagesLoadPortionSize;

@interface MYPChatModel : NSObject

@property (nonatomic, strong) NSMutableArray<MYPChatMessage *> *messages;

@property (strong, nonatomic, readonly) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic, readonly) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic, readonly) NSNumber *binderID;

@property (strong, nonatomic, readonly) NSString *senderID;
@property (strong, nonatomic, readonly) NSString *senderDisplayName;

@property (strong, nonatomic, readonly) JSQMessagesAvatarImage *placeholderAvatarImage;

- (instancetype)initWithBinder:(MYPBinder *)binder;
- (instancetype)initWithBinderID:(NSNumber *)binderID NS_DESIGNATED_INITIALIZER;

- (BOOL)isOutgoingMessage:(MYPChatMessage *)msg;

// Timestamps
- (NSAttributedString *)timestampForMessageAtIndexPath:(NSIndexPath *)path;
- (CGFloat)heightForCellTimestampLabelAtIndexPath:(NSIndexPath *)path;

// Senders' names
- (NSAttributedString *)senderNameForMessageAtIndexPath:(NSIndexPath *)path;
- (CGFloat)heightForCellSenderNameLabelAtIndexPath:(NSIndexPath *)path;

- (void)avatarForMessage:(MYPChatMessage *)message
              completion:(void (^)(UIImage *image, NSError *error)) completion;

- (void)sendMessage:(NSString *)messageText
           senderId:(NSString *)senderId
  senderDisplayName:(NSString *)senderDisplayName
               date:(NSDate *)date
         completion:(void (^)(MYPChatMessage *msg, BOOL success, NSError *error))completion;

- (void)loadMessages:(void (^)(BOOL success, BOOL allMessagesLoaded, NSError *error))completion;

@end

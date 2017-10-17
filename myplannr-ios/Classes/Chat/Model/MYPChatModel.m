//
//  MYPChatModel.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/12/2016.
//
//

#import "MYPChatModel.h"
#import "MYPUserProfile.h"
#import "MYPUser.h"
#import "MYPService.h"
#import "MYPBinder.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSInteger const kMessagesLoadPortionSize = 30;

@interface MYPChatModel ()

@property (strong, nonatomic, readwrite) JSQMessagesAvatarImage *placeholderAvatarImage;
@property (strong, nonatomic, readwrite) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic, readwrite) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic, readwrite) NSNumber *binderID;

@property (strong, nonatomic) NSMutableDictionary<NSString *, UIImage*> *userAvatarsCache;

@end

@implementation MYPChatModel

- (instancetype)initWithBinder:(MYPBinder *)binder {
    return [self initWithBinderID:binder.binderId];
}

- (instancetype)initWithBinderID:(NSNumber *)binderID {
    self = [super init];
    if (self) {
        self.binderID = binderID;
        
        self.messages = [NSMutableArray array];
        self.userAvatarsCache = [NSMutableDictionary dictionary];
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor myp_colorWithHexInt:0xEDF6FD]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor myp_colorWithHexInt:0xEDF6FD]];
    }
    return self;
}

- (instancetype)init {
    return [self initWithBinderID:nil];
}

#pragma mark - Public methods & properties

- (BOOL)isOutgoingMessage:(MYPChatMessage *)msg {
    NSParameterAssert(msg != nil);
    
    NSString *senderID = msg.senderId; 
    return [senderID isEqualToString:self.senderID];
}

- (JSQMessagesAvatarImage *)placeholderAvatarImage {
    if (_placeholderAvatarImage == nil) {
        UIImage *img = [UIImage imageNamed:@"AvatarPlaceholder"];
        _placeholderAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithPlaceholder:img
                                                                                   diameter:kChatAvatarSize];
    }
    return _placeholderAvatarImage;
}

- (void)sendMessage:(NSString *)messageText
           senderId:(NSString *)senderId
  senderDisplayName:(NSString *)senderDisplayName
               date:(NSDate *)date
         completion:(void (^)(MYPChatMessage *, BOOL, NSError *))completion
{
    NSNumber *binderID = self.binderID;
    MYPUser *user = [MYPUserProfile sharedInstance].currentUser;
    MYPChatMessage *msg = [[MYPChatMessage alloc] initWithText:messageText binderID:binderID currentUser:user];
    [self.messages addObject:msg];
    
    [[MYPService sharedInstance] sendMessage:msg
                                     handler:^(id object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         completion(msg, error == nil, error);
     }];
}

- (void)loadMessages:(void (^)(BOOL success, BOOL allMessagesLoaded, NSError *error))completion {
    NSInteger offset = self.messages.count;
    NSInteger limit = kMessagesLoadPortionSize;
    [[MYPService sharedInstance] messagesForBinderWithID:self.binderID
                                                  offset:offset
                                                   limit:limit
                                                 handler:^(NSArray *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         if (!error) {
             NSArray *sortedArray = [object sortedArrayUsingSelector:@selector(compare:)];
             self.messages = [sortedArray arrayByAddingObjectsFromArray:self.messages].mutableCopy;
         }
         
         if (completion) {
             completion(error == nil, object.count < limit, error);
         }
     }];
}

- (NSString *)senderID {
    MYPUser *user = [MYPUserProfile sharedInstance].currentUser;
    return user.userId.stringValue;
}

- (NSString *)senderDisplayName {
    MYPUser *user = [MYPUserProfile sharedInstance].currentUser;
    return user.fullName;
}

- (NSAttributedString *)timestampForMessageAtIndexPath:(NSIndexPath *)path {
    if (path.item % 3 == 0) {
        MYPChatMessage *message = [self.messages objectAtIndex:path.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (CGFloat)heightForCellTimestampLabelAtIndexPath:(NSIndexPath *)path {
    if (path.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0;
}

- (NSAttributedString *)senderNameForMessageAtIndexPath:(NSIndexPath *)path {
    MYPChatMessage *currentMessage = [self.messages objectAtIndex:path.item];
    
    if ([self isOutgoingMessage:currentMessage]) {
        return nil;
    }
    
    if (path.item - 1 >= 0) {
        MYPChatMessage *previousMessage = [self.messages objectAtIndex:path.item - 1];
        if ([[previousMessage senderId] isEqualToString:currentMessage.senderId]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:currentMessage.senderDisplayName];
}

- (CGFloat)heightForCellSenderNameLabelAtIndexPath:(NSIndexPath *)path {
    MYPChatMessage *currentMessage = [self.messages objectAtIndex:path.item];
    
    if ([self isOutgoingMessage:currentMessage]) {
        return 0.0f;
    }
    
    if (path.item - 1 >= 0) {
        MYPChatMessage *previousMessage = [self.messages objectAtIndex:path.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (void)avatarForMessage:(MYPChatMessage *)message completion:(void (^)(UIImage *, NSError *))completion {
    NSParameterAssert(message != nil);
    NSParameterAssert(completion != nil);
    
    MYPUser *sender = message.sender;
    NSString *userID = sender.userId.stringValue;
    UIImage *cachedImage = self.userAvatarsCache[userID];
    if (cachedImage != nil) {
        completion(cachedImage, nil);
        return;
    }
    
    NSString *avatarURL = sender.avatarUrl;
    if (avatarURL.length > 0) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:avatarURL]
                              options:0
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (error) {
                 completion(nil, error);
                 return;
             }
             
             JSQMessagesAvatarImage *ai = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                     diameter:kChatAvatarSize];
             [self.userAvatarsCache setObject:ai.avatarImage forKey:userID];
             completion(ai.avatarImage, nil);
         }];
    } else {
        UIColor *bckgColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        UIColor *textColor = [UIColor colorWithWhite:0.60f alpha:1.0f];
        UIFont *font = [UIFont systemFontOfSize:14.0f];
        NSString *initials = [NSString stringWithFormat:@"%@%@",
                              [sender.firstName substringToIndex:1],
                              [sender.lastName substringToIndex:1]];
        JSQMessagesAvatarImage *ai = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:initials
                                                                                backgroundColor:bckgColor
                                                                                      textColor:textColor
                                                                                           font:font
                                                                                       diameter:kChatAvatarSize];
        [self.userAvatarsCache setObject:ai.avatarImage forKey:userID];
        completion(ai.avatarImage, nil);
    }
}

@end

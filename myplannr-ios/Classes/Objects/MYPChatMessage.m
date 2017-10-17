//
//  MYPChatMessage.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 02/09/16.
//
//

#import "MYPChatMessage.h"
#import "MYPConstants.h"
#import "MYPService.h"
#import "RKValueTransformer+Extenstions.h"

@interface MYPChatMessage ()

@property (nonatomic, strong, readwrite) NSNumber *messageId;

@end

@implementation MYPChatMessage

- (instancetype)initWithText:(NSString *)text binderID:(NSNumber *)binderID currentUser:(MYPUser *)user {
    return [self initWithMessageID:nil text:text binderID:binderID sender:user date:[NSDate date]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSString *createdAt =  dictionary[@"created_at"];
    NSDictionary *senderDictionary = dictionary[@"sender"];
    NSAssert(createdAt.length > 0, @"created_at is nil or empty");
    NSAssert(senderDictionary, @"sender is nil");
    
    // Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = kServerDateTimeFormat;
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    NSDate *date = [formatter dateFromString:createdAt];
    
    // Sender
    NSManagedObjectContext *context = [MYPService sharedInstance].managedObjectContext;
    MYPUser *sender = [[MYPUser alloc] initWithDictionary:senderDictionary context:context];
    
    return [self initWithMessageID:dictionary[@"id"]
                              text:dictionary[@"text"]
                          binderID:dictionary[@"binder_id"]
                            sender:sender
                              date:date];
}

- (instancetype)initWithMessageID:(NSNumber *)msgID
                             text:(NSString *)text
                         binderID:(NSNumber *)binderID
                           sender:(MYPUser *)sender
                             date:(NSDate *)date
{
    self = [super init];
    if (self) {
        self.messageId = msgID;
        self.text = text;
        self.binderId = binderID;
        self.sender = sender;
        self.createdAt = date;
    }
    return self;
}

+ (RKObjectMapping *)responseMapping {
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[self class]];
    [objectMapping addAttributeMappingsFromDictionary:@{
                                                        @"id"        : @"messageId",
                                                        @"binder_id" : @"binderId",
                                                        @"text"      : @"text"
                                                        }];
    // Sender
    RKManagedObjectStore *store = [RKManagedObjectStore defaultStore];
    RKObjectMapping *userMapping = [MYPUser responseMappingForManagedObjectStore:store];
    RKRelationshipMapping *senderMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"sender"
                                                                                       toKeyPath:@"sender"
                                                                                     withMapping:userMapping];
    [objectMapping addPropertyMapping:senderMapping];
    
    RKValueTransformer *dateTransformer = [RKValueTransformer myp_dateTransformerWithDateFormat:kServerDateTimeFormat];
    
    // "created_at": NSString -> NSDate
    RKAttributeMapping *createdAtMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"created_at"
                                                                                 toKeyPath:@"createdAt"];
    createdAtMapping.valueTransformer = dateTransformer;
    [objectMapping addPropertyMapping:createdAtMapping];
    
    // "updated_at": NSString -> NSDate
    RKAttributeMapping *updatedAtMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"updated_at"
                                                                                 toKeyPath:@"updatedAt"];
    updatedAtMapping.valueTransformer = dateTransformer;
    [objectMapping addPropertyMapping:updatedAtMapping];
    
    return objectMapping;
}

+ (RKObjectMapping *)requestMapping {
    return [[self responseMapping] inverseMapping];
}

#pragma mark - JSQMessageData

- (NSString *)senderId {
    return self.sender.userId.stringValue;
}

- (NSString *)senderDisplayName {
    return self.sender.fullName;
}

- (NSDate *)date {
    return self.createdAt;
}

- (BOOL)isMediaMessage {
    return NO; // we don't support media messages currently
}

- (NSUInteger)messageHash {
    return [self hash];
}

- (NSString *)text {
    return _text;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (!object) {
        return NO;
    }
    if (![object isKindOfClass:[MYPChatMessage class]]) {
        return NO;
    }
    
    MYPChatMessage *message = (MYPChatMessage *)object;
    if (message.messageId != nil && self.messageId != nil) {
        return [message.messageId isEqualToNumber:self.messageId];
    }

    return NO;
}

- (NSUInteger)hash {
    return self.messageId.longValue ^ (long)self.createdAt.timeIntervalSince1970 ^ self.text.hash;
}

#pragma mark - Sorting

- (NSComparisonResult)compare:(MYPChatMessage *)otherObject {
    NSDate *d1 = self.createdAt;
    NSDate *d2 = otherObject.createdAt;
    return [d1 compare:d2];
}

@end

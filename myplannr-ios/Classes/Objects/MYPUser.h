//
//  MYPUser.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 22/08/16.
//
//

#import "MYPServiceObject.h"
#import "MYPUserProtocol.h"

@class MYPBinder;

@interface MYPUser : MYPServiceObject<MYPUserProtocol>

@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, strong) NSSet<MYPBinder *> *ownedBinders;

- (instancetype)initWithContext:(NSManagedObjectContext *)context;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;

@end

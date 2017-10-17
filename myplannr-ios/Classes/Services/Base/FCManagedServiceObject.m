//
//  FCManagedServiceObject.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/02/2017.
//
//

#import "FCManagedServiceObject.h"
#import "FCNetworkServiceBase.h"

@implementation FCManagedServiceObject

- (instancetype)init {
    NSString *reason = [NSString stringWithFormat:@"%@ class must use initWithEntity:insertIntoManagedObjectContext: instead",
                        NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"FCManagedServiceObject: illegal constructor (init) is called"
                                   reason:reason
                                 userInfo:nil];
}

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self.class fc_entityName]
                                              inManagedObjectContext:context];
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        
    }
    return self;
}

- (BOOL)isSaved {
    return !self.objectID.isTemporaryID;
}

+ (RKEntityMapping *)responseMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    @throw [NSException exceptionWithName:@"FCServiceObject: responseMappingForManagedObjectStore:store: not overriden"
                                   reason:@"This class and its methods shouldn't be used directly"
                                 userInfo:nil];
}

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    
}

- (void)willTurnIntoFault {
    
}

- (void)didTurnIntoFault {
    
}

@end
